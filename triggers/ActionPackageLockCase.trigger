/*
* Every time an Action Package is added or deleted (or undeleted) from a Case,
* check to see if that Case has any action packages on it and set its Has_Action_Packages__c
* field appropriately.  
*
* This field is used to prevent certain critical fields (VIN, Buyer, Seller, Transporter) from
* being updated on a Case after action packages have been created for that Case.  
*/

trigger ActionPackageLockCase on Action_Package__c (after delete, after insert, after update, after undelete) {
  Set<ID> caseIDs = new Set<ID>();
  
  if (Trigger.isDelete) {
    for (Action_Package__c ap : Trigger.old) {
    // djpatel: Added condition for Case Migration Process
      if(!ap.Is_Migrated_Openlane_Case_Action_Package__c)
      {
      caseIds.add(ap.Case__c);
      }
    }
  } else if (Trigger.isInsert || Trigger.isUnDelete || Trigger.isUpdate) {
    
    for (Action_Package__c ap : Trigger.new) {
      // djpatel: Added condition for Case Migration Process
      if(!ap.Is_Migrated_Openlane_Case_Action_Package__c)
      {
          caseIds.add(ap.Case__c);
      }
    }
    
  } 
  
  List<Case> cases = new List<Case>();
  for (Case c : [SELECT Id, Has_Action_Packages__c, 
           (SELECT Id FROM Action_Packages__r 
            WHERE Status__c NOT IN ('Canceled', 'Deactivated'))
                 FROM Case WHERE Id IN :caseIDs]) 
  {
    if (c.Action_Packages__r.size() > 0) {
      c.Has_Action_Packages__c = true;
    } else {
      c.Has_Action_Packages__c = false;
    }
    
    cases.add(c);
  }
  
  update cases;
  
  
}