public class ProjetGeocodeBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    private static final Integer DELAY_MS = 2000;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return ProjetService.getNeedsGeocodingQueryLocator();
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        waitForRateLimit();
        List<Projet__c> toUpdate = new List<Projet__c>();
        for (SObject record : scope) {
            Projet__c projet = (Projet__c) record;

            // Le batch décide : dans TOUS les cas terminaux (pas d'adresse valide,
            // aucune coordonnée renvoyée, succès, ou échec OpenStreetMap) on repasse
            // le flag à false. Pas de retry (choix assumé, cf. cas 1).
            Projet__c result = new Projet__c(Id = projet.Id, NeedsGeocoding__c = false);

            try {
                ProjetService.ResolvedAddress addr = ProjetService.resolveGeocodingAddress(projet);
                if (addr == null) {
                    System.debug('[GeocodeBatch] ' + projet.Id + ' - no valid address found -> false');
                } else {
                    System.debug('[GeocodeBatch] ' + projet.Id + ' - callout via ' + addr.source + ' address: '
                        + addr.street + ', ' + addr.postalCode + ' ' + addr.city
                        + (String.isBlank(addr.country) ? '' : ', ' + addr.country));

                    Projet__c geocoded = ProjetService.geocodeFromAddress(projet.Id, addr.city, addr.country, addr.street, addr.postalCode, addr.state);
                    if (geocoded == null) {
                        System.debug('[GeocodeBatch] ' + projet.Id + ' - no coordinates returned by OpenStreetMap -> false');
                    } else {
                        // Coordonnées trouvées : on conserve les coords posées par geocodeFromAddress.
                        System.debug('[GeocodeBatch] ' + projet.Id + ' - coords: lat=' + geocoded.latitude__c + ', lng=' + geocoded.longitude__c);
                        result = geocoded;
                        result.NeedsGeocoding__c = false;
                    }
                }
            } catch (Exception e) {
                // Échec technique OpenStreetMap : false, pas de retry (cf. cas 1).
                System.debug(LoggingLevel.ERROR, '[GeocodeBatch] ' + projet.Id + ' - error -> false: ' + e.getMessage() + ' | ' + e.getStackTraceString());
            }

            toUpdate.add(result);
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {}

    @TestVisible
    private static void waitForRateLimit() {
        Long endTime = System.now().getTime() + DELAY_MS;
        while (System.now().getTime() < endTime) {}
    }
}