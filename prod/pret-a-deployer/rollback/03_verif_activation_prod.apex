// Verification post-activation, lecture + ecriture en Savepoint/rollback (aucune donnee conservee).
Savepoint sp = Database.setSavepoint();

Id anaLealContactId = '003NN00000VyZ6PYAV';
Id anaLealUserId = '005bk000000BlhxAAC';

// Cas 1 : contact interne avec User -> OwnerId doit basculer sur le User
Task t1 = new Task(Subject = 'TEST verif activation - interne', WhoId = anaLealContactId, ActivityDate = Date.today());
insert t1;
Task t1Reloaded = [SELECT OwnerId FROM Task WHERE Id = :t1.Id];
System.debug('Cas 1 (attendu = User Ana Leal ' + anaLealUserId + ') : OwnerId = ' + t1Reloaded.OwnerId);

// Cas 2 : contact externe (sans Utilisateur_Salesforce__c) -> OwnerId doit basculer sur la Queue
Contact contactExterne = [SELECT Id FROM Contact WHERE Utilisateur_Salesforce__c = null AND Email != null LIMIT 1];
Task t2 = new Task(Subject = 'TEST verif activation - externe', WhoId = contactExterne.Id, ActivityDate = Date.today());
insert t2;
Task t2Reloaded = [SELECT OwnerId FROM Task WHERE Id = :t2.Id];
Group queue = [SELECT Id FROM Group WHERE DeveloperName = 'Taches_non_attribuees' AND Type = 'Queue'];
System.debug('Cas 2 (attendu = Queue ' + queue.Id + ') : OwnerId = ' + t2Reloaded.OwnerId);

Database.rollback(sp);
System.debug('Rollback effectue, aucune tache conservee.');
