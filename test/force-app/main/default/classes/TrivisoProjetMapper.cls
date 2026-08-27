public class TrivisoProjetMapper {

    public static List<TrivisoProjetRecord> mapProjetsToTrivisoRecords(List<Projet__c> projets) {
        List<TrivisoProjetRecord> trivisoRecords = new List<TrivisoProjetRecord>();
        
        if (projets == null || projets.isEmpty()) {
            System.debug('TRIVISO_LOG: No projets to map');
            return trivisoRecords;
        }
        
        System.debug('TRIVISO_LOG: Mapping ' + projets.size() + ' Projet__c to TrivisoProjetRecord for export');
        
        for (Projet__c projet : projets) {
            TrivisoProjetRecord record = mapFromProjet(projet);
            trivisoRecords.add(record);
        }
        
        System.debug('TRIVISO_LOG: Mapped ' + trivisoRecords.size() + ' Projet__c to TrivisoProjetRecord');
        
        return trivisoRecords;
    }
    
    public static TrivisoProjetRecord mapFromProjet(Projet__c projet) {
        TrivisoProjetRecord record = new TrivisoProjetRecord();
        
        // SAIS_COM_Salesforce_Id - ID Salesforce du projet
        record.saisComSalesforceId = projet.Id != null ? String.valueOf(projet.Id) : '';
        
        record.saisComId = projet.SAIS_com_ID__c != null ? projet.SAIS_com_ID__c : '';
        
        // SAIS_COM_Identification - Numéro du projet (Numero_projet__c ou Name)
        record.saisComIdentification = projet.Numero_projet__c != null ? projet.Numero_projet__c : '';
        
        // SAIS_COM_Description - Nom/Description du projet (Name)
        record.saisComDescription = projet.Name != null ? projet.Name : '';
        
        // SAIS_COM_No_Comm_client - Référence client
        record.saisComNoCommClient = projet.Reference_client__c != null ? projet.Reference_client__c : '';
        
        // SAIS_COM_Etat_ID - ID de l'étape du projet (Etape__c)
        record.saisComEtatId = projet.Etape__c != null ? String.valueOf(projet.Etape__c) : '';
        
        // SAIS_COM_Genre_projet - Genre du projet (Type_projet__c)
        record.saisComGenreProjet = projet.Type_projet__c != null ? projet.Type_projet__c : '';
        
        // SAIS_COM_Fam_Désignation - Famille commerciale
        record.saisComFamDesignation = projet.Famille_commerciale__c != null ? projet.Famille_commerciale__c : '';
        
        // SAIS_COM_Date_ouvert - Date d'ouverture (Date_de_fermeture__c)
        if (projet.Date_de_fermeture__c != null) {
            record.saisComDateOuvert = formatDateForXml(projet.Date_de_fermeture__c);
        } else {
            record.saisComDateOuvert = '';
        }
        
        // SAIS_COM_Date_Modif - Date de dernière modification
        if (projet.LastModifiedDate != null) {
            record.saisComDateModif = formatDateForXml(projet.LastModifiedDate.date());
        } else {
            record.saisComDateModif = '';
        }
        
        // SAIS_COM_ADR_FACT_ID - ID Triviso du nom du compte (via relation Account)
        record.saisComAdrFactId = (projet.Compte_Facturation__r != null && projet.Compte_Facturation__r.Identification__c != null) ? projet.Compte_Facturation__r.Identification__c : '';
        record.saisComAdrFactSalesforceId = projet.Compte_Facturation__c != null ? String.valueOf(projet.Compte_Facturation__c) : '';

        // SAIS_COM_ADR_LIVR_ID - ID Triviso de l'adresse de livraison (via relation)
        record.saisComAdrLivrId = (projet.Adresse_de_Livraison__r != null && projet.Adresse_de_Livraison__r.Identification__c != null) ? projet.Adresse_de_Livraison__r.Identification__c : '';
        record.saisComAdrLivrSalesforceId = projet.Adresse_de_Livraison__c != null ? String.valueOf(projet.Adresse_de_Livraison__c) : '';

        // SAIS_COM_ADR_MO_ID - ID Triviso du maître d'ouvrage (via relation)
        record.saisComAdrMoId = (projet.Maitre_d_ouvrage__r != null && projet.Maitre_d_ouvrage__r.Identification__c != null) ? projet.Maitre_d_ouvrage__r.Identification__c : '';
        record.saisComAdrMoSalesforceId = projet.Maitre_d_ouvrage__c != null ? String.valueOf(projet.Maitre_d_ouvrage__c) : '';

        // SAIS_COM_ADR_ARCH_ID - ID Triviso de l'architecte (via relation Account)
        record.saisComAdrArchId = (projet.Architecte__r != null && projet.Architecte__r.Identification__c != null) ? projet.Architecte__r.Identification__c : '';
        record.saisComAdrArchSalesforceId = projet.Architecte__c != null ? String.valueOf(projet.Architecte__c) : '';

        // SAIS_COM_ADR_RESP_ID - ID Triviso du responsable commercial (via relation)
        record.saisComAdrRespId = (projet.Responsable_commercial__r != null && projet.Responsable_commercial__r.Identification__c != null) ? projet.Responsable_commercial__r.Identification__c : '';
        record.saisComAdrRespSalesforceId = projet.Responsable_commercial__c != null ? String.valueOf(projet.Responsable_commercial__c) : '';

        // SAIS_COM_ADR_MAND_ID - ID Triviso du mandant (via relation Mandant__c)
        record.saisComAdrMandId = (projet.Mandant__r != null && projet.Mandant__r.IdentifiantSoci_t_grpupe__c != null) ? projet.Mandant__r.IdentifiantSoci_t_grpupe__c : '';
        record.saisComAdrMandSalesforceId = projet.Mandant__c != null ? String.valueOf(projet.Mandant__c) : '';

        // SAIS_COM_ADR_RESP_PROJ_ID - ID Triviso du chef de projet (via relation Contact)
        record.saisComAdrRespProjId = (projet.Responsable_Projet_Contact__r != null && projet.Responsable_Projet_Contact__r.Identification__c != null) ? projet.Responsable_Projet_Contact__r.Identification__c : '';
        record.saisComAdrRespProjSalesforceId = projet.Responsable_Projet_Contact__c != null ? String.valueOf(projet.Responsable_Projet_Contact__c) : '';

        // SAIS_COM_ADR_FACT_CONTACT_ID - ID Triviso du contact facturation
        record.saisComAdrFactContactId = (projet.Facturation_Contact__r != null && projet.Facturation_Contact__r.Identification__c != null) ? projet.Facturation_Contact__r.Identification__c : '';

        // SAIS_COM_ADR_LIVR_CONTACT_ID - ID Triviso du contact adresse de livraison
        record.saisComAdrLivrContactId = (projet.Adresse_de_Livraison_2__r != null && projet.Adresse_de_Livraison_2__r.Identification__c != null) ? projet.Adresse_de_Livraison_2__r.Identification__c : '';

        // SAIS_COM_ADR_MO_CONTACT_ID - ID Triviso du contact maître d'ouvrage
        record.saisComAdrMoContactId = (projet.Maitre_d_ouvrage_Contact__r != null && projet.Maitre_d_ouvrage_Contact__r.Identification__c != null) ? projet.Maitre_d_ouvrage_Contact__r.Identification__c : '';

        // SAIS_COM_ADR_ARCH_CONTACT_ID - ID Triviso du contact architecte
        record.saisComAdrArchContactId = (projet.Architecte_EG_Contact__r != null && projet.Architecte_EG_Contact__r.Identification__c != null) ? projet.Architecte_EG_Contact__r.Identification__c : '';

        record.genreProjetSf = projet.Genre_Projet_SF__c != null ? projet.Genre_Projet_SF__c : '';

        // Montants - Mapping depuis les champs Decimal de Projet__c
        record.saisComSomPrixRevientSansProvision = formatDecimalForXml(projet.Calculation_net_sans_provision__c);
        record.saisComSomPrixRevient = formatDecimalForXml(projet.Calculation_net_avec_provision__c);
        record.saisComSomOffert = formatDecimalForXml(projet.Offert__c);
        record.saisComSomConfirme = formatDecimalForXml(projet.Confirme__c);
        record.saisComSomCorrectionConfirme = formatDecimalForXml(projet.Correction_confirm__c);
        record.saisComSomFacture = formatDecimalForXml(projet.Facture__c);
        record.saisComSomPaye = formatDecimalForXml(projet.Paye__c);
        record.saisComSomDac = formatDecimalForXml(projet.Montant__c);
        record.saisComSomPotentielFacturation = formatDecimalForXml(projet.A_facturer__c);
        record.saisComSomAvanceClient = formatDecimalForXml(projet.Avance_client__c);
        record.saisComSomSoldeAPayeCHF = formatDecimalForXml(projet.Paiement_client_recevoir__c);
        
        return record;
    }
    
    /**
     * Convertit un TrivisoProjetRecord en Map pour l'export XML
     * 
     * IMPORTANT: L'ordre des champs doit correspondre exactement à field_names dans projet_import_module.py:
     * 1. SAIS_COM_Salesforce_Id
     * 2. SAIS_COM_ID
     * 3. SAIS_COM_Identification
     * 4. SAIS_COM_Description
     * 5. SAIS_COM_No_Comm_client
     * 6. SAIS_COM_Etat_ID
     * 7. SAIS_COM_Genre_projet
     * 8. SAIS_COM_Fam_Désignation
     * 9. SAIS_COM_Date_ouvert
     * 10. SAIS_COM_Date_Modif
     * 11. SAIS_COM_ADR_FACT_ID
     * 12. SAIS_COM_ADR_LIVR_ID
     * 13. SAIS_COM_ADR_MO_ID
     * 14. SAIS_COM_ADR_ARCH_ID
     * 15. SAIS_COM_ADR_RESP_ID
     * 16. SAIS_COM_ADR_MAND_ID
     * 17. SAIS_COM_ADR_RESP_PROJ_ID
     * 18. SAIS_COM_SOM_Prix_revient_sans_provision
     * 19. SAIS_COM_SOM_Prix_revient
     * 20. SAIS_COM_SOM_Offert
     * 21. SAIS_COM_SOM_Confirmé
     * 22. SAIS_COM_SOM_Correction_Confirmé
     * 23. SAIS_COM_SOM_Facturé
     * 24. SAIS_COM_SOM_Payé
     * 25. SAIS_COM_SOM_DAC
     * 26. SAIS_COM_SOM_potentiel_facturation
     * 27. SAIS_COM_SOM_avance_client
     * 28. SAIS_COM_SOM_Solde_a_paye_CHF
     * 
     * Note: L'ordre dans la Map n'a pas d'importance car le script Python utilise field_names pour définir l'ordre dans le XML
     */
    public static Map<String, String> mapToExportRecord(TrivisoProjetRecord record) {
        Map<String, String> exportRecord = new Map<String, String>();
        
        // Ordre correspondant à field_names dans projet_import_module.py
        exportRecord.put('SAIS_COM_Salesforce_Id', record.saisComSalesforceId != null ? record.saisComSalesforceId : '');
        exportRecord.put('SAIS_COM_ID', record.saisComId != null ? record.saisComId : '');
        exportRecord.put('SAIS_COM_Identification', record.saisComIdentification != null ? record.saisComIdentification : '');
        exportRecord.put('SAIS_COM_Description', record.saisComDescription != null ? record.saisComDescription : '');
        exportRecord.put('SAIS_COM_No_Comm_client', record.saisComNoCommClient != null ? record.saisComNoCommClient : '');
        exportRecord.put('SAIS_COM_Etat_ID', record.saisComEtatId != null ? record.saisComEtatId : '');
        exportRecord.put('SAIS_COM_Genre_projet', record.saisComGenreProjet != null ? record.saisComGenreProjet : '');
        exportRecord.put('SAIS_COM_Fam_Désignation', record.saisComFamDesignation != null ? record.saisComFamDesignation : '');
        exportRecord.put('SAIS_COM_Date_ouvert', record.saisComDateOuvert != null ? record.saisComDateOuvert : '');
        exportRecord.put('SAIS_COM_Date_Modif', record.saisComDateModif != null ? record.saisComDateModif : '');
        exportRecord.put('SAIS_COM_ADR_FACT_ID', record.saisComAdrFactId != null ? record.saisComAdrFactId : '');
        exportRecord.put('SAIS_COM_ADR_FACT_Salesforce_ID', record.saisComAdrFactSalesforceId != null ? record.saisComAdrFactSalesforceId : '');
        exportRecord.put('SAIS_COM_ADR_LIVR_ID', record.saisComAdrLivrId != null ? record.saisComAdrLivrId : '');
        exportRecord.put('SAIS_COM_ADR_LIVR_Salesforce_ID', record.saisComAdrLivrSalesforceId != null ? record.saisComAdrLivrSalesforceId : '');
        exportRecord.put('SAIS_COM_ADR_MO_ID', record.saisComAdrMoId != null ? record.saisComAdrMoId : '');
        exportRecord.put('SAIS_COM_ADR_MO_Salesforce_ID', record.saisComAdrMoSalesforceId != null ? record.saisComAdrMoSalesforceId : '');
        exportRecord.put('SAIS_COM_ADR_ARCH_ID', record.saisComAdrArchId != null ? record.saisComAdrArchId : '');
        exportRecord.put('SAIS_COM_ADR_ARCH_Salesforce_ID', record.saisComAdrArchSalesforceId != null ? record.saisComAdrArchSalesforceId : '');
        exportRecord.put('SAIS_COM_ADR_RESP_ID', record.saisComAdrRespId != null ? record.saisComAdrRespId : '');
        exportRecord.put('SAIS_COM_ADR_RESP_Salesforce_ID', record.saisComAdrRespSalesforceId != null ? record.saisComAdrRespSalesforceId : '');
        exportRecord.put('SAIS_COM_ADR_MAND_ID', record.saisComAdrMandId != null ? record.saisComAdrMandId : '');
        exportRecord.put('SAIS_COM_ADR_MAND_Salesforce_ID', record.saisComAdrMandSalesforceId != null ? record.saisComAdrMandSalesforceId : '');
        exportRecord.put('SAIS_COM_ADR_RESP_PROJ_ID', record.saisComAdrRespProjId != null ? record.saisComAdrRespProjId : '');
        exportRecord.put('SAIS_COM_ADR_RESP_PROJ_Salesforce_ID', record.saisComAdrRespProjSalesforceId != null ? record.saisComAdrRespProjSalesforceId : '');
        exportRecord.put('SAIS_COM_ADR_FACT_CONTACT_ID', record.saisComAdrFactContactId != null ? record.saisComAdrFactContactId : '');
        exportRecord.put('SAIS_COM_ADR_LIVR_CONTACT_ID', record.saisComAdrLivrContactId != null ? record.saisComAdrLivrContactId : '');
        exportRecord.put('SAIS_COM_ADR_MO_CONTACT_ID', record.saisComAdrMoContactId != null ? record.saisComAdrMoContactId : '');
        exportRecord.put('SAIS_COM_ADR_ARCH_CONTACT_ID', record.saisComAdrArchContactId != null ? record.saisComAdrArchContactId : '');
        exportRecord.put('GENRE_PROJET_SF', record.genreProjetSf != null ? record.genreProjetSf : '');

        return exportRecord;
    }
    
    private static String formatDateForXml(Date dateValue) {
        if (dateValue == null) {
            return '';
        }
        // Format: DD.MM.YYYY HH:MM:SS (on met 00:00:00 pour l'heure car Date n'a pas d'heure)
        Integer dayInt = dateValue.day();
        Integer monthInt = dateValue.month();
        Integer yearInt = dateValue.year();
        String day = dayInt < 10 ? '0' + String.valueOf(dayInt) : String.valueOf(dayInt);
        String month = monthInt < 10 ? '0' + String.valueOf(monthInt) : String.valueOf(monthInt);
        String year = String.valueOf(yearInt);
        return day + '.' + month + '.' + year + ' 00:00:00';
    }
    
    private static String formatDecimalForXml(Decimal decimalValue) {
        if (decimalValue == null) {
            return '';
        }
        return String.valueOf(decimalValue);
    }
}