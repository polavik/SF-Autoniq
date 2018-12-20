/* ***************************************************
	Apex class: ContentBucketUtilities (c) 2016 Appirio Inc
	
	Author : Jim Cook
	Created: 12-19-2016

    The purpose of this class is to provide an esy way to 
    discover the content buckets a user can access. 
 
    Note: if you need to chec multiple buckets, call the getBucketsForAUser
    ONCE, store it's result in your class and pass that result to
    the versions of isViewerOrEditor, isView, or isEditor, which accept 
    the List<BucketWrapper>. Otherwise you'll use too many SOQL calls.
    
****************************************************** */

public class ContentBucketUtilities {

   public static List<String> getBucketNamesForAUser(Id uid) {
      List<String> result    = new List<String>();
      List<BucketWrapper> bw = getBucketsForAUser(uid);
      for(BucketWrapper one: bw)
         result.add(one.bucketName);
      return result;
   }

   public static List<BucketWrapper> getBucketsForAUser(Id uid){
   	  List<BucketWrapper> bucketInfo = new List<BucketWrapper>();
      
      // Find the groups that the user is a part of.
      Set<Group> pgTwo = getAllGroupsForAUser(uid);

      // Build a query to find all the Intranet Content Buckets that are assigned to any of the groups the user is a part of.
      String bucketQuery ='select Id, Name, Viewers__c, Permission_Groups__c from Intranet_Content_Buckets__c where ';
      for(Group g : pgTwo) {
         bucketQuery+= 'Viewers__c includes (\''+ g.developerName.replaceAll('_', ' ') + '\') or '; 
         bucketQuery+= 'Permission_Groups__c includes (\'' + g.developerName.replaceAll('_', ' ') + '\') or ';  
      }
      bucketQuery+= 'Viewers__c includes (\'All Internal Users - Default\') ';
      List<Intranet_Content_Buckets__c> buckets = Database.query(bucketQuery);

//      System.debug('@@@ found '+ buckets.size() + ' buckets, line 47 ' + bucketQuery);      
//      for(Intranet_Content_Buckets__c icb : buckets)
//        System.debug('!!! - ' + icb.Name + ' ' + icb.Viewers__c + ' ' + icb.Permission_Groups__c);

      boolean tempViewer;
      boolean tempEditor;
      for(Intranet_Content_Buckets__c bucket : buckets) { 
         for(Group g : pgTwo) {
         	tempViewer = tempEditor = false;
            if(null != bucket.Viewers__c && bucket.Viewers__c.contains(g.developerName.replaceAll('_', ' '))) tempViewer= true;
            if(null != bucket.Permission_Groups__c && bucket.Permission_Groups__c.contains(g.developerName.replaceAll('_', ' '))) tempEditor= true;
            bucketInfo.add(new BucketWrapper(uid, bucket.Name, tempViewer, tempEditor ));
         }
         if(bucket.Viewers__c.contains('All Internal Users - Default'))
         	   bucketInfo.add(new BucketWrapper(uid, bucket.Name, tempViewer, tempEditor ));
      }
      
//      for(BucketWrapper bw:bucketInfo){
//         System.debug(bw.u + ' ' + bw.bucketName +' ' + bw.isViewer  + ' ' + bw.isEditor);
//      }
      
	  return bucketInfo;
   }

   public static Set<Group> getAllGroupsForAUser(Id uid) {
   	  Set<Group> result = new Set<Group>();
      Set<Id> intermediateGroupIds = new Set<Id>();
      Set<Id>groupsToRecurse =new Set<Id>();
      Boolean moreLevels = true;
      Integer soqlCount = 0;
      Integer failSafe = 0;
      
       // Make a list of the group IDs for the groups the user belongs to.
      // "pg" is "Public Group", not "page".
      Set<id> pgOne = new Set<Id>(); 
      soqlCount++;
      for(GroupMember g : [Select GroupId, UserOrGroupId From GroupMember where UserOrGroupId = :uid]) pgOne.add(g.GroupId);

      // Find the groups that the user is directly a part of.
      Set<Group> pgTwo=new Set<Group>();
      soqlCount++;
      for(Group gg : [select Id, DeveloperName from Group where id in :pgOne] ) {
      	pgTwo.add(gg);
   	    result.add(gg);
      }
   	
   	  // See if any of these groups are a member of other groups.
   	  Set<Id> pgThree = new Set<Id>();
      while(moreLevels && failSafe <5) {
   	     // Create a set of IDs for the groups we found in the previous pass. 
   	     for(Group g : pgTwo) intermediateGroupIds.add(g.Id);
   	     // Look those groups up in GroupMember to see if they are members of another group.
   	     soqlCount++;
   	     if(soqlCount > 99) return result;
         for(GroupMember gm : [Select GroupId, UserOrGroupId From GroupMember where UserOrGroupId = :intermediateGroupIds]) pgThree.add(gm.GroupId);
   	     // If we found anything, add the new groups to result, and set up for another pass.
   	     if(pgThree.size() > 0) {
   	     	pgTwo = new Set<Group>();
   	     	soqlCount++; return result;
   	        for(Group gg : [select Id, DeveloperName from Group where id in :pgThree] ) {
   	        	result.add(gg);
                pgTwo.add(gg);
   	        }
   	        failSafe++;
   	     }
   	     // If we DIDN'T find anything, we're done.
   	     else moreLevels =false;
      }
   	
   	  return result;
   }


   public static String buildTheBucketSOQLClause(List<String> buckets, String prefix){
   	  String result = ' ' + prefix + ' ';
   	          	
   	  if(buckets.size() > 0 ){
      	 // Add the bucket list.
      	 result += ' Content_Bucket__r.Name in ('; 
         // loop through all the buckets and add each one.
         for(String x : buckets) result += '\'' + x + '\',';
         // Strip out the trailing comma.
         result =  result.substring(0, result.length()-1);
         // Close out the bucket list.
         result += ' ) ';
   	  }
   	  return result;
   }


   public static boolean isViewerOrEditor(Id u, String bucketName, List<BucketWrapper> lbw){
      for(BucketWrapper bucket : lbw) if(bucketName == bucket.bucketName && (bucket.isEditor || bucket.isViewer)) return true;
      return false;
   }

   public static boolean isViewer(Id u, String bucketName, List<BucketWrapper> lbw){
      for(BucketWrapper bucket : lbw) if(bucketName == bucket.bucketName && bucket.isViewer) return true;
      return false;
   }
   
   public static boolean isEditor(Id u, String bucketName, List<BucketWrapper> lbw){
      for(BucketWrapper bucket : lbw) if(bucketName == bucket.bucketName && bucket.isEditor) return true;
      return false;
   }
   
   public static boolean isViewerOrEditor(Id u, String bucketName){
      List<BucketWrapper> buckets = getBucketsForAUser(u);
      for(BucketWrapper bucket : buckets) if(bucketName == bucket.bucketName && (bucket.isEditor || bucket.isViewer)) return true;
      return false;
   }

   public static boolean isViewer(Id u, String bucketName){
      List<BucketWrapper> buckets = getBucketsForAUser(u);
      for(BucketWrapper bucket : buckets) if(bucketName == bucket.bucketName && bucket.isViewer) return true;
      return false;
   }   
   
   public static boolean isEditor(Id u, String bucketName){
      List<BucketWrapper> buckets = getBucketsForAUser(u);
      for(BucketWrapper bucket : buckets) if(bucketName == bucket.bucketName && bucket.isEditor) return true;
      return false;
   }

   public class BucketWrapper {
	  public Id      u          {get; set;}
	  public String  bucketName {get; set;}
	  public boolean isViewer   {get; set;}
	  public boolean isEditor   {get; set;}
	
	  public BucketWrapper(Id iu, String bN, boolean isV, boolean isE){
	     this.u = iu;
	     this.bucketName = bN;
	     this.isViewer = isV;
	     this.isEditor = isE;
      }
   }
}