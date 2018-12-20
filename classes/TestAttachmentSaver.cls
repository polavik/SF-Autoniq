@isTest
private class TestAttachmentSaver {
	
	static testMethod void testAdminUser() {
		
		// Create test data (a new Account with an Attachment)
		Account acct = new Account(Name = 'Test Account');
		insert acct;
		Blob attachBody = Blob.valueOf('attachment body');
		Attachment attach = new Attachment(Name = 'TestAttachment', ParentId = acct.Id, Body = attachBody);
		insert attach;
		
		// Verify that no error is thrown when the attachment is deleted
		Boolean errorThrown = false;
		try {
			delete attach;
		} catch (Exception e) {
			System.debug(e);
			errorThrown = true;
		}
		System.assert(!errorThrown);
	}
}