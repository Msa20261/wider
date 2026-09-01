public with sharing class DocumentSuiviProjetController {

    public class DocumentLigne {
        @AuraEnabled public String reference;
        @AuraEnabled public String description;
        @AuraEnabled public String genre;
        @AuraEnabled public String etat;
        @AuraEnabled public Decimal montant;
        @AuraEnabled public Decimal ponderation;
        @AuraEnabled public Decimal montantPondere;
        @AuraEnabled public String categorie;
        @AuraEnabled public Boolean offert;
        @AuraEnabled public Boolean commande;
        @AuraEnabled public Boolean facture;
    }

    public class RepartitionStatut {
        @AuraEnabled public String statut;
        @AuraEnabled public Integer nombreDocuments;
        @AuraEnabled public Decimal totalMontant;
        @AuraEnabled public Decimal totalMontantPondere;
    }

    public class SuiviProjet {
        @AuraEnabled public Decimal totalConfirme;
        @AuraEnabled public Decimal totalEnCours;
        @AuraEnabled public Decimal totalEnCoursPondere;
        @AuraEnabled public Decimal totalFacture;
        @AuraEnabled public List<DocumentLigne> documents;
        @AuraEnabled public List<RepartitionStatut> repartitionParStatut;
    }

    private static final String CATEGORIE_CONFIRME = 'Confirmé';
    private static final String CATEGORIE_EN_COURS = 'En cours';
    private static final String CATEGORIE_FACTURE = 'Facturé';
    private static final String CATEGORIE_AUTRE = 'Autre';
    private static final String STATUT_INCONNU = '(Statut non renseigné)';

    @AuraEnabled(cacheable=true)
    public static SuiviProjet getSuiviDocuments(Id projetId) {
        SuiviProjet resultat = new SuiviProjet();
        resultat.totalConfirme = 0;
        resultat.totalEnCours = 0;
        resultat.totalEnCoursPondere = 0;
        resultat.totalFacture = 0;
        resultat.documents = new List<DocumentLigne>();
        resultat.repartitionParStatut = new List<RepartitionStatut>();

        List<Get_Document__c> docs = [
            SELECT numero_document__c, Description_du_document__c, Genre_document__c,
                   Etat_document__c, Montant_document__c, Ponderation_pour_les_offres__c,
                   DOC_Etat_Offert__c, DOC_Etat_Commande__c, DOC_Etat_Facture__c,
                   Doc_Brouillon__c, Date_creation_Triviso__c
            FROM Get_Document__c
            WHERE Doc_Projet__c = :projetId
            AND Doc_Brouillon__c != 'Brouillon'
            ORDER BY Date_creation_Triviso__c DESC NULLS LAST
        ];

        Map<String, RepartitionStatut> repartitionParCle = new Map<String, RepartitionStatut>();

        for (Get_Document__c doc : docs) {
            Decimal montant = parseDecimal(doc.Montant_document__c);
            Decimal ponderation = parseDecimal(doc.Ponderation_pour_les_offres__c);
            Boolean offert = estCoche(doc.DOC_Etat_Offert__c);
            Boolean commande = estCoche(doc.DOC_Etat_Commande__c);
            Boolean facture = estCoche(doc.DOC_Etat_Facture__c);

            DocumentLigne ligne = new DocumentLigne();
            ligne.reference = doc.numero_document__c;
            ligne.description = doc.Description_du_document__c;
            ligne.genre = doc.Genre_document__c;
            ligne.etat = doc.Etat_document__c;
            ligne.montant = montant;
            ligne.ponderation = ponderation;
            ligne.offert = offert;
            ligne.commande = commande;
            ligne.facture = facture;
            ligne.categorie = categoriser(offert, commande, facture);

            // Une pondération absente veut dire "certain" (déjà confirmé/facturé) : on ne dégrade pas le montant.
            Decimal ponderationEffective = (ponderation != null) ? ponderation : 100;
            if (montant != null) {
                ligne.montantPondere = montant * ponderationEffective / 100;
            }

            if (montant != null) {
                if (ligne.categorie == CATEGORIE_CONFIRME) {
                    resultat.totalConfirme += montant;
                } else if (ligne.categorie == CATEGORIE_FACTURE) {
                    resultat.totalFacture += montant;
                } else if (ligne.categorie == CATEGORIE_EN_COURS) {
                    resultat.totalEnCours += montant;
                    resultat.totalEnCoursPondere += ligne.montantPondere;
                }
            }

            resultat.documents.add(ligne);

            String cleStatut = String.isNotBlank(doc.Etat_document__c) ? doc.Etat_document__c : STATUT_INCONNU;
            RepartitionStatut repartition = repartitionParCle.get(cleStatut);
            if (repartition == null) {
                repartition = new RepartitionStatut();
                repartition.statut = cleStatut;
                repartition.nombreDocuments = 0;
                repartition.totalMontant = 0;
                repartition.totalMontantPondere = 0;
                repartitionParCle.put(cleStatut, repartition);
            }
            repartition.nombreDocuments += 1;
            if (montant != null) {
                repartition.totalMontant += montant;
                repartition.totalMontantPondere += ligne.montantPondere;
            }
        }

        resultat.repartitionParStatut = repartitionParCle.values();
        return resultat;
    }

    private static String categoriser(Boolean offert, Boolean commande, Boolean facture) {
        if (commande) {
            return CATEGORIE_CONFIRME;
        }
        if (facture) {
            return CATEGORIE_FACTURE;
        }
        if (offert) {
            return CATEGORIE_EN_COURS;
        }
        return CATEGORIE_AUTRE;
    }

    private static Boolean estCoche(String valeur) {
        return valeur != null && valeur.trim() == '1';
    }

    // Les montants stockes en Texte suivent le format numerique de la locale de l'utilisateur qui a
    // execute le flow (ex. FR/CH : "24 343,7" avec espace fine insecable U+202F en separateur de
    // milliers et virgule en separateur decimal). On normalise avant de parser en Decimal.
    // \p{Zs} = categorie Unicode "Space Separator" : couvre l'espace normal, l'espace insecable
    // (U+00A0) et l'espace fine insecable (U+202F) vus dans les exports Triviso.
    private static Decimal parseDecimal(String valeur) {
        if (String.isBlank(valeur)) {
            return null;
        }
        String nettoye = valeur.trim().replaceAll('\\p{Zs}', '').replace(',', '.');
        try {
            return Decimal.valueOf(nettoye);
        } catch (Exception e) {
            return null;
        }
    }
}
