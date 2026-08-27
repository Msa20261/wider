public class ProjetProxyMapper {
    
    private static Map<String, String> CSV_TO_SF_FIELD_MAPPING = new Map<String, String>{
        'SAIS_COM_ID' => 'ID_Projet_Triviso__c',
        'SAIS_COM_Identification' => 'Numero_Projet__c',
        'SAIS_COM_Description' => 'Nom_Projet__c',
        'SAIS_COM_No_Comm_client' => 'Reference_Client__c',
        'SAIS_COM_Etat_ID' => 'ID_Etape_Projet__c',
        'SAIS_COM_Genre_projet' => 'Genre_Projet__c',
        'SAIS_COM_Fam_Désignation' => 'Famille_Commerciale__c',
        'SAIS_COM_Date_ouvert' => 'Date_Ouverture_Projet__c',
        'SAIS_COM_Date_Modif' => 'Date_Derniere_Modification__c',
        'SAIS_COM_ADR_FACT_ID' => 'Compte_Facturation_Triviso_ID__c',
        'SAIS_COM_ADR_LIVR_ID' => 'Compte_Livraison_Triviso_ID__c',
        'SAIS_COM_ADR_MO_ID' => 'Compte_Maitre_Ouvrage_Triviso_ID__c',
        'SAIS_COM_ADR_ARCH_ID' => 'Compte_Architecte_Triviso_ID__c',
        'SAIS_COM_ADR_FACT_CONTACT_ID' => 'Facturation_Contact__c',
        'SAIS_COM_ADR_LIVR_CONTACT_ID' => 'Adresse_de_Livraison_2__c',
        'SAIS_COM_ADR_MO_CONTACT_ID' => 'Maitre_d_ouvrage_Contact__c',
        'SAIS_COM_ADR_ARCH_CONTACT_ID' => 'Architecte_EG_Contact__c',
        'SAIS_COM_ADR_RESP_ID' => 'Compte_Responsable_Commercial_Triviso_ID__c',
        'SAIS_COM_ADR_MAND_ID' => 'Compte_Mandant_Triviso_ID__c',
        'SAIS_COM_ADR_RESP_PROJ_ID' => 'Compte_Responsable_Projet_Triviso_ID__c',
        'SAIS_COM_ADR_COMPTE_ID' => 'SAIS_COM_ADR_COMPTE_ID__c',
        'SAIS_COM_SOM_Prix_revient_sans_provision' => 'Montant_Net_Sans_Provision__c',
        'SAIS_COM_SOM_Prix_revient' => 'Montant_Net_Avec_Provision__c',
        'SAIS_COM_SOM_Offert' => 'Montant_Offert__c',
        'SAIS_COM_SOM_Confirmé' => 'Montant_Confirme__c',
        'SAIS_COM_SOM_Correction_Confirmé' => 'Montant_Correction_Confirme__c',
        'SAIS_COM_SOM_Facturé' => 'Montant_Facture__c',
        'SAIS_COM_SOM_Payé' => 'Montant_Paye__c',
        'SAIS_COM_SOM_DAC' => 'Montant_DAC__c',
        'SAIS_COM_SOM_potentiel_facturation' => 'Potentiel_Facturation__c',
        'SAIS_COM_SOM_avance_client' => 'Avance_Client__c',
        'SAIS_COM_SOM_Solde_a_paye_CHF' => 'Solde_Client_A_Payer_CHF__c'
    };
    
    // Method for TrivisoProjetExport.CsvRecordDeserializer
    public static ProjetProxyRecord mapFromCsvRecord(TrivisoProjetExport.CsvRecordDeserializer csvRecord) {
        ProjetProxyRecord record = new ProjetProxyRecord();
        
        System.debug('TRIVISO_LOG: Mapping TrivisoProjetExport.CsvRecordDeserializer to ProjetProxyRecord');
        System.debug('TRIVISO_LOG: csvRecord.SAIS_COM_ID = ' + csvRecord.SAIS_COM_ID);
        System.debug('TRIVISO_LOG: csvRecord.SAIS_COM_Identification = ' + csvRecord.SAIS_COM_Identification);
        System.debug('TRIVISO_LOG: csvRecord.SAIS_COM_Description = ' + csvRecord.SAIS_COM_Description);
        System.debug('TRIVISO_LOG: csvRecord.SAIS_COM_Fam_Designation = ' + csvRecord.SAIS_COM_Fam_Designation);
        System.debug('TRIVISO_LOG: csvRecord.SAIS_COM_SOM_Prix_revient = ' + csvRecord.SAIS_COM_SOM_Prix_revient);
        
        record.idProjetTriviso = csvRecord.SAIS_COM_ID;
        record.numeroProjet = csvRecord.SAIS_COM_Identification;
        record.nomProjet = csvRecord.SAIS_COM_Description;
        record.referenceClient = csvRecord.SAIS_COM_No_Comm_client;
        record.idEtapeProjet = csvRecord.SAIS_COM_Etat_ID;
        record.genreProjet = csvRecord.SAIS_COM_Genre_projet;
        record.familleCommerciale = csvRecord.SAIS_COM_Fam_Designation != null ? csvRecord.SAIS_COM_Fam_Designation : '';
        record.dateOuvertureProjet = csvRecord.SAIS_COM_Date_ouvert;
        record.dateDerniereModification = csvRecord.SAIS_COM_Date_Modif;
        record.compteFacturationTrivisoId = csvRecord.SAIS_COM_ADR_FACT_ID;
        record.compteLivraisonTrivisoId = csvRecord.SAIS_COM_ADR_LIVR_ID;
        record.compteMaitreOuvrageTrivisoId = csvRecord.SAIS_COM_ADR_MO_ID;
        record.compteArchitecteTrivisoId = csvRecord.SAIS_COM_ADR_ARCH_ID;
        record.facturationContactId = csvRecord.SAIS_COM_ADR_FACT_CONTACT_ID;
        record.adresseLivraison2ContactId = csvRecord.SAIS_COM_ADR_LIVR_CONTACT_ID;
        record.maitreOuvrageContactId = csvRecord.SAIS_COM_ADR_MO_CONTACT_ID;
        record.architecteEGContactId = csvRecord.SAIS_COM_ADR_ARCH_CONTACT_ID;
        record.compteResponsableCommercialTrivisoId = csvRecord.SAIS_COM_ADR_RESP_ID;
        record.saisComAdrRespId = csvRecord.SAIS_COM_ADR_RESP_ID;
        record.compteMandantTrivisoId = csvRecord.SAIS_COM_ADR_MAND_ID;
        record.compteResponsableProjetTrivisoId = csvRecord.SAIS_COM_ADR_RESP_PROJ_ID;
        record.saisComAdrCompteId = csvRecord.SAIS_COM_ADR_COMPTE_ID;

        record.montantNetSansProvision = String.isNotBlank(csvRecord.SAIS_COM_SOM_Prix_revient_sans_provision) ? parseDecimal(csvRecord.SAIS_COM_SOM_Prix_revient_sans_provision) : null;
        record.montantNetAvecProvision = String.isNotBlank(csvRecord.SAIS_COM_SOM_Prix_revient) ? parseDecimal(csvRecord.SAIS_COM_SOM_Prix_revient) : null;
        record.montantOffert = String.isNotBlank(csvRecord.SAIS_COM_SOM_Offert) ? parseDecimal(csvRecord.SAIS_COM_SOM_Offert) : null;
        record.montantConfirme = String.isNotBlank(csvRecord.SAIS_COM_SOM_Confirme) ? parseDecimal(csvRecord.SAIS_COM_SOM_Confirme) : null;
        record.montantCorrectionConfirme = String.isNotBlank(csvRecord.SAIS_COM_SOM_Correction_Confirme) ? parseDecimal(csvRecord.SAIS_COM_SOM_Correction_Confirme) : null;
        record.montantFacture = String.isNotBlank(csvRecord.SAIS_COM_SOM_Facture) ? parseDecimal(csvRecord.SAIS_COM_SOM_Facture) : null;
        record.montantPaye = String.isNotBlank(csvRecord.SAIS_COM_SOM_Paye) ? parseDecimal(csvRecord.SAIS_COM_SOM_Paye) : null;
        record.montantDAC = String.isNotBlank(csvRecord.SAIS_COM_SOM_DAC) ? parseDecimal(csvRecord.SAIS_COM_SOM_DAC) : null;
        record.potentielFacturation = String.isNotBlank(csvRecord.SAIS_COM_SOM_potentiel_facturation) ? parseDecimal(csvRecord.SAIS_COM_SOM_potentiel_facturation) : null;
        record.avanceClient = String.isNotBlank(csvRecord.SAIS_COM_SOM_avance_client) ? parseDecimal(csvRecord.SAIS_COM_SOM_avance_client) : null;
        record.soldeClientAPayerCHF = String.isNotBlank(csvRecord.SAIS_COM_SOM_Solde_a_paye_CHF) ? parseDecimal(csvRecord.SAIS_COM_SOM_Solde_a_paye_CHF) : null;
        
        System.debug('TRIVISO_LOG: Mapped ProjetProxyRecord: ' + JSON.serialize(record));
        
        return record;
    }
    
    public static ProjetProxyRecord mapFromCsvRow(List<String> headers, List<String> row) {
        ProjetProxyRecord record = new ProjetProxyRecord();
        Map<String, String> rowMap = new Map<String, String>();
        
        for (Integer i = 0; i < headers.size() && i < row.size(); i++) {
            String header = headers[i];
            String value = row[i];
            if (String.isNotBlank(value)) {
                rowMap.put(header, value);
            }
        }
        
        String sfField;
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ID');
        if (sfField != null) record.idProjetTriviso = rowMap.get('SAIS_COM_ID');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_Identification');
        if (sfField != null) record.numeroProjet = rowMap.get('SAIS_COM_Identification');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_Description');
        if (sfField != null) record.nomProjet = rowMap.get('SAIS_COM_Description');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_No_Comm_client');
        if (sfField != null) record.referenceClient = rowMap.get('SAIS_COM_No_Comm_client');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_Etat_ID');
        if (sfField != null) record.idEtapeProjet = rowMap.get('SAIS_COM_Etat_ID');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_Genre_projet');
        if (sfField != null) record.genreProjet = rowMap.get('SAIS_COM_Genre_projet');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_Fam_Désignation');
        if (sfField != null) record.familleCommerciale = rowMap.get('SAIS_COM_Fam_Désignation');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_Date_ouvert');
        if (sfField != null) record.dateOuvertureProjet = rowMap.get('SAIS_COM_Date_ouvert');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_Date_Modif');
        if (sfField != null) record.dateDerniereModification = rowMap.get('SAIS_COM_Date_Modif');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_FACT_ID');
        if (sfField != null) record.compteFacturationTrivisoId = rowMap.get('SAIS_COM_ADR_FACT_ID');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_LIVR_ID');
        if (sfField != null) record.compteLivraisonTrivisoId = rowMap.get('SAIS_COM_ADR_LIVR_ID');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_MO_ID');
        if (sfField != null) record.compteMaitreOuvrageTrivisoId = rowMap.get('SAIS_COM_ADR_MO_ID');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_ARCH_ID');
        if (sfField != null) record.compteArchitecteTrivisoId = rowMap.get('SAIS_COM_ADR_ARCH_ID');

        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_FACT_CONTACT_ID');
        if (sfField != null) record.facturationContactId = rowMap.get('SAIS_COM_ADR_FACT_CONTACT_ID');

        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_LIVR_CONTACT_ID');
        if (sfField != null) record.adresseLivraison2ContactId = rowMap.get('SAIS_COM_ADR_LIVR_CONTACT_ID');

        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_MO_CONTACT_ID');
        if (sfField != null) record.maitreOuvrageContactId = rowMap.get('SAIS_COM_ADR_MO_CONTACT_ID');

        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_ARCH_CONTACT_ID');
        if (sfField != null) record.architecteEGContactId = rowMap.get('SAIS_COM_ADR_ARCH_CONTACT_ID');

        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_RESP_ID');
        if (sfField != null) record.compteResponsableCommercialTrivisoId = rowMap.get('SAIS_COM_ADR_RESP_ID');
        if (sfField != null) record.saisComAdrRespId = rowMap.get('SAIS_COM_ADR_RESP_ID');

        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_MAND_ID');
        if (sfField != null) record.compteMandantTrivisoId = rowMap.get('SAIS_COM_ADR_MAND_ID');
        
        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_RESP_PROJ_ID');
        if (sfField != null) record.compteResponsableProjetTrivisoId = rowMap.get('SAIS_COM_ADR_RESP_PROJ_ID');

        sfField = CSV_TO_SF_FIELD_MAPPING.get('SAIS_COM_ADR_COMPTE_ID');
        if (sfField != null) record.saisComAdrCompteId = rowMap.get('SAIS_COM_ADR_COMPTE_ID');

        String montantValue = rowMap.get('SAIS_COM_SOM_Prix_revient_sans_provision');
        record.montantNetSansProvision = String.isNotBlank(montantValue) ? parseDecimal(montantValue) : null;
        
        montantValue = rowMap.get('SAIS_COM_SOM_Prix_revient');
        record.montantNetAvecProvision = String.isNotBlank(montantValue) ? parseDecimal(montantValue) : null;
        
        montantValue = rowMap.get('SAIS_COM_SOM_Offert');
        record.montantOffert = String.isNotBlank(montantValue) ? parseDecimal(montantValue) : null;
        
        montantValue = rowMap.get('SAIS_COM_SOM_Confirmé');
        record.montantConfirme = String.isNotBlank(montantValue) ? parseDecimal(montantValue) : null;
        
        montantValue = rowMap.get('SAIS_COM_SOM_Correction_Confirmé');
        record.montantCorrectionConfirme = String.isNotBlank(montantValue) ? parseDecimal(montantValue) : null;
        
        montantValue = rowMap.get('SAIS_COM_SOM_Facturé');
        record.montantFacture = String.isNotBlank(montantValue) ? parseDecimal(montantValue) : null;
        
        montantValue = rowMap.get('SAIS_COM_SOM_Payé');
        record.montantPaye = String.isNotBlank(montantValue) ? parseDecimal(montantValue) : null;
        
        montantValue = rowMap.get('SAIS_COM_SOM_DAC');
        record.montantDAC = String.isNotBlank(montantValue) ? parseDecimal(montantValue) : null;
        
        montantValue = rowMap.get('SAIS_COM_SOM_potentiel_facturation');
        record.potentielFacturation = String.isNotBlank(montantValue) ? parseDecimal(montantValue) : null;
        
        montantValue = rowMap.get('SAIS_COM_SOM_avance_client');
        record.avanceClient = String.isNotBlank(montantValue) ? parseDecimal(montantValue) : null;
        
        montantValue = rowMap.get('SAIS_COM_SOM_Solde_a_paye_CHF');
        record.soldeClientAPayerCHF = String.isNotBlank(montantValue) ? parseDecimal(montantValue) : null;
        
        return record;
    }
    
    public static Proxy_Projet__c mapToProxyProjet(ProjetProxyRecord record) {
        Proxy_Projet__c projet = new Proxy_Projet__c();
        
        System.debug('TRIVISO_LOG: Mapping ProjetProxyRecord to Proxy_Projet__c');
        System.debug('TRIVISO_LOG: record.idProjetTriviso = ' + record.idProjetTriviso);
        System.debug('TRIVISO_LOG: record.numeroProjet = ' + record.numeroProjet);
        System.debug('TRIVISO_LOG: record.nomProjet = ' + record.nomProjet);
        
        projet.ID_Projet_Triviso__c = record.idProjetTriviso;
        projet.Numero_Projet__c = record.numeroProjet;
        projet.Nom_Projet__c = record.nomProjet;
        projet.Reference_Client__c = record.referenceClient;
        projet.ID_Etape_Projet__c = record.idEtapeProjet;
        projet.Genre_Projet__c = record.genreProjet;
        projet.Famille_Commerciale__c = record.familleCommerciale;
        
        System.debug('TRIVISO_LOG: record.dateOuvertureProjet = ' + record.dateOuvertureProjet);
        if (String.isNotBlank(record.dateOuvertureProjet)) {
            Date parsedDate = parseDate(record.dateOuvertureProjet);
            projet.Date_Ouverture_Projet__c = parsedDate;
            System.debug('TRIVISO_LOG: Parsed Date_Ouverture_Projet__c = ' + parsedDate);
        }
        
        System.debug('TRIVISO_LOG: record.dateDerniereModification = ' + record.dateDerniereModification);
        if (String.isNotBlank(record.dateDerniereModification)) {
            Date parsedDate = parseDate(record.dateDerniereModification);
            projet.Date_Derniere_Modification__c = parsedDate;
            System.debug('TRIVISO_LOG: Parsed Date_Derniere_Modification__c = ' + parsedDate);
        }
        
        projet.Compte_Facturation_Triviso_ID__c = record.compteFacturationTrivisoId;
        projet.Compte_Livraison_Triviso_ID__c = record.compteLivraisonTrivisoId;
        projet.Compte_Maitre_Ouvrage_Triviso_ID__c = record.compteMaitreOuvrageTrivisoId;
        projet.Compte_Architecte_Triviso_ID__c = record.compteArchitecteTrivisoId;
        projet.Facturation_Contact__c = record.facturationContactId;
        projet.Adresse_de_Livraison_2__c = record.adresseLivraison2ContactId;
        projet.Maitre_d_ouvrage_Contact__c = record.maitreOuvrageContactId;
        projet.Architecte_EG_Contact__c = record.architecteEGContactId;
        projet.Compte_Responsable_Commercial_Triviso_ID__c = record.compteResponsableCommercialTrivisoId;
        projet.SAIS_COM_ADR_RESP_ID__c = record.saisComAdrRespId;
        projet.Compte_Mandant_Triviso_ID__c = record.compteMandantTrivisoId;
        projet.Compte_Responsable_Projet_Triviso_ID__c = record.compteResponsableProjetTrivisoId;
        projet.SAIS_COM_ADR_COMPTE_ID__c = record.saisComAdrCompteId;

        System.debug('TRIVISO_LOG: Mapping montants - montantNetSansProvision = ' + record.montantNetSansProvision);
        projet.Montant_Net_Sans_Provision__c = parseDecimal(record.montantNetSansProvision);
        projet.Montant_Net_Avec_Provision__c = parseDecimal(record.montantNetAvecProvision);
        projet.Montant_Offert__c = parseDecimal(record.montantOffert);
        projet.Montant_Confirme__c = parseDecimal(record.montantConfirme);
        projet.Montant_Correction_Confirme__c = parseDecimal(record.montantCorrectionConfirme);
        projet.Montant_Facture__c = parseDecimal(record.montantFacture);
        projet.Montant_Paye__c = parseDecimal(record.montantPaye);
        projet.Montant_DAC__c = parseDecimal(record.montantDAC);
        projet.Potentiel_Facturation__c = parseDecimal(record.potentielFacturation);
        projet.Avance_Client__c = parseDecimal(record.avanceClient);
        projet.Solde_Client_A_Payer_CHF__c = parseDecimal(record.soldeClientAPayerCHF);
        
        projet.Statut__c = 'Reçu';
        projet.Date_Reception__c = Datetime.now();
        projet.Source__c = 'Triviso';
        
        System.debug('TRIVISO_LOG: Final Proxy_Projet__c object: ' + JSON.serialize(projet));
        
        return projet;
    }
    
    private static Date parseDate(String dateStr) {
        if (String.isBlank(dateStr)) {
            return null;
        }
        
        try {
            // Support format: "DD.MM.YYYY HH:MM:SS" or "DD.MM.YYYY"
            String dateOnly = dateStr.trim();
            if (dateOnly.contains(' ')) {
                dateOnly = dateOnly.substring(0, dateOnly.indexOf(' '));
            }
            
            // Parse DD.MM.YYYY format
            if (dateOnly.contains('.')) {
                List<String> parts = dateOnly.split('\\.');
                if (parts.size() == 3) {
                    String day = parts[0];
                    String month = parts[1];
                    String year = parts[2];
                    // Convert to ISO format: YYYY-MM-DD
                    String isoDate = year + '-' + month + '-' + day;
                    System.debug('TRIVISO_LOG: Parsing date from ' + dateStr + ' to ' + isoDate);
                    return Date.valueOf(isoDate);
                }
            }
            
            // Try standard Date.valueOf for ISO format
            return Date.valueOf(dateStr);
        } catch (Exception e) {
            System.debug('TRIVISO_LOG: Error parsing date: ' + dateStr + ' - ' + e.getMessage() + ' | Stack: ' + e.getStackTraceString());
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
                System.debug('TRIVISO_LOG: Error parsing decimal: ' + strValue + ' - ' + e.getMessage());
                return null;
            }
        }
        
        try {
            return Decimal.valueOf(String.valueOf(value));
        } catch (Exception e) {
            System.debug('TRIVISO_LOG: Error parsing decimal: ' + value + ' - ' + e.getMessage());
            return null;
        }
    }
    
    // Mapping inverse: Proxy_Projet__c → Format CSV (pour export vers Triviso)
    public static Map<String, String> mapToCsvRecord(Proxy_Projet__c projet) {
        Map<String, String> csvRecord = new Map<String, String>();
        
        csvRecord.put('Salesforce_Id', String.valueOf(projet.Id));
        csvRecord.put('SAIS_COM_ID', projet.ID_Projet_Triviso__c != null ? projet.ID_Projet_Triviso__c : '');
        csvRecord.put('SAIS_COM_Identification', projet.Numero_Projet__c != null ? projet.Numero_Projet__c : '');
        csvRecord.put('SAIS_COM_Description', projet.Nom_Projet__c != null ? projet.Nom_Projet__c : '');
        csvRecord.put('SAIS_COM_No_Comm_client', projet.Reference_Client__c != null ? projet.Reference_Client__c : '');
        csvRecord.put('SAIS_COM_Etat_ID', projet.ID_Etape_Projet__c != null ? projet.ID_Etape_Projet__c : '');
        csvRecord.put('SAIS_COM_Genre_projet', projet.Genre_Projet__c != null ? projet.Genre_Projet__c : '');
        csvRecord.put('SAIS_COM_Fam_Désignation', projet.Famille_Commerciale__c != null ? projet.Famille_Commerciale__c : '');
        
        // Format dates: Date → DD.MM.YYYY HH:MM:SS
        if (projet.Date_Ouverture_Projet__c != null) {
            csvRecord.put('SAIS_COM_Date_ouvert', formatDateForCsv(projet.Date_Ouverture_Projet__c));
        } else {
            csvRecord.put('SAIS_COM_Date_ouvert', '');
        }
        
        if (projet.Date_Derniere_Modification__c != null) {
            csvRecord.put('SAIS_COM_Date_Modif', formatDateForCsv(projet.Date_Derniere_Modification__c));
        } else {
            csvRecord.put('SAIS_COM_Date_Modif', '');
        }
        
        csvRecord.put('SAIS_COM_ADR_FACT_ID', projet.Compte_Facturation_Triviso_ID__c != null ? projet.Compte_Facturation_Triviso_ID__c : '');
        csvRecord.put('SAIS_COM_ADR_LIVR_ID', projet.Compte_Livraison_Triviso_ID__c != null ? projet.Compte_Livraison_Triviso_ID__c : '');
        csvRecord.put('SAIS_COM_ADR_MO_ID', projet.Compte_Maitre_Ouvrage_Triviso_ID__c != null ? projet.Compte_Maitre_Ouvrage_Triviso_ID__c : '');
        csvRecord.put('SAIS_COM_ADR_ARCH_ID', projet.Compte_Architecte_Triviso_ID__c != null ? projet.Compte_Architecte_Triviso_ID__c : '');
        csvRecord.put('SAIS_COM_ADR_RESP_ID', projet.Compte_Responsable_Commercial_Triviso_ID__c != null ? projet.Compte_Responsable_Commercial_Triviso_ID__c : '');
        csvRecord.put('SAIS_COM_ADR_MAND_ID', projet.Compte_Mandant_Triviso_ID__c != null ? projet.Compte_Mandant_Triviso_ID__c : '');
        csvRecord.put('SAIS_COM_ADR_RESP_PROJ_ID', projet.Compte_Responsable_Projet_Triviso_ID__c != null ? projet.Compte_Responsable_Projet_Triviso_ID__c : '');
        
        // Montants: Decimal → String
        csvRecord.put('SAIS_COM_SOM_Prix_revient_sans_provision', formatDecimalForCsv(projet.Montant_Net_Sans_Provision__c));
        csvRecord.put('SAIS_COM_SOM_Prix_revient', formatDecimalForCsv(projet.Montant_Net_Avec_Provision__c));
        csvRecord.put('SAIS_COM_SOM_Offert', formatDecimalForCsv(projet.Montant_Offert__c));
        csvRecord.put('SAIS_COM_SOM_Confirme', formatDecimalForCsv(projet.Montant_Confirme__c));
        csvRecord.put('SAIS_COM_SOM_Correction_Confirme', formatDecimalForCsv(projet.Montant_Correction_Confirme__c));
        csvRecord.put('SAIS_COM_SOM_Facture', formatDecimalForCsv(projet.Montant_Facture__c));
        csvRecord.put('SAIS_COM_SOM_Paye', formatDecimalForCsv(projet.Montant_Paye__c));
        csvRecord.put('SAIS_COM_SOM_DAC', formatDecimalForCsv(projet.Montant_DAC__c));
        csvRecord.put('SAIS_COM_SOM_potentiel_facturation', formatDecimalForCsv(projet.Potentiel_Facturation__c));
        csvRecord.put('SAIS_COM_SOM_avance_client', formatDecimalForCsv(projet.Avance_Client__c));
        csvRecord.put('SAIS_COM_SOM_Solde_a_paye_CHF', formatDecimalForCsv(projet.Solde_Client_A_Payer_CHF__c));
        
        return csvRecord;
    }
    
    private static String formatDateForCsv(Date dateValue) {
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
    
    private static String formatDecimalForCsv(Decimal decimalValue) {
        if (decimalValue == null) {
            return '';
        }
        return String.valueOf(decimalValue);
    }
}