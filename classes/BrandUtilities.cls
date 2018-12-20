public class BrandUtilities {

// Retrieve list of brands to display in dropdown.   
   public static List<EdgeForceIntranetContentController.ContentVersionWrapper> getBrandList() {
        List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        List<EdgeForceIntranetContentController.ContentVersionWrapper> resultList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    
    
      String queryString =  'Select Id, Name, Description__c, Team_Mission_Statement__c, Brand_Lifecycle_Category__c, ' + 
                                    'Lifecycle_Flipcard_Image__c,Team_Brand_Image_File_Name__c, Target__c,Frame_Height__c,' + 
                                    '(SELECT Id, Name FROM Attachments order by Name)' +
                                    'From Intranet_Content__c  '  + 
                                    'WHERE Status__c=\'Published\' ' +
                                    'AND RecordType.Name =\'Team Page RT\' AND Page_Type__c=\'Brand\' order by Name';
      EdgeForceIntranetContentController versionHandler = new EdgeForceIntranetContentController();
      tempList = versionHandler.processContentAndVersionMenu(queryString);
      
        for(Intranet_Content__c bList : [Select Id From Intranet_Content__c 
                                         WHERE Status__c='Published' 
                                         AND RecordType.Name ='Team Page RT' 
                                         AND Page_Type__c='Brand' 
                                         order by Name])
        { 
           Integer attachCount = 0;       
           for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempList) {
              attachCount = 0;
                    for( Attachment att : wrapper.content.Attachments) {
                       if( att.Name == wrapper.content.Team_Brand_Image_File_Name__c) wrapper.baseImageLocation = attachCount;                       
                       attachCount++;
                    } 
             if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(bList.Id).substring(0,15)){
                resultList.add(wrapper);
             }
           }
        }
        
      return resultList;
    }


}