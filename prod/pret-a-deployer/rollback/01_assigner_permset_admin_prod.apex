// A executer en prod APRES le deploiement du package Task_Attribution_Automatique, via Setup > Apex Anonyme
// Assigne le Permission Set technique a l'admin prod (parite avec wider-test : seul admin.wider@upmind.fr.test l'a en test).

User admin = [SELECT Id FROM User WHERE Username = 'admin.wider@upmind.fr' LIMIT 1];
PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PS_Utilisateur_SF_Technique' LIMIT 1];

List<PermissionSetAssignment> existing = [
    SELECT Id FROM PermissionSetAssignment
    WHERE AssigneeId = :admin.Id AND PermissionSetId = :ps.Id
];
if (existing.isEmpty()) {
    insert new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetId = ps.Id);
    System.debug('Permission Set assigne.');
} else {
    System.debug('Deja assigne, rien a faire.');
}
