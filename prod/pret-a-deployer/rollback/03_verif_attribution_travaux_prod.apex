Savepoint sp = Database.setSavepoint();

Attribution_Travaux__c a = new Attribution_Travaux__c(
    Projet__c = 'a02NN00000HCS1zYAH',
    Travaux_CFC__c = 'TEST verif prod'
);
insert a;
Attribution_Travaux__c reloaded = [SELECT Name, Projet__c, Travaux_CFC__c FROM Attribution_Travaux__c WHERE Id = :a.Id];
System.debug('Cree : ' + reloaded.Name + ' | Projet=' + reloaded.Projet__c + ' | CFC=' + reloaded.Travaux_CFC__c);

List<Attribution_Travaux__c> relatedList = [SELECT Id FROM Attribution_Travaux__c WHERE Projet__c = 'a02NN00000HCS1zYAH'];
System.debug('Related list Attributions_Travaux__r fonctionne, count=' + relatedList.size());

Database.rollback(sp);
System.debug('Rollback effectue, aucune donnee conservee.');
