public class TrivisoAccountMapper {

    // Genre_de_client__c des comptes personnels (record type PersonAccount), en minuscules
    // pour comparaison avec le genre normalisé. Anciennement 'compte_personne'.
    private static final String GENRE_PRIVE = 'privé';

    public static List<TrivisoAccountRecord> mapAccountsToTrivisoRecords(List<Account> accounts) {
        List<TrivisoAccountRecord> trivisoRecords = new List<TrivisoAccountRecord>();
        
        if (accounts == null || accounts.isEmpty()) {
            System.debug('TRIVISO_LOG: No accounts to map');
            return trivisoRecords;
        }

        Set<Id> personReportsToIds = new Set<Id>();
        for (Account acc : accounts) {
            String genre = acc.Genre_de_client__c != null ? acc.Genre_de_client__c.trim().toLowerCase() : null;
            Id personReportsToId = getPersonReportsToId(acc);
            if (genre == GENRE_PRIVE && personReportsToId != null) {
                personReportsToIds.add(personReportsToId);
            }
        }

        Map<Id, Contact> reportsToContactsById = new Map<Id, Contact>();
        if (!personReportsToIds.isEmpty()) {
            for (Contact reportsToContact : [
                SELECT Id, Identification__c
                FROM Contact
                WHERE Id IN :personReportsToIds
            ]) {
                reportsToContactsById.put(reportsToContact.Id, reportsToContact);
            }
        }
        
        System.debug('TRIVISO_LOG: Mapping ' + accounts.size() + ' Accounts to TrivisoAccountRecord for export');
        
        for (Account acc : accounts) {
            TrivisoAccountRecord record = mapFromAccount(acc, reportsToContactsById);
            trivisoRecords.add(record);
        }
        
        System.debug('TRIVISO_LOG: Mapped ' + trivisoRecords.size() + ' Accounts to TrivisoAccountRecord');
        
        return trivisoRecords;
    }
    
    public static TrivisoAccountRecord mapFromAccount(Account account) {
        return mapFromAccount(account, null);
    }

    private static TrivisoAccountRecord mapFromAccount(Account account, Map<Id, Contact> reportsToContactsById) {
        TrivisoAccountRecord record = new TrivisoAccountRecord();
        String genre = account.Genre_de_client__c != null ? account.Genre_de_client__c.trim().toLowerCase() : null;
        
        // Champs alignés sur Proxy_Address__c pour cohérence XML
        record.adresTag = account.Genre_de_client__c;
        String adresIdPc = (String)account.get('ADRES_ID__pc');
        record.adresId = String.isNotBlank(adresIdPc) ? adresIdPc : account.ADRES_ID__c;
        if (genre == 'fournisseur' || genre == 'filiale' || genre == 'entreprise') {
            record.adresOrganisationIdentif = account.Parent != null && String.isNotBlank(account.Parent.Identification__c)
                ? account.Parent.Identification__c
                : null;
        } else if (genre == GENRE_PRIVE) {
            Id personReportsToId = getPersonReportsToId(account);
            Contact reportsToContact = reportsToContactsById != null ? reportsToContactsById.get(personReportsToId) : null;
            record.adresOrganisationIdentif = reportsToContact?.Identification__c;
        } else {
            record.adresOrganisationIdentif = null;
        }
        record.adresIdentification = account.Identification__c;
        record.adresDateCreation = account.CreatedDate != null ? formatDateTimeForExport(account.CreatedDate) : null;
        record.adresDateModif = account.LastModifiedDate != null ? formatDateTimeForExport(account.LastModifiedDate) : null;
        record.adresDateInactive = (account.Compte_Actif__c == true) ? null : (account.LastModifiedDate != null ? formatDateTimeForExport(account.LastModifiedDate) : null);
        if (genre == GENRE_PRIVE) {
            record.adresNom = account.LastName;
            record.adresPrenom = account.FirstName;
        } else {
            record.adresNom = account.Name;
            record.adresPrenom = account.Prenom__c;
        }
        record.adresSupplement = account.Supplement_adresse__c;
        record.adresCasePostale = account.Case_postale__c;
        record.adresRue = String.isNotBlank(account.Adresse_compte__Street__s) ? account.Adresse_compte__Street__s : account.BillingStreet;
        record.adresTelephone1 = account.Telephone_1__c;
        record.adresTelephone2 = account.Telephone_2__c;
        record.adresTelephone3 = account.Telephone_3__c;
        if (genre == 'entreprise' || genre == 'fournisseur' || genre == 'filiale') {
            record.adresNatel1 = account.Phone_2__c;
        } else {
            record.adresNatel1 = String.isNotBlank(account.PersonMobilePhone) ? account.PersonMobilePhone : account.Phone;
        }
        record.adresNatel2 = String.isNotBlank(account.Mobile_2__pc) ? account.Mobile_2__pc : account.Phone_2__c;
        record.adresEmail = account.Email_1__c;
        record.adresEmail2 = account.Email_2__c;
        record.adresSiteWeb = account.Website;
        record.adresEntete = String.isNotBlank(account.Ent_te__c) ? account.Ent_te__c : account.Salutation;
        // Comptes personnels : le champ remonte du Contact en __pc, sinon champ Account classique
        String idEntetePc = (String)account.get('ADRES_ID_entete_c__pc');
        record.adresIdEntete = String.isNotBlank(idEntetePc) ? idEntetePc : account.ADRES_ID_entete_c__c;
        record.adresTvaIntracom = String.isNotBlank(account.No_TVA_EU__c) ? account.No_TVA_EU__c : account.Numero_TVA__c;
        record.adresNoRegistreCommerce = account.Registre_commerce__c;
        record.adresNpl = String.isNotBlank(account.Adresse_compte__PostalCode__s) ? account.Adresse_compte__PostalCode__s : account.BillingPostalCode;
        record.adresLieu = String.isNotBlank(account.Adresse_compte__City__s) ? account.Adresse_compte__City__s : account.BillingCity;
        record.adresPaysDescription = String.isNotBlank(account.Adresse_compte__CountryCode__s) ? account.Adresse_compte__CountryCode__s : account.BillingCountry;
        record.adresPaysIdentification = record.adresPaysDescription; // Même source pour Account
        record.adresTitre = String.isNotBlank(account.PersonTitle) ? account.PersonTitle : null;
        record.adresDepartement = String.isNotBlank(account.PersonDepartment) ? account.PersonDepartment : null;
        String languePc = (String)account.get('Langue__pc');
        record.adresLangue = String.isNotBlank(languePc) ? languePc : account.Langue__c;
        record.adresNoEori = account.No_EORI__c;
        record.adresSalesforceId = account.Id;
        
        return record;
    }
    
    private static String formatDateTimeForExport(Datetime dt) {
        if (dt == null) return null;
        return dt.format('dd.MM.yyyy HH:mm:ss');
    }

    private static Id getPersonReportsToId(Account account) {
        try {
            return (Id)account.get('PersonReportsToId');
        } catch (Exception e) {
            return null;
        }
    }
    
    // Même mapping que Contact et Proxy_Address__c pour cohérence XML (Salesforce => XML)
    public static Map<String, String> mapToExportRecord(TrivisoAccountRecord record) {
        Map<String, String> exportRecord = new Map<String, String>();
        
        exportRecord.put('ADRES_Salesforce_Id', record.adresSalesforceId != null ? record.adresSalesforceId : '');
        exportRecord.put('ADRES_Tag', record.adresTag != null ? record.adresTag : '');
        exportRecord.put('ADRES_ID', record.adresId != null ? record.adresId : '');
        exportRecord.put('ADRES_Organisation_Identif', record.adresOrganisationIdentif != null ? record.adresOrganisationIdentif : '');
        exportRecord.put('ADRES_Identification', record.adresIdentification != null ? record.adresIdentification : '');
        exportRecord.put('ADRES_Date_creation', record.adresDateCreation != null ? record.adresDateCreation : '');
        exportRecord.put('ADRES_Date_modif', record.adresDateModif != null ? record.adresDateModif : '');
        exportRecord.put('ADRES_Date_inactive', record.adresDateInactive != null ? record.adresDateInactive : '');
        exportRecord.put('ADRES_Nom', record.adresNom != null ? record.adresNom : '');
        exportRecord.put('ADRES_Prenom', record.adresPrenom != null ? record.adresPrenom : '');
        exportRecord.put('ADRES_Supplement', record.adresSupplement != null ? record.adresSupplement : '');
        exportRecord.put('ADRES_Case_postale', record.adresCasePostale != null ? record.adresCasePostale : '');
        exportRecord.put('ADRES_Rue', record.adresRue != null ? record.adresRue : '');
        exportRecord.put('ADRES_Telephone1', record.adresTelephone1 != null ? record.adresTelephone1 : '');
        exportRecord.put('ADRES_Telephone2', record.adresTelephone2 != null ? record.adresTelephone2 : '');
        exportRecord.put('ADRES_Telephone3', record.adresTelephone3 != null ? record.adresTelephone3 : '');
        exportRecord.put('ADRES_Natel1', record.adresNatel1 != null ? record.adresNatel1 : '');
        exportRecord.put('ADRES_Natel2', record.adresNatel2 != null ? record.adresNatel2 : '');
        exportRecord.put('ADRES_Email', record.adresEmail != null ? record.adresEmail : '');
        exportRecord.put('ADRES_Email2', record.adresEmail2 != null ? record.adresEmail2 : '');
        exportRecord.put('ADRES_Site_Web', record.adresSiteWeb != null ? record.adresSiteWeb : '');
        exportRecord.put('ADRES_entete', record.adresEntete != null ? record.adresEntete : '');
        exportRecord.put('ADRES_ID_entete', record.adresIdEntete != null ? record.adresIdEntete : '');
        exportRecord.put('ADRES_TVA_intracom', record.adresTvaIntracom != null ? record.adresTvaIntracom : '');
        exportRecord.put('ADRES_No_registre_commerce', record.adresNoRegistreCommerce != null ? record.adresNoRegistreCommerce : '');
        exportRecord.put('ADRES_NPL', record.adresNpl != null ? record.adresNpl : '');
        exportRecord.put('ADRES_Lieu', record.adresLieu != null ? record.adresLieu : '');
        exportRecord.put('ADRES_PAYS_Description', record.adresPaysDescription != null ? record.adresPaysDescription : '');
        exportRecord.put('ADRES_PAYS_Identification', record.adresPaysIdentification != null ? record.adresPaysIdentification : '');
        exportRecord.put('ADRES_Titre', record.adresTitre != null ? record.adresTitre : '');
        exportRecord.put('ADRES_Departement', record.adresDepartement != null ? record.adresDepartement : '');
        exportRecord.put('ADRES_Langue', record.adresLangue != null ? record.adresLangue : '');
        exportRecord.put('ADRES_No_EORI', record.adresNoEori != null ? record.adresNoEori : '');
        
        return exportRecord;
    }
}