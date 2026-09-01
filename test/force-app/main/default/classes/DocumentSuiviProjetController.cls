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
    }

    public class SuiviProjet {
        @AuraEnabled public Decimal totalConfirme;
        @AuraEnabled public Decimal totalEnCours;
        @AuraEnabled public Decimal totalEnCoursPondere;
        @AuraEnabled public Decimal totalFacture;
        @AuraEnabled public List<DocumentLigne> documents;
    }

    private static final String CATEGORIE_CONFIRME = 'Confirmé';
    private static final String CATEGORIE_EN_COURS = 'En cours';
    private static final String CATEGORIE_FACTURE = 'Facturé';
    private static final String CATEGORIE_AUTRE = 'Autre';

    @AuraEnabled(cacheable=true)
    public static SuiviProjet getSuiviDocuments(Id projetId) {
        SuiviProjet resultat = new SuiviProjet();
        resultat.totalConfirme = 0;
        resultat.totalEnCours = 0;
        resultat.totalEnCoursPondere = 0;
        resultat.totalFacture = 0;
        resultat.documents = new List<DocumentLigne>();

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

        for (Get_Document__c doc : docs) {
            Decimal montant = parseDecimal(doc.Montant_document__c);
            Decimal ponderation = parseDecimal(doc.Ponderation_pour_les_offres__c);

            DocumentLigne ligne = new DocumentLigne();
            ligne.reference = doc.numero_document__c;
            ligne.description = doc.Description_du_document__c;
            ligne.genre = doc.Genre_document__c;
            ligne.etat = doc.Etat_document__c;
            ligne.montant = montant;
            ligne.ponderation = ponderation;
            ligne.categorie = categoriser(doc.DOC_Etat_Offert__c, doc.DOC_Etat_Commande__c, doc.DOC_Etat_Facture__c);

            if (montant != null) {
                if (ligne.categorie == CATEGORIE_CONFIRME) {
                    resultat.totalConfirme += montant;
                } else if (ligne.categorie == CATEGORIE_FACTURE) {
                    resultat.totalFacture += montant;
                } else if (ligne.categorie == CATEGORIE_EN_COURS) {
                    resultat.totalEnCours += montant;
                    Decimal pondere = (ponderation != null) ? montant * ponderation / 100 : montant;
                    ligne.montantPondere = pondere;
                    resultat.totalEnCoursPondere += pondere;
                }
            }

            resultat.documents.add(ligne);
        }

        return resultat;
    }

    private static String categoriser(String etatOffert, String etatCommande, String etatFacture) {
        if (estCoche(etatCommande)) {
            return CATEGORIE_CONFIRME;
        }
        if (estCoche(etatFacture)) {
            return CATEGORIE_FACTURE;
        }
        if (estCoche(etatOffert)) {
            return CATEGORIE_EN_COURS;
        }
        return CATEGORIE_AUTRE;
    }

    private static Boolean estCoche(String valeur) {
        return valeur != null && valeur.trim() == '1';
    }

    private static Decimal parseDecimal(String valeur) {
        if (String.isBlank(valeur)) {
            return null;
        }
        try {
            return Decimal.valueOf(valeur.trim());
        } catch (Exception e) {
            return null;
        }
    }
}
