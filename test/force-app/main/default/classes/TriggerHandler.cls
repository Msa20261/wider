public class TriggerHandler {
    public static Boolean bypassProjetTrigger = false;

    @InvocableMethod(label='Bypass Projet Trigger' description='Désactive le ProjetTrigger pour la durée de la transaction. À appeler depuis un Flow avant tout CreateNewProjet.')
    public static void setBypassProjetTrigger() {
        bypassProjetTrigger = true;
    }
}