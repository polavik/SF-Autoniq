trigger DealerProfileAfterInsertUpdateDelete on Survey__c (after insert, after update, before delete) {
   
   Set<ID> acctsToAdd = new Set<ID>();
   Set<ID> odpToRemove = new Set<ID>();
   Map<ID, Survey__c> surveyById = new Map<ID, Survey__c>();
   Set<ID> allDpId = new Set<ID>();
   if(Trigger.isDelete){
       for(Survey__c s: Trigger.old){
          allDpId.add(s.id);
       }
   }else{
       for(Survey__c s: Trigger.new){
          allDpId.add(s.id);
       }
   }
   List<Survey__c> allDP = [select id, account__r.id
                              from Survey__c
                             where id in :allDpId];
   if(Trigger.isInsert){
       for(Survey__c dp: allDP){
          if(dp.account__c != null){
              acctsToAdd.add(dp.account__r.Id);
              surveyById.put(dp.account__r.Id, dp);
          }
       }
      
   }
   if(Trigger.isUpdate){
      for(Survey__c dp: allDP){
          if(Trigger.oldMap.get(dp.id).account__r.id != dp.account__r.id){
              acctsToAdd.add(dp.account__r.Id);
              odpToRemove.add(dp.id);
              surveyById.put(dp.account__r.Id, dp);
          }
       }
   }
   if(Trigger.isDelete){
      for(Survey__c dp: allDP){
         odpToRemove.add(dp.id);
      }
   }
   
   List<Opportunity_Dealer_Profile__c> odps = [select id
                                                 from opportunity_dealer_profile__c 
                                                where dealer_profile__r.id in :odpToRemove];
   if(odps != null && odps.size() > 0)
      delete odps;                                                
   
   List<Opportunity> opps = [select o.id, o.account.Id
                               from opportunity o
                              where o.AccountId in :acctsToAdd];
   List<Opportunity_Dealer_Profile__c> odpToUpsert = new List<Opportunity_Dealer_Profile__c>();
   for(Opportunity o: opps){
      Opportunity_Dealer_Profile__c odp = new Opportunity_Dealer_Profile__c();
      Survey__c dp = surveyById.get(o.account.id);
      odp.dealer_Profile__c = dp.id;
      odp.opportunity__c = o.id;
      odp.account__c = o.account.id;
      odpToUpsert.add(odp);
   }
   
   if(odpToUpsert.size() > 0)
      upsert odpToUpsert;                              
                                 
}