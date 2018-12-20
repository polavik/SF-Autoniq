@isTest
public class TestLockFields {
	public TestLockFields() {
	}

    static testMethod void testIndividualUser(){
    	// Tests that when an individual user changes a value, it will be changed regardless of the Locked_Fields__c
    	Account a = new Account(Name='Test Account',AFC_Dealer_Id__c='12345', MDM_Refresh_Date__c = System.now().addMinutes(-1));
    	insert a;

    	Test.startTest();
    		a.AFC_Dealer_Id__c = '55555';
    		update a;
        	Account a2 = [select id, Locked_Fields__c, AFC_Dealer_Id__c from Account where id = :a.Id limit 1];
    		System.assertEquals('55555',a2.AFC_Dealer_Id__c);
    		a2.Locked_Fields__c = 'AFC_Dealer_Id__c';
    		a2.AFC_Dealer_Id__c = '12345';
    		update a2;
        	Account a3 = [select id, Locked_Fields__c, AFC_Dealer_Id__c from Account where id = :a.Id limit 1];
    		System.assertEquals('12345',a3.AFC_Dealer_Id__c);
    	Test.stopTest();
    }

    static testMethod void testStewardshipUser(){
    	// Tests that when a stewardship user changes a value, it will be changed unless that field is in the Locked_Fields__c attribute.
        Stewardship_Users__c dgu = new Stewardship_Users__c();
        dgu.Name=UserInfo.getUsername();
        insert dgu;

    	Account a = new Account(Name='Test Account',AFC_Dealer_Id__c='12345', MDM_Refresh_Date__c = System.now().addMinutes(-1));
    	insert a;

    	Test.startTest();
    		a.AFC_Dealer_Id__c = '55555';
    		update a;
        	Account a2 = [select id, Locked_Fields__c, AFC_Dealer_Id__c from Account where id = :a.Id limit 1];
    		System.assertEquals('55555',a2.AFC_Dealer_Id__c);
    		a2.Locked_Fields__c = 'AFC_Dealer_Id__c';
    		a2.AFC_Dealer_Id__c = '12345';
    		update a2;
        	Account a3 = [select id, Locked_Fields__c, AFC_Dealer_Id__c from Account where id = :a.Id limit 1];
    		System.assertEquals('55555',a3.AFC_Dealer_Id__c);  // (stays the same and is not updated)
    	Test.stopTest();
    }
}