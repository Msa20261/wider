public class ProjetQueueable implements Queueable, Database.AllowsCallouts {
    
    private Id projetId;
    
    public ProjetQueueable(Id projetId) {
        this.projetId = projetId;
    }
    
    public void execute(QueueableContext context) {
        try {
            System.debug('Traitement du projet: ' + projetId);
            
            // Utiliser ProjetService pour récupérer les coordonnées
            ProjetService.fetchProjetCoords(projetId);
            
            System.debug('Coordonnées mises à jour pour le projet: ' + projetId);
            
        } catch (Exception e) {
            System.debug('Erreur dans ProjetQueueable: ' + e.getMessage());
            // Log l'erreur ou envoyer une notification
        }
    }
}