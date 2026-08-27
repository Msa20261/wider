public class AddressProxyMapper {
    
    private static Map<String, String> CSV_TO_SF_FIELD_MAPPING = new Map<String, String>{
        'ADRES_Tag' => 'ADRES_Tag__c',
        'ADRES_ID' => 'ADRESTriviso_ID__c',
        'ADRES_Organisation_Identif' => 'ADRES_Organisation_Identif__c',
        // ADRES_Identification => ADRES_ID__c ET ADRES_Identification__c (double mapping, voir mapToProxyAddress)
        'ADRES_Identification' => 'ADRES_Identification__c',
        'ADRES_Date_creation' => 'ADRES_Date_creation__c',
        'ADRES_Date_modif' => 'ADRES_Date_modif__c',
        'ADRES_Date_inactive' => 'ADRES_Date_inactive__c',
        'ADRES_Nom' => 'ADRES_Nom__c',
        'ADRES_Prenom' => 'ADRES_Prenom__c',
        'ADRES_Supplement' => 'ADRES_Supplement__c',
        'ADRES_Case_postale' => 'ADRES_Case_postale__c',
        'ADRES_Rue' => 'ADRES_Rue__c',
        'ADRES_Telephone1' => 'ADRES_Telephone1__c',
        'ADRES_Telephone2' => 'ADRES_Telephone2__c',
        'ADRES_Telephone3' => 'ADRES_Telephone3__c',
        'ADRES_Natel1' => 'ADRES_Natel1__c',
        'ADRES_Natel2' => 'ADRES_Natel2__c',
        'ADRES_Email' => 'ADRES_Email__c',
        'ADRES_Email2' => 'ADRES_Email2__c',
        'ADRES_Site_Web' => 'ADRES_Site_Web__c',
        'ADRES_entete' => 'ADRES_entete__c',
        'ADRES_ID_entete' => 'ADRES_ID_entete__c',
        'ADRES_TVA_intracom' => 'ADRES_TVA_intracom__c',
        'ADRES_No_registre_commerce' => 'ADRES_No_registre_commerce__c',
        'ADRES_NPL' => 'ADRES_NPL__c',
        'ADRES_Lieu' => 'ADRES_Lieu__c',
        'ADRES_PAYS_Description' => 'ADRES_PAYS_Description__c',
        'ADRES_PAYS_Identification' => 'ADRES_PAYS_Identification__c',
        'ADRES_Titre' => 'ADRES_Titre__c',
        'ADRES_Departement' => 'ADRES_Departement__c',
        'ADRES_Langue' => 'ADRES_Langue__c',
        'ADRES_No_EORI' => 'ADRES_No_EORI__c'
    };
    
    public static AddressProxyRecord mapFromCsvRecord(TrivisoAddressExport.CsvRecordDeserializer csvRecord) {
        AddressProxyRecord record = new AddressProxyRecord();
        
        System.debug('TRIVISO_LOG: Mapping CsvRecordDeserializer to AddressProxyRecord');
        System.debug('TRIVISO_LOG: csvRecord.ADRES_ID = ' + csvRecord.ADRES_ID);
        System.debug('TRIVISO_LOG: csvRecord.ADRES_Nom = ' + csvRecord.ADRES_Nom);
        
        record.adresTag = csvRecord.ADRES_Tag;
        record.adresId = csvRecord.ADRES_ID;
        record.adresOrganisationIdentif = csvRecord.ADRES_Organisation_Identif;
        record.adresIdentification = csvRecord.ADRES_Identification;
        record.adresDateCreation = csvRecord.ADRES_Date_creation;
        record.adresDateModif = csvRecord.ADRES_Date_modif;
        record.adresDateInactive = csvRecord.ADRES_Date_inactive;
        record.adresNom = csvRecord.ADRES_Nom;
        record.adresPrenom = csvRecord.ADRES_Prenom;
        record.adresSupplement = csvRecord.ADRES_Supplement;
        record.adresCasePostale = csvRecord.ADRES_Case_postale;
        record.adresRue = csvRecord.ADRES_Rue;
        record.adresTelephone1 = csvRecord.ADRES_Telephone1;
        record.adresTelephone2 = csvRecord.ADRES_Telephone2;
        record.adresTelephone3 = csvRecord.ADRES_Telephone3;
        record.adresNatel1 = csvRecord.ADRES_Natel1;
        record.adresNatel2 = csvRecord.ADRES_Natel2;
        record.adresEmail = csvRecord.ADRES_Email;
        record.adresEmail2 = csvRecord.ADRES_Email2;
        record.adresSiteWeb = csvRecord.ADRES_Site_Web;
        record.adresEntete = csvRecord.ADRES_entete;
        record.adresIdEntete = csvRecord.ADRES_ID_entete;
        record.adresTvaIntracom = csvRecord.ADRES_TVA_intracom;
        record.adresNoRegistreCommerce = csvRecord.ADRES_No_registre_commerce;
        record.adresNpl = csvRecord.ADRES_NPL;
        record.adresLieu = csvRecord.ADRES_Lieu;
        record.adresPaysDescription = csvRecord.ADRES_PAYS_Description;
        record.adresPaysIdentification = csvRecord.ADRES_PAYS_Identification;
        record.adresTitre = csvRecord.ADRES_Titre;
        record.adresDepartement = csvRecord.ADRES_Departement;
        record.adresLangue = csvRecord.ADRES_Langue;
        record.adresNoEori = csvRecord.ADRES_No_EORI;
        
        System.debug('TRIVISO_LOG: Mapped AddressProxyRecord: ' + JSON.serialize(record));
        
        return record;
    }
    
    public static Proxy_Address__c mapToProxyAddress(AddressProxyRecord record) {
        Proxy_Address__c address = new Proxy_Address__c();
        
        System.debug('TRIVISO_LOG: Mapping AddressProxyRecord to Proxy_Address__c');
        System.debug('TRIVISO_LOG: record.adresId = ' + record.adresId);
        System.debug('TRIVISO_LOG: record.adresNom = ' + record.adresNom);
        
        address.ADRES_Tag__c = record.adresTag;
        address.ADRESTriviso_ID__c = record.adresId;
        address.ADRES_ID__c = record.adresIdentification;
        address.ADRES_Organisation_Identif__c = record.adresOrganisationIdentif;
        address.ADRES_Identification__c = record.adresIdentification;
        
        if (String.isNotBlank(record.adresDateCreation)) {
            Datetime parsedDateTime = parseDateTime(record.adresDateCreation);
            address.ADRES_Date_creation__c = parsedDateTime;
        }
        
        if (String.isNotBlank(record.adresDateModif)) {
            Datetime parsedDateTime = parseDateTime(record.adresDateModif);
            address.ADRES_Date_modif__c = parsedDateTime;
        }
        
        address.ADRES_Date_inactive_2__c = !String.isNotBlank(record.adresDateInactive);
        if (!address.ADRES_Date_inactive_2__c) {
            Datetime parsedDateTime = parseDateTime(record.adresDateInactive);
            address.ADRES_Date_inactive__c = parsedDateTime;
        }
        
        address.ADRES_Nom__c = record.adresNom;
        address.ADRES_Prenom__c = record.adresPrenom;
        address.ADRES_Supplement__c = record.adresSupplement;
        address.ADRES_Case_postale__c = record.adresCasePostale;
        address.ADRES_Rue__c = record.adresRue;
        address.ADRES_Telephone1__c = record.adresTelephone1;
        address.ADRES_Telephone2__c = record.adresTelephone2;
        address.ADRES_Telephone3__c = record.adresTelephone3;
        address.ADRES_Natel1__c = record.adresNatel1;
        address.ADRES_Natel2__c = record.adresNatel2;
        address.ADRES_Email__c = record.adresEmail;
        address.ADRES_Email2__c = record.adresEmail2;
        address.ADRES_Site_Web__c = record.adresSiteWeb;
        address.ADRES_entete__c = record.adresEntete;
        address.ADRES_ID_entete__c = record.adresIdEntete;
        address.ADRES_TVA_intracom__c = record.adresTvaIntracom;
        address.ADRES_No_registre_commerce__c = record.adresNoRegistreCommerce;
        address.ADRES_NPL__c = record.adresNpl;
        address.ADRES_Lieu__c = record.adresLieu;
        address.ADRES_PAYS_Description__c = record.adresPaysDescription;
        address.ADRES_PAYS_Identification__c = record.adresPaysIdentification;
        address.ADRES_Titre__c = record.adresTitre;
        address.ADRES_Departement__c = record.adresDepartement;
        address.ADRES_Langue__c = record.adresLangue;
        address.ADRES_No_EORI__c = record.adresNoEori;
        
        address.Statut__c = 'Reçu';
        address.Date_Reception__c = Datetime.now();
        address.Source__c = 'Triviso';
        
        System.debug('TRIVISO_LOG: Final Proxy_Address__c object: ' + JSON.serialize(address));
        
        return address;
    }
    
    private static Datetime parseDateTime(String dateStr) {
        if (String.isBlank(dateStr)) {
            return null;
        }
        
        try {
            // Support format: "DD.MM.YYYY HH:MM:SS" or "DD.MM.YYYY"
            String dateTimeStr = dateStr.trim();
            String dateOnly = dateTimeStr;
            String timeOnly = '00:00:00';
            
            if (dateTimeStr.contains(' ')) {
                List<String> parts = dateTimeStr.split(' ', 2);
                dateOnly = parts[0];
                if (parts.size() > 1) {
                    timeOnly = parts[1];
                }
            }
            
            // Parse DD.MM.YYYY format
            if (dateOnly.contains('.')) {
                // Parse manually using indexOf for reliability (more robust than split)
                Integer firstDot = dateOnly.indexOf('.');
                Integer secondDot = dateOnly.indexOf('.', firstDot + 1);
                
                // Validate that we have two dots and can extract day, month, year
                // secondDot must be > -1 (found) and > firstDot and < length (not at the end)
                if (firstDot >= 0 && secondDot >= 0 && secondDot > firstDot && secondDot < dateOnly.length()) {
                    String day = dateOnly.substring(0, firstDot).trim();
                    String month = dateOnly.substring(firstDot + 1, secondDot).trim();
                    String year = dateOnly.substring(secondDot + 1).trim();
                    
                    // Ensure proper padding for day and month (adds security without changing behavior)
                    if (day.length() == 1) day = '0' + day;
                    if (month.length() == 1) month = '0' + month;
                    
                    // Parse time HH:MM:SS
                    List<String> timeParts = timeOnly.split(':');
                    String hour = timeParts.size() > 0 && String.isNotBlank(timeParts[0]) ? timeParts[0].trim() : '00';
                    String minute = timeParts.size() > 1 && String.isNotBlank(timeParts[1]) ? timeParts[1].trim() : '00';
                    String second = timeParts.size() > 2 && String.isNotBlank(timeParts[2]) ? timeParts[2].trim() : '00';
                    
                    // Ensure proper padding for time components (adds security without changing behavior)
                    if (hour.length() == 1) hour = '0' + hour;
                    if (minute.length() == 1) minute = '0' + minute;
                    if (second.length() == 1) second = '0' + second;
                    
                    // Convert to ISO format: YYYY-MM-DDTHH:MM:SS
                    String isoDateTime = year + '-' + month + '-' + day + 'T' + hour + ':' + minute + ':' + second;
                    try {
                        // Use Datetime.newInstance() for more reliable parsing
                        Integer yearInt = Integer.valueOf(year);
                        Integer monthInt = Integer.valueOf(month);
                        Integer dayInt = Integer.valueOf(day);
                        Integer hourInt = Integer.valueOf(hour);
                        Integer minuteInt = Integer.valueOf(minute);
                        Integer secondInt = Integer.valueOf(second);
                        
                        return Datetime.newInstance(yearInt, monthInt, dayInt, hourInt, minuteInt, secondInt);
                    } catch (Exception valueOfEx) {
                        // Fallback to valueOf
                        try {
                            return Datetime.valueOf(isoDateTime);
                        } catch (Exception e2) {
                            return null;
                        }
                    }
                }
            }
            
            // Try standard Datetime.valueOf for ISO format
            try {
                return Datetime.valueOf(dateStr);
            } catch (Exception e) {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
    }
    
    // Mapping inverse: Proxy_Address__c → Format CSV (pour export vers Triviso)
    public static Map<String, String> mapToCsvRecord(Proxy_Address__c address) {
        Map<String, String> csvRecord = new Map<String, String>();
        
        csvRecord.put('Salesforce_Id', String.valueOf(address.Id));
        csvRecord.put('ADRES_Tag', address.ADRES_Tag__c != null ? address.ADRES_Tag__c : '');
        csvRecord.put('ADRES_ID', address.ADRES_ID__c != null ? address.ADRES_ID__c : '');
        csvRecord.put('ADRES_Organisation_Identif', address.ADRES_Organisation_Identif__c != null ? address.ADRES_Organisation_Identif__c : '');
        csvRecord.put('ADRES_Identification', address.ADRES_Identification__c != null ? address.ADRES_Identification__c : '');
        
        // Format dates: Datetime → DD.MM.YYYY HH:MM:SS
        csvRecord.put('ADRES_Date_creation', formatDateTimeForCsv(address.ADRES_Date_creation__c));
        csvRecord.put('ADRES_Date_modif', formatDateTimeForCsv(address.ADRES_Date_modif__c));
        csvRecord.put('ADRES_Date_inactive', formatDateTimeForCsv(address.ADRES_Date_inactive__c));
        
        csvRecord.put('ADRES_Nom', address.ADRES_Nom__c != null ? address.ADRES_Nom__c : '');
        csvRecord.put('ADRES_Prenom', address.ADRES_Prenom__c != null ? address.ADRES_Prenom__c : '');
        csvRecord.put('ADRES_Supplement', address.ADRES_Supplement__c != null ? address.ADRES_Supplement__c : '');
        csvRecord.put('ADRES_Case_postale', address.ADRES_Case_postale__c != null ? address.ADRES_Case_postale__c : '');
        csvRecord.put('ADRES_Rue', address.ADRES_Rue__c != null ? address.ADRES_Rue__c : '');
        csvRecord.put('ADRES_Telephone1', address.ADRES_Telephone1__c != null ? address.ADRES_Telephone1__c : '');
        csvRecord.put('ADRES_Telephone2', address.ADRES_Telephone2__c != null ? address.ADRES_Telephone2__c : '');
        csvRecord.put('ADRES_Telephone3', address.ADRES_Telephone3__c != null ? address.ADRES_Telephone3__c : '');
        csvRecord.put('ADRES_Natel1', address.ADRES_Natel1__c != null ? address.ADRES_Natel1__c : '');
        csvRecord.put('ADRES_Natel2', address.ADRES_Natel2__c != null ? address.ADRES_Natel2__c : '');
        csvRecord.put('ADRES_Email', address.ADRES_Email__c != null ? address.ADRES_Email__c : '');
        csvRecord.put('ADRES_Email2', address.ADRES_Email2__c != null ? address.ADRES_Email2__c : '');
        csvRecord.put('ADRES_Site_Web', address.ADRES_Site_Web__c != null ? address.ADRES_Site_Web__c : '');
        csvRecord.put('ADRES_entete', address.ADRES_entete__c != null ? address.ADRES_entete__c : '');
        csvRecord.put('ADRES_TVA_intracom', address.ADRES_TVA_intracom__c != null ? address.ADRES_TVA_intracom__c : '');
        csvRecord.put('ADRES_No_registre_commerce', address.ADRES_No_registre_commerce__c != null ? address.ADRES_No_registre_commerce__c : '');
        csvRecord.put('ADRES_NPL', address.ADRES_NPL__c != null ? address.ADRES_NPL__c : '');
        csvRecord.put('ADRES_Lieu', address.ADRES_Lieu__c != null ? address.ADRES_Lieu__c : '');
        csvRecord.put('ADRES_PAYS_Description', address.ADRES_PAYS_Description__c != null ? address.ADRES_PAYS_Description__c : '');
        csvRecord.put('ADRES_PAYS_Identification', address.ADRES_PAYS_Identification__c != null ? address.ADRES_PAYS_Identification__c : '');
        csvRecord.put('ADRES_Titre', address.ADRES_Titre__c != null ? address.ADRES_Titre__c : '');
        csvRecord.put('ADRES_Departement', address.ADRES_Departement__c != null ? address.ADRES_Departement__c : '');
        csvRecord.put('ADRES_Langue', address.ADRES_Langue__c != null ? address.ADRES_Langue__c : '');
        csvRecord.put('ADRES_No_EORI', address.ADRES_No_EORI__c != null ? address.ADRES_No_EORI__c : '');
        
        return csvRecord;
    }
    
    private static String formatDateTimeForCsv(Datetime dateTimeValue) {
        if (dateTimeValue == null) {
            return '';
        }
        // Format: DD.MM.YYYY HH:MM:SS
        Integer dayInt = dateTimeValue.day();
        Integer monthInt = dateTimeValue.month();
        Integer yearInt = dateTimeValue.year();
        Integer hourInt = dateTimeValue.hour();
        Integer minuteInt = dateTimeValue.minute();
        Integer secondInt = dateTimeValue.second();
        
        String day = dayInt < 10 ? '0' + String.valueOf(dayInt) : String.valueOf(dayInt);
        String month = monthInt < 10 ? '0' + String.valueOf(monthInt) : String.valueOf(monthInt);
        String year = String.valueOf(yearInt);
        String hour = hourInt < 10 ? '0' + String.valueOf(hourInt) : String.valueOf(hourInt);
        String minute = minuteInt < 10 ? '0' + String.valueOf(minuteInt) : String.valueOf(minuteInt);
        String second = secondInt < 10 ? '0' + String.valueOf(secondInt) : String.valueOf(secondInt);
        
        return day + '.' + month + '.' + year + ' ' + hour + ':' + minute + ':' + second;
    }
}