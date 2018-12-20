trigger BestOfferBeforeInsertUpdate on Best_Offers__c (before insert, before update) {
  for (Best_Offers__c bo : Trigger.new){
      if (Trigger.isUpdate && 
          Trigger.oldMap.get(bo.id).offer_Status__c != null &&
          Trigger.oldMap.get(bo.id).offer_Status__c.equals('Open') &&
          !bo.offer_status__c.equals('Open')){
            bo.owner__c = UserInfo.getUserId();
      }  
  }

}