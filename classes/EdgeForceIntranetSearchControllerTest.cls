/**
  * Apex Class: IntranetSearchControllerTest
  * Description: test class for IntranetSearchController
  * Created By: kenji
  * Created Date: 12/05/2012
  * LastModifiedBy : Harshit Jain
  * LastModifiedDate : 12/24/2012
  * RealetedTo :  T-106113-Test search configuration via intranet config custom setting
*/
@isTest
private without sharing class EdgeForceIntranetSearchControllerTest {

    static testMethod void testSearch() {
        RecordType RecType = [Select Id From RecordType Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Language'];
        Intranet_Content__c intranetCategoryLimit = IntranetTestUtility.createIntranetConfig(true, 'Search Limit', '100');
        Intranet_Content__c intranetPaginationLimit = IntranetTestUtility.createIntranetConfig(true, 'Search Pagination', '10');
        Intranet_Content__c intranetLanguage = IntranetTestUtility.createIntranetConfig(false, 'en_US', 'English');
        intranetLanguage.RecordTypeId = RecType.Id;
        insert intranetLanguage;

        RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Portal'];
        Intranet_content__c  IC = new Intranet_content__c (Name =userinfo.getLanguage(),value__c = 'English',recordTypeId = RecType.id);
        insert IC;

        RecordType searchRT = [Select id From RecordType Where Name='Config - Search' Limit 1];

        Intranet_Content__c searchConfig = new Intranet_Content__c();
        searchConfig.Name = 'Chatter Post';
        searchConfig.Object_Name__c = 'FeedItem';
        searchConfig.RecordTypeId = searchRT.id;
        insert searchConfig;

        searchConfig = new Intranet_Content__c();
        searchConfig.Name = 'Documents';
        searchConfig.Object_Name__c = 'ContentVersion';
        searchConfig.RecordTypeId = searchRT.id;
        insert searchConfig;

        searchConfig = new Intranet_Content__c();
        searchConfig.Name = 'Article';
        searchConfig.Object_Name__c = 'Intranet_Content_Version__c';
        searchConfig.RecordTypeId = searchRT.id;
        insert searchConfig;

        searchConfig = new Intranet_Content__c();
        searchConfig.Name = 'ChatterUser';
        searchConfig.Object_Name__c = 'User';
        searchConfig.RecordTypeId = searchRT.id;
        insert searchConfig;
        
        searchConfig = new Intranet_Content__c();
        searchConfig.Name = 'Account';
        searchConfig.Object_Name__c = 'Account';
        searchConfig.RecordTypeId = searchRT.id;
        insert searchConfig; 


        system.assertEquals(EdgeForceIntranetSearchController.categoryLimit, 100);
        system.assertEquals(EdgeForceIntranetSearchController.paginationLimit, 10);

        //array for holding the Ids of objects that will be returned from the SOSL query
        list<id> fixedSearchResults= new list<id>();

        //get a list of searchable objects
        map<string,string> objectsList = EdgeForceIntranetSearchController.getSearchableObjects();

        //create an account
        Account testAccount = new Account();
        testAccount.name = 'test';
        insert testAccount;

        fixedSearchResults.add(testAccount.id);

        //create a user
        User createUser;

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            createUser = IntranetTestUtility.createUser(1,true);
            fixedSearchResults.add(createUser.id);
        }
        fixedSearchResults.add(thisUser.Id);

        ContentWorkSpace cwMaster = [Select Id from ContentWorkSpace Limit 1]; //where Name like '%Teva Master'];
        
        ContentVersion testContentInsert = new ContentVersion();
        System.runAs ( createUser ) {
        testContentInsert.ContentURL='http://www.google.com/';
        testContentInsert.Title ='Google.com';
        insert testContentInsert;
        }
        fixedSearchResults.add(testContentInsert.id);

        //create a chatter post
        FeedItem fitem = new FeedItem();
        fitem.type = 'TextPost';
        fitem.ParentId = UserInfo.getUserId();
        fitem.Title = 'test';  //This is the title that displays for the LinkUrl
        fitem.body = 'Production deploy test';
        insert fitem;
        fixedSearchResults.add(fitem.id);

        //fixedSearchResults.add(fItem.id);

        String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet Article').getRecordTypeId();
        String recordTypeId_learningCenter = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet Link').getRecordTypeId();

        //Insert new Intranet_Article__c records
        Intranet_Content__c article1 = new Intranet_Content__c();
        article1.Type__c = 'News';
        article1.Name = 'Test';
        article1.Start_Date__c = Datetime.now();
        article1.End_Date__c = Datetime.now().addDays(5);
        article1.URL__c = 'testtest';
        //article1.Pages__c = 'Brand';
        article1.RecordTypeId = recordTypeId;
        
        Intranet_Content__c article2 = new Intranet_Content__c();
        article2.Article_Type__c = 'News';
        article2.Name = 'Test';
        article2.Start_Date__c = Datetime.now();
        article2.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        article2.URL__c = 'testtest';
        article2.Skip_Menu_Link__c = true;
        article2.RecordTypeId = recordTypeId;
        
        Intranet_Content__c articleLearning = new Intranet_Content__c();
        articleLearning.Article_Type__c = 'News';
        articleLearning.Type__c = 'News';
        articleLearning.Name = 'Test';
        articleLearning.Start_Date__c = Datetime.now();
        articleLearning.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        articleLearning.URL__c = 'testtest';
        articleLearning.Skip_Menu_Link__c = true;
        articleLearning.RecordTypeId = recordTypeId_learningCenter;
        list<Intranet_Content__c> listArticle = new list<Intranet_Content__c>{article1,article2, articleLearning};
        for(Intranet_Content__c icontent : listArticle){
            icontent.Status__c = 'Published';
        }
        insert listArticle;

        Intranet_Content_Version__c intraContVer1 = new Intranet_Content_Version__c();
        intraContVer1.Intranet_Content__c = article1.Id;
        intraContVer1.Name = 'Test';
        intraContVer1.Language__c = 'English';
        intraContVer1.Summary__c  = 'test';
        intraContVer1.Primary_Record__c = true;
        intraContVer1.Description__c = 'testtest';

        Intranet_Content_Version__c intraContVer2 = new Intranet_Content_Version__c();
        intraContVer2.Intranet_Content__c = article2.Id;
        intraContVer2.Name = 'Test';
        intraContVer2.Summary__c  = 'test';
        intraContVer2.Description__c = 'testtest';
        
        Intranet_Content_Version__c intraContVerLearning = new Intranet_Content_Version__c();
        intraContVerLearning.Intranet_Content__c = articleLearning.Id;
        intraContVerLearning.Name = 'Test';
        intraContVerLearning.Summary__c  = 'test';
        intraContVerLearning.Description__c = 'testtest';
        
        list<Intranet_Content_Version__c> listContentVer = new list<Intranet_Content_Version__c>{intraContVer1,intraContVer2, intraContVerLearning};
        insert listContentVer;
        fixedSearchResults.add(intraContVer1.id);
        fixedSearchResults.add(intraContVer2.id);
        fixedSearchResults.add(intraContVerLearning.id);
                
        recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet CMS Pages').getRecordTypeId();
        String recType1 = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet Link').getRecordTypeId();
        //Insert new Intranet CMS Page records
        article1 = new Intranet_Content__c();
        article1.Name = 'Test';
        article1.Type__c = 'News';
        article1.Start_Date__c = Datetime.now();
        article1.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        article1.URL__c = 'testtest';
        article1.RecordTypeId = recordTypeId;
        article1.Status__c = 'Published';
        article1.Show_In_Header_Menu__c = true;
        article1.Template__c = 'Home';
        article1.Parent__c = listArticle[0].id;
                insert article1;
                
        article2 = new Intranet_Content__c();
        article2.Name = 'Test';
        article2.Type__c = 'News';
        article2.Start_Date__c = Datetime.now();
        article2.End_Date__c = Datetime.now().addDays(5);
        //article2.Pages__c = 'Brand';
        article2.Status__c = 'Published';
        article2.RecordTypeId = recType1;
        article2.Show_In_Header_Menu__c = true;
        article2.Template__c = 'Interior Home';
        article2.URL__c = 'testtest';
        article2.Skip_Menu_Link__c = false;
                
        Intranet_Content__c article3 = createIntranetContent('test2',recordTypeId,'Team',false);
        article3.Parent__c = listArticle[0].id;
        Intranet_Content__c article4 = createIntranetContent('test2',recordTypeId,'Content',false);
        article4.Parent__c = listArticle[0].id;
        Intranet_Content__c article5 = createIntranetContent('test3',recordTypeId,'Home',false);
        article5.Parent__c = article1.id;
        Intranet_Content__c article6 = createIntranetContent('test4',recordTypeId,'Interior Home',false);
        article6.Parent__c = article1.id;

        listArticle = new list<Intranet_Content__c>{article2,article3,article4,article5, article6};
        insert listArticle;

        intraContVer1 = new Intranet_Content_Version__c();
        intraContVer1.Intranet_Content__c = article1.Id;
        intraContVer1.Name = 'test';
        intraContVer1.Summary__c  = 'test';
        intraContVer1.Language__c = 'test';
        intraContVer1.Primary_Record__c = true;
        intraContVer1.Description__c = 'testest';

        intraContVer2 = new Intranet_Content_Version__c();
        intraContVer2.Intranet_Content__c = article2.Id;
        intraContVer2.Name = 'test';
        intraContVer2.Summary__c  = 'test';
        intraContVer2.Language__c = 'test';
        intraContVer2.Primary_Record__c = false;
        intraContVer2.Description__c = 'testest';

        Intranet_Content_Version__c intraContVer3 = new Intranet_Content_Version__c();
        intraContVer3.Intranet_Content__c = article3.Id;
        intraContVer3.Name = 'test';
        intraContVer3.Summary__c  = 'test';
        intraContVer3.Language__c = 'English';
        intraContVer3.Description__c = 'testest';

        Intranet_Content_Version__c intraContVer4 = new Intranet_Content_Version__c();
        intraContVer4.Intranet_Content__c = article4.Id;
        intraContVer4.Name = 'test';
        intraContVer4.Summary__c  = 'test';
        intraContVer4.Language__c = 'English';
        intraContVer4.Description__c = 'testest';
        
        Intranet_Content_Version__c intraContVer5 = new Intranet_Content_Version__c();
        intraContVer5.Intranet_Content__c = article5.Id;
        intraContVer5.Name = 'test';
        intraContVer5.Summary__c  = 'test';
        intraContVer5.Language__c = 'English';
        intraContVer5.Description__c = 'testest';
        
        Intranet_Content_Version__c intraContVer6 = new Intranet_Content_Version__c();
        intraContVer6.Intranet_Content__c = article6.Id;
        intraContVer6.Name = 'test';
        intraContVer6.Summary__c  = 'test';
        intraContVer6.Language__c = 'English';
        intraContVer6.Description__c = 'testest';

        listContentVer = new list<Intranet_Content_Version__c>{intraContVer1,intraContVer2,intraContVer3,intraContVer4,intraContVer5,intraContVer6};
        insert listContentVer;

        fixedSearchResults.add(intraContVer1.id);
        fixedSearchResults.add(intraContVer2.id);
        fixedSearchResults.add(intraContVer3.id);
        fixedSearchResults.add(intraContVer4.id);
        fixedSearchResults.add(intraContVer5.id);
        fixedSearchResults.add(intraContVer6.id);

        string[] objectsToSearch = new  string[]{'Intranet_Content_Version__c','User','FeedItem','ContentVersion'};
        map<string,string> labels = new map<string,string>();
        labels.put('Account','Clients');

        //set the results of the SOSL query
        Test.setFixedSearchResults(fixedSearchResults);
        string[] tagList = new  string[]{'Test','Home','test'};
        string[] fileTypeList = new  string[]{'jpeg','jpg','pdf','txt','link'};
        
        EdgeForceIntranetSearchController.globalSearch('test', false, objectsToSearch, tagList, fileTypeList, labels, 10, new List<String>());

        EdgeForceIntranetSearchController.globalSearch('test', false, objectsToSearch, new List<String>(), new List<String>(), labels, 10, new List<String>());
    }

    public static Intranet_Content__c createIntranetContent(string name, id recordTypeId, string templateName, boolean isInsert){
        Intranet_Content__c article2 = new Intranet_Content__c();
        article2.Name = name;
        article2.Type__c = 'News';
        article2.Start_Date__c = Datetime.now();
        article2.End_Date__c = Datetime.now().addDays(5);
        //article2.Pages__c = 'Brand';
        article2.Status__c = 'Published';
        article2.RecordTypeId = recordTypeId;
        article2.Show_In_Header_Menu__c = true;
        article2.Template__c = templateName;
        //article2.URL__c = 'https://testtest';
        if(isInsert){
            insert article2;
        }
        return article2;
    }

}