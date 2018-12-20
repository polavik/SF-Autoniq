/* *************************************************************************
   Copyright (c) Appirio 2017

Created By   : Jim Cook (Appirio)
Created Date : January 21,2017
Description  : Static methods to simplify access to Intranet_Content__c.

**************************************************************************** */
public  class ContentUtilities {

   public static List<EdgeForceIntranetContentController.ContentVersionWrapper> content{get; set;}

   public static List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllContent(){
        // If we already have the data, return it.
        if(null != content) return content;
        
        //Build the query for finding content.
        String queryString = 'SELECT Name, Id, RecordType.Name, Parent__c, Parent__r.Name, Content_Bucket__r.Name, Skip_Menu_Link__c, ' + 
                                     'Sequence__c, URL__c, Target__c, Template__c, Team_Brand_Image_File_Name__c,' + 
                                     'Page_Type__c, Show_In_Header_Menu__c, Content_Type__c, Language__c, Team_Mission_Statement__c, Title__c, ' +
                                     'Show_Sub_Team__c, Sub_Team_Sequence__c, Description__c, Target_URL__c, Status__c, ' +
                                     'Show_Meet_The_Team__c, Meet_The_Team_Sequence__c, ' +
                                     'Show_About_The_Team__c, About_The_Team_Sequence__c, ' +
                                     'Show_News__c, News_Sequence__c, Start_Date__c, End_Date__c, ' +
                                     'Show_Calendar__c, Calendar_Sequence__c, ' +
                                     'Address_Street__c, Address_City__c, Address_State__c, Address_ZIP__c, Address_Country__c, ' +
                                     'Email__c, Phone__c, Logo_File_Name__c,' +
                                     'Show_Chatter_Feed__c, Chatter_Feed_Sequence__c, ' +
                                     'Show_Collapsible_Content__c, Collapsible_Content_Sequence__c, ' +
                                     'Show_News_Banner__c, News_Banner_Sequence__c, ' +
                                     'Show_Resource_Library__c, Resource_Library_Sequence__c, Overlay_Color__c, ' + 
                                     '(SELECT Id, Name FROM Attachments), ' +
                                     '(SELECT Tags__r.Tag__c FROM Intranet_Content_Tags__r) ' + 
                             'FROM Intranet_Content__c WHERE ' + 
                              ContentBucketUtilities.buildTheBucketSOQLClause(ContentBucketUtilities.getBucketNamesForAUser(UserInfo.getUserId()), '') +
                              ' ORDER BY Parent__c, Sequence__c ASC';
        EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
        System.debug('queryString ' + queryString);
        try{
        	content = contentController.processContentAndVersionMenu(queryString);
        }
        catch(Exception e){
        	content = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        }
        return content;
   }
}