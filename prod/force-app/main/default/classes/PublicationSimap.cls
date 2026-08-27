public class PublicationSimap {

    public class PublicationSimapException extends Exception {}

    public static final String PUBLICATION_PREFIX = 'Publication SIMAP ';
    public static final String SIMAP_BASE_DETAIL_URL = 'https://www.simap.ch/en/project-detail/';
    public static final String SIMAP_PDF_SUFFIX = '?print-view=';

    public static Publication_Simap__c insertPublicationHeader(SimapHeadersService.PublicationDeserializer rawPubData) {
        system.debug('rawPubData : ' + rawPubData);
        Publication_Simap__c publicationSimap = new Publication_Simap__c();
        publicationSimap.Bureau_d_achat__c = SimapUtils.getValidPublicationProcOfficeName(rawPubData);
        publicationSimap.Numero_de_projet__c = rawPubData.projectNumber;
        publicationSimap.Numero_de_publication__c = rawPubData.publicationNumber;
        publicationSimap.Id_publication_detail__c = rawPubData.publicationId;
        publicationSimap.Id_publication_page__c = rawPubData.id;
        publicationSimap.Lien_PDF__c = SIMAP_BASE_DETAIL_URL + rawPubData.id + SIMAP_PDF_SUFFIX;
        publicationSimap.Titre_de_publication__c = SimapUtils.getValidPublicationTitle(rawPubData);
        publicationSimap.Lieu_d_execution__c = SimapUtils.orderAddressConverter(rawPubData.orderAddress);
        publicationSimap.Name = PUBLICATION_PREFIX + rawPubData.publicationNumber;
        if (rawPubData.publicationDate != null) {
            publicationSimap.Date_de_publication__c = Date.valueOf(rawPubData.publicationDate);
        } else {
            publicationSimap.Date_de_publication__c = null;
        }
        if (rawPubData.offerDeadline != null) {
            publicationSimap.Deadline_Offre__c = Date.valueOf(rawPubData.offerDeadline);
        } else {
            publicationSimap.Deadline_Offre__c = null;
        }
        publicationSimap.Type_de_projet__c = rawPubData.projectType;
        publicationSimap.Type_de_publication__c = rawPubData.pubType;
        publicationSimap.Type_de_process__c = rawPubData.processType;
        publicationSimap.Corrige__c = rawPubData.corrected;
        
        insert publicationSimap;

        System.debug('Publication SIMAP created: ' + publicationSimap);

        return publicationSimap;
    }

    public static Publication_Simap__c updatePublicationWithDetails(
        Publication_Simap__c publication,
        SimapPublicationDetailService.SimapPublicationDetailResponse simapDetailResponse
    ) {

        if (simapDetailResponse.ted != null) {
            SimapPublicationDetailService.Ted ted = simapDetailResponse.ted;
            publication.statut__c = ted.status;
            publication.Url__c = ted.url;
        }

        if (simapDetailResponse.base != null) {
            SimapPublicationDetailService.Base base = simapDetailResponse.base;
            // publication.Name = SimapUtils.getValidField(base.title).left(80);
            // publication.Numero_de_publication__c = base.publicationNumber;
            // publication.Type_de_process__c = base.processType;
            publication.Denomination_CPV__c = SimapUtils.getValidField(base.cpvCode?.label);
            publication.Type_de_l_offre__c = base.type;
            publication.Code_CPV__c = base.cpvCode?.code;
            publication.Nom_de_l_offre__c = SimapUtils.getValidField(base.title);
        }

        if (simapDetailResponse.dates != null) {
            SimapPublicationDetailService.Dates dates = simapDetailResponse.dates;
            publication.Date_de_publication__c = dates.publicationDate;
            publication.Deadline_Offre__c = dates.offerDeadline;
        }

        if (simapDetailResponse.projectInfo != null) {
            SimapPublicationDetailService.ProjectInfo projectInfo = simapDetailResponse.projectInfo;
            publication.Adresse_bureau_d_achat__c = SimapUtils.addressConverter(projectInfo.procOfficeAddress);
            // This address is used in the Projet transformation flow in order to allow
            // the Projet trigger to fetch geographical coords
            publication.Adresse_bureau_d_achat_formatee__City__s = SimapUtils.getValidField(projectInfo.procOfficeAddress?.city);
            publication.Adresse_bureau_d_achat_formatee__PostalCode__s = projectInfo.procOfficeAddress?.postalCode;
            publication.Adresse_bureau_d_achat_formatee__Street__s = SimapUtils.getValidField(projectInfo.procOfficeAddress?.street);
            publication.Adresse_bureau_d_achat_formatee__CountryCode__s = projectInfo.procOfficeAddress?.countryId;
            
            publication.Telephone_bureau_d_achat__c = projectInfo.procOfficeAddress?.phone;
            publication.Email_bureau_d_achat__c = projectInfo.procOfficeAddress?.email;
            publication.Contact_bureau_d_achat__c = SimapUtils.getValidField(projectInfo.procOfficeAddress?.contactPerson);

            publication.Adresse_contact__c = SimapUtils.addressConverter(projectInfo.procurementRecipientAddress);
            publication.Telephone_contact__c = projectInfo.procurementRecipientAddress?.phone;
            publication.Email_contact__c = projectInfo.procurementRecipientAddress?.email;
            publication.Nom_service_demandeur__c = SimapUtils.getValidField(projectInfo.procurementRecipientAddress?.name);
            publication.Contact_service_demandeur__c = SimapUtils.getValidField(projectInfo.procurementRecipientAddress?.contactPerson);

            publication.Adresse_de_l_offre__c = SimapUtils.addressConverter(projectInfo.offerAddress);
            publication.Reference_de_l_offre__c = projectInfo.offerAddress?.reference;
            publication.Info_generale__c = SimapUtils.getValidField(projectInfo.offerSpecificNote).stripHtmlTags();
        
            publication.offre_canton__c = SimapUtils.getValidCantonValue(projectInfo);
        }

        if (simapDetailResponse.procurement != null) {
            SimapPublicationDetailService.Procurement procurement = simapDetailResponse.procurement;
            publication.order_description__c = SimapUtils.getValidField(procurement.orderDescription).stripHtmlTags();
        }

        update publication;

        return publication;
    }

    public static List<Publication_Simap__c> getVisitedSimapPublications(Set<String> publicationIds) {
        return [
            SELECT 
                Id,
                Id_publication_page__c,
                Projet__c,
                CreatedDate,
                CreatedBy.Name
            FROM
                Publication_Simap__c
            WHERE
                Id_publication_page__c = :publicationIds
        ];
    }

    public static List<Publication_Simap__c> getPublicationSimapByDetailId(String idPublicationDetail) {
        return [
            SELECT
                Id,
                Id_publication_detail__c
            FROM
                Publication_Simap__c
            WHERE
                Id_publication_detail__c = :IdPublicationDetail
        ];
    }

    public static Publication_Simap__c getPublicationById(Id publicationSimapId) {
        return [
            SELECT
                Id,
                Id_publication_detail__c,
                Id_publication_page__c,
                offre_canton__c,
                Lieu_d_execution__c
            FROM
                Publication_Simap__c
            WHERE
                Id = :publicationSimapId
            LIMIT 1
        ];
    } 
}