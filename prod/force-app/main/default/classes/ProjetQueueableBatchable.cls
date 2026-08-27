public class ProjetQueueableBatchable implements Queueable, Database.AllowsCallouts {
    
    private static final Integer BATCH_SIZE = 20;
    private static final Integer DELAY_BETWEEN_CALLOUTS_MS = 1100;
    
    private List<Id> projetIds;
    private Integer currentIndex;
    
    public ProjetQueueableBatchable(List<Id> projetIds) {
        this(projetIds, 0);
    }
    
    public ProjetQueueableBatchable(List<Id> projetIds, Integer currentIndex) {
        this.projetIds = projetIds;
        this.currentIndex = currentIndex;
    }
    
    public void execute(QueueableContext context) {
        if (projetIds == null || projetIds.isEmpty() || currentIndex >= projetIds.size()) {
            return;
        }
        
        List<Id> batchToProcess = new List<Id>();
        Integer endIndex = Math.min(currentIndex + BATCH_SIZE, projetIds.size());
        
        for (Integer i = currentIndex; i < endIndex; i++) {
            batchToProcess.add(projetIds[i]);
        }
        
        List<Projet__c> projetsToUpdate = new List<Projet__c>();
        
        for (Id projetId : batchToProcess) {
            try {
                Long startTime = System.now().getTime();
                
                Projet__c projet = ProjetService.fetchProjetCoords(projetId);
                
                if (projet != null) {
                    projetsToUpdate.add(projet);
                }
                
                Long elapsedTime = System.now().getTime() - startTime;
                Long remainingDelay = DELAY_BETWEEN_CALLOUTS_MS - elapsedTime;
                Boolean isNotLastProjetInBatch = projetId != batchToProcess[batchToProcess.size() - 1];
                Boolean shouldWaitForRateLimit = remainingDelay > 0 && isNotLastProjetInBatch;
                
                if (shouldWaitForRateLimit) {
                    waitBetweenCallouts(remainingDelay);
                }
                
            } catch (Exception e) {
                System.debug('Erreur pour projet ' + projetId + ': ' + e.getMessage());
            }
        }
        
        if (!projetsToUpdate.isEmpty()) {
            try {
                update projetsToUpdate;
            } catch (Exception e) {
                System.debug('Erreur lors de la mise à jour des projets: ' + e.getMessage());
            }
        }
        
        if (endIndex < projetIds.size()) {
            System.enqueueJob(new ProjetQueueableBatchable(projetIds, endIndex));
        }
    }
    
    @TestVisible
    private static void waitBetweenCallouts(Long delayInMilliseconds) {
        Long currentTime = System.now().getTime();
        Long endDelayTime = currentTime + delayInMilliseconds;
        while (System.now().getTime() < endDelayTime) {
        }
    }
}