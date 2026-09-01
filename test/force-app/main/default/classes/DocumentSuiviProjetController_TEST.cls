@isTest
private class DocumentSuiviProjetController_TEST {

    @TestSetup
    static void setup() {
        Projet__c projet = new Projet__c(Numero_projet__c = 'TEST-LWC-001');
        insert projet;

        List<Get_Document__c> docs = new List<Get_Document__c>();

        docs.add(new Get_Document__c(
            Doc_Projet__c = projet.Id, ID_Document__c = 'T1', numero_document__c = 'A1',
            Description_du_document__c = 'Offre confirmée', Genre_document__c = 'Offre',
            Etat_document__c = 'offert, commandé', Montant_document__c = '600',
            Ponderation_pour_les_offres__c = '100', DOC_Etat_Offert__c = '1',
            DOC_Etat_Commande__c = '1', DOC_Etat_Facture__c = '0', Doc_Brouillon__c = 'Actif'));

        docs.add(new Get_Document__c(
            Doc_Projet__c = projet.Id, ID_Document__c = 'T2', numero_document__c = 'A2',
            Description_du_document__c = 'Offre complémentaire', Genre_document__c = 'Offre',
            Etat_document__c = 'offert, pas encore commandé, prob. 50%', Montant_document__c = '400',
            Ponderation_pour_les_offres__c = '50', DOC_Etat_Offert__c = '1',
            DOC_Etat_Commande__c = '0', DOC_Etat_Facture__c = '0', Doc_Brouillon__c = 'Actif'));

        docs.add(new Get_Document__c(
            Doc_Projet__c = projet.Id, ID_Document__c = 'T3', numero_document__c = 'A3',
            Description_du_document__c = 'Facture acompte', Genre_document__c = 'Facture d\'acompte',
            Etat_document__c = 'payé, facturé avec offre', Montant_document__c = '200',
            Ponderation_pour_les_offres__c = '100', DOC_Etat_Offert__c = '0',
            DOC_Etat_Commande__c = '0', DOC_Etat_Facture__c = '1', Doc_Brouillon__c = 'Actif'));

        docs.add(new Get_Document__c(
            Doc_Projet__c = projet.Id, ID_Document__c = 'T4', numero_document__c = 'A4',
            Description_du_document__c = 'Brouillon a exclure', Genre_document__c = 'Offre',
            Etat_document__c = 'offert, pas encore commandé', Montant_document__c = '99999',
            Ponderation_pour_les_offres__c = '100', DOC_Etat_Offert__c = '1',
            DOC_Etat_Commande__c = '0', DOC_Etat_Facture__c = '0', Doc_Brouillon__c = 'Brouillon'));

        docs.add(new Get_Document__c(
            Doc_Projet__c = projet.Id, ID_Document__c = 'T5', numero_document__c = 'A5',
            Description_du_document__c = 'Montant vide', Genre_document__c = 'Offre',
            Etat_document__c = 'offert, pas encore commandé', Montant_document__c = null,
            Ponderation_pour_les_offres__c = null, DOC_Etat_Offert__c = '1',
            DOC_Etat_Commande__c = '0', DOC_Etat_Facture__c = '0', Doc_Brouillon__c = 'Actif'));

        // Format locale FR/CH reel observe en prod : espace fine insecable (U+202F) en separateur
        // de milliers, virgule en separateur decimal.
        docs.add(new Get_Document__c(
            Doc_Projet__c = projet.Id, ID_Document__c = 'T6', numero_document__c = 'A6',
            Description_du_document__c = 'Montant format locale FR', Genre_document__c = 'Offre',
            Etat_document__c = 'offert, commandé', Montant_document__c = '24 343,7',
            Ponderation_pour_les_offres__c = '100', DOC_Etat_Offert__c = '1',
            DOC_Etat_Commande__c = '1', DOC_Etat_Facture__c = '0', Doc_Brouillon__c = 'Actif'));

        insert docs;
    }

    @isTest
    static void testGetSuiviDocuments_CategoriesEtTotaux() {
        Projet__c projet = [SELECT Id FROM Projet__c WHERE Numero_projet__c = 'TEST-LWC-001'];

        Test.startTest();
        DocumentSuiviProjetController.SuiviProjet resultat = DocumentSuiviProjetController.getSuiviDocuments(projet.Id);
        Test.stopTest();

        System.assertEquals(24943.7, resultat.totalConfirme, 'Total confirme incorrect (600 + 24343,7)');
        System.assertEquals(400, resultat.totalEnCours, 'Total en cours incorrect');
        System.assertEquals(200, resultat.totalEnCoursPondere, 'Total en cours pondere incorrect (400 * 50%)');
        System.assertEquals(200, resultat.totalFacture, 'Total facture incorrect');
        System.assertEquals(5, resultat.documents.size(), 'Le brouillon doit etre exclu (6 crees, 1 brouillon)');

        Boolean montantVideTrouve = false;
        Boolean confirmeTrouve = false;
        Boolean enCoursTrouve = false;
        Boolean formatLocaleTrouve = false;
        for (DocumentSuiviProjetController.DocumentLigne ligne : resultat.documents) {
            if (ligne.reference == 'A5') {
                montantVideTrouve = true;
                System.assertEquals(null, ligne.montant, 'Montant vide doit rester null, pas planter');
                System.assertEquals(null, ligne.montantPondere, 'Montant pondere doit rester null si montant vide');
            }
            if (ligne.reference == 'A1') {
                confirmeTrouve = true;
                System.assertEquals(true, ligne.commande, 'A1 doit avoir commande=true');
                System.assertEquals(false, ligne.facture, 'A1 ne doit pas etre facture');
                System.assertEquals(600, ligne.montantPondere, 'Montant pondere doit etre le montant plein (pond=100)');
            }
            if (ligne.reference == 'A2') {
                enCoursTrouve = true;
                System.assertEquals(true, ligne.offert, 'A2 doit etre offert');
                System.assertEquals(false, ligne.commande, 'A2 ne doit pas etre commande');
                System.assertEquals(200, ligne.montantPondere, 'Montant pondere A2 incorrect (400 * 50%)');
            }
            if (ligne.reference == 'A6') {
                formatLocaleTrouve = true;
                System.assertEquals(24343.7, ligne.montant, 'Le format locale FR/CH (espace fine insecable + virgule) doit etre parse correctement');
            }
        }
        System.assert(montantVideTrouve, 'Le document avec montant vide doit etre present');
        System.assert(formatLocaleTrouve, 'Le document au format locale FR/CH doit etre present');
        System.assert(confirmeTrouve, 'Le document confirme doit etre present');
        System.assert(enCoursTrouve, 'Le document en cours doit etre present');

        System.assert(!resultat.repartitionParStatut.isEmpty(), 'La repartition par statut doit contenir des entrees');
        Integer totalDocumentsRepartis = 0;
        for (DocumentSuiviProjetController.RepartitionStatut r : resultat.repartitionParStatut) {
            totalDocumentsRepartis += r.nombreDocuments;
        }
        System.assertEquals(5, totalDocumentsRepartis, 'La somme de la repartition doit couvrir tous les documents non-brouillon');
    }

    @isTest
    static void testGetSuiviDocuments_AucunDocument() {
        Projet__c projetVide = new Projet__c(Numero_projet__c = 'TEST-LWC-VIDE');
        insert projetVide;

        Test.startTest();
        DocumentSuiviProjetController.SuiviProjet resultat = DocumentSuiviProjetController.getSuiviDocuments(projetVide.Id);
        Test.stopTest();

        System.assertEquals(0, resultat.totalConfirme);
        System.assertEquals(0, resultat.totalEnCours);
        System.assertEquals(0, resultat.totalFacture);
        System.assertEquals(0, resultat.documents.size());
    }
}
