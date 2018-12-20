@isTest
public class TestStewardshipHelper {
    public static String currentTest = '';

    static testMethod void testStaticInitializer(){
     	Stewardship_Users__c dgu = new Stewardship_Users__c();
     	dgu.Name=UserInfo.getUsername();
     	insert dgu;

     	Stewardship_Key_Fields__c dgkf = new Stewardship_Key_Fields__c();
     	dgkf.Name='testkeyfield';
     	dgkf.Object_Name__c = 'Account';
     	dgkf.Field_Name__c = 'Integration_Id__c';
     	insert dgkf;	

    	Test.startTest();
    		System.assertEquals(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Stewardship').getRecordTypeId(),StewardshipHelper.stewardshipRtId);
    		System.assert(StewardshipHelper.stewardshipUsernames.contains(UserInfo.getUsername()));
    		System.assertEquals('Integration_Id__c',StewardshipHelper.stewardshipKeyFieldsMap.get('Account')[0]);
    	Test.stopTest();
    }

    static testMethod void testCreateDuplicateIntegrationIdCase(){
        Account a = new Account(Name='Test Account', MDM_Refresh_Date__c=System.now(),Integration_Id__c='123456789');
        insert a;
        Account b = new Account(Name='Test Account2', MDM_Refresh_Date__c=System.now(),Integration_Id__c='123456789');
        insert b;
        Test.startTest();
            StewardshipHelper.createDuplicateIntegrationIdCase('123456789',new List<Id>{a.id,b.id});
            System.assertEquals(1,[select id from Case where Subject = 'Duplicate Integration Id: 123456789' limit 1].size());
        Test.stopTest();
    }

    static testMethod void testCreateStewardshipCases(){
     	Account a = new Account(Name='Test Account');
     	insert a;
     	Account b = new Account(Name='Test Account2', MDM_Refresh_Date__c=System.now());
     	insert b;
     	Account c = new Account(Name='Test Account3', MDM_Refresh_Date__c=System.now());
     	insert c;
     	Account d = new Account(Name='Test Account4', MDM_Refresh_Date__c=System.now());
     	insert d;
		Map<Id,List<String>> flipMap = new Map<Id,List<String>>();
		flipMap.put(b.id,new List<String>{'Auction_Access_Number__c,Integration_Id__c'});
		flipMap.put(c.id,new List<String>{'AFC_Dealer_Id__c,ATC_Org_Id__c'});

    	Test.startTest();
    		StewardshipHelper.createLocalAccountIntegrationCases(new List<Id>{a.Id});
    		System.assertEquals(1,[select id from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and Subject = 'Local Account Integration' and AccountId = :a.id].size());
    		StewardshipHelper.createKeyFieldDeletionCase(a.Id, new Set<String>{'Auction_Access_Number__c,Integration_Id__c'});
    		System.assertEquals(1,[select id from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and subject = 'Key Field Deletion Attempt' and AccountId = :a.id].size());
            Map<Id,List<String>> caseMap = new Map<Id,List<String>>();
            caseMap.put(a.Id,new List<String>{'Auction_Access_Number__c,Integration_Id__c'});
    		StewardshipHelper.createDataFlippingCases(caseMap);
    		System.assertEquals(1,[select id from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and subject = 'Data Flipping Notification' and AccountId = :a.id].size());

    		StewardshipHelper.createDataFlippingCases(flipMap);
    		System.assertEquals(2,[select id from Case where  RecordTypeId = :StewardshipHelper.stewardshipRtId and subject = 'Data Flipping Notification' and AccountId in (:b.id,:c.id)].size());

    		// Total of 3 Flipping Stewardship Cases
    		System.assertEquals(3,[select id from Case where  RecordTypeId = :StewardshipHelper.stewardshipRtId and subject = 'Data Flipping Notification'].size());

    		// Most of these should not create a new Case, as there is already one open.  That is why the assertion numbers are the same as above.
    		StewardshipHelper.createLocalAccountIntegrationCases(new List<Id>{a.Id});
    		System.assertEquals(1,[select id from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and Subject = 'Local Account Integration' and AccountId = :a.id].size());
    		StewardshipHelper.createKeyFieldDeletionCase(a.Id, new Set<String>{'Auction_Access_Number__c,Integration_Id__c'});
    		System.assertEquals(1,[select id from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and subject = 'Key Field Deletion Attempt' and AccountId = :a.id].size());
    		StewardshipHelper.createDataFlippingCase(a.Id, new Set<String>{'Auction_Access_Number__c,Integration_Id__c'});
    		System.assertEquals(1,[select id from Case where RecordTypeId = :StewardshipHelper.stewardshipRtId and subject = 'Data Flipping Notification' and AccountId = :a.id].size());

    		// Adding this one to the existing flipMap means that one additional Case will be created (from the three flipMap inputs)
    		flipMap.put(d.id,new List<String>{'Name,OwnerId'});

    		StewardshipHelper.createDataFlippingCases(flipMap);
    		System.assertEquals(4,[select id from Case where  RecordTypeId = :StewardshipHelper.stewardshipRtId and subject = 'Data Flipping Notification'].size());
    	Test.stopTest();
    }
}