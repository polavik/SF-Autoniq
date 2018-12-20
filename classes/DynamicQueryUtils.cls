public class DynamicQueryUtils {
	public class DynamicQueryException extends Exception{}
    private static final String CONTACT_ADMIN_ERROR=' Contact your administrator';
    private static final String NO_FIELDS='No fields to show on the table.';

    public static String getDynamicQuery(String objectName, Set<String> fieldsToQuery, Set<String> fieldsToFilter, sObject filterValuesDummyObj){
        if(fieldsToQuery.isEmpty()){
            throw new DynamicQueryException(NO_FIELDS + CONTACT_ADMIN_ERROR);
        }

        //Basic query
        String query = 'SELECT ' +
                        String.join(new List<String>(fieldsToQuery), ',') +
                        ' FROM '+ objectName + ' ';
        
        //Filters
        List<String> filters = new List<String>();

        for(String fieldName : fieldsToFilter){
            Object fieldValue = filterValuesDummyObj.get(fieldName);
            if(fieldValue!=null){
                //Escape single quotes on string fields
                if(fieldValue instanceof String){
                    fieldValue = '\'' + String.escapeSingleQuotes((String) fieldValue) + '\'';
                } else if(fieldValue instanceof Date){
                    fieldValue = String.valueOf((Date) fieldValue);
                } else if(fieldValue instanceof DateTime){
                    fieldValue = ((Datetime) fieldValue).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');
                }
                filters.add(fieldName + '=' + fieldValue);
            }
        }
        if(!filters.isEmpty()){
                query += ' WHERE ' + String.join(filters, ' AND ');
        }

        return query;
    }
}