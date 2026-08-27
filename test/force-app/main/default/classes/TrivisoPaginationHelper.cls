public class TrivisoPaginationHelper {

    public static final Integer DEFAULT_PAGE_SIZE = 500;

    public static Map<String, Object> parseRequest(RestRequest req) {
        String body = req.requestBody != null ? req.requestBody.toString() : '';
        return String.isNotBlank(body)
            ? (Map<String, Object>) JSON.deserializeUntyped(body)
            : new Map<String, Object>();
    }

    public static String getLastId(Map<String, Object> requestMap) {
        return (String) requestMap.get('lastId');
    }

    public static Integer getPageSize(Map<String, Object> requestMap) {
        return requestMap.containsKey('pageSize')
            ? Integer.valueOf(String.valueOf(requestMap.get('pageSize')))
            : DEFAULT_PAGE_SIZE;
    }

    public static DateTime getSinceDate(Map<String, Object> requestMap) {
        String raw = (String) requestMap.get('sinceDate');
        if (String.isBlank(raw)) return null;
        List<String> parts = raw.split('/');
        if (parts.size() != 3) return null;
        Integer day   = Integer.valueOf(parts[0]);
        Integer month = Integer.valueOf(parts[1]);
        Integer year  = Integer.valueOf(parts[2]);
        Date d = Date.newInstance(year, month, day);
        return DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));
    }
}