@isTest
private class TestBatchContactUpdate {
    static List<Contact> contactsToUpdate;
    static List<Contact> allContacts;

    static void setup(){
    	final Integer NUM_OF_CONTACTS = 10;
    	
    	insert new BW_Apps_Config__c(Contact_Update_Endpoint_URL__c='http://www.example.com',
    								Contact_Update_Timeout__c =12000,
    								Username_Receiving_Error_Messages__c = UserInfo.getUserName());

    	contactsToUpdate = TestServices.createContacts(NUM_OF_CONTACTS, false);
    	List<Contact> contactsToFilter = TestServices.createContacts(NUM_OF_CONTACTS, false);
    	allContacts = new List<Contact>(contactsToUpdate);
    	allContacts.addAll(contactsToFilter);
    	
    	for(Integer i=0; i<contactsToUpdate.size();i++){
    		contactsToUpdate[i].Cosmos_Sync_Pending__c = TRUE;
            contactsToUpdate[i].Party_Id__c='Test' + i;
    	}

    	insert allContacts;
    }

    static testMethod void testBatch(){
    	setup();

    	Test.setMock( WebServiceMock.class, new MockSchemaContactUpdateSuccess());

    	Test.startTest();
    		Database.executeBatch(new BatchContactUpdate());
    	Test.stopTest();

    	List<Contact> updatedContacts = [SELECT Id, Cosmos_Sync_Pending__c from Contact];
    	System.assertEquals(allContacts.size(), updatedContacts.size(), 'We should get the inserted contacts');
    	System.assertEquals(Pluck.ids(allContacts), Pluck.ids(updatedContacts), 'We should get the inserted contacts');
    	for(Contact ctc :updatedContacts){
    		System.assert(!ctc.Cosmos_Sync_Pending__c, 'The webervice should be successful and update the contact checkbox');
    	}
    }

    static testMethod void testBatch_Failure(){
    	setup();

    	Test.setMock( WebServiceMock.class, new MockSchemaContactUpdateFailure());

    	Test.startTest();
    		Database.executeBatch(new BatchContactUpdate());
    	Test.stopTest();

    	List<Contact> updatedContacts = [SELECT Id, Cosmos_Sync_Pending__c from Contact];

    	Set<Id> contactsToUpdateIds= Pluck.ids(contactsToUpdate);

    	System.assertEquals(allContacts.size(), updatedContacts.size(), 'We should get the inserted contacts');
    	System.assertEquals(Pluck.ids(allContacts), Pluck.ids(updatedContacts), 'We should get the inserted contacts');
    	for(Contact ctc :updatedContacts){
    		if(contactsToUpdateIds.contains(ctc.Id)){
    			System.assert(ctc.Cosmos_Sync_Pending__c, 'The webervice should fail and not update the contact checkbox');
    		}else {
    			System.assert(!ctc.Cosmos_Sync_Pending__c, 'The webervice should filter the records with the checkbox unchecked');
    		}
    	}

    	System.assert(Limits.getLimitEmailInvocations()>0, 'The webservice failure should send an email');
    }
}