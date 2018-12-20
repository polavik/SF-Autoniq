trigger LoginHistoryBeforeInsertUpdate on Login_History__c (before insert, before update) {
    Set<String> loginNames = new Set<String>();
    List<Login_History__c> loginHistories = new List<Login_History__c>();
    for(Login_History__c lh: Trigger.new){
        if(lh.Login_Name__c != null){
            loginNames.add(lh.Login_Name__c);
            loginHistories.add(lh);
        }    
    }
    Map<String, Contact> conts = new Map<String, Contact>();
    for(Contact cont: [SELECT Login_Name__c,Id,Login_ID__c FROM Contact WHERE Login_Name__c IN :loginNames]){
        conts.put(cont.Login_Name__c,cont);
    }        
               
    for(Login_History__c lh: loginHistories){    
        system.debug(lh.Login_Name__c);
        if(conts.containsKey(lh.Login_Name__c)){       
            system.debug('Match Id: '+(conts.get(lh.Login_Name__c)).Id);
            lh.Contact__c = conts.get(lh.Login_Name__c).Id;               
        }
    }
    
    List<Contact> contactList = new List<Contact>();
    List<String> masterIndexIdList = new List<String>();
    Map<String, Contact> mIContactMap = new Map<String, Contact>();
    
    for(Login_History__c l : Trigger.new)
    {
        if(l.Master_Index_ID__c != null)
        {
            masterIndexIdList.add(l.Master_Index_ID__c);
        }
    }
    
    system.debug('Master Index Id List: ' + masterIndexIdList);
    
    contactList =     
    [
        SELECT Id, Master_Index__c
        FROM Contact
        WHERE Master_Index__c in : masterIndexIdList
    ];
    
    system.debug('Contact List: ' + contactList );
    
    for(Contact c : contactList)
    {
        if(c.Master_Index__c != null)
        {
            mIContactMap.put(c.Master_Index__c, c);
        }
     }
     
     system.debug('Master Index ID Contact Map: ' + mIContactMap);
     
     for(Login_History__c l : Trigger.new)
     {
         if(l.Master_Index_ID__c != null && mIContactMap.get(l.Master_Index_ID__c) != null)
         {
             system.debug('Updating Login History');
             l.Contact__c = mIContactMap.get(l.Master_Index_ID__c).Id;
         }
     }

}