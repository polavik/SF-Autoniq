trigger OpportunityAfterInsertUpdateDelete on Opportunity (after insert, after update, before delete) {
   
   Set<ID> acctsToAdd = new Set<ID>();
   Set<ID> odpToRemove = new Set<ID>();
   Map<ID, Opportunity> oppById = new Map<ID, Opportunity>();
   Set<ID> allOppId = new Set<ID>();
   if(Trigger.isDelete){
       for(Opportunity o: Trigger.old){
          allOppId.add(o.id);
       }
   }else{
       for(Opportunity o: Trigger.new){
          allOppId.add(o.id);
       }
   }
   List<Opportunity> allOpp = [select id, account.id
                              from Opportunity
                             where id in :allOppId];
   if(Trigger.isInsert){
       for(Opportunity opp: allOpp){
          if(opp.account != null){
              acctsToAdd.add(opp.account.Id);
              oppById.put(opp.account.Id, opp);
          }
       }
      
   }
   if(Trigger.isUpdate){
      for(Opportunity opp: allOpp){
          if(Trigger.oldMap.get(opp.id).account.id != opp.account.id){
              acctsToAdd.add(opp.account.Id);
              odpToRemove.add(opp.id);
              oppById.put(opp.account.Id, opp);
          }
       }
   }
   if(Trigger.isDelete){
      for(Opportunity opp: allOpp){
         odpToRemove.add(opp.id);
      }
   }
   
   List<Opportunity_Dealer_Profile__c> odps = [select id
                                                 from opportunity_dealer_profile__c 
                                                where opportunity__r.id in :odpToRemove];
   if(odps != null && odps.size() > 0)
      delete odps;                                                
   
   List<Survey__c> dps = [select s.id, s.account__r.Id
                               from survey__c s
                              where s.Account__r.Id in :acctsToAdd];
   List<Opportunity_Dealer_Profile__c> odpToUpsert = new List<Opportunity_Dealer_Profile__c>();
   for(Survey__c s: dps){
      Opportunity_Dealer_Profile__c odp = new Opportunity_Dealer_Profile__c();
      Opportunity  o = oppById.get(s.account__r.id);
      odp.dealer_Profile__c = s.id;
      odp.opportunity__c = o.id;
      odp.account__c = o.account.id;
      odpToUpsert.add(odp);
   }
   
   if(odpToUpsert.size() > 0)
      upsert odpToUpsert;                              
                                 
}