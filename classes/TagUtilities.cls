/* *******************************************
copyright (c) 2016 Appirio Inc.

author:Jim Cook
purpose: Fetch Versioned content by Tag(s).

********************************************** 8*/
public with sharing class TagUtilities {

  public static List<EdgeForceIntranetContentController.ContentVersionWrapper> getVersionedContentByTags(List<String> resultFields, List<String> tags, String rtName) {
    DateTime td = DateTime.now();
    String todaysDate = td.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');   
    List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    List<EdgeForceIntranetContentController.ContentVersionWrapper> finalList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    
    // Get IDs of Tags, and create a list of those IDs.
    List<Intranet_Content_Tags__c> aaa = [SELECT ID, Intranet_Content__c, Tags__r.Tag__c 
                                          FROM   Intranet_Content_Tags__c 
                                          WHERE  Tags__r.Tag__c in :tags];
    List<Id> x = new List<Id>();
    for(Intranet_Content_Tags__c bbb : aaa) {
       x.add(bbb.Intranet_Content__c);
    }
    
    // Build SOQL string to fetch correct Intranet_Content__c items.
    String queryString = 'SELECT Id, (SELECT Id FROM Attachments)';
    for(String cField : resultFields ) {
       queryString +=( ', ' +cField);
    }
    queryString += ' FROM Intranet_Content__c WHERE recordType.Name = \'' + rtName + '\'';
    queryString += ' AND  Start_Date__c <=' + todaysDate  + ' AND  End_Date__c >=' +  todaysDate ;
    queryString += ' AND  Status__c=\'Published\' '; 
    queryString += ' AND Id IN ( ';
    for(String d : x ) { 
       queryString += '\'' + d + '\', ';
    }
    queryString = queryString.substring(0, queryString.length()-2);
    queryString+= ' )  ORDER BY Sequence__c ASC NULLS LAST, Start_Date__c DESC';
    
    EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
    try {
       tempList = contentController.processContentAndVersionMenu(queryString);
    }
    catch(Exception e) {
    	System.debug('queryString failed in TagUtilities line 42. '+ queryString + ' error: ' + e.getMessage() );
    	return finalList;
    }
    for(Intranet_Content__c content : Database.query(queryString))
    {
     for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempList)    {
        if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
            finalList.add(wrapper);
          }else{
            continue;
          }
        }   	
    }                                     
    System.debug('*** queryString=' + queryString);  
    System.debug('*** tempList.size=' + tempList.size());  
    System.debug('*** finalList.size=' + finalList.size());

/*    List<Intranet_Content__c> res = Database.query(queryString);
    SYstem.debug('*** res.size()= ' + res.size() + ' ' + queryString);
    for(Intranet_Content__c xx :  res){
       finalList.add(new EdgeForceIntranetContentController.ContentVersionWrapper(xx, null) );
    }
*/
    return finalList;
  }


}