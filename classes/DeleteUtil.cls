global with sharing class DeleteUtil 
{
    webservice static List<CustomDeleteResult> deleteByExternalId(String objectType, String fieldName, List<String> externalIds)
    {
        List<String> quotedExternalIds = new List<String>();
        for (String s : externalIds)
        {
            quotedExternalIds.add('\''+s+'\'');
        }
        
        String query = 'SELECT Id, '+fieldName+' FROM '+objectType+' WHERE '+fieldName+' IN ('+Utils.joinList(quotedExternalIds, ',')+')';
        List<SObject> objs = Database.query(query);
        
        Map<Object, Integer> indexMap = new Map<Object, Integer>();
        for (Integer i = 0; i < objs.size(); i++)
        {
            indexMap.put(objs.get(i).get(fieldName), i);
        }
        
        List<Database.DeleteResult> deleteResults = Database.delete(objs);
        
        List<CustomDeleteResult> rtnList = new List<CustomDeleteResult>();
        for (String externalId : externalIds)
        {
            Integer i = indexMap.get(externalId);
            if (i != null)
            {
                Database.DeleteResult r = deleteResults[i];
                CustomDeleteResult cdr = new CustomDeleteResult();
                cdr.isSuccess = r.isSuccess();
                if (r.getErrors() != null)
                {
                    List<String> errors = new List<String>();
                    for (Database.Error error : r.getErrors())
                    {
                        errors.add(error.getMessage());
                    }
                }
                rtnList.add(cdr);
            }
            else
            {
                CustomDeleteResult cdr = new CustomDeleteResult();
                cdr.isSuccess = false;
                cdr.errors = new String[] {'External Id ' + externalId + ' could not be found.'};
            }
        }
        return rtnList;
    }
    
      webservice static Boolean deleteByConditions(String objectType, String conditionString, List<String> ids)
    {
        Boolean deleteResult = false;
        
        List<String> quotedIds= new List<String>();
        for (String id : ids)
        {
            quotedIds.add('\''+id+'\'');
        }
        String query = 'Select Id FROM '+ objectType +' WHERE id IN ('+Utils.joinList(quotedIds, ',')+')';
        if(conditionString != '') 
            query += ' AND ' + conditionString;
        List<SObject> objs = Database.query(query);
        
        try 
        {
           if (objs.size() > 0 )
           {
              Database.delete(objs);              
           }
           else
           {
              system.debug(' No satisfied records was found in object ' + objectType );
           }
           deleteResult = true;
        }
        catch (Exception e) 
        {
           system.debug(e);
        }
        return deleteResult;
        
    }
    
    global class CustomDeleteResult
    {
        webservice Boolean isSuccess {get; set;}
        webservice List<String> errors {get; set;}
    }
}