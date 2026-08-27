public class ProjetGeocodeScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ProjetGeocodeBatch(), 1);
    }
}