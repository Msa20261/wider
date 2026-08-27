public class SimapUtils {

    public class SimapUtilsException extends Exception {}

    public static final Integer CUSTOM_FIELD_MAX_LENGTH = 225;
    public static final String ADDRESS_SEPARATOR = ', ';
    public static final Map<String, String> COUNTRY_LABELS = new Map<String, String> {
        'CH' => 'Suisse'
    };

    public static List<SObject> getSelectedCantonalEntities() {
        return [
            SELECT 
                Id,
                Name,
                simap_id__c,
                Abbreviation__c,
                inclus_dans_API_SIMAP__c
            FROM
                Simap_Cantons__c
            WHERE
                inclus_dans_API_SIMAP__c = true
            WITH USER_MODE
        ];
    }

    public static List<SObject> getSelectedProjectSubTypes() {
        return [
            SELECT
                Id,
                Name,
                Nom_API_param__c,
                inclus_dans_API_SIMAP__c
            FROM
                Simap_Type_de_Contrat__c
            WHERE
                inclus_dans_API_SIMAP__c = true
            WITH USER_MODE
        ];
    }

    public static List<Simap_Code_CPV__c> getSelectedSimapCodesCPV() {
        return [
            SELECT
                Id,
                Name,
                Code_CPV__c,
                inclus_dans_API_SIMAP__c
            FROM
                Simap_Code_CPV__c
            WHERE
                inclus_dans_API_SIMAP__c = true
        ];
    }

    public static Simap_Code_CFC_BKP__c getDefaultCodeCfcBkp() {
        List<Simap_Code_CFC_BKP__c> codeCfcBkps = [
            SELECT
                Id,
                Code_CFC_BKP__c,
                inclus_dans_API_SIMAP__c
            FROM
                Simap_Code_CFC_BKP__c
            ];
        
        if (codeCfcBkps.isEmpty()) {
            throw new SimapUtilsException('No code CFC / BKP found. at least one record should be present');
        }

        if (codeCfcBkps.size() > 1) {
            throw new SimapUtilsException('Multiple code CFC / BKP found. only one record should be present');
        }

        return codeCfcBkps[0];
    }

    public static List<Simap_Type_de_Publication__c> getDefaultTypeDePublication() {
        return [
            SELECT
                Id,
                Name,
                inclus_dans_API_SIMAP__c,
                simap_value__c
            FROM
                Simap_Type_de_Publication__c
            WHERE
                inclus_dans_API_SIMAP__c = true
        ];
    }

    public static String checkAndTrimLength(String fieldValue) {
        if (fieldValue == null) {
            return null;
        }
        fieldValue = fieldValue.trim();
        return fieldValue.length() > CUSTOM_FIELD_MAX_LENGTH ? fieldValue.substring(0, CUSTOM_FIELD_MAX_LENGTH) : fieldValue;
    }

    public static String getValidField(SimapHeadersService.SimapSwissLangSet fieldMap) {
        if (fieldMap == null) {
            return '';
        }
        if (fieldMap.fr != null && fieldMap.fr != '') {
            return fieldMap.fr;
        } else if (fieldMap.de != null && fieldMap.de != '') {
            return fieldMap.de;
        } else if (fieldMap.it != null && fieldMap.it != '') {
            return fieldMap.it;
        } else if (fieldMap.en != null && fieldMap.en != '') {
            return fieldMap.en;
        } else {
            return null;
        }
    }

    public static String addressConverter(SimapPublicationDetailService.SimapAdress addr) {
        if (
            addr?.city == null ||
            addr?.postalCode == null ||
            addr?.street == null
        ) {
            return null;
        }
        String parsedAddress = '';

        String parsedStreet = getValidField(addr.street);
        String parsedCity = getValidField(addr.city);

        List<String> addressParts = new List<String> {
            parsedStreet,
            parsedCity,
            addr.cantonId,
            addr.countryId,
            addr.postalCode
        };

        for(String addressPart : addressParts) {
            if(!String.isBlank(addressPart) && addressPart != null) {
                parsedAddress += addressPart + ADDRESS_SEPARATOR;
            }
        }

        parsedAddress = parsedAddress.removeEnd(ADDRESS_SEPARATOR);
        return parsedAddress;
    }

    // the order address of the search payload has no street, so it is formatted
    // as 'postalCode city, cantonId, country' instead of going through addressConverter
    public static String orderAddressConverter(SimapHeadersService.SimapOrderAddress addr) {
        if (addr == null) {
            return null;
        }

        String locality = '';
        for (String localityPart : new List<String> { addr.postalCode, getValidField(addr.city) }) {
            if (!String.isBlank(localityPart)) {
                locality += localityPart + ' ';
            }
        }
        locality = locality.trim();

        String country = COUNTRY_LABELS.containsKey(addr.countryId)
            ? COUNTRY_LABELS.get(addr.countryId)
            : addr.countryId;

        String parsedAddress = '';
        for (String addressPart : new List<String> { locality, addr.cantonId, country }) {
            if (!String.isBlank(addressPart)) {
                parsedAddress += addressPart + ADDRESS_SEPARATOR;
            }
        }

        return checkAndTrimLength(parsedAddress.removeEnd(ADDRESS_SEPARATOR));
    }

    public static String getValidPublicationTitle(SimapHeadersService.PublicationDeserializer publication) {
        return checkAndTrimLength(getValidField(publication.title));
    }

    public static String getValidPublicationProcOfficeName(SimapHeadersService.PublicationDeserializer publication) {
        return checkAndTrimLength(getValidField(publication.procOfficeName));
    }

    public static String getValidCantonValue(SimapPublicationDetailService.ProjectInfo projectInfo) {
        if (projectInfo.procOfficeAddress?.cantonId != null) {
            String cantonName = getCantonNameByAbbreviation(projectInfo.procOfficeAddress.cantonId);
            if (cantonName != null) {
                return cantonName;
            }
        }
        if (projectInfo.procurementRecipientAddress?.cantonId != null) {
            String cantonName = getCantonNameByAbbreviation(projectInfo.procurementRecipientAddress.cantonId);
            if (cantonName != null) {
                return cantonName;
            }
        }
        if (projectInfo.offerAddress?.cantonId != null) {
            String cantonName = getCantonNameByAbbreviation(projectInfo.offerAddress.cantonId);
            if (cantonName != null) {
                return cantonName;
            }
        }

        return null;
    }

    public static String getCantonNameByAbbreviation(String cantonId) {
        List<SObject> simapCantonalEntities = SimapUtils.getSelectedCantonalEntities();
        for (SObject entity : simapCantonalEntities) {
            if ((String) entity.get('Abbreviation__c') == cantonId) {
                return (String) entity.get('Name');
            }
        }
        return null;
    }

}