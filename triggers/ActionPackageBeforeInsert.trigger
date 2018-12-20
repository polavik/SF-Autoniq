trigger ActionPackageBeforeInsert on Action_Package__c (before insert) {
  
  List<ID> caseIds = new List<ID>();
  for (Action_Package__c pkg : Trigger.new) {
    caseIds.add(pkg.Case__c);
  }
  
  // Fetch Related Object Data for all Action Packages
  Map<ID, Case> caseMap = new Map<ID, Case>(
    [SELECT Description FROM Case WHERE Id IN :caseIds]
  );
  
  
  // Copy Description from Case into Case_Description field on Action Package
  for (Action_Package__c pkg : Trigger.new) {
    Case c = caseMap.get(pkg.Case__c);
    if (c != null) {
      pkg.Case_Description__c = c.Description;
    }
  }
}