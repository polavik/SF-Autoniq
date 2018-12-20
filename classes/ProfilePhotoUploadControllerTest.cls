@isTest
private class ProfilePhotoUploadControllerTest {
	
	// SeeAllData=true is required to test the ConnectApi per Salesforce	
	@isTest(SeeAllData=true)
	static void controllerTest() {
		
		ProfilePhotoUploadController controller = new ProfilePhotoUploadController();
		controller.blobValue = Blob.valueOf('TestBlob');
		controller.contentType = '.png';
		controller.filename = 'testImage.png';
		controller.userId = UserInfo.getUserId();

		Test.startTest();

		String photoUrl = controller.getLargePhotoUrl();

		PageReference pRef = controller.upload();

		System.assertEquals(null, pRef, 'The return of the upload method should be null.');

		Test.stopTest();
	}
	
}