//
// (c) 2014 Appirio, Inc.
//
// Handler Class for this trigger EF_ShareContentBucketWithGroupTrgHandler and
// EF_ShareWithViewersPublicGroups
//
// November 10th, 2014  Sidhant Agarwal     Modified T-333318
// November 11th, 2014  Sidhant Agarwal     Modified T-333318
//
trigger IntranetContentBucket_ShareWithPublicGroups on Intranet_Content_Buckets__c (after update) {
    //Modified ref. T-333318(Revised)
     if(trigger.isAfter) {
        if(trigger.isUpdate) {
            EF_ShareWithViewersPublicGroups.icbShareManager(trigger.oldmap, trigger.newmap);
        }
    }
}