@isTest
public class KAR_CalendarControllerTest {
    @isTest
    static void checkCalenderName(){
        test.startTest();
        
        Intranet_Content_Buckets__c intra = new Intranet_Content_Buckets__c();
        intra.Name='test';
        intra.Permission_Groups__c='Intranet Content Admins	';
        intra.Viewers__c='HR';
        intra.OwnerId = UserInfo.getUserId();
        insert intra;     

        
        
        
        Intranet_Content__c c = new Intranet_Content__c();
        c.Name='test';
        c.Content_Bucket__c=intra.Id;
        c.Team_Calendar_Name__c='test';
        c.RecordTypeId=Schema.SObjectType.Intranet_Content__C.getRecordTypeInfosByName().get('Team Page RT').getRecordTypeId();
        insert c;
        list<Intranet_Content__c> j = new list<Intranet_Content__c>([SELECT Id FROM Intranet_Content__c WHERE   Content_Bucket__r.Name = 'test' AND recordType.Name ='Team Page RT']);
       
        System.debug('>>-->>'+j);
        
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User();
        u.Alias = 'standt';
        u.Email='standarduser@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LastName='test';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey='America/Los_Angeles';
        u.UserName='standard@testorg.com';
        insert u;
        
        
        
         List<Event> resultList=new List<Event>();
        for(integer i=0;i<200;i++)
        {
            Event ev= new Event();
           ev.Ownerid = u.id;
            ev.Description ='test'+i;
            ev.Subject='test'+i;
            ev.StartDateTime=Date.today();
            ev.EndDateTime=Date.today();
            ev.CreatedById=u.id;
            resultList.add(ev);
            
        }
        insert resultList;
        
         ApexPages.currentPage().getParameters().put('name','test');
        
        KAR_CalendarController k =new KAR_CalendarController();
        
        
        
        
        
        
        
    

    }}