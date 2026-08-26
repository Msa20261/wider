// A executer en prod APRES le script 01, via Setup > Apex Anonyme
// Rapproche les Contacts internes Wider avec leur User Salesforce correspondant (par email),
// meme logique que sur wider-test (demande #9, etape 3).
//
// Toni Cortes (Contact 003NN00000VyVEvYAN) n'a PAS de User Salesforce actif en prod au 2026-08-26
// -> laisse volontairement vide ; les taches qui lui seraient attribuees tomberont sur la Queue
// "Taches non attribuees" jusqu'a la creation de son compte (comportement natif du flow, pas un bug).

Map<Id, Id> contactToUser = new Map<Id, Id>{
    (Id) '003NN00000VyZ6PYAV' => (Id) '005bk000000BlhxAAC', // Ana Leal -> a.leal4@wider-sa.ch
    (Id) '003NN00000Vy9rsYAB' => (Id) '005NN00000EsxpRYAR'  // Alexandre Gilbert -> gilbert@wider-sa.ch
};

List<Contact> toUpdate = new List<Contact>();
for (Id contactId : contactToUser.keySet()) {
    toUpdate.add(new Contact(Id = contactId, Utilisateur_Salesforce__c = contactToUser.get(contactId)));
}
update toUpdate;
System.debug('Contacts rapproches : ' + toUpdate.size());
