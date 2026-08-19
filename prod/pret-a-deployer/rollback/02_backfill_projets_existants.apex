// A executer en prod APRES le script 01, via Setup > Apex Anonyme
// Recalcule Probabilit__c sur les Projets existants deja a une des etapes concernees,
// sans attendre leur prochain changement d'etape naturel.

Map<String,String> mapping = new Map<String,String>{
    'Opportunité' => '0%',
    'Ouvert' => '0%',
    'Ouvert (Offre envoyée)' => '50%',
    'En préparation' => '50%',
    'Confirmé' => '100%'
};

List<Projet__c> toUpdate = new List<Projet__c>();
for (Projet__c p : [SELECT Id, Etape__c, Probabilit__c FROM Projet__c WHERE Etape__c IN :mapping.keySet()]) {
    String newVal = mapping.get(p.Etape__c);
    if (p.Probabilit__c != newVal) {
        p.Probabilit__c = newVal;
        toUpdate.add(p);
    }
}
System.debug('TOTAL A METTRE A JOUR: ' + toUpdate.size());

List<Database.SaveResult> results = Database.update(toUpdate, false);
Integer successCount = 0;
Integer errorCount = 0;
for (Database.SaveResult r : results) {
    if (r.isSuccess()) {
        successCount++;
    } else {
        errorCount++;
        System.debug('ERREUR sur ' + r.getId() + ' : ' + r.getErrors());
    }
}
System.debug('SUCCES: ' + successCount + ' ERREURS: ' + errorCount);
