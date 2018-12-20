@isTest
public class TestStewardshipAccountTriggers {
    public static String currentTest = '';

    static testMethod void testFlippingResponse(){
        // Because we cannot test the creation of History object records during a Unit Test, 
        // there is a Test.isRunningTest() block in the afterupdate portion of the AccountAfterInsertUpdate Trigger, which assumes
        // the update of two records and simulates that the first record finds two flipping fields and the second
        // finds none.

        Stewardship_Users__c dgu = new Stewardship_Users__c();
        dgu.Name=UserInfo.getUsername();
        insert dgu;

        MDM_Settings__c mdms = new Mdm_Settings__c();
        mdms.Stale_Hours__c = 720;
        mdms.MDM_Test_Env_Endpoint__c = 'http://internal.test.auctionintegrationhub.com/karcustomermdm/KARCMDMService';
        mdms.MDM_Current_Environment__c = 'test';
        mdms.Minimum_Match_Score__c = 80;
        mdms.Data_Flipping_Limit__c = 48;
        insert mdms;

        Property__c p1 = new Property__c(Name='WS Security Username',Property_Id__c='wsse.username',Property_Value__c='fakeusername');
        insert p1;
        Property__c p2 = new Property__c(Name='WS Security Password',Property_Id__c='wsse.password',Property_Value__c='fakepassword');
        insert p2;     

        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name='Test Account', Integration_Id__c='12345', MDM_Refresh_Date__c = System.now().addMinutes(-1)));
        accountList.add(new Account(Name='Test Account2', Integration_Id__c='12345', MDM_Refresh_Date__c = System.now().addMinutes(-1)));
        insert accountList;
        Test.startTest();
            currentTest = 'FlipTest';
            update accountList;
            currentTest = '';
            List<Case> cList = [select id, Subject, AccountId  from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and AccountId = :accountList[0].id];
            System.assertEquals(1,cList.size());
            System.assertEquals('Data Flipping Notification',cList[0].Subject);
            System.assertEquals(accountList[0].Id,cList[0].AccountId);
            System.assertEquals(0,[select id from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and AccountId = :accountList[1].id].size());
        Test.stopTest();
    }

    // SINCE THIS HAS BEEN MOVED TO A SCHEDULED JOB, THIS IS NO LONGER AN APPROPRIATE TEST - EW - 2/1/17
    //static testMethod void testLocalAccountIntegration(){
    //    Stewardship_Users__c dgu = new Stewardship_Users__c();
    //    dgu.Name=UserInfo.getUsername();
    //    insert dgu;

    //    MDM_Settings__c mdms = new Mdm_Settings__c();
    //    mdms.Stale_Hours__c = 720;
    //    mdms.MDM_Test_Env_Endpoint__c = 'http://internal.test.auctionintegrationhub.com/karcustomermdm/KARCMDMService';
    //    mdms.MDM_Current_Environment__c = 'test';
    //    mdms.Minimum_Match_Score__c = 80;
    //    mdms.Data_Flipping_Limit__c = 48;
    //    insert mdms;

    //    Property__c p1 = new Property__c(Name='WS Security Username',Property_Id__c='wsse.username',Property_Value__c='fakeusername');
    //    insert p1;
    //    Property__c p2 = new Property__c(Name='WS Security Password',Property_Id__c='wsse.password',Property_Value__c='fakepassword');
    //    insert p2;     

    //    Account a = new Account(Name='Test Account', MDM_Refresh_Date__c = System.now().addMinutes(-1));

    //    Test.startTest();
    //        insert a;
    //        List<Case> cList = [select id, Subject, AccountId  from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and AccountId = :a.id and Subject = 'Local Account Integration'];
    //        System.assertEquals(1,cList.size());
    //        System.assertEquals(a.Id,cList[0].AccountId);
    //        System.assertEquals('Local Account Integration',cList[0].Subject);

    //    Test.stopTest();
    //}

    static testMethod void testKeyFieldDeletion(){
        Stewardship_Users__c dgu = new Stewardship_Users__c();
        dgu.Name=UserInfo.getUsername();
        insert dgu;

        MDM_Settings__c mdms = new Mdm_Settings__c();
        mdms.Stale_Hours__c = 720;
        mdms.MDM_Test_Env_Endpoint__c = 'http://internal.test.auctionintegrationhub.com/karcustomermdm/KARCMDMService';
        mdms.MDM_Current_Environment__c = 'test';
        mdms.Minimum_Match_Score__c = 80;
        mdms.Data_Flipping_Limit__c = 48;
        insert mdms;

        Property__c p1 = new Property__c(Name='WS Security Username',Property_Id__c='wsse.username',Property_Value__c='fakeusername');
        insert p1;
        Property__c p2 = new Property__c(Name='WS Security Password',Property_Id__c='wsse.password',Property_Value__c='fakepassword');
        insert p2;     
        
        Stewardship_Key_Fields__c dgkf = new Stewardship_Key_Fields__c();
        dgkf.Name='testkeyfield';
        dgkf.Object_Name__c = 'Account';
        dgkf.Field_Name__c = 'Integration_Id__c';
        insert dgkf;

        Account a = new Account(Name='Test Account', Integration_Id__c='12345', MDM_Refresh_Date__c = System.now().addMinutes(-1));
        insert a;

        Test.startTest();
            a.Integration_Id__c = null;
            update a;
            a = [select id, Integration_Id__c from Account where id = :a.id limit 1];
            Account b = [select id, Integration_Id__c from Account where id = :a.id limit 1];
            // This integration id was not deleted.
            System.assertEquals(a.Integration_Id__c,b.Integration_Id__c); 
            // A stewardship Case was created.
            List<Case> cList = [select id, Subject, AccountId  from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and AccountId = :a.id];
            System.assertEquals(1,cList.size());
            System.assertEquals('Key Field Deletion Attempt',cList[0].Subject);
        Test.stopTest();
    }
}