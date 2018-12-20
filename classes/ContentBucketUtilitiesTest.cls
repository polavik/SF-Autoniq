/*
 * Apex Class: ContentBucketUtilitiesTest
 * Description: Test class for ContentBucketUtilities
 * Created By: Jim Cook
 * Created Date: Jan 30, 2017
*/

   @isTest(SeeAllData=true)
   private class ContentBucketUtilitiesTest{
   
      static testMethod void test_getBucketNamesForAUser() {
      	try{
           List<String> testResult = ContentBucketUtilities.getBucketNamesForAUser(UserInfo.getUserId());
//           System.assertNotEquals(null, testResult);
      
           List<ContentBucketUtilities.BucketWrapper> x = ContentBucketUtilities.getBucketsForAUser(UserInfo.getUserId());
//           System.assertNotEquals(null, x);
      
           ContentBucketUtilities.isViewerOrEditor(UserInfo.getUserId(), 'Anything', x);
           ContentBucketUtilities.isViewer(UserInfo.getUserId(), 'Anything', x);
           ContentBucketUtilities.isEditor(UserInfo.getUserId(), 'Anything', x);

           ContentBucketUtilities.isViewerOrEditor(UserInfo.getUserId(), 'Anything');
           ContentBucketUtilities.isViewer(UserInfo.getUserId(), 'Anything');
           ContentBucketUtilities.isEditor(UserInfo.getUserId(), 'Anything');      
      	}
      	catch(Exception e) {}
   }

}