trigger CaseAfterDelete on Case (after delete) {
    if(Trigger.isDelete){
        List<Id> accountIdSet = new List<Id>();
        for(Case c : Trigger.old){
            if(c.RecordTypeId == StewardshipHelper.stewardshipRtId){
                accountIdSet.add(c.AccountId);
            }
        }
        List<Account> aList = [select id, In_Stewardship__c, (select id from Cases where RecordTypeId = :StewardshipHelper.stewardshipRtId and status = 'Open') from account where id in :accountIdSet];
        for(Account a : aList){
            a.In_Stewardship__c = !(a.Cases.size() == 0);
        }
        update aList;
    }
}