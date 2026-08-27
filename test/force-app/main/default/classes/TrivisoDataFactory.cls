@isTest
public class TrivisoDataFactory {
    
    // ============================================
    // AddressProxyRecord Factory Methods
    // ============================================
    
    /**
     * Creates a default AddressProxyRecord with all fields populated
     */
    public static AddressProxyRecord createAddressProxyRecord() {
        AddressProxyRecord record = new AddressProxyRecord();
        
        record.adresTag = 'TEST_TAG';
        record.adresId = 'ADRES_' + String.valueOf(Crypto.getRandomLong());
        record.adresOrganisationIdentif = 'ORG_' + String.valueOf(Crypto.getRandomLong());
        record.adresIdentification = 'IDENT_' + String.valueOf(Crypto.getRandomLong());
        record.adresDateCreation = '01.01.2024 10:00:00';
        record.adresDateModif = '15.06.2024 14:30:00';
        record.adresDateInactive = null;
        record.adresNom = 'Dupont';
        record.adresPrenom = 'Jean';
        record.adresSupplement = 'Bâtiment A';
        record.adresCasePostale = '1234';
        record.adresRue = 'Rue de la Paix 10';
        record.adresTelephone1 = '+41 21 123 45 67';
        record.adresTelephone2 = '+41 21 123 45 68';
        record.adresTelephone3 = null;
        record.adresNatel1 = '+41 79 123 45 67';
        record.adresNatel2 = null;
        record.adresEmail = 'jean.dupont@example.com';
        record.adresEmail2 = 'jean.dupont.alt@example.com';
        record.adresSiteWeb = 'https://www.example.com';
        record.adresEntete = 'Monsieur';
        record.adresIdEntete = 'ENT-001';
        record.adresTvaIntracom = 'CHE-123.456.789';
        record.adresNoRegistreCommerce = 'CH-123.456.789';
        record.adresNpl = '1000';
        record.adresLieu = 'Lausanne';
        record.adresPaysDescription = 'Suisse';
        record.adresTitre = 'Ingénieur';
        record.adresDepartement = 'VD';
        record.adresLangue = 'FR';
        record.adresNoEori = 'CH123456789';
        
        return record;
    }
    
    /**
     * Creates an AddressProxyRecord with custom values
     */
    public static AddressProxyRecord createAddressProxyRecord(Map<String, Object> overrides) {
        AddressProxyRecord record = createAddressProxyRecord();
        
        if (overrides != null) {
            if (overrides.containsKey('adresTag')) record.adresTag = (String)overrides.get('adresTag');
            if (overrides.containsKey('adresId')) record.adresId = (String)overrides.get('adresId');
            if (overrides.containsKey('adresOrganisationIdentif')) record.adresOrganisationIdentif = (String)overrides.get('adresOrganisationIdentif');
            if (overrides.containsKey('adresIdentification')) record.adresIdentification = (String)overrides.get('adresIdentification');
            if (overrides.containsKey('adresDateCreation')) record.adresDateCreation = (String)overrides.get('adresDateCreation');
            if (overrides.containsKey('adresDateModif')) record.adresDateModif = (String)overrides.get('adresDateModif');
            if (overrides.containsKey('adresDateInactive')) record.adresDateInactive = (String)overrides.get('adresDateInactive');
            if (overrides.containsKey('adresNom')) record.adresNom = (String)overrides.get('adresNom');
            if (overrides.containsKey('adresPrenom')) record.adresPrenom = (String)overrides.get('adresPrenom');
            if (overrides.containsKey('adresSupplement')) record.adresSupplement = (String)overrides.get('adresSupplement');
            if (overrides.containsKey('adresCasePostale')) record.adresCasePostale = (String)overrides.get('adresCasePostale');
            if (overrides.containsKey('adresRue')) record.adresRue = (String)overrides.get('adresRue');
            if (overrides.containsKey('adresTelephone1')) record.adresTelephone1 = (String)overrides.get('adresTelephone1');
            if (overrides.containsKey('adresTelephone2')) record.adresTelephone2 = (String)overrides.get('adresTelephone2');
            if (overrides.containsKey('adresTelephone3')) record.adresTelephone3 = (String)overrides.get('adresTelephone3');
            if (overrides.containsKey('adresNatel1')) record.adresNatel1 = (String)overrides.get('adresNatel1');
            if (overrides.containsKey('adresNatel2')) record.adresNatel2 = (String)overrides.get('adresNatel2');
            if (overrides.containsKey('adresEmail')) record.adresEmail = (String)overrides.get('adresEmail');
            if (overrides.containsKey('adresEmail2')) record.adresEmail2 = (String)overrides.get('adresEmail2');
            if (overrides.containsKey('adresSiteWeb')) record.adresSiteWeb = (String)overrides.get('adresSiteWeb');
            if (overrides.containsKey('adresEntete')) record.adresEntete = (String)overrides.get('adresEntete');
            if (overrides.containsKey('adresIdEntete')) record.adresIdEntete = (String)overrides.get('adresIdEntete');
            if (overrides.containsKey('adresTvaIntracom')) record.adresTvaIntracom = (String)overrides.get('adresTvaIntracom');
            if (overrides.containsKey('adresNoRegistreCommerce')) record.adresNoRegistreCommerce = (String)overrides.get('adresNoRegistreCommerce');
            if (overrides.containsKey('adresNpl')) record.adresNpl = (String)overrides.get('adresNpl');
            if (overrides.containsKey('adresLieu')) record.adresLieu = (String)overrides.get('adresLieu');
            if (overrides.containsKey('adresPaysDescription')) record.adresPaysDescription = (String)overrides.get('adresPaysDescription');
            if (overrides.containsKey('adresTitre')) record.adresTitre = (String)overrides.get('adresTitre');
            if (overrides.containsKey('adresDepartement')) record.adresDepartement = (String)overrides.get('adresDepartement');
            if (overrides.containsKey('adresLangue')) record.adresLangue = (String)overrides.get('adresLangue');
            if (overrides.containsKey('adresNoEori')) record.adresNoEori = (String)overrides.get('adresNoEori');
        }
        
        return record;
    }
    
    /**
     * Creates a list of AddressProxyRecord objects
     */
    public static List<AddressProxyRecord> createAddressProxyRecords(Integer count) {
        List<AddressProxyRecord> records = new List<AddressProxyRecord>();
        for (Integer i = 0; i < count; i++) {
            AddressProxyRecord record = createAddressProxyRecord();
            record.adresId = 'ADRES_' + String.valueOf(i + 1);
            record.adresNom = 'Nom_' + String.valueOf(i + 1);
            record.adresPrenom = 'Prenom_' + String.valueOf(i + 1);
            records.add(record);
        }
        return records;
    }
    
    // ============================================
    // ProjetProxyRecord Factory Methods
    // ============================================
    
    /**
     * Creates a default ProjetProxyRecord with all fields populated
     */
    public static ProjetProxyRecord createProjetProxyRecord() {
        ProjetProxyRecord record = new ProjetProxyRecord();
        
        record.idProjetTriviso = 'PROJ_' + String.valueOf(Crypto.getRandomLong());
        record.numeroProjet = 'NUM-' + String.valueOf(Crypto.getRandomLong());
        record.nomProjet = 'Projet Test';
        record.referenceClient = 'REF-' + String.valueOf(Crypto.getRandomLong());
        record.idEtapeProjet = 'ETAPE_1';
        record.genreProjet = 'Construction';
        record.familleCommerciale = 'Famille Test';
        record.dateOuvertureProjet = '01.01.2024';
        record.dateDerniereModification = '15.06.2024';
        record.compteFacturationTrivisoId = 'ADRES_FACT_1';
        record.compteLivraisonTrivisoId = 'ADRES_LIVR_1';
        record.compteMaitreOuvrageTrivisoId = 'ADRES_MO_1';
        record.compteArchitecteTrivisoId = 'ADRES_ARCH_1';
        record.facturationContactId = 'CONT_FACT_1';
        record.adresseLivraison2ContactId = 'CONT_LIVR_1';
        record.maitreOuvrageContactId = 'CONT_MO_1';
        record.architecteEGContactId = 'CONT_ARCH_1';
        record.compteResponsableCommercialTrivisoId = 'ADRES_RESP_1';
        record.compteMandantTrivisoId = 'ADRES_MAND_1';
        record.compteResponsableProjetTrivisoId = 'ADRES_RESP_PROJ_1';
        record.montantNetSansProvision = 100000.00;
        record.montantNetAvecProvision = 110000.00;
        record.montantOffert = 105000.00;
        record.montantConfirme = 108000.00;
        record.montantCorrectionConfirme = 109000.00;
        record.montantFacture = 107000.00;
        record.montantPaye = 50000.00;
        record.montantDAC = 2000.00;
        record.potentielFacturation = 120000.00;
        record.avanceClient = 10000.00;
        record.soldeClientAPayerCHF = 57000.00;
        
        return record;
    }
    
    /**
     * Creates a ProjetProxyRecord with custom values
     */
    public static ProjetProxyRecord createProjetProxyRecord(Map<String, Object> overrides) {
        ProjetProxyRecord record = createProjetProxyRecord();
        
        if (overrides != null) {
            if (overrides.containsKey('idProjetTriviso')) record.idProjetTriviso = (String)overrides.get('idProjetTriviso');
            if (overrides.containsKey('numeroProjet')) record.numeroProjet = (String)overrides.get('numeroProjet');
            if (overrides.containsKey('nomProjet')) record.nomProjet = (String)overrides.get('nomProjet');
            if (overrides.containsKey('referenceClient')) record.referenceClient = (String)overrides.get('referenceClient');
            if (overrides.containsKey('idEtapeProjet')) record.idEtapeProjet = (String)overrides.get('idEtapeProjet');
            if (overrides.containsKey('genreProjet')) record.genreProjet = (String)overrides.get('genreProjet');
            if (overrides.containsKey('familleCommerciale')) record.familleCommerciale = (String)overrides.get('familleCommerciale');
            if (overrides.containsKey('dateOuvertureProjet')) record.dateOuvertureProjet = (String)overrides.get('dateOuvertureProjet');
            if (overrides.containsKey('dateDerniereModification')) record.dateDerniereModification = (String)overrides.get('dateDerniereModification');
            if (overrides.containsKey('compteFacturationTrivisoId')) record.compteFacturationTrivisoId = (String)overrides.get('compteFacturationTrivisoId');
            if (overrides.containsKey('compteLivraisonTrivisoId')) record.compteLivraisonTrivisoId = (String)overrides.get('compteLivraisonTrivisoId');
            if (overrides.containsKey('compteMaitreOuvrageTrivisoId')) record.compteMaitreOuvrageTrivisoId = (String)overrides.get('compteMaitreOuvrageTrivisoId');
            if (overrides.containsKey('compteArchitecteTrivisoId')) record.compteArchitecteTrivisoId = (String)overrides.get('compteArchitecteTrivisoId');
            if (overrides.containsKey('facturationContactId')) record.facturationContactId = (String)overrides.get('facturationContactId');
            if (overrides.containsKey('adresseLivraison2ContactId')) record.adresseLivraison2ContactId = (String)overrides.get('adresseLivraison2ContactId');
            if (overrides.containsKey('maitreOuvrageContactId')) record.maitreOuvrageContactId = (String)overrides.get('maitreOuvrageContactId');
            if (overrides.containsKey('architecteEGContactId')) record.architecteEGContactId = (String)overrides.get('architecteEGContactId');
            if (overrides.containsKey('compteResponsableCommercialTrivisoId')) record.compteResponsableCommercialTrivisoId = (String)overrides.get('compteResponsableCommercialTrivisoId');
            if (overrides.containsKey('compteMandantTrivisoId')) record.compteMandantTrivisoId = (String)overrides.get('compteMandantTrivisoId');
            if (overrides.containsKey('compteResponsableProjetTrivisoId')) record.compteResponsableProjetTrivisoId = (String)overrides.get('compteResponsableProjetTrivisoId');
            if (overrides.containsKey('montantNetSansProvision')) record.montantNetSansProvision = overrides.get('montantNetSansProvision');
            if (overrides.containsKey('montantNetAvecProvision')) record.montantNetAvecProvision = overrides.get('montantNetAvecProvision');
            if (overrides.containsKey('montantOffert')) record.montantOffert = overrides.get('montantOffert');
            if (overrides.containsKey('montantConfirme')) record.montantConfirme = overrides.get('montantConfirme');
            if (overrides.containsKey('montantCorrectionConfirme')) record.montantCorrectionConfirme = overrides.get('montantCorrectionConfirme');
            if (overrides.containsKey('montantFacture')) record.montantFacture = overrides.get('montantFacture');
            if (overrides.containsKey('montantPaye')) record.montantPaye = overrides.get('montantPaye');
            if (overrides.containsKey('montantDAC')) record.montantDAC = overrides.get('montantDAC');
            if (overrides.containsKey('potentielFacturation')) record.potentielFacturation = overrides.get('potentielFacturation');
            if (overrides.containsKey('avanceClient')) record.avanceClient = overrides.get('avanceClient');
            if (overrides.containsKey('soldeClientAPayerCHF')) record.soldeClientAPayerCHF = overrides.get('soldeClientAPayerCHF');
        }
        
        return record;
    }
    
    /**
     * Creates a list of ProjetProxyRecord objects
     */
    public static List<ProjetProxyRecord> createProjetProxyRecords(Integer count) {
        List<ProjetProxyRecord> records = new List<ProjetProxyRecord>();
        for (Integer i = 0; i < count; i++) {
            ProjetProxyRecord record = createProjetProxyRecord();
            record.idProjetTriviso = 'PROJ_' + String.valueOf(i + 1);
            record.numeroProjet = 'NUM-' + String.valueOf(i + 1);
            record.nomProjet = 'Projet Test ' + String.valueOf(i + 1);
            records.add(record);
        }
        return records;
    }
    
    // ============================================
    // Triviso Mapper Support Factory Methods
    // ============================================

    public static Account createAccountForTrivisoMapper(Boolean doInsert) {
        if (doInsert) {
            List<Account> existingAccounts = [
                SELECT Id, Name, Genre_de_client__c, Identification__c, Prenom__c, Supplement_adresse__c, Case_postale__c,
                       BillingStreet, BillingCity, BillingPostalCode, BillingCountry,
                       Telephone_1__c, Telephone_2__c, Telephone_3__c,
                       Phone, Phone_2__c,
                       Email_1__c, Email_2__c,
                    //    Website, Ent_te__c, Lettre_Ent_te__c,
                       No_TVA_EU__c, Numero_TVA__c, Registre_commerce__c,
                       Langue__c, No_EORI__c, Compte_Actif__c, ParentId
                FROM Account
                WHERE Name = 'TRIVISO_ACCOUNT_MAPPER'
                LIMIT 1
            ];
            if (!existingAccounts.isEmpty()) {
                Account acc = existingAccounts[0];
                acc.Genre_de_client__c = 'TRIVISO_TAG';
                acc.Identification__c = 'TRIVISO_ACCOUNT_ID';
                acc.Prenom__c = 'Prenom';
                acc.Supplement_adresse__c = 'Suppl';
                acc.Case_postale__c = 'CP';
                acc.BillingStreet = 'Rue 1';
                acc.BillingCity = 'Ville';
                acc.BillingPostalCode = '1000';
                acc.BillingCountry = 'CH';
                acc.Telephone_1__c = 'T1';
                acc.Telephone_2__c = 'T2';
                acc.Telephone_3__c = 'T3';
                acc.Phone = 'N1';
                acc.Phone_2__c = 'N2';
                acc.Email_1__c = 'a@test.com';
                acc.Email_2__c = 'b@test.com';
                acc.Website = 'https://test.com';
                acc.Ent_te__c = 'Entete';
                // acc.Lettre_Ent_te__c = 'Lettre';
                acc.No_TVA_EU__c = 'TVA_EU';
                acc.Numero_TVA__c = 'TVA_CH';
                acc.Registre_commerce__c = 'RC';
                acc.Langue__c = 'FR';
                acc.No_EORI__c = 'EORI';
                acc.Compte_Actif__c = false;
                update acc;
                return acc;
            }
        }
        Account parent;
        if (doInsert) {
            List<Account> parents = [
                SELECT Id
                FROM Account
                WHERE Name = 'TRIVISO_ACCOUNT_PARENT'
                LIMIT 1
            ];
            if (!parents.isEmpty()) {
                parent = parents[0];
            } else {
                parent = new Account();
                parent.Name = 'TRIVISO_ACCOUNT_PARENT';
                parent.Identification__c = 'TRIVISO_PARENT_ID';
                insert parent;
            }
        } else {
            parent = new Account();
            parent.Name = 'TRIVISO_ACCOUNT_PARENT';
            parent.Identification__c = 'TRIVISO_PARENT_ID';
        }
        Account acc = new Account();
        acc.Name = 'TRIVISO_ACCOUNT_MAPPER';
        acc.ParentId = doInsert ? parent.Id : null;
        acc.Genre_de_client__c = 'TRIVISO_TAG';
        acc.Identification__c = 'TRIVISO_ACCOUNT_ID';
        acc.Prenom__c = 'Prenom';
        acc.ADRES_ID_entete_c__c = 'IDENT-ENT-ACC';
        acc.Supplement_adresse__c = 'Suppl';
        acc.Case_postale__c = 'CP';
        acc.BillingStreet = 'Rue 1';
        acc.BillingCity = 'Ville';
        acc.BillingPostalCode = '1000';
        acc.BillingCountry = 'CH';
        acc.Telephone_1__c = 'T1';
        acc.Telephone_2__c = 'T2';
        acc.Telephone_3__c = 'T3';
        acc.Phone = 'N1';
        acc.Phone_2__c = 'N2';
        acc.Email_1__c = 'a@test.com';
        acc.Email_2__c = 'b@test.com';
        acc.Website = 'https://test.com';
        acc.Ent_te__c = 'Entete';
        // acc.Lettre_Ent_te__c = 'Lettre';
        acc.No_TVA_EU__c = 'TVA_EU';
        acc.Numero_TVA__c = 'TVA_CH';
        acc.Registre_commerce__c = 'RC';
        acc.Langue__c = 'FR';
        acc.No_EORI__c = 'EORI';
        acc.Compte_Actif__c = false;
        if (doInsert) {
            insert acc;
        }
        return acc;
    }

    public static Contact createContactForTrivisoMapper(Boolean doInsert) {
        Account acc = createAccountForTrivisoMapper(doInsert);
        String runId = String.valueOf(Crypto.getRandomLong());
        Contact c = new Contact();
        c.FirstName = 'TRIVISO_FN_' + runId;
        c.LastName = 'TRIVISO_LN_' + runId;
        c.Salutation = 'M.';
        c.Email = 'c_' + runId + '@test.com';
        c.Email_2__c = 'c2_' + runId + '@test.com';
        c.Telephone_1__c = 'T1_' + runId;
        c.Telephone_2__c = 'T2_' + runId;
        c.Telephone_3__c = 'T3_' + runId;
        c.MobilePhone = 'M1_' + runId;
        c.Mobile_2__c = 'M2_' + runId;
        c.MailingStreet = 'Rue 1';
        c.MailingCity = 'Ville';
        c.MailingPostalCode = '1000';
        c.MailingCountry = 'CH';
        c.Title = 'Titre';
        c.Department = 'Dep';
        c.Identification__c = 'TRIVISO_CONTACT_ID';
        c.Langue__c = 'FR';
        c.Genre_contact__c = 'TRIVISO_TAG';
        c.SiteWeb__c = 'https://test.com';
        c.ADRES_ID_entete_c__c = 'IDENT-ENT-CTC';
        c.Supplement__c = 'Suppl';
        c.Case_postale__c = 'CP';
        // c.Lettre_Ent_te__c = 'Lettre';
        c.AccountId = acc.Id;
        if (doInsert) {
            insert c;
        }
        return c;
    }

    public static Projet__c createProjetForTrivisoMapper(Boolean doInsert) {
        Account fact = createAccountForTrivisoMapper(doInsert);
        Account livr = createAccountForTrivisoMapper(doInsert);
        Account mo = createAccountForTrivisoMapper(doInsert);
        Contact moContact = createContactForTrivisoMapper(doInsert);
        String runId = String.valueOf(Crypto.getRandomLong());
        Projet__c projet = new Projet__c();
        projet.Name = 'TRIVISO_PROJET_MAPPER_' + runId;
        projet.Numero_projet__c = 'TRIVISO_NUM_' + runId;
        projet.Reference_client__c = 'TRIVISO_REF_CLIENT_' + runId;
        projet.Etape__c = 'Qualification';
        projet.Etat__c = 'Terminé';
        projet.Type_projet__c = 'Type A';
        projet.Famille_commerciale__c = 'Famille A';
        projet.Date_de_fermeture__c = Date.newInstance(2024, 3, 15);
        projet.Calculation_net_sans_provision__c = 100000.00;
        projet.Calculation_net_avec_provision__c = 110000.00;
        projet.Offert__c = 105000.00;
        projet.Confirme__c = 108000.00;
        projet.Correction_confirm__c = 109000.00;
        projet.Facture__c = 107000.00;
        projet.Paye__c = 50000.00;
        projet.Montant__c = 2000.00;
        projet.A_facturer__c = 120000.00;
        projet.Avance_client__c = 10000.00;
        projet.Paiement_client_recevoir__c = 57000.00;
        projet.Nom_du_compte__c = fact.Id;
        projet.Compte_Livraison__c = livr.Id;
        projet.Adresse_de_Livraison__c = livr.Id;
        projet.Maitre_d_ouvrage__c = mo.Id;
        projet.Maitre_d_ouvrage_Contact__c = moContact.Id;
        projet.Architecte__c = mo.Id;
        projet.Chef_de_projet__c = moContact.Id;
        projet.Responsable_commercial__c = moContact.Id;
        if (doInsert) {
            insert projet;
        }
        return projet;
    }
    
    // ============================================
    // TrivisoAddressExport.CsvRecordDeserializer Factory Methods
    // ============================================
    
    /**
     * Creates a default TrivisoAddressExport.CsvRecordDeserializer with all fields populated
     */
    public static TrivisoAddressExport.CsvRecordDeserializer createAddressCsvRecord() {
        TrivisoAddressExport.CsvRecordDeserializer csvRecord = new TrivisoAddressExport.CsvRecordDeserializer();
        
        csvRecord.ADRES_Tag = 'TEST_TAG';
        csvRecord.ADRES_ID = 'ADRES_' + String.valueOf(Crypto.getRandomLong());
        csvRecord.ADRES_Organisation_Identif = 'ORG_' + String.valueOf(Crypto.getRandomLong());
        csvRecord.ADRES_Identification = 'IDENT_' + String.valueOf(Crypto.getRandomLong());
        csvRecord.ADRES_Date_creation = '01.01.2024 10:00:00';
        csvRecord.ADRES_Date_modif = '15.06.2024 14:30:00';
        csvRecord.ADRES_Date_inactive = null;
        csvRecord.ADRES_Nom = 'Dupont';
        csvRecord.ADRES_Prenom = 'Jean';
        csvRecord.ADRES_Supplement = 'Bâtiment A';
        csvRecord.ADRES_Case_postale = '1234';
        csvRecord.ADRES_Rue = 'Rue de la Paix 10';
        csvRecord.ADRES_Telephone1 = '+41 21 123 45 67';
        csvRecord.ADRES_Telephone2 = '+41 21 123 45 68';
        csvRecord.ADRES_Telephone3 = null;
        csvRecord.ADRES_Natel1 = '+41 79 123 45 67';
        csvRecord.ADRES_Natel2 = null;
        csvRecord.ADRES_Email = 'jean.dupont@example.com';
        csvRecord.ADRES_Email2 = 'jean.dupont.alt@example.com';
        csvRecord.ADRES_Site_Web = 'https://www.example.com';
        csvRecord.ADRES_entete = 'Monsieur';
        csvRecord.ADRES_ID_entete = 'ENT-001';
        csvRecord.ADRES_TVA_intracom = 'CHE-123.456.789';
        csvRecord.ADRES_No_registre_commerce = 'CH-123.456.789';
        csvRecord.ADRES_NPL = '1000';
        csvRecord.ADRES_Lieu = 'Lausanne';
        csvRecord.ADRES_PAYS_Description = 'Suisse';
        csvRecord.ADRES_Titre = 'Ingénieur';
        csvRecord.ADRES_Departement = 'VD';
        csvRecord.ADRES_Langue = 'FR';
        csvRecord.ADRES_No_EORI = 'CH123456789';
        
        return csvRecord;
    }
    
    /**
     * Creates a TrivisoAddressExport.CsvRecordDeserializer with custom values
     */
    public static TrivisoAddressExport.CsvRecordDeserializer createAddressCsvRecord(Map<String, Object> overrides) {
        TrivisoAddressExport.CsvRecordDeserializer csvRecord = createAddressCsvRecord();
        
        if (overrides != null) {
            if (overrides.containsKey('ADRES_Tag')) csvRecord.ADRES_Tag = (String)overrides.get('ADRES_Tag');
            if (overrides.containsKey('ADRES_ID')) csvRecord.ADRES_ID = (String)overrides.get('ADRES_ID');
            if (overrides.containsKey('ADRES_Organisation_Identif')) csvRecord.ADRES_Organisation_Identif = (String)overrides.get('ADRES_Organisation_Identif');
            if (overrides.containsKey('ADRES_Identification')) csvRecord.ADRES_Identification = (String)overrides.get('ADRES_Identification');
            if (overrides.containsKey('ADRES_Date_creation')) csvRecord.ADRES_Date_creation = (String)overrides.get('ADRES_Date_creation');
            if (overrides.containsKey('ADRES_Date_modif')) csvRecord.ADRES_Date_modif = (String)overrides.get('ADRES_Date_modif');
            if (overrides.containsKey('ADRES_Date_inactive')) csvRecord.ADRES_Date_inactive = (String)overrides.get('ADRES_Date_inactive');
            if (overrides.containsKey('ADRES_Nom')) csvRecord.ADRES_Nom = (String)overrides.get('ADRES_Nom');
            if (overrides.containsKey('ADRES_Prenom')) csvRecord.ADRES_Prenom = (String)overrides.get('ADRES_Prenom');
            if (overrides.containsKey('ADRES_Supplement')) csvRecord.ADRES_Supplement = (String)overrides.get('ADRES_Supplement');
            if (overrides.containsKey('ADRES_Case_postale')) csvRecord.ADRES_Case_postale = (String)overrides.get('ADRES_Case_postale');
            if (overrides.containsKey('ADRES_Rue')) csvRecord.ADRES_Rue = (String)overrides.get('ADRES_Rue');
            if (overrides.containsKey('ADRES_Telephone1')) csvRecord.ADRES_Telephone1 = (String)overrides.get('ADRES_Telephone1');
            if (overrides.containsKey('ADRES_Telephone2')) csvRecord.ADRES_Telephone2 = (String)overrides.get('ADRES_Telephone2');
            if (overrides.containsKey('ADRES_Telephone3')) csvRecord.ADRES_Telephone3 = (String)overrides.get('ADRES_Telephone3');
            if (overrides.containsKey('ADRES_Natel1')) csvRecord.ADRES_Natel1 = (String)overrides.get('ADRES_Natel1');
            if (overrides.containsKey('ADRES_Natel2')) csvRecord.ADRES_Natel2 = (String)overrides.get('ADRES_Natel2');
            if (overrides.containsKey('ADRES_Email')) csvRecord.ADRES_Email = (String)overrides.get('ADRES_Email');
            if (overrides.containsKey('ADRES_Email2')) csvRecord.ADRES_Email2 = (String)overrides.get('ADRES_Email2');
            if (overrides.containsKey('ADRES_Site_Web')) csvRecord.ADRES_Site_Web = (String)overrides.get('ADRES_Site_Web');
            if (overrides.containsKey('ADRES_entete')) csvRecord.ADRES_entete = (String)overrides.get('ADRES_entete');
            if (overrides.containsKey('ADRES_ID_entete')) csvRecord.ADRES_ID_entete = (String)overrides.get('ADRES_ID_entete');
            if (overrides.containsKey('ADRES_TVA_intracom')) csvRecord.ADRES_TVA_intracom = (String)overrides.get('ADRES_TVA_intracom');
            if (overrides.containsKey('ADRES_No_registre_commerce')) csvRecord.ADRES_No_registre_commerce = (String)overrides.get('ADRES_No_registre_commerce');
            if (overrides.containsKey('ADRES_NPL')) csvRecord.ADRES_NPL = (String)overrides.get('ADRES_NPL');
            if (overrides.containsKey('ADRES_Lieu')) csvRecord.ADRES_Lieu = (String)overrides.get('ADRES_Lieu');
            if (overrides.containsKey('ADRES_PAYS_Description')) csvRecord.ADRES_PAYS_Description = (String)overrides.get('ADRES_PAYS_Description');
            if (overrides.containsKey('ADRES_Titre')) csvRecord.ADRES_Titre = (String)overrides.get('ADRES_Titre');
            if (overrides.containsKey('ADRES_Departement')) csvRecord.ADRES_Departement = (String)overrides.get('ADRES_Departement');
            if (overrides.containsKey('ADRES_Langue')) csvRecord.ADRES_Langue = (String)overrides.get('ADRES_Langue');
            if (overrides.containsKey('ADRES_No_EORI')) csvRecord.ADRES_No_EORI = (String)overrides.get('ADRES_No_EORI');
        }
        
        return csvRecord;
    }
    
    /**
     * Creates a list of TrivisoAddressExport.CsvRecordDeserializer objects
     */
    public static List<TrivisoAddressExport.CsvRecordDeserializer> createAddressCsvRecords(Integer count) {
        List<TrivisoAddressExport.CsvRecordDeserializer> csvRecords = new List<TrivisoAddressExport.CsvRecordDeserializer>();
        for (Integer i = 0; i < count; i++) {
            TrivisoAddressExport.CsvRecordDeserializer csvRecord = createAddressCsvRecord();
            csvRecord.ADRES_ID = 'ADRES_' + String.valueOf(i + 1);
            csvRecord.ADRES_Nom = 'Nom_' + String.valueOf(i + 1);
            csvRecord.ADRES_Prenom = 'Prenom_' + String.valueOf(i + 1);
            csvRecords.add(csvRecord);
        }
        return csvRecords;
    }
    
    // ============================================
    // TrivisoProjetExport.CsvRecordDeserializer Factory Methods
    // ============================================
    
    /**
     * Creates a default TrivisoProjetExport.CsvRecordDeserializer with all fields populated
     */
    public static TrivisoProjetExport.CsvRecordDeserializer createProjetCsvRecord() {
        TrivisoProjetExport.CsvRecordDeserializer csvRecord = new TrivisoProjetExport.CsvRecordDeserializer();
        
        csvRecord.SAIS_COM_ID = 'PROJ_' + String.valueOf(Crypto.getRandomLong());
        csvRecord.SAIS_COM_Identification = 'NUM-' + String.valueOf(Crypto.getRandomLong());
        csvRecord.SAIS_COM_Description = 'Projet Test';
        csvRecord.SAIS_COM_No_Comm_client = 'REF-' + String.valueOf(Crypto.getRandomLong());
        csvRecord.SAIS_COM_Etat_ID = 'ETAPE_1';
        csvRecord.SAIS_COM_Genre_projet = 'Construction';
        csvRecord.SAIS_COM_Fam_Designation = 'Famille Test';
        csvRecord.SAIS_COM_Date_ouvert = '01.01.2024';
        csvRecord.SAIS_COM_Date_Modif = '15.06.2024';
        csvRecord.SAIS_COM_ADR_FACT_ID = 'ADRES_FACT_1';
        csvRecord.SAIS_COM_ADR_LIVR_ID = 'ADRES_LIVR_1';
        csvRecord.SAIS_COM_ADR_MO_ID = 'ADRES_MO_1';
        csvRecord.SAIS_COM_ADR_ARCH_ID = 'ADRES_ARCH_1';
        csvRecord.SAIS_COM_ADR_RESP_ID = 'ADRES_RESP_1';
        csvRecord.SAIS_COM_ADR_MAND_ID = 'ADRES_MAND_1';
        csvRecord.SAIS_COM_ADR_RESP_PROJ_ID = 'ADRES_RESP_PROJ_1';
        csvRecord.SAIS_COM_ADR_FACT_CONTACT_ID = 'CONT_FACT_1';
        csvRecord.SAIS_COM_ADR_LIVR_CONTACT_ID = 'CONT_LIVR_1';
        csvRecord.SAIS_COM_ADR_MO_CONTACT_ID = 'CONT_MO_1';
        csvRecord.SAIS_COM_ADR_ARCH_CONTACT_ID = 'CONT_ARCH_1';
        csvRecord.SAIS_COM_SOM_Prix_revient_sans_provision = '100000.00';
        csvRecord.SAIS_COM_SOM_Prix_revient = '110000.00';
        csvRecord.SAIS_COM_SOM_Offert = '105000.00';
        csvRecord.SAIS_COM_SOM_Confirme = '108000.00';
        csvRecord.SAIS_COM_SOM_Correction_Confirme = '109000.00';
        csvRecord.SAIS_COM_SOM_Facture = '107000.00';
        csvRecord.SAIS_COM_SOM_Paye = '50000.00';
        csvRecord.SAIS_COM_SOM_DAC = '2000.00';
        csvRecord.SAIS_COM_SOM_potentiel_facturation = '120000.00';
        csvRecord.SAIS_COM_SOM_avance_client = '10000.00';
        csvRecord.SAIS_COM_SOM_Solde_a_paye_CHF = '57000.00';
        
        return csvRecord;
    }
    
    /**
     * Creates a TrivisoProjetExport.CsvRecordDeserializer with custom values
     */
    public static TrivisoProjetExport.CsvRecordDeserializer createProjetCsvRecord(Map<String, Object> overrides) {
        TrivisoProjetExport.CsvRecordDeserializer csvRecord = createProjetCsvRecord();
        
        if (overrides != null) {
            if (overrides.containsKey('SAIS_COM_ID')) csvRecord.SAIS_COM_ID = (String)overrides.get('SAIS_COM_ID');
            if (overrides.containsKey('SAIS_COM_Identification')) csvRecord.SAIS_COM_Identification = (String)overrides.get('SAIS_COM_Identification');
            if (overrides.containsKey('SAIS_COM_Description')) csvRecord.SAIS_COM_Description = (String)overrides.get('SAIS_COM_Description');
            if (overrides.containsKey('SAIS_COM_No_Comm_client')) csvRecord.SAIS_COM_No_Comm_client = (String)overrides.get('SAIS_COM_No_Comm_client');
            if (overrides.containsKey('SAIS_COM_Etat_ID')) csvRecord.SAIS_COM_Etat_ID = (String)overrides.get('SAIS_COM_Etat_ID');
            if (overrides.containsKey('SAIS_COM_Genre_projet')) csvRecord.SAIS_COM_Genre_projet = (String)overrides.get('SAIS_COM_Genre_projet');
            if (overrides.containsKey('SAIS_COM_Fam_Designation')) csvRecord.SAIS_COM_Fam_Designation = (String)overrides.get('SAIS_COM_Fam_Designation');
            if (overrides.containsKey('SAIS_COM_Date_ouvert')) csvRecord.SAIS_COM_Date_ouvert = (String)overrides.get('SAIS_COM_Date_ouvert');
            if (overrides.containsKey('SAIS_COM_Date_Modif')) csvRecord.SAIS_COM_Date_Modif = (String)overrides.get('SAIS_COM_Date_Modif');
            if (overrides.containsKey('SAIS_COM_ADR_FACT_ID')) csvRecord.SAIS_COM_ADR_FACT_ID = (String)overrides.get('SAIS_COM_ADR_FACT_ID');
            if (overrides.containsKey('SAIS_COM_ADR_LIVR_ID')) csvRecord.SAIS_COM_ADR_LIVR_ID = (String)overrides.get('SAIS_COM_ADR_LIVR_ID');
            if (overrides.containsKey('SAIS_COM_ADR_MO_ID')) csvRecord.SAIS_COM_ADR_MO_ID = (String)overrides.get('SAIS_COM_ADR_MO_ID');
            if (overrides.containsKey('SAIS_COM_ADR_ARCH_ID')) csvRecord.SAIS_COM_ADR_ARCH_ID = (String)overrides.get('SAIS_COM_ADR_ARCH_ID');
            if (overrides.containsKey('SAIS_COM_ADR_RESP_ID')) csvRecord.SAIS_COM_ADR_RESP_ID = (String)overrides.get('SAIS_COM_ADR_RESP_ID');
            if (overrides.containsKey('SAIS_COM_ADR_MAND_ID')) csvRecord.SAIS_COM_ADR_MAND_ID = (String)overrides.get('SAIS_COM_ADR_MAND_ID');
            if (overrides.containsKey('SAIS_COM_ADR_RESP_PROJ_ID')) csvRecord.SAIS_COM_ADR_RESP_PROJ_ID = (String)overrides.get('SAIS_COM_ADR_RESP_PROJ_ID');
            if (overrides.containsKey('SAIS_COM_ADR_FACT_CONTACT_ID')) csvRecord.SAIS_COM_ADR_FACT_CONTACT_ID = (String)overrides.get('SAIS_COM_ADR_FACT_CONTACT_ID');
            if (overrides.containsKey('SAIS_COM_ADR_LIVR_CONTACT_ID')) csvRecord.SAIS_COM_ADR_LIVR_CONTACT_ID = (String)overrides.get('SAIS_COM_ADR_LIVR_CONTACT_ID');
            if (overrides.containsKey('SAIS_COM_ADR_MO_CONTACT_ID')) csvRecord.SAIS_COM_ADR_MO_CONTACT_ID = (String)overrides.get('SAIS_COM_ADR_MO_CONTACT_ID');
            if (overrides.containsKey('SAIS_COM_ADR_ARCH_CONTACT_ID')) csvRecord.SAIS_COM_ADR_ARCH_CONTACT_ID = (String)overrides.get('SAIS_COM_ADR_ARCH_CONTACT_ID');
            if (overrides.containsKey('SAIS_COM_SOM_Prix_revient_sans_provision')) csvRecord.SAIS_COM_SOM_Prix_revient_sans_provision = (String)overrides.get('SAIS_COM_SOM_Prix_revient_sans_provision');
            if (overrides.containsKey('SAIS_COM_SOM_Prix_revient')) csvRecord.SAIS_COM_SOM_Prix_revient = (String)overrides.get('SAIS_COM_SOM_Prix_revient');
            if (overrides.containsKey('SAIS_COM_SOM_Offert')) csvRecord.SAIS_COM_SOM_Offert = (String)overrides.get('SAIS_COM_SOM_Offert');
            if (overrides.containsKey('SAIS_COM_SOM_Confirme')) csvRecord.SAIS_COM_SOM_Confirme = (String)overrides.get('SAIS_COM_SOM_Confirme');
            if (overrides.containsKey('SAIS_COM_SOM_Correction_Confirme')) csvRecord.SAIS_COM_SOM_Correction_Confirme = (String)overrides.get('SAIS_COM_SOM_Correction_Confirme');
            if (overrides.containsKey('SAIS_COM_SOM_Facture')) csvRecord.SAIS_COM_SOM_Facture = (String)overrides.get('SAIS_COM_SOM_Facture');
            if (overrides.containsKey('SAIS_COM_SOM_Paye')) csvRecord.SAIS_COM_SOM_Paye = (String)overrides.get('SAIS_COM_SOM_Paye');
            if (overrides.containsKey('SAIS_COM_SOM_DAC')) csvRecord.SAIS_COM_SOM_DAC = (String)overrides.get('SAIS_COM_SOM_DAC');
            if (overrides.containsKey('SAIS_COM_SOM_potentiel_facturation')) csvRecord.SAIS_COM_SOM_potentiel_facturation = (String)overrides.get('SAIS_COM_SOM_potentiel_facturation');
            if (overrides.containsKey('SAIS_COM_SOM_avance_client')) csvRecord.SAIS_COM_SOM_avance_client = (String)overrides.get('SAIS_COM_SOM_avance_client');
            if (overrides.containsKey('SAIS_COM_SOM_Solde_a_paye_CHF')) csvRecord.SAIS_COM_SOM_Solde_a_paye_CHF = (String)overrides.get('SAIS_COM_SOM_Solde_a_paye_CHF');
        }
        
        return csvRecord;
    }
    
    /**
     * Creates a list of TrivisoProjetExport.CsvRecordDeserializer objects
     */
    public static List<TrivisoProjetExport.CsvRecordDeserializer> createProjetCsvRecords(Integer count) {
        List<TrivisoProjetExport.CsvRecordDeserializer> csvRecords = new List<TrivisoProjetExport.CsvRecordDeserializer>();
        for (Integer i = 0; i < count; i++) {
            TrivisoProjetExport.CsvRecordDeserializer csvRecord = createProjetCsvRecord();
            csvRecord.SAIS_COM_ID = 'PROJ_' + String.valueOf(i + 1);
            csvRecord.SAIS_COM_Identification = 'NUM-' + String.valueOf(i + 1);
            csvRecord.SAIS_COM_Description = 'Projet Test ' + String.valueOf(i + 1);
            csvRecords.add(csvRecord);
        }
        return csvRecords;
    }
    
    // ============================================
    // Proxy_Address__c Factory Methods
    // ============================================
    
    /**
     * Creates a Proxy_Address__c SObject (not inserted) with all fields populated
     */
    public static Proxy_Address__c createProxyAddress() {
        Proxy_Address__c address = new Proxy_Address__c();
        
        address.ADRES_Tag__c = 'TEST_TAG';
        address.ADRES_ID__c = 'ADRES_' + String.valueOf(Crypto.getRandomLong());
        address.ADRES_Organisation_Identif__c = 'ORG_' + String.valueOf(Crypto.getRandomLong());
        address.ADRES_Identification__c = 'IDENT_' + String.valueOf(Crypto.getRandomLong());
        address.ADRES_Date_creation__c = Datetime.newInstance(2024, 1, 1, 10, 0, 0);
        address.ADRES_Date_modif__c = Datetime.newInstance(2024, 6, 15, 14, 30, 0);
        address.ADRES_Date_inactive__c = null;
        address.ADRES_Nom__c = 'Dupont';
        address.ADRES_Prenom__c = 'Jean';
        address.ADRES_Supplement__c = 'Bâtiment A';
        address.ADRES_Case_postale__c = '1234';
        address.ADRES_Rue__c = 'Rue de la Paix 10';
        address.ADRES_Telephone1__c = '+41 21 123 45 67';
        address.ADRES_Telephone2__c = '+41 21 123 45 68';
        address.ADRES_Telephone3__c = null;
        address.ADRES_Natel1__c = '+41 79 123 45 67';
        address.ADRES_Natel2__c = null;
        address.ADRES_Email__c = 'jean.dupont@example.com';
        address.ADRES_Email2__c = 'jean.dupont.alt@example.com';
        address.ADRES_Site_Web__c = 'https://www.example.com';
        address.ADRES_entete__c = 'Monsieur';
        address.ADRES_ID_entete__c = 'ENT-001';
        address.ADRES_TVA_intracom__c = 'CHE-123.456.789';
        address.ADRES_No_registre_commerce__c = 'CH-123.456.789';
        address.ADRES_NPL__c = '1000';
        address.ADRES_Lieu__c = 'Lausanne';
        address.ADRES_PAYS_Description__c = 'Suisse';
        address.ADRES_PAYS_Identification__c = 'CH';
        address.ADRES_Titre__c = 'Ingénieur';
        address.ADRES_Departement__c = 'VD';
        address.ADRES_Langue__c = 'FR';
        address.ADRES_No_EORI__c = 'CH123456789';
        address.Statut__c = 'Reçu';
        address.Date_Reception__c = Datetime.now();
        address.Source__c = 'Triviso';
        
        return address;
    }
    
    /**
     * Creates a Proxy_Address__c SObject with custom values
     */
    public static Proxy_Address__c createProxyAddress(Map<String, Object> overrides) {
        Proxy_Address__c address = createProxyAddress();
        
        if (overrides != null) {
            for (String field : overrides.keySet()) {
                address.put(field, overrides.get(field));
            }
        }
        
        return address;
    }
    
    /**
     * Creates and inserts a Proxy_Address__c record
     */
    public static Proxy_Address__c createProxyAddress(Boolean doInsert) {
        Proxy_Address__c address = createProxyAddress();
        if (doInsert) {
            insert address;
        }
        return address;
    }
    
    /**
     * Creates and inserts a list of Proxy_Address__c records
     */
    public static List<Proxy_Address__c> createProxyAddresses(Integer count, Boolean doInsert) {
        List<Proxy_Address__c> addresses = new List<Proxy_Address__c>();
        for (Integer i = 0; i < count; i++) {
            Proxy_Address__c address = createProxyAddress();
            address.ADRES_ID__c = 'ADRES_' + String.valueOf(i + 1);
            address.ADRES_Nom__c = 'Nom_' + String.valueOf(i + 1);
            address.ADRES_Prenom__c = 'Prenom_' + String.valueOf(i + 1);
            addresses.add(address);
        }
        if (doInsert && addresses.size() > 0) {
            insert addresses;
        }
        return addresses;
    }
    
    // ============================================
    // Proxy_Projet__c Factory Methods
    // ============================================
    
    /**
     * Creates a Proxy_Projet__c SObject (not inserted) with all fields populated
     */
    public static Proxy_Projet__c createProxyProjet() {
        Proxy_Projet__c projet = new Proxy_Projet__c();
        
        projet.ID_Projet_Triviso__c = 'PROJ_' + String.valueOf(Crypto.getRandomLong());
        projet.Numero_Projet__c = 'NUM-' + String.valueOf(Crypto.getRandomLong());
        projet.Nom_Projet__c = 'Projet Test';
        projet.Reference_Client__c = 'REF-' + String.valueOf(Crypto.getRandomLong());
        projet.ID_Etape_Projet__c = 'ETAPE_1';
        projet.Genre_Projet__c = 'Construction';
        projet.Famille_Commerciale__c = 'Famille Test';
        projet.Date_Ouverture_Projet__c = Date.newInstance(2024, 1, 1);
        projet.Date_Derniere_Modification__c = Date.newInstance(2024, 6, 15);
        projet.Compte_Facturation_Triviso_ID__c = 'ADRES_FACT_1';
        projet.Compte_Livraison_Triviso_ID__c = 'ADRES_LIVR_1';
        projet.Compte_Maitre_Ouvrage_Triviso_ID__c = 'ADRES_MO_1';
        projet.Compte_Architecte_Triviso_ID__c = 'ADRES_ARCH_1';
        projet.Facturation_Contact__c = 'CONT_FACT_1';
        projet.Adresse_de_Livraison_2__c = 'CONT_LIVR_1';
        projet.Maitre_d_ouvrage_Contact__c = 'CONT_MO_1';
        projet.Architecte_EG_Contact__c = 'CONT_ARCH_1';
        projet.Compte_Responsable_Commercial_Triviso_ID__c = 'ADRES_RESP_1';
        projet.Compte_Mandant_Triviso_ID__c = 'ADRES_MAND_1';
        projet.Compte_Responsable_Projet_Triviso_ID__c = 'ADRES_RESP_PROJ_1';
        projet.Montant_Net_Sans_Provision__c = 100000.00;
        projet.Montant_Net_Avec_Provision__c = 110000.00;
        projet.Montant_Offert__c = 105000.00;
        projet.Montant_Confirme__c = 108000.00;
        projet.Montant_Correction_Confirme__c = 109000.00;
        projet.Montant_Facture__c = 107000.00;
        projet.Montant_Paye__c = 50000.00;
        projet.Montant_DAC__c = 2000.00;
        projet.Potentiel_Facturation__c = 120000.00;
        projet.Avance_Client__c = 10000.00;
        projet.Solde_Client_A_Payer_CHF__c = 57000.00;
        projet.Statut__c = 'Reçu';
        projet.Date_Reception__c = Datetime.now();
        projet.Source__c = 'Triviso';
        
        return projet;
    }
    
    /**
     * Creates a Proxy_Projet__c SObject with custom values
     */
    public static Proxy_Projet__c createProxyProjet(Map<String, Object> overrides) {
        Proxy_Projet__c projet = createProxyProjet();
        
        if (overrides != null) {
            for (String field : overrides.keySet()) {
                projet.put(field, overrides.get(field));
            }
        }
        
        return projet;
    }
    
    /**
     * Creates and inserts a Proxy_Projet__c record
     */
    public static Proxy_Projet__c createProxyProjet(Boolean doInsert) {
        Proxy_Projet__c projet = createProxyProjet();
        if (doInsert) {
            insert projet;
        }
        return projet;
    }
    
    /**
     * Creates and inserts a list of Proxy_Projet__c records
     */
    public static List<Proxy_Projet__c> createProxyProjets(Integer count, Boolean doInsert) {
        List<Proxy_Projet__c> projets = new List<Proxy_Projet__c>();
        for (Integer i = 0; i < count; i++) {
            Proxy_Projet__c projet = createProxyProjet();
            projet.ID_Projet_Triviso__c = 'PROJ_' + String.valueOf(i + 1);
            projet.Numero_Projet__c = 'NUM-' + String.valueOf(i + 1);
            projet.Nom_Projet__c = 'Projet Test ' + String.valueOf(i + 1);
            projets.add(projet);
        }
        if (doInsert && projets.size() > 0) {
            insert projets;
        }
        return projets;
    }
}