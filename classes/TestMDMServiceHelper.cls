@isTest
public class TestMDMServiceHelper {
    public static String currentTest = '';

    static testMethod void testCreateTags(){
    	Test.startTest();
    		System.assertEquals('<tagName>tagValue</tagName>',MDMServiceHelper.createTag('tagName','tagValue'));
    		System.assertEquals('<tagName/>',MDMServiceHelper.createTag('tagName',''));
    		System.assertEquals('<tagName/>',MDMServiceHelper.createTag('tagName',null));
    		System.assertEquals('',MDMServiceHelper.createTag(null,'tagValue'));
    		System.assertEquals('',MDMServiceHelper.createTag('','tagValue'));
    		System.assertEquals('',MDMServiceHelper.createTag(null,null));
    	Test.stopTest();
    }

    static testMethod void testfindTags(){
		String sourceString = '<maintag><subtag>sub1</subtag><subtag>sub2</subtag><newsub3/><AttributeSubtag4 att="true">sub4</AttributeSubtag4></maintag>';
        //NOTE:  can't currently handle empty tags with attributes.
    	Test.startTest();
    		System.assertEquals(2,MDMServiceHelper.findTags(sourceString,'subtag',true).size());
    		System.assertEquals(0,MDMServiceHelper.findTags(sourceString,'doesnotexisttag',true).size());
    		System.assertEquals('sub1',MDMServiceHelper.findTags(sourceString,'subtag',true)[0]);
    		System.assertEquals('<subtag>sub1</subtag>',MDMServiceHelper.findTags(sourceString,'subtag',false)[0]);
    		System.assertEquals('sub4',MDMServiceHelper.findTags(sourceString,'AttributeSubtag4',true)[0]);
    		System.assertEquals('<AttributeSubtag4 att="true">sub4</AttributeSubtag4>',MDMServiceHelper.findTags(sourceString,'AttributeSubtag4',false)[0]);
    		System.assertEquals(0,MDMServiceHelper.findTags(sourceString,'newsub3',true).size());
    		System.assertEquals('<newsub3/>',MDMServiceHelper.findTags(sourceString,'newsub3',false)[0]);
    	Test.stopTest();
    }

    static testMethod void testUpdateAccountValues(){
    	Account a = new Account(Name='Test Account', MDM_Refresh_Date__c=System.now());
    	insert a;
    	MDMServiceHelper.MDMAccount mdmAccount = new MDMServiceHelper.MDMAccount();
    	mdmAccount.dbaName = 'dba';
    	mdmAccount.legalName = 'Test Account'; // There is a Workflow Rule (AFC Populate Legal Name) that sets legal_name__c to the value of the Name field
    	mdmAccount.integrationId = '12345';
    	mdmAccount.auctionAccessNumber = '23456';
    	mdmAccount.phone = '1234567890';
    	mdmAccount.fax = '0987654321';
    	mdmAccount.taxIdNumber = '34567';

        MDMServiceHelper.MDMAccountAddress address = new MDMServiceHelper.MDMAccountAddress();
        address.isPrimary = true;
        address.streetAddress = '123 Main';
        address.city = 'Carmel';
        address.state = 'IN';
        address.country = 'USA';
        address.postalCode = '46322';
        mdmAccount.addressList.add(address);

    	Test.startTest();
    		Account result = MDMServiceHelper.updateAccountValues(a,mdmAccount);
            update result;
    		System.assert(account.Mdm_Refresh_Date__c != null);
    		System.assertEquals(true,result.Mdm_Compliant__c);
    		System.assertEquals('dba',result.dba__c);
    		System.assertEquals('Test Account',result.legal_Name__c);
    		System.assertEquals('12345',result.integration_Id__c);
    		System.assertEquals('23456',result.auction_Access_Number__c);
    		System.assertEquals('1234567890',result.phone);
    		System.assertEquals('0987654321',result.fax);
    		System.assertEquals('123 Main',result.billingStreet);
            System.assertEquals('Carmel',result.billingCity);
            System.assertEquals('IN',result.billingState);
            System.assertEquals('46322',result.billingPostalCode);
            System.assertEquals('USA',result.billingCountry);

    		// Test that Account attributes with non-null values are NOT overwritten with the MDMAccount info.
    		mdmAccount.phone = '5555555555';
    		result = MDMServiceHelper.updateAccountValues(result,mdmAccount);
    		System.assertEquals('1234567890',result.phone.replaceAll('[^0-9]', '')); // ignore any phone masking characters Salesforce applied when we updated the Account in line 74.
            System.assertEquals(false,result.Mdm_Compliant__c);
    	Test.stopTest();
    }

    static testMethod void testIsAccountCompliant(){
    	Account a = new Account(Name='test',dba__c='test1',legal_Name__c='test2',Auction_Access_Number__c='123456',phone='1234567890',fax='0987654321',Tax_Identification_Number__c='234567');
    	MDMServiceHelper.MDMAccount mdmAccount = new MDMServiceHelper.MDMAccount();
    	mdmAccount.dbaName = 'test1';
    	mdmAccount.legalName = 'test2';
    	mdmAccount.auctionAccessNumber = '123456';
    	mdmAccount.phone = '1234567890';
    	mdmAccount.fax = '0987654321';
    	mdmAccount.taxIdNumber = '234567';

    	// Test that they are compliant, but that if you change a value in one, they become non-compliant
    	Test.startTest();
    		System.assert(MDMServiceHelper.isAccountCompliant(a,mdmAccount));
    		mdmAccount.dbaName = 'test11';
    		System.assert(!MDMServiceHelper.isAccountCompliant(a,mdmAccount));

    	Test.stopTest();
    }

    //Test Mocks
    static testMethod void testGetOrganizationMatchResultsNoMatch(){
        setup();
        Test.setMock(HttpCalloutMock.class,new TestMDMServiceMock(TestMDMServiceMock.MATCHRESPONSE_NO_MATCH));

    	Account a = new Account(Name='Test Account', MDM_Refresh_Date__c = System.now().addMinutes(-1));
    	insert a;
        a = [select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c, 
                            BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax from Account where id = :a.Id limit 1];

    	Test.startTest();
            MDMServiceHelper.MDMServiceRequest serviceRequest = new MDMServiceHelper.MDMServiceRequest(MDMServiceHelper.getRequestString(a));
            serviceRequest.makeRequest();
    		System.assertEquals(0,serviceRequest.mdmResultList.size());
    	Test.stopTest();
    }

    static testMethod void testGetOrganizationMatchResultsOneAddress(){
        setup();
        Test.setMock(HttpCalloutMock.class,new TestMDMServiceMock(TestMDMServiceMock.MATCHRESPONSE_ONE_ADDRESS));

    	Account a = new Account(Name='Test Account', MDM_Refresh_Date__c = System.now().addMinutes(-1));
    	insert a;
        a = [select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c, 
                            BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax from Account where id = :a.Id limit 1];
    	Test.startTest();
            MDMServiceHelper.MDMServiceRequest serviceRequest = new MDMServiceHelper.MDMServiceRequest(MDMServiceHelper.getRequestString(a));
            serviceRequest.makeRequest();
            System.assertEquals(1,serviceRequest.mdmResultList.size());
    	Test.stopTest();
    }

    static testMethod void testGetOrganizationMatchResultsMultipleAddresses(){
        setup();
        Test.setMock(HttpCalloutMock.class,new TestMDMServiceMock(TestMDMServiceMock.MATCHRESPONSE_MULTIPLE_ADDRESSES));

        Account a = new Account(Name='Test Account', MDM_Refresh_Date__c = System.now().addMinutes(-1));
        insert a;
        a = [select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c, 
                            BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax from Account where id = :a.Id limit 1];

    	Test.startTest();
            MDMServiceHelper.MDMServiceRequest serviceRequest = new MDMServiceHelper.MDMServiceRequest(MDMServiceHelper.getRequestString(a));
            serviceRequest.makeRequest();
    		System.assertEquals(1,serviceRequest.mdmResultList.size());
    		System.assertEquals(2,serviceRequest.mdmResultList[0].addressList.size());
    		System.assertEquals(true,serviceRequest.mdmResultList[0].addressList[0].isPrimary);
    		System.assertEquals('1071 S Main St',serviceRequest.mdmResultList[0].addressList[0].StreetAddress);
    		System.assertEquals('9 Foxwell Rd Se',serviceRequest.mdmResultList[0].addressList[1].StreetAddress);
    	Test.stopTest();
    }

    static testMethod void testGetOrganizationMatchResultsMultipleCandidates(){
        setup();
        Test.setMock(HttpCalloutMock.class,new TestMDMServiceMock(TestMDMServiceMock.MATCHRESPONSE_MULTIPLE_CANDIDATES));
                
    	Account a = new Account(Name='Test Account', MDM_Refresh_Date__c = System.now().addMinutes(-1));
    	insert a;
        a = [select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c, 
                            BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax from Account where id = :a.Id limit 1];

    	Test.startTest();
            MDMServiceHelper.MDMServiceRequest serviceRequest = new MDMServiceHelper.MDMServiceRequest(MDMServiceHelper.getRequestString(a));
            serviceRequest.makeRequest();
    		System.assertEquals(2,serviceRequest.mdmResultList.size());
    		System.assertEquals('WILLIS LEXUS CORP.',serviceRequest.mdmResultList[0].dbaName);
    		System.assertEquals('WILL LEX CORP.',serviceRequest.mdmResultList[1].dbaName);
    	Test.stopTest();
    }

    static testMethod void testGetOrganizationMatchResultsUnclearWinner(){
        setup();
        Test.setMock(HttpCalloutMock.class,new TestMDMServiceMock(TestMDMServiceMock.MATCHRESPONSE_UNCLEAR_WINNER));
                
    	Account a = new Account(Name='Test Account', MDM_Refresh_Date__c = System.now().addMinutes(-1));
    	insert a;
        a = [select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c, 
                            BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax from Account where id = :a.Id limit 1];
    	Test.startTest();
            MDMServiceHelper.MDMServiceRequest serviceRequest = new MDMServiceHelper.MDMServiceRequest(MDMServiceHelper.getRequestString(a));
            serviceRequest.makeRequest();
    		System.assertEquals(2,serviceRequest.mdmResultList.size());
    		System.assertEquals(50,serviceRequest.mdmResultList[0].matchScore);
    		System.assertEquals(55,serviceRequest.mdmResultList[1].matchScore);
    	Test.stopTest();
    }

    static testMethod void testgetMDMAccountDataNoMatch(){
        setup();
        Test.setMock(HttpCalloutMock.class,new TestMDMServiceMock(TestMDMServiceMock.QUERYRESPONSE_NO_MATCH));
                
    	Account a = new Account(Name='Test Account',Integration_Id__c='00055', MDM_Refresh_Date__c = System.now().addMinutes(-1));
    	insert a;
        a = [select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c, 
                            BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax from Account where id = :a.Id limit 1];

    	Test.startTest();
            MDMServiceHelper.MDMServiceRequest serviceRequest = new MDMServiceHelper.MDMServiceRequest(MDMServiceHelper.getRequestString(a));
            serviceRequest.makeRequest();
    		System.assertEquals(0,serviceRequest.mdmResultList.size());
    	Test.stopTest();
    }

    static testMethod void testgetMDMAccountDataOneMatch(){
        setup();
        Test.setMock(HttpCalloutMock.class,new TestMDMServiceMock(TestMDMServiceMock.QUERYRESPONSE_MATCH));
                
    	Account a = new Account(Name='Test Account',Integration_Id__c='500686465', MDM_Refresh_Date__c = System.now().addMinutes(-1));
    	insert a;
        a = [select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c, 
                            BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax from Account where id = :a.Id limit 1];
    	Test.startTest();
            MDMServiceHelper.MDMServiceRequest serviceRequest = new MDMServiceHelper.MDMServiceRequest(MDMServiceHelper.getRequestString(a));
            serviceRequest.makeRequest();
    		System.assertEquals(1,serviceRequest.mdmResultList.size());
    	Test.stopTest();
    }

    private static void setup(){
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
    }
}