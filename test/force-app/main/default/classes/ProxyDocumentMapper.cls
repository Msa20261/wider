public class ProxyDocumentMapper {
    
    public static Proxy_Document__c mapToProxyDocument(TrivisoDocumentExport.CsvRecordDeserializer csvRecord) {
        Proxy_Document__c document = new Proxy_Document__c();
        
        document.ID_Journal_commande__c = csvRecord.ID_Journal_commande;
        document.ID_Saisie_commande__c = csvRecord.ID_Saisie_commande;
        document.DOC_Projet_ID__c = csvRecord.DOC_Projet_ID;
        document.DOC_No_ref__c = csvRecord.DOC_No_ref;
        document.DOC_Lien_doc__c = csvRecord.DOC_Lien_doc;
        
        if (String.isNotBlank(csvRecord.DOC_Date_creation)) {
            Date parsedDate = parseDate(csvRecord.DOC_Date_creation);
            document.DOC_Date_creation__c = parsedDate;
        }
        
        if (String.isNotBlank(csvRecord.DOC_Date_modif)) {
            Date parsedDate = parseDate(csvRecord.DOC_Date_modif);
            document.DOC_Date_modif__c = parsedDate;
        }
        
        document.DOC_Identification__c = csvRecord.DOC_Identification;
        document.DOC_Description__c = csvRecord.DOC_Description;
        document.DOC_Paye_TTC__c = parseDecimal(csvRecord.DOC_Paye_TTC);
        document.DOC_Montant_HT__c = parseDecimal(csvRecord.DOC_Montant_HT);
        document.DOC_Montant_TTC__c = parseDecimal(csvRecord.DOC_Montant_TTC);
        document.DOC_Brouillon__c = parseDecimal(csvRecord.DOC_Brouillon);
        
        if (String.isNotBlank(csvRecord.DOC_DEB_Date_creation)) {
            Date parsedDate = parseDate(csvRecord.DOC_DEB_Date_creation);
            document.DOC_DEB_Date_creation__c = parsedDate;
        }
        
        document.DOC_DEB_Resp_creation__c = csvRecord.DOC_DEB_Resp_creation;
        document.DOC_DEB_Doc_suppr__c = parseDecimal(csvRecord.DOC_DEB_Doc_suppr);
        document.DOC_DEB_No_ecriture__c = csvRecord.DOC_DEB_No_ecriture;
        document.DOC_Genre_document__c = csvRecord.DOC_Genre_document;
        document.DOC_Condition_paiement__c = csvRecord.DOC_Condition_paiement;
        document.DOC_Etat_doc__c = csvRecord.DOC_Etat_doc;
        document.DOC_Etat_Pond__c = parseDecimal(csvRecord.DOC_Etat_Pond);
        document.DOC_Etat_Offert__c = csvRecord.DOC_Etat_Offert;
        document.DOC_Etat_Commande__c = csvRecord.DOC_Etat_Commande;
        document.DOC_Etat_Facture__c = csvRecord.DOC_Etat_Facture;
        document.DOC_DEB_Montant__c = parseDecimal(csvRecord.DOC_DEB_Montant);
        document.DOC_DEB_Monnaie__c = csvRecord.DOC_DEB_Monnaie;
        document.DOC_DEB_Solde_a_paye_CHF__c = parseDecimal(csvRecord.DOC_DEB_Solde_a_paye_CHF);
        document.DOC_DEB_Solde_a_paye_ME__c = parseDecimal(csvRecord.DOC_DEB_Solde_a_paye_ME);
        
        if (String.isNotBlank(csvRecord.DOC_DEB_Echeance_adapte)) {
            Date parsedDate = parseDate(csvRecord.DOC_DEB_Echeance_adapte);
            document.DOC_DEB_Echeance_adapte__c = parsedDate;
        }
        
        // L'ID adresse Triviso arrive paddé de zéros ("0000014278") et doit le rester :
        // c'est la forme stockée dans ADRES_ID__c. Aucune conversion numérique ici.
        document.DOC_ADR_DEST_ID__c = csvRecord.DOC_ADR_DEST_ID;
        document.DOC_ADR_DEST_Nom_Prenom__c = csvRecord.DOC_ADR_DEST_Nom_Prenom;
        
        return document;
    }
    
    private static Date parseDate(String dateStr) {
        if (String.isBlank(dateStr)) {
            return null;
        }
        
        try {
            String dateOnly = dateStr.trim();
            if (dateOnly.contains(' ')) {
                dateOnly = dateOnly.substring(0, dateOnly.indexOf(' '));
            }
            
            if (dateOnly.contains('/')) {
                List<String> parts = dateOnly.split('/');
                if (parts.size() == 3) {
                    String month = parts[0];
                    String day = parts[1];
                    String year = parts[2];
                    String isoDate = year + '-' + month + '-' + day;
                    return Date.valueOf(isoDate);
                }
            }
            
            if (dateOnly.contains('.')) {
                List<String> parts = dateOnly.split('\\.');
                if (parts.size() == 3) {
                    String day = parts[0];
                    String month = parts[1];
                    String year = parts[2];
                    String isoDate = year + '-' + month + '-' + day;
                    return Date.valueOf(isoDate);
                }
            }
            
            return Date.valueOf(dateStr);
        } catch (Exception e) {
            return null;
        }
    }
    
    private static Decimal parseDecimal(Object value) {
        if (value == null) {
            return null;
        }
        
        if (value instanceof Decimal) {
            return (Decimal)value;
        }
        
        if (value instanceof String) {
            String strValue = (String)value;
            if (String.isBlank(strValue)) {
                return null;
            }
            try {
                return Decimal.valueOf(strValue);
            } catch (Exception e) {
                return null;
            }
        }
        
        try {
            return Decimal.valueOf(String.valueOf(value));
        } catch (Exception e) {
            return null;
        }
    }
}