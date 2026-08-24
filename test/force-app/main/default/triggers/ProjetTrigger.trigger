trigger ProjetTrigger on Projet__c (before update, after update) {

    if (TriggerHandler.bypassProjetTrigger) {
        return;
    }

    // Rien a la creation : NeedsGeocoding__c vaut true par defaut au niveau du
    // champ, donc tout projet nait marque et ProjetGeocodeBatch le reprend. Le
    // flow JobScheduleProjet bypasse ce trigger de toute facon.

    switch on Trigger.operationType {

        when BEFORE_UPDATE {
            for (Projet__c projet : Trigger.new) {
                Projet__c old = Trigger.oldMap.get(projet.Id);

                // Le géocodage part du compte rattaché en adresse de livraison : seul un
                // changement de ce lookup invalide les coordonnées. Cela couvre aussi le
                // rattachement tardif par les flux Triviso, qui résolvent le compte après
                // la création du projet — c'est bien un update du Projet.
                //
                // Limite connue : modifier l'adresse du compte lui-même ne propage rien ici,
                // il faudrait un trigger sur Account (non implémenté à ce jour).
                //
                // Sinon on NE TOUCHE PAS au flag : ne jamais remettre false ici,
                // c'est le batch qui décide (évite l'écrasement du true posé à la création).
                if (old.Adresse_de_Livraison__c != projet.Adresse_de_Livraison__c) {
                    projet.NeedsGeocoding__c = true;
                }
            }
        }

        when AFTER_UPDATE {
            // Géocodage immédiat réservé à la modification unitaire (un user
            // rattache ou corrige le compte de livraison dans l'UI et veut voir
            // le pin bougé tout de suite).
            //
            // Volontairement PAS en AFTER_INSERT : a la creation, la valeur par
            // defaut du champ marque deja le projet et ProjetGeocodeBatch prend le
            // relais. Or le flow planifie JobScheduleProjet insere les
            // Projet__c un par un (variable unitaire VarNewProjet), et un flow
            // planifié exécute ses interviews par lots de 200 dans UNE SEULE
            // transaction : la condition size() == 1 était donc vraie 200 fois de
            // suite, ce qui dépassait la limite de 50 appels @future et remontait
            // en CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY: Too many retries of batch save.
            //
            // Pas de garde-fou sur Limits.getFutureCalls() ici, volontairement :
            // c'est le flow qui porte la responsabilite de ne pas declencher le
            // trigger en masse, via l'action Apex "Bypass Projet Trigger". Un
            // second filet ne ferait que transformer un depassement en geocodage
            // silencieusement partiel, bien plus dur a diagnostiquer qu'une erreur
            // franche. Reste que size() == 1 est un proxy imparfait de "edition
            // manuelle unitaire" : tout appelant faisant des updates unitaires en
            // boucle heurtera la limite de 50 @future, et c'est assume.
            if (Trigger.new.size() == 1 && !System.isBatch() && !System.isFuture()
                && Trigger.new[0].NeedsGeocoding__c) {
                ProjetService.geocodeSingleProjetAsync(Trigger.new[0].Id);
            }
        }
    }
}