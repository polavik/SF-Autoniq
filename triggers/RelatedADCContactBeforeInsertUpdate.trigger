trigger RelatedADCContactBeforeInsertUpdate on Related_Adesa_com_Contact__c (before insert, before update) {

    List<Contact> contactList = new List<Contact>();
    List<String> masterIndexIdList = new List<String>();
    Map<String, Contact> mIContactMap = new Map<String, Contact>();
    
    for(Related_Adesa_com_Contact__c r : Trigger.new)
    {
        if(r.Master_Index_ID__c != null)
        {
            masterIndexIdList.add(r.Master_Index_ID__c);
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
     
     for(Related_Adesa_com_Contact__c r : Trigger.new)
     {
         if(r.Master_Index_ID__c != null && mIContactMap.get(r.Master_Index_ID__c) != null)
         {
             system.debug('Updating Login History');
             r.Contact__c = mIContactMap.get(r.Master_Index_ID__c).Id;
         }
     }



}