public with sharing class ATNQDynamicPathUtility {

    public static Object getValue(sObject record, String path) {
        if (path == null || String.isBlank(path))
            return null;

        Object value = null;
        String[] parts = path.split('\\.');
        for (integer i = 0; i < parts.size(); i++) {
            if (i == parts.size() - 1) {
                value = record.get(parts[i]);
            }
            else {
                record = record.getSObject(parts[i]);
            }
        }
        return value;
    }
}