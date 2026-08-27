public class TrivisoContact {

    public static List<Contact> getContacts() {
        List<Contact> contacts = [
            SELECT Id, Salutation, FirstName, LastName, Email, Email_2__c,
                   Telephone_1__c, Telephone_2__c, Telephone_3__c,
                   MobilePhone, Mobile_2__c,
                   MailingStreet, MailingCity, MailingPostalCode, MailingCountry,
                   Adresse_Contact__Street__s, Adresse_Contact__City__s,
                   Adresse_Contact__PostalCode__s, Adresse_Contact__CountryCode__s,
                   Title, Department, Identification__c, ADRES_ID__c, Langue__c, Genre_contact__c,
                   AccountId, Account.Identification__c,
                   Supplement__c, Case_postale__c, SiteWeb__c, ADRES_ID_entete_c__c,
                   Contact_actif__c, CreatedDate, LastModifiedDate
            FROM Contact
            WHERE Genre_contact__c != 'contact_employe' AND IsPersonAccount = false
        ];

        System.debug('TRIVISO_LOG: Found ' + contacts.size() + ' Contacts');

        return contacts;
    }

    public static List<TrivisoContactRecord> getContactsAsTrivisoRecords() {
        List<Contact> contacts = getContacts();
        return TrivisoContactMapper.mapContactsToTrivisoRecords(contacts);
    }

    public static List<Map<String, String>> getContactsForExport() {
        List<TrivisoContactRecord> trivisoRecords = getContactsAsTrivisoRecords();

        List<Map<String, String>> exportRecords = new List<Map<String, String>>();
        for (TrivisoContactRecord record : trivisoRecords) {
            Map<String, String> exportRecord = TrivisoContactMapper.mapToExportRecord(record);
            exportRecords.add(exportRecord);
        }

        System.debug('TRIVISO_LOG: Converted ' + exportRecords.size() + ' records to export format');

        return exportRecords;
    }

    public static List<Map<String, String>> getContactsForExportPage(String lastId, Integer pageSize, DateTime sinceDate) {
        String fields =
            'SELECT Id, Salutation, FirstName, LastName, Email, Email_2__c, ' +
            'Telephone_1__c, Telephone_2__c, Telephone_3__c, ' +
            'MobilePhone, Mobile_2__c, ' +
            'MailingStreet, MailingCity, MailingPostalCode, MailingCountry, ' +
            'Adresse_Contact__Street__s, Adresse_Contact__City__s, ' +
            'Adresse_Contact__PostalCode__s, Adresse_Contact__CountryCode__s, ' +
            'Title, Department, Identification__c, ADRES_ID__c, Langue__c, Genre_contact__c, ' +
            'AccountId, Account.Identification__c, ' +
            'Supplement__c, Case_postale__c, SiteWeb__c, ADRES_ID_entete_c__c, ' +
            'Contact_actif__c, CreatedDate, LastModifiedDate ' +
            'FROM Contact';

        List<String> conditions = new List<String>{'Genre_contact__c != \'contact_employe\'', 'IsPersonAccount = false'};
        if (String.isNotBlank(lastId)) {
            conditions.add('Id > :lastId');
        }
        if (sinceDate != null) {
            conditions.add('(CreatedDate >= :sinceDate OR LastModifiedDate >= :sinceDate)');
        }

        String query = fields + ' WHERE ' + String.join(conditions, ' AND ') + ' ORDER BY Id ASC LIMIT :pageSize';

        List<Contact> contacts = Database.query(query);

        System.debug('TRIVISO_LOG: Page query (lastId=' + lastId + ', sinceDate=' + sinceDate + ') returned ' + contacts.size() + ' contacts');

        List<TrivisoContactRecord> trivisoRecords = TrivisoContactMapper.mapContactsToTrivisoRecords(contacts);
        List<Map<String, String>> exportRecords = new List<Map<String, String>>();
        for (TrivisoContactRecord record : trivisoRecords) {
            exportRecords.add(TrivisoContactMapper.mapToExportRecord(record));
        }
        return exportRecords;
    }
}