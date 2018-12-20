@isTest
private class TestChecklistItemUploadContExt {

	@isTest static void testProcessUpload() {
		PageReference pRef = Page.ChecklistItemUpload;
		Test.setCurrentPage(pRef);
		User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
		Opportunity testOpportunity = TestServices.createTestOpportunity('Opportunity','Not Started','Indianapolis', true);
		Application__c testApplication = TestServices.createTestApplication(testOpportunity.id, 'Shull', true);
		Checklist__c testChecklist = TestServices.createTestChecklist(testApplication.id, true);
		Checklist_Item__c testChecklistItem = TestServices.createTestChecklistItem(testChecklist.id, 'Credit', 'Not Started',true);

		ApexPages.StandardController stanCon = New ApexPages.StandardController(testChecklistItem);
		ChecklistItemUploadContExt con = new ChecklistItemUploadContExt(stanCon);
		con.fileData = Blob.valueOf('File');
		con.fileName = 'File Name';
		con.processUpload();

		Checklist_Item__c upCheck = [SELECT Id, Name, Document_Attached__c FROM Checklist_Item__c WHERE ID =:testChecklistItem.id LIMIT 1];

		System.assertEquals(true, upCheck.Document_Attached__c);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		for(Apexpages.Message msg:msgs){
			System.assertEquals(ApexPages.Severity.CONFIRM, msg.getSeverity());
		}
	}

	@isTest static void testProcessUploadNoFile() {
		PageReference pRef = Page.ChecklistItemUpload;
		Test.setCurrentPage(pRef);

		User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);
		Opportunity testOpportunity = TestServices.createTestOpportunity('Opportunity','Not Started','Indianapolis', true);
		Application__c testApplication = TestServices.createTestApplication(testOpportunity.id, 'Shull', true);
		Checklist__c testChecklist = TestServices.createTestChecklist(testApplication.id, true);
		Checklist_Item__c testChecklistItem = TestServices.createTestChecklistItem(testChecklist.id, 'Credit', 'Not Started',true);

		ApexPages.StandardController stanCon = New ApexPages.StandardController(testChecklistItem);
		ChecklistItemUploadContExt con = new ChecklistItemUploadContExt(stanCon);

		//Blob Data for File Attachment not set
		con.processUpload();

		Checklist_Item__c upCheck = [SELECT Id, Name, Document_Attached__c FROM Checklist_Item__c WHERE ID =:testChecklistItem.id LIMIT 1];

		System.assertEquals(false, upCheck.Document_Attached__c);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		for(Apexpages.Message msg:msgs){
			System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity());
		}
	}

}