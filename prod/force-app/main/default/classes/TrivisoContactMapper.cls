public class TrivisoContactMapper {

    public static List<TrivisoContactRecord> mapContactsToTrivisoRecords(List<Contact> contacts) {
        List<TrivisoContactRecord> trivisoRecords = new List<TrivisoContactRecord>();
        
        if (contacts == null || contacts.isEmpty()) {
            System.debug('TRIVISO_LOG: No contacts to map');
            return trivisoRecords;
        }
        
        System.debug('TRIVISO_LOG: Mapping ' + contacts.size() + ' Contacts to TrivisoContactRecord for export');
        
        for (Contact cont : contacts) {
            TrivisoContactRecord record = mapFromContact(cont);
            trivisoRecords.add(record);
        }
        
        System.debug('TRIVISO_LOG: Mapped ' + trivisoRecords.size() + ' Contacts to TrivisoContactRecord');
        
        return trivisoRecords;
    }
    

    public static TrivisoContactRecord mapFromContact(Contact contact) {
        TrivisoContactRecord record = new TrivisoContactRecord();
        
        // Champs alignés sur Proxy_Address__c pour cohérence XML
        record.adresTag = contact.Genre_contact__c;
        record.adresId = contact.ADRES_ID__c;
        record.adresOrganisationIdentif = contact.Account != null && String.isNotBlank(contact.Account.Identification__c)
            ? contact.Account.Identification__c
            : null;
        record.adresIdentification = contact.Identification__c;
        record.adresDateCreation = contact.CreatedDate != null ? formatDateTimeForExport(contact.CreatedDate) : null;
        record.adresDateModif = contact.LastModifiedDate != null ? formatDateTimeForExport(contact.LastModifiedDate) : null;
        record.adresDateInactive = (contact.Contact_actif__c == true) ? null : (contact.LastModifiedDate != null ? formatDateTimeForExport(contact.LastModifiedDate) : null);
        record.adresNom = contact.LastName;
        record.adresPrenom = contact.FirstName;
        record.adresSupplement = contact.Supplement__c;
        record.adresCasePostale = contact.Case_postale__c;
        record.adresRue = String.isNotBlank(contact.Adresse_Contact__Street__s) ? contact.Adresse_Contact__Street__s : contact.MailingStreet;
        record.adresTelephone1 = contact.Telephone_1__c;
        record.adresTelephone2 = contact.Telephone_2__c;
        record.adresTelephone3 = contact.Telephone_3__c;
        record.adresNatel1 = contact.MobilePhone;
        record.adresNatel2 = contact.Mobile_2__c;
        record.adresEmail = contact.Email;
        record.adresEmail2 = contact.Email_2__c;
        record.adresSiteWeb = contact.SiteWeb__c;
        record.adresEntete = contact.Salutation;
        record.adresIdEntete = contact.ADRES_ID_entete_c__c;
        record.adresTvaIntracom = null;
        record.adresNoRegistreCommerce = null;
        record.adresNpl = String.isNotBlank(contact.Adresse_Contact__PostalCode__s) ? contact.Adresse_Contact__PostalCode__s : contact.MailingPostalCode;
        record.adresLieu = String.isNotBlank(contact.Adresse_Contact__City__s) ? contact.Adresse_Contact__City__s : contact.MailingCity;
        record.adresPaysDescription = String.isNotBlank(contact.Adresse_Contact__CountryCode__s) ? contact.Adresse_Contact__CountryCode__s : contact.MailingCountry;
        record.adresPaysIdentification = record.adresPaysDescription; // Même source pour Contact
        record.adresTitre = contact.Title;
        record.adresDepartement = contact.Department;
        record.adresLangue = contact.Langue__c;
        record.adresNoEori = null;
        record.adresSalesforceId = contact.Id;
        record.adresOrganSalesforceId = contact.AccountId;
        
        return record;
    }
    
    private static String formatDateTimeForExport(Datetime dt) {
        if (dt == null) return null;
        return dt.format('dd.MM.yyyy HH:mm:ss');
    }
    
    // Même mapping que Account et Proxy_Address__c pour cohérence XML (Salesforce => XML)
    public static Map<String, String> mapToExportRecord(TrivisoContactRecord record) {
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
        exportRecord.put('ADRES_Organ_salesforce_ID', record.adresOrganSalesforceId != null ? record.adresOrganSalesforceId : '');

        return exportRecord;
    }
}