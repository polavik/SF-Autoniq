@isTest
public class TestDataGatewayContact {
    public static String currentTest = '';

    static testMethod void testCheckNumberOfChanges(){
        currentTest = 'testCheckNumberOfChanges';
        Test.setMock(HttpCalloutMock.class,new TestDataGatewayMDMServiceMock('Organization'));
        Data_Gateway_MDMService_Endpoint__c endpoint = new Data_Gateway_MDMService_Endpoint__c(Name='MDMServiceEndpoint',Environment_URL__c='http://inthub.test.auctionintegrationhub.com/karcustomermdm/KARCMDMService');
        insert endpoint;
        Account a = new Account(Name='Test Account');
        insert a;
        Test.setMock(HttpCalloutMock.class,new TestDataGatewayMDMServiceMock('Person'));
        Contact c = new Contact(LastName='Last Name',FirstName='First Name',Rep_Auction_Access_Number__c='100877633');
        insert c;

        Data_Gateway_Flip_Fields__c flipField1 = new Data_Gateway_Flip_Fields__c(Name='Rep_Auction_Access_Number__c',Object_Name__c='Contact',Timeframe__c=2);
        Data_Gateway_Flip_Fields__c flipField2 = new Data_Gateway_Flip_Fields__c(Name='Name',Object_Name__c='Contact',Timeframe__c=2);
        Map<String,Data_Gateway_Flip_Fields__c> flipFieldMap = new Map<String,Data_Gateway_Flip_Fields__c>();
        flipFieldMap.put('Rep_Auction_Access_Number__c',flipField1);
        insert flipField1;
        insert flipField2;
        flipFieldMap.put('Name',flipField2);
        
        DateTime dateReference = System.now();
        Test.startTest();
            // Note: We are using the JSON method in this Test because is allows us to set the CreatedDate for the History (which is relevant to our test).
            // Testing that the second Auction_Access_Number__c is not considered, because it is out of range for the custom setting's Time_Reference__c value.
            List<ContactHistory> historyList = new List<ContactHistory>();
            historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
            historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Federal_Tax_Identification_Id__c","CreatedDate":"'+dateReference.addDays(-1).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
            historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Integration_Id__c","CreatedDate":"'+dateReference.addDays(-2).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
            historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.addDays(-3).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
            Map<String,Integer> changes = DataGatewayContactHelper.checkNumberOfChanges(flipFieldMap,historyList);
            System.assertEquals(1, changes.get('Rep_Auction_Access_Number__c'));
            System.assertEquals(0, changes.get('Name'));
            System.assertEquals(null, changes.get('Federal_Tax_Identification_Id__c')); 

            // Testing that both values for Auction_Access_Number__c are considered.
            List<ContactHistory> historyList2 = new List<ContactHistory>();
            historyList2.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
            historyList2.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.addDays(-1).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
            System.debug(historyList2);
            Map<String,Integer> changes2 = DataGatewayContactHelper.checkNumberOfChanges(flipFieldMap,historyList2);
            System.assertEquals(2, changes2.get('Rep_Auction_Access_Number__c'));
            System.assertEquals(0, changes2.get('Name'));
            System.assertEquals(null, changes2.get('Federal_Tax_Identification_Id__c'));

        Test.stopTest();
        currentTest = '';
    }

    static testMethod void testWrongUser(){
        currentTest = 'testWrongUser';
        Data_Gateway_Users__c dataGatewayUsers = new Data_Gateway_Users__c(Name='Test User Name');
        insert dataGatewayUsers;

        currentTest = 'testWrongUser';
        Account a = new Account(Name='Test Account');
        insert a;
        Contact c = new Contact(LastName='Last Name',FirstName='First Name', AccountId=a.id);
        insert c;
        
        Test.startTest();
            c.Integration_Id__c = '12345';
            update c;
            // If we do not get an exception from the AccountAfterInsertUpdate trigger, this test passes
        Test.stopTest();
        currentTest = '';
    }

    static testMethod void testWithViolations(){
        currentTest = 'testWithViolations';
        Test.setMock(HttpCalloutMock.class,new TestDataGatewayMDMServiceMock('Organization'));
        Data_Gateway_MDMService_Endpoint__c endpoint = new Data_Gateway_MDMService_Endpoint__c(Name='MDMServiceEndpoint',Environment_URL__c='http://inthub.test.auctionintegrationhub.com/karcustomermdm/KARCMDMService');
        insert endpoint;
        Account a = new Account(Name='Test Account');
        insert a;
        Test.setMock(HttpCalloutMock.class,new TestDataGatewayMDMServiceMock('Person'));
        Contact c = new Contact(LastName='Last Name',FirstName='First Name', Rep_Auction_Access_Number__c='100877633',AccountId=a.id);
        insert c;

        Map<String,Data_Gateway_Flip_Fields__c> flipFieldMap = null;
        List<ContactHistory> historyList = new List<ContactHistory>();
        DateTime dateReference = System.now();
        
        // We are using this method because is allows us to set the CreatedDate for the History (which is relevant to our test).
        historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
        historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.addDays(-1).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
        historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.addDays(-2).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
        historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.addDays(-3).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));

        Test.startTest();
            Map<String,Integer> changes = DataGatewayContactHelper.checkNumberOfChanges(flipFieldMap,historyList);
            System.assertEquals(0, changes.keySet().size());
        Test.stopTest();
        currentTest = '';
    }   

    static testMethod void testNoCustomSettings(){
        currentTest = 'testNoCustomSettings';
        Test.setMock(HttpCalloutMock.class,new TestDataGatewayMDMServiceMock('Organization'));
        Data_Gateway_MDMService_Endpoint__c endpoint = new Data_Gateway_MDMService_Endpoint__c(Name='MDMServiceEndpoint',Environment_URL__c='http://inthub.test.auctionintegrationhub.com/karcustomermdm/KARCMDMService');
        insert endpoint;
        Account a = new Account(Name='Test Account');
        insert a;
        Test.setMock(HttpCalloutMock.class,new TestDataGatewayMDMServiceMock('Person'));
        Contact c = new Contact(LastName='Last Name',FirstName='First Name', Rep_Auction_Access_Number__c='100877633', AccountId=a.id);
        insert c;

        Map<String,Data_Gateway_Flip_Fields__c> flipFieldMap = null;
        List<ContactHistory> historyList = new List<ContactHistory>();
        DateTime dateReference = System.now();
        
        // We are using this method because is allows us to set the CreatedDate for the History (which is relevant to our test).
        historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
        historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.addDays(-1).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
        historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.addDays(-2).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));
        historyList.add((ContactHistory) JSON.deserialize('{"ContactId":"'+a.id+'","Field":"Rep_Auction_Access_Number__c","CreatedDate":"'+dateReference.addDays(-3).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'"}', ContactHistory.class));

        Test.startTest();
            Map<String,Integer> changes = DataGatewayContactHelper.checkNumberOfChanges(flipFieldMap,historyList);
            System.assertEquals(0, changes.keySet().size());
        Test.stopTest();
        currentTest = '';
    }  

    static testMethod void testKeyFieldDeletion(){
        currentTest = 'testKeyFieldDeletion';
        Data_Gateway_Users__c dataGatewayUser = new Data_Gateway_Users__c(Name=UserInfo.getUsername());
        insert dataGatewayUser;


        Test.setMock(HttpCalloutMock.class,new TestDataGatewayMDMServiceMock('Organization'));
        Data_Gateway_MDMService_Endpoint__c endpoint = new Data_Gateway_MDMService_Endpoint__c(Name='MDMServiceEndpoint',Environment_URL__c='http://inthub.test.auctionintegrationhub.com/karcustomermdm/KARCMDMService');
        insert endpoint;
        Account a = new Account(Name='Test Account');
        insert a;
        Test.setMock(HttpCalloutMock.class,new TestDataGatewayMDMServiceMock('Person'));
        Contact c = new Contact(FirstName ='First Name',LastName='Last Name',Rep_Auction_Access_Number__c='100877633', Phone='(123) 456-7890', AccountId=a.Id);
        insert c;

        Data_Gateway_Key_Fields__c keyField1 = new Data_Gateway_Key_Fields__c(Name='ContactAuction_Access_Number__c',Field_Name__c='Rep_Auction_Access_Number__c',Object_Name__c='Contact');
        insert keyField1;
        Data_Gateway_Key_Fields__c keyField2 = new Data_Gateway_Key_Fields__c(Name='ContactPhone',Field_Name__c='Phone',Object_Name__c='Contact');
        insert keyField2;
        
        DataGatewayTriggerHelper.resetTrigger();
        Set<String> keyFieldSet = new Set<String>{'Rep_Auction_Access_Number__c','Phone'};
        
        Test.startTest();
            c.Rep_Auction_Access_Number__c = null;
            c.Phone = null;
            update c;
            List<Gateway_Violation__c> gvList = [select Violations_Content__c from Gateway_Violation__c];
            System.assertEquals(1,gvList.size());
            List<DataGatewayManager.GatewayViolation> gv = (List<DataGatewayManager.GatewayViolation>)JSON.deserialize(gvList[0].Violations_Content__c, List<DataGatewayManager.GatewayViolation>.class);
            System.assertEquals(2,gv.size());
            System.assertEquals('Key Field Deletion',gv[0].type);
            System.assertEquals(c.id,gv[0].recordId);
            System.assertEquals('Update Declined',gv[0].result);
            System.assertEquals(1,gv[0].reasonList.size());
            System.assert(keyFieldSet.contains(gv[0].reasonList[0].field));
            
            System.assertEquals('Key Field Deletion',gv[1].type);
            System.assertEquals(c.id,gv[1].recordId);
            System.assertEquals('Update Declined',gv[1].result);
            System.assertEquals(1,gv[1].reasonList.size());
            System.assert(keyFieldSet.contains(gv[1].reasonList[0].field));
            
            List<Contact> cList = [select id, Rep_Auction_Access_Number__c, Phone from Contact where id = :c.id];
            System.assertEquals('100877633',cList[0].Rep_Auction_Access_Number__c);
            System.assertEquals('(123) 456-7890',cList[0].Phone);

        Test.stopTest();
        currentTest = '';
    }    

    static testMethod void testMiscellaneous(){
        currentTest = 'testMiscellaneous';
        Test.startTest();
            DataGatewayManager.GatewayViolation gv = new DataGatewayManager.GatewayViolation();
            gv.recordId = '000000000000000000';
            gv.type = 'Attribute Flipping';
            System.assertEquals(gv.result,'Update Applied'); // The default value
            System.assert(gv.reasonList != null);

            DataGatewayManager.GatewayChange gc = new DataGatewayManager.GatewayChange('name','1','2');
            System.assertEquals(gc.field,'name');
            System.assertEquals(gc.oldValue,'1');
            System.assertEquals(gc.newValue,'2');
        Test.stopTest();
        currentTest = '';
    }  

    static testMethod void testInsertUser(){
        currentTest = 'testInsertUser';
        Data_Gateway_MDMService_Endpoint__c endpoint = new Data_Gateway_MDMService_Endpoint__c(Name='MDMServiceEndpoint',Environment_URL__c='http://inthub.test.auctionintegrationhub.com/karcustomermdm/KARCMDMService');
        insert endpoint;
        Data_Gateway_Update_Only_Users__c insertUser = new Data_Gateway_Update_Only_Users__c(Name='Test Name',Username__c=UserInfo.getUsername(),Object_Name__c='Contact');
        insert insertUser;
        Test.setMock(HttpCalloutMock.class,new TestDataGatewayMDMServiceMock('Person'));

        Test.startTest();
            Contact c = new Contact(FirstName='First Name',LastName='Last Name',Rep_Auction_Access_Number__c='100877633', Phone='(123) 456-7890');
            try{
                insert c; 
            } catch (Exception e){
                System.assert(e.getMessage().contains('This user is not authorized to insert Contact records'));
            }   
        Test.stopTest();
        currentTest = '';

    }   
}