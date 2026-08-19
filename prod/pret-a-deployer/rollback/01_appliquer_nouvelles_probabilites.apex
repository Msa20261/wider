// A executer en prod APRES le deploiement du flow, via Setup > Apex Anonyme
// Met a jour la table de reference Probabilit_par_tape__c avec les nouvelles valeurs.

Map<String,String> updates = new Map<String,String>{
    'Opportunité' => '0%',
    'Ouvert' => '0%',
    'Ouvert (Offre envoyée)' => '50%',
    'En préparation' => '50%',
    'Confirmé' => '100%'
};

List<Probabilit_par_tape__c> toUpdate = new List<Probabilit_par_tape__c>();
for (Probabilit_par_tape__c p : [SELECT Id, Name, Etape__c, Probabilit__c FROM Probabilit_par_tape__c WHERE Etape__c IN :updates.keySet()]) {
    String newVal = updates.get(p.Etape__c);
    if (p.Probabilit__c != newVal) {
        p.Probabilit__c = newVal;
        toUpdate.add(p);
    }
}
System.debug('LIGNES A METTRE A JOUR: ' + toUpdate.size());
update toUpdate;
