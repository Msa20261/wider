public with sharing class ProjetService {

    public class ProjetException extends Exception {}

    @AuraEnabled
    public static String getProjetsWithAccount() {
        try {
            List<Projet__c> listOfProjets = [
                SELECT
                    Id,
                    latitude__c,
                    longitude__c,
                    Adresse_de_Livraison__r.Adresse_compte__street__s,
                    Adresse_de_Livraison__r.Adresse_compte__city__s,
                    Adresse_de_Livraison__r.Adresse_compte__postalCode__s,
                    Adresse_de_Livraison__r.Adresse_compte__CountryCode__s,
                    Name,
                    Nom_du_compte__r.Name,
                    Nom_du_compte__r.Id,
                    CreatedDate,
                    Etape__c,
                    Mandant__r.Name,
                    Mandant__r.Id
                FROM
                    Projet__c
                WHERE
                    latitude__c != null
                AND longitude__c != null
                AND Nom_du_compte__c != null
                WITH USER_MODE
            ];

            return JSON.serialize(listOfProjets);
        } catch (Exception e) {
            throw new ProjetException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getProjet(String projetId) {
        try {
            List<Projet__c> recordProjet = [
                SELECT
                    Id,
                    latitude__c,
                    longitude__c,
                    Adresse_de_Livraison__r.Adresse_compte__street__s,
                    Adresse_de_Livraison__r.Adresse_compte__city__s,
                    Adresse_de_Livraison__r.Adresse_compte__postalCode__s,
                    Adresse_de_Livraison__r.Adresse_compte__CountryCode__s,
                    Name,
                    Nom_du_compte__r.Name,
                    Nom_du_compte__r.Id,
                    CreatedDate,
                    Etape__c,
                    Mandant__r.Name,
                    Mandant__r.Id
                FROM
                    Projet__c
                WHERE
                    Id = :projetId
                WITH USER_MODE
            ];

            if (recordProjet.isEmpty()) {
                throw new ProjetException('No projet found with ID: ' + projetId);
            }

            return JSON.serialize(recordProjet);
        } catch (ProjetException e) {
            throw new ProjetException(e.getMessage());
        } catch (Exception e) {
            throw new ProjetException(e.getMessage());
        }
    }

    public static Boolean hasValidAddress(String city, String street, String postalCode) {
        return !String.isBlank(city) && !String.isBlank(street) && !String.isBlank(postalCode);
    }

    public static Boolean hasValidAddress(Account acc) {
        return acc != null && hasValidAddress(
            acc.Adresse_compte__city__s,
            acc.Adresse_compte__street__s,
            acc.Adresse_compte__postalCode__s
        );
    }

    public class ResolvedAddress {
        public String city;
        public String country;
        public String street;
        public String postalCode;
        public String state;
        public String source;

        public ResolvedAddress(String city, String country, String street, String postalCode, String state, String source) {
            this.city       = city;
            this.country    = country;
            this.street     = street;
            this.postalCode = postalCode;
            this.state      = state;
            this.source     = source;
        }
    }

    /**
     * Seule source du géocodage : le compte rattaché en adresse de livraison
     * (Adresse_de_Livraison__c, lookup Account alimenté par Triviso via SAIS_COM_ADR_LIVR_ID).
     *
     * Aucun repli sur l'adresse de facturation ni sur le compte du projet : un pin de la
     * cartographie correspond donc toujours à un lieu de livraison, ou n'existe pas.
     */
    public static ResolvedAddress resolveGeocodingAddress(Projet__c projet) {
        Account livraison = projet.Adresse_de_Livraison__r;
        if (!hasValidAddress(livraison)) return null;

        return new ResolvedAddress(
            livraison.Adresse_compte__city__s,
            livraison.Adresse_compte__CountryCode__s,
            livraison.Adresse_compte__street__s,
            livraison.Adresse_compte__postalCode__s,
            null, 'livraison'
        );
    }

    @future(callout=true)
    public static void geocodeSingleProjetAsync(Id projetId) {
        List<Projet__c> projets = [
            SELECT Id,
                   Adresse_de_Livraison__r.Adresse_compte__city__s,
                   Adresse_de_Livraison__r.Adresse_compte__street__s,
                   Adresse_de_Livraison__r.Adresse_compte__postalCode__s,
                   Adresse_de_Livraison__r.Adresse_compte__CountryCode__s
            FROM Projet__c
            WHERE Id = :projetId AND NeedsGeocoding__c = true
        ];
        if (projets.isEmpty()) return;

        ResolvedAddress addr = resolveGeocodingAddress(projets[0]);
        if (addr == null) return;

        Projet__c geocoded = geocodeFromAddress(projetId, addr.city, addr.country, addr.street, addr.postalCode, addr.state);
        if (geocoded == null) return;

        geocoded.NeedsGeocoding__c = false;
        update geocoded;
    }

    public static Database.QueryLocator getNeedsGeocodingQueryLocator() {
        return Database.getQueryLocator(
            'SELECT Id, ' +
            'Adresse_de_Livraison__r.Adresse_compte__city__s, ' +
            'Adresse_de_Livraison__r.Adresse_compte__street__s, ' +
            'Adresse_de_Livraison__r.Adresse_compte__postalCode__s, ' +
            'Adresse_de_Livraison__r.Adresse_compte__CountryCode__s ' +
            'FROM Projet__c WHERE NeedsGeocoding__c = true'
        );
    }

    public static Projet__c fetchProjetCoords(Id projetId) {
        List<Projet__c> projets = [
            SELECT
                Id,
                Adresse_Facturation__c
            FROM
                Projet__c
            WHERE
                Id = :projetId
            WITH USER_MODE
        ];

        if (projets.size() == 0) {
            throw new ProjetException('No projet found');
        }
        
        if (projets.size() > 1) {
            throw new ProjetException('Multiple projets found with the same ID: ' + projetId);
        }

        Projet__c projet = projets[0];

        Address address = projet.Adresse_Facturation__c;

        if (address == null) {
            throw new ProjetException('No address found for projet: ' + projetId);
        }

        String city = address.getCity();
        String country = address.getCountry();
        String street = address.getStreet();
        String postalCode = address.getPostalCode();
        String state = address.getState();

        if (String.isBlank(street) || String.isBlank(city) || String.isBlank(postalCode)) {
            throw new ProjetException('No address found for projet: ' + projetId);
        }

        System.debug('city: ' + city);
        System.debug('country: ' + country);
        System.debug('street: ' + street);
        System.debug('postalCode: ' + postalCode);
        System.debug('state: ' + state);

        if (!Schema.sObjectType.Projet__c.isUpdateable()) {
            throw new ProjetException('Insufficient permissions to update Projet__c records');
        }

        String urlParameters = getUrlParams(
            city,
            country,
            street,
            postalCode,
            state
        );

        HttpRequest req = buildOpenStreetMapRequest(urlParameters);
        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            throw new ProjetException('HTTP error: ' + res.getStatusCode() + ' - ' + res.getBody());
        }

        List<OpenStreetMapResponse> data;
        try {
            data = (List<OpenStreetMapResponse>) JSON.deserialize(res.getBody(), List<OpenStreetMapResponse>.class);
        } catch (Exception e) {
            System.debug('JSON deserialization failed for projet ' + projetId + ': ' + e.getMessage());
            throw new ProjetException('JSON deserialization failed: ' + e.getMessage());
        }

        if (data == null || data.size() == 0) {
            throw new ProjetException('No coordinates found for the address: ' + street + ', ' + postalCode + ' ' + city + ', ' + country + ', ' + state);
        }

        System.debug(data);

        for (OpenStreetMapResponse item : data) {
            projet.latitude__c = item.lat;
            projet.longitude__c = item.lon;
        }

        return projet;
    }

    class OpenStreetMapResponse {
        String lat;
        String lon;
    }

    public static HttpRequest buildOpenStreetMapRequest(String urlParameters) {
        HttpRequest req = new HttpRequest();
        String url = 'https://nominatim.openstreetmap.org/search?format=json&limit=1' + urlParameters;

        System.debug(url);

        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('User-Agent', 'Salesforce-WiderApp/1.0');
        req.setTimeout(30000);

        return req; 
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static Projet__c geocodeFromAddress(Id projetId, String city, String country, String street, String postalCode, String state) {
        String urlParameters = getUrlParams(city, country, street, postalCode, state);
        HttpRequest req = buildOpenStreetMapRequest(urlParameters);

        System.debug('[GeocodeService] calling OSM: ' + req.getEndpoint());

        Http http = new Http();
        HTTPResponse res;
        try {
            res = http.send(req);
        } catch (Exception e) {
            throw new ProjetException('HTTP callout failed: ' + e.getMessage());
        }

        System.debug('[GeocodeService] OSM response status: ' + res.getStatusCode());

        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            throw new ProjetException('HTTP error: ' + res.getStatusCode() + ' - ' + res.getBody());
        }

        List<OpenStreetMapResponse> data;
        try {
            data = (List<OpenStreetMapResponse>) JSON.deserialize(res.getBody(), List<OpenStreetMapResponse>.class);
        } catch (Exception e) {
            throw new ProjetException('JSON deserialization failed: ' + e.getMessage());
        }

        if (data == null || data.isEmpty()) {
            System.debug('[GeocodeService] OSM returned no results for: ' + street + ', ' + postalCode + ' ' + city);
            return null;
        }

        System.debug('[GeocodeService] OSM result: lat=' + data[0].lat + ', lon=' + data[0].lon);

        Projet__c projet = new Projet__c(Id = projetId);
        projet.latitude__c  = data[0].lat;
        projet.longitude__c = data[0].lon;
        return projet;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static String getUrlParams(
        String city,
        String country,
        String street,
        String postalCode,
        String state
    ) {
        String urlParameters = '';

        if (city != null) {
            urlParameters += '&city=' + EncodingUtil.urlEncode(city, 'UTF-8');
        }
        if (country != null) {
            // Nominatim distingue deux paramètres : `countrycodes` attend un code ISO
            // 3166-1 alpha-2 et restreint réellement la recherche, `country` attend un
            // nom de pays. L'adresse de livraison fournit un code (Adresse_compte__CountryCode__s).
            urlParameters += country.length() == 2
                ? '&countrycodes=' + EncodingUtil.urlEncode(country.toLowerCase(), 'UTF-8')
                : '&country=' + EncodingUtil.urlEncode(country, 'UTF-8');
        }
        if (street != null) {
            urlParameters += '&street=' + EncodingUtil.urlEncode(street, 'UTF-8');
        }
        if (postalCode != null) {
            // `postalcode` en minuscules : Nominatim ignore silencieusement `postalCode`.
            urlParameters += '&postalcode=' + EncodingUtil.urlEncode(postalCode, 'UTF-8');
        }
        if (state != null) {
            urlParameters += '&state=' + EncodingUtil.urlEncode(state, 'UTF-8');
        }

        return urlParameters;
    }

    public static List<Projet__c> getProjetWithoutTrivisoId() {
        return [
            SELECT 
                Id,
                Name,
                Numero_projet__c,
                Reference_client__c,
                Etape__c,
                Type_projet__c,
                Famille_commerciale__c,
                Date_de_fermeture__c,
                LastModifiedDate,
                Nom_du_compte__r.Identification__c,
                Adresse_de_Livraison__r.Identification__c,
                Maitre_d_ouvrage__r.Identification__c,
                Architecte__r.Identification__c,
                Responsable_commercial__r.Identification__c,
                Mandant__r.IdentifiantSoci_t_grpupe__c,
                Chef_de_projet__r.Identification__c,
                Facturation_Contact__r.Identification__c,
                Adresse_de_Livraison_2__r.Identification__c,
                Maitre_d_ouvrage_Contact__r.Identification__c,
                Architecte_EG_Contact__r.Identification__c,
                Calculation_net_sans_provision__c,
                Calculation_net_avec_provision__c,
                Offert__c,
                Confirme__c,
                Correction_confirm__c,
                Facture__c,
                Paye__c,
                Montant__c,
                A_facturer__c,
                Avance_client__c,
                Paiement_client_recevoir__c
            FROM Projet__c
            WHERE Numero_projet__c = null
            ORDER BY CreatedDate DESC
        ];
    }

    public static List<Projet__c> getProjetPageForExport(String lastId, Integer pageSize, DateTime sinceDate) {
        String fields =
            'SELECT Id, Name, Numero_projet__c, SAIS_com_ID__c, Reference_client__c, Etape__c, Type_projet__c, ' +
            'Famille_commerciale__c, Date_de_fermeture__c, LastModifiedDate, ' +
            'Compte_Facturation__c, Compte_Facturation__r.Identification__c, Nom_du_compte__r.Identification__c, Adresse_de_Livraison__r.Identification__c, ' +
            'Maitre_d_ouvrage__r.Identification__c, Architecte__r.Identification__c, ' +
            'Responsable_commercial__r.Identification__c, Mandant__r.IdentifiantSoci_t_grpupe__c, ' +
            'Responsable_Projet_Contact__c, Responsable_Projet_Contact__r.Identification__c, Genre_Projet_SF__c, ' +
            'Facturation_Contact__r.Identification__c, Adresse_de_Livraison_2__r.Identification__c, ' +
            'Maitre_d_ouvrage_Contact__r.Identification__c, Architecte_EG_Contact__r.Identification__c, ' +
            'Calculation_net_sans_provision__c, ' +
            'Calculation_net_avec_provision__c, Offert__c, Confirme__c, Correction_confirm__c, ' +
            'Facture__c, Paye__c, Montant__c, A_facturer__c, Avance_client__c, Paiement_client_recevoir__c ' +
            'FROM Projet__c';

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

        System.debug('TRIVISO_LOG: getProjetPageForExport query (lastId=' + lastId + ', sinceDate=' + sinceDate + ')');
        return Database.query(query);
    }

    public static void updateTrivisoExportDate(List<Projet__c> projets) {
        if (projets == null || projets.isEmpty()) {
            return;
        }

        Date today = Date.today();
        for (Projet__c projet : projets) {
            projet.Triviso_export_date__c = today;
        }

        try {
            update projets;
        } catch (Exception e) {
            throw new ProjetException('Error updating Triviso_export_date__c: ' + e.getMessage());
        }
    }

}