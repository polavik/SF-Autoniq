@isTest
private class TestInspectionRequestHelper {

    static testMethod void test1() 
    {
      Property__c objProperty2 = new Property__c(Property_Id__c='is.migration.running',Property_Value__c='Yes');
        insert objProperty2 ;  
      
      Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '1234567', Source_Id__c = '1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Inspection_Request__c ir = new Inspection_Request__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '1234567', Purchase__c = p.Id, PSI_Passed__c = 'Cancel', PSI_Cancel_Redirect__c = false);
        insert ir;
    }
  
    /*
    static testMethod void testFail() 
    {
        Property__c objProperty2 = new Property__c(Property_Id__c='is.migration.running',Property_Value__c='No');
        insert objProperty2 ;        
        System.debug('-----Property__c.Property_Id__c = [' + objProperty2.Property_Id__c + '] value=' + objProperty2.Property_Value__c);
        
        
       Id profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;        
       User emp = new User
       (
           Alias='test3',Email='test3@test.com',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
           ProfileId=profileId,TimeZoneSidKey='America/Los_Angeles', UserName='test3@test.com.afctest'
       );
    insert emp;
    
    //SELECT  ATC_Organization_ID__c,id,CDN_Joint_Election_Form_on_File__c FROM account
       Account a = new Account(Name='Test Account And Stuff' ,ATC_Organization_ID__c ='123456',CDN_Joint_Election_Form_on_File__c =true);
        insert a;
        
        Contact con = new Contact(LastName='Mr. Awesomeson');
        insert con;        

        Document ms = new Document();
        ms.Name = 'Mediator Certificate';
        Blob bb = Blob.valueOf('testtesttesttesttesttestetesatetestetestetstestestesterateMIIMSAIBAzCCDA4GC');
        ms.body=bb;
        ms.FolderId = emp.id;
    insert ms;

        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '1234567', Source_Id__c = '1234567',
               Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, 
               ATC_Buyer__c=a.Id, ATC_Buyer_Contact__c = con.Id, Inspection_Fee__c = 100.1,
               Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;       
        System.debug('-----Purchase__c.name = [' + p.name + '] id= [' + p.id + ']');

    
        Inspection_Request__c ir3 = new Inspection_Request__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '1234567', 
                        Purchase__c = p.Id, PSI_Passed__c = 'FAIL', PSI_Cancel_Redirect__c = false,
                        process_PSI__c=true ,
                        PSI_Review_Comments__c = 'test PSI Review Comments',
                        PSI_Failed_Reason__c = 'test PSI Failed Reason' ,Inspection_Type__c ='PSI by Processing Auction 7-day Full'
                         );
       insert ir3;
     Test.startTest();            
    Test.setMock(WebServiceMock.class, new WebServiceMockMediator());
        System.debug('-----Inspection_Request__c ir3.name = [' + ir3.name + '], ir3.PSI_Passed__c =' + ir3.PSI_Passed__c);
 
    Test.stopTest();                  
    }
    */
    
    static testMethod void testCancel() 
    {
        Property__c objProperty2 = new Property__c(Property_Id__c='is.migration.running',Property_Value__c='No');
        insert objProperty2 ;        
        System.debug('-----Property__c.Property_Id__c = [' + objProperty2.Property_Id__c + '] value=' + objProperty2.Property_Value__c);
        
        
       Id profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;        
       User emp = new User
       (
           Alias='test3',Email='test3@test.com',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
           ProfileId=profileId,TimeZoneSidKey='America/Los_Angeles', UserName='test3@test.com.afctest'
       );
    insert emp;
    
       Account a = new Account(Name='Test Account And Stuff');
        insert a;
        
        Contact con = new Contact(LastName='Mr. Awesomeson');
        insert con;        

        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '1234567', Source_Id__c = '1234567',
               Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, 
               ATC_Buyer__c=a.Id, ATC_Buyer_Contact__c = con.Id, Inspection_Fee__c = 100.1,
               Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;       
        System.debug('-----Purchase__c.name = [' + p.name + '] id= [' + p.id + ']');
        
        Document ms = new Document();
        ms.Name = 'Mediator Certificate';
        Blob bb = Blob.valueOf('testtesttesttesttesttestetesatetestetestetstestestesterateMIIMSAIBAzCCDA4GC');
        ms.body=bb;
        ms.FolderId = emp.id;
    insert ms;
            
     Test.startTest();            
                
        Inspection_Request__c ir = new Inspection_Request__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '1234567', 
                          Purchase__c = p.Id, PSI_Passed__c = 'Cancel', PSI_Cancel_Redirect__c = false,process_PSI__c=true,
                            PSI_Review_Comments__c = 'test PSI Review Comments',
                            PSI_Failed_Reason__c = 'test PSI Failed Reason' ,Inspection_Type__c ='PSI by Processing Auction 7-day Full'
                            
                        );
        insert ir;
        System.debug('-----Inspection_Request__c ir.name = [' + ir.name + '], ir.PSI_Passed__c =' + ir.PSI_Passed__c);
    Test.stopTest();               
    }
    
    static testMethod void testPASS() 
    {
        Property__c objProperty2 = new Property__c(Property_Id__c='is.migration.running',Property_Value__c='No');
        insert objProperty2 ;        
        System.debug('-----Property__c.Property_Id__c = [' + objProperty2.Property_Id__c + '] value=' + objProperty2.Property_Value__c);
        
        
       Id profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;        
       User emp = new User
       (
           Alias='test3',Email='test3@test.com',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
           ProfileId=profileId,TimeZoneSidKey='America/Los_Angeles', UserName='test3@test.com.afctest'
       );
    insert emp;
    
       Account a = new Account(Name='Test Account And Stuff');
        insert a;
        
        Contact con = new Contact(LastName='Mr. Awesomeson');
        insert con;        

        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '1234567', Source_Id__c = '1234567',
               Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, 
               ATC_Buyer__c=a.Id, ATC_Buyer_Contact__c = con.Id,
               Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;       
        System.debug('-----Purchase__c.name = [' + p.name + '] id= [' + p.id + ']');
        
        Document ms = new Document();
        ms.Name = 'Mediator Certificate';
        Blob bb = Blob.valueOf('testtesttesttesttesttestetesatetestetestetstestestesterateMIIMSAIBAzCCDA4GC');
        ms.body=bb;
        ms.FolderId = emp.id;
    insert ms;
            
        Test.startTest();  
        Inspection_Request__c ir2 = new Inspection_Request__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '1234567',
                         Purchase__c = p.Id, PSI_Passed__c = 'PASS', PSI_Cancel_Redirect__c = false,process_PSI__c=true,                         
                        PSI_Review_Comments__c = 'test PSI Review Comments',
                        PSI_Failed_Reason__c = 'test PSI Failed Reason' ,Inspection_Type__c ='PSI by Processing Auction 7-day Full'                         
                         );
        insert ir2;
        System.debug('-----Inspection_Request__c ir2.name = [' + ir2.name + '], ir2.PSI_Passed__c =' + ir2.PSI_Passed__c);
    
    Test.stopTest();
                           
    }
 
}