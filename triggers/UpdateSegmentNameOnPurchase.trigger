trigger UpdateSegmentNameOnPurchase on Purchase__c (before insert, before update) {
   
   String amsRecordType = Utils.getRecordTypeId('Purchase__c', 'ADESA AMS Purchase');    
 
   for(Purchase__c p: Trigger.new){
      if(p.recordTypeId == amsRecordType ){
            p.Segment_Name__c= 'ADESA INLANE';
      }
   }
}