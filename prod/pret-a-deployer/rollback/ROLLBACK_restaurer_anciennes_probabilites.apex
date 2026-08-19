// SCRIPT DE ROLLBACK - a utiliser UNIQUEMENT si la revision des probabilites doit etre annulee.
// Restaure les valeurs qui existaient AVANT le correctif du 2026-08-19 :
//   Opportunite  0%  -> 10%
//   Ouvert       0%  -> 30%
//   Offre envoyee (Ouvert (Offre envoyee))  50% -> 40%
//   En preparation 50% -> 60%
//   Confirme     100% -> 75%
// Ne touche pas Attribution/Chiffrage/Execute/Facture/Termine/Pas execute (non modifies par le correctif).
//
// A executer en 2 temps : d'abord sur la table de reference, puis sur les Projets existants
// si on veut aussi annuler le rattrapage retroactif du 2026-08-19.

Map<String,String> oldValues = new Map<String,String>{
    'Opportunité' => '10%',
    'Ouvert' => '30%',
    'Ouvert (Offre envoyée)' => '40%',
    'En préparation' => '60%',
    'Confirmé' => '75%'
};

// 1) Table de reference
List<Probabilit_par_tape__c> tableToRevert = new List<Probabilit_par_tape__c>();
for (Probabilit_par_tape__c p : [SELECT Id, Etape__c, Probabilit__c FROM Probabilit_par_tape__c WHERE Etape__c IN :oldValues.keySet()]) {
    String oldVal = oldValues.get(p.Etape__c);
    if (p.Probabilit__c != oldVal) {
        p.Probabilit__c = oldVal;
        tableToRevert.add(p);
    }
}
System.debug('TABLE - lignes a restaurer: ' + tableToRevert.size());
update tableToRevert;

// 2) Projets existants (uniquement ceux dont la probabilite correspond encore exactement
//    a la nouvelle valeur, pour ne pas ecraser une saisie manuelle faite depuis)
Map<String,String> newValues = new Map<String,String>{
    'Opportunité' => '0%',
    'Ouvert' => '0%',
    'Ouvert (Offre envoyée)' => '50%',
    'En préparation' => '50%',
    'Confirmé' => '100%'
};
List<Projet__c> projetsToRevert = new List<Projet__c>();
for (Projet__c p : [SELECT Id, Etape__c, Probabilit__c FROM Projet__c WHERE Etape__c IN :oldValues.keySet()]) {
    if (p.Probabilit__c == newValues.get(p.Etape__c)) {
        p.Probabilit__c = oldValues.get(p.Etape__c);
        projetsToRevert.add(p);
    }
}
System.debug('PROJETS - lignes a restaurer: ' + projetsToRevert.size());
Database.update(projetsToRevert, false);
