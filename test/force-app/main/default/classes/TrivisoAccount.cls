public class TrivisoAccount {

    public static List<Account> getAccounts() {
        List<Account> accounts = [
            SELECT Id, Name, FirstName, LastName, ParentId, Parent.Identification__c,
                   BillingCity, BillingCountry, BillingPostalCode, BillingStreet,
                   Adresse_compte__Street__s, Adresse_compte__City__s,
                   Adresse_compte__PostalCode__s, Adresse_compte__CountryCode__s,
                   Case_postale__c, Email_1__c, Email_2__c,
                   No_EORI__c, Numero_TVA__c, No_TVA_EU__c, Phone, Phone_2__c,
                   Registre_commerce__c, Telephone_1__c, Telephone_2__c, Telephone_3__c,
                   Supplement_adresse__c, Prenom__c, Ent_te__c, Website, Identification__c, ADRES_ID__c, ADRES_ID__pc,
                   ADRES_ID_entete_c__c, ADRES_ID_entete_c__pc,
                   Langue__c, Langue__pc, Genre_de_client__c, Compte_Actif__c, CreatedDate, LastModifiedDate,
                   PersonMobilePhone, Mobile_2__pc, PersonTitle, PersonDepartment, Salutation, PersonReportsToId
            FROM Account
        ];

        System.debug('TRIVISO_LOG: Found ' + accounts.size() + ' Accounts');

        return accounts;
    }

    public static List<TrivisoAccountRecord> getAccountsAsTrivisoRecords() {
        List<Account> accounts = getAccounts();
        return TrivisoAccountMapper.mapAccountsToTrivisoRecords(accounts);
    }

    public static List<Map<String, String>> getAccountsForExport() {
        List<TrivisoAccountRecord> trivisoRecords = getAccountsAsTrivisoRecords();

        List<Map<String, String>> exportRecords = new List<Map<String, String>>();
        for (TrivisoAccountRecord record : trivisoRecords) {
            Map<String, String> exportRecord = TrivisoAccountMapper.mapToExportRecord(record);
            exportRecords.add(exportRecord);
        }

        System.debug('TRIVISO_LOG: Converted ' + exportRecords.size() + ' records to export format');

        return exportRecords;
    }

    // Pagination par curseur (Id > lastId) pour éviter la limite OFFSET=2000 de Salesforce
    public static List<Map<String, String>> getAccountsForExportPage(String lastId, Integer pageSize, DateTime sinceDate) {
        String fields =
            'SELECT Id, Name, FirstName, LastName, ParentId, Parent.Identification__c, ' +
            'BillingCity, BillingCountry, BillingPostalCode, BillingStreet, ' +
            'Adresse_compte__Street__s, Adresse_compte__City__s, ' +
            'Adresse_compte__PostalCode__s, Adresse_compte__CountryCode__s, ' +
            'Case_postale__c, Email_1__c, Email_2__c, ' +
            'No_EORI__c, Numero_TVA__c, No_TVA_EU__c, Phone, Phone_2__c, ' +
            'Registre_commerce__c, Telephone_1__c, Telephone_2__c, Telephone_3__c, ' +
            'Supplement_adresse__c, Prenom__c, Ent_te__c, Website, Identification__c, ADRES_ID__c, ADRES_ID__pc, ' +
            'ADRES_ID_entete_c__c, ADRES_ID_entete_c__pc, ' +
            'Langue__c, Langue__pc, Genre_de_client__c, Compte_Actif__c, CreatedDate, LastModifiedDate, ' +
            'PersonMobilePhone, Mobile_2__pc, PersonTitle, PersonDepartment, Salutation, PersonReportsToId ' +
            'FROM Account';

        List<String> conditions = new List<String>();
        if (String.isNotBlank(lastId)) {
            conditions.add('Id > :lastId');
        }
        if (sinceDate != null) {
            conditions.add('(CreatedDate >= :sinceDate OR LastModifiedDate >= :sinceDate)');
        }

        String query = fields;
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        query += ' ORDER BY Id ASC LIMIT :pageSize';

        List<Account> accounts = Database.query(query);

        System.debug('TRIVISO_LOG: Page query (lastId=' + lastId + ', sinceDate=' + sinceDate + ') returned ' + accounts.size() + ' accounts');

        List<TrivisoAccountRecord> trivisoRecords = TrivisoAccountMapper.mapAccountsToTrivisoRecords(accounts);
        List<Map<String, String>> exportRecords = new List<Map<String, String>>();
        for (TrivisoAccountRecord record : trivisoRecords) {
            exportRecords.add(TrivisoAccountMapper.mapToExportRecord(record));
        }
        return exportRecords;
    }
}