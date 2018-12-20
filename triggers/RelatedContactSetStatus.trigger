trigger RelatedContactSetStatus on Related_Contact__c (before insert, before update) {
    
    ID invalidAcctType = 
        [select Id, Name, SobjectType 
         from RecordType 
         where SobjectType = 'Account' 
         and Name = 'Invalid/OOB'].Id;
    
    ID invalidContactType = 
        [select Id, Name, SobjectType
         from RecordType
         where SobjectType = 'Contact'
         and Name = 'Invalid'].Id;
                             
    ID activeRContactType = 
        [select Id, Name, SobjectType
         from RecordType
         where SobjectType = 'Related_Contact__c'
         and Name = 'Active'].Id;
                             
    ID invalidRContactType = 
        [select Id, Name, SobjectType
         from RecordType
         where SobjectType = 'Related_Contact__c'
         and Name = 'Invalid'].Id;
    
    List<ID> contactIds = new List<ID>();
    List<ID> acctIds = new List<ID>();
    
    for (Related_Contact__c rc : Trigger.new) {
         contactIds.add(rc.Contact__c);
         acctIds.add(rc.Account__c);
    }
    
    Map<ID, Account> acctMap = new Map<ID, Account>(
        [select RecordTypeId
         from Account
         where Id in :acctIds]
    );
    
    Map<ID, Contact> contactMap = new Map<ID, Contact>(
        [select RecordTypeId
         from Contact
         where Id in :contactIds]
    );
    
    for (Related_Contact__c rc : Trigger.new) {
        Account acct = acctMap.get(rc.Account__c);
        Contact contact = contactMap.get(rc.Contact__c);
        if (acct == null || acct.RecordTypeId == null) {
          rc.addError('Account does not exist or RecordType not provided');
          continue;
        }
        
        if (contact == null ) {
          rc.addError('Contact does not exist');
          continue;
        }
        
        if (acct.RecordTypeId == invalidAcctType || contact.RecordTypeId == invalidContactType) {
            rc.RecordTypeId = invalidRContactType;
            rc.Active__c = false;
        } else {
            rc.RecordTypeId = activeRContactType;
            rc.Active__c = true;
        }
    }
    
    
    List<Contact> contactList = new List<Contact>();
    List<String> masterIndexIdList = new List<String>();
    Map<String, Contact> mIContactMap = new Map<String, Contact>();
    
    for(Related_Contact__c rc : Trigger.new)
    {
        if(rc.Master_Index_ID__c != null)
        {
            masterIndexIdList.add(rc.Master_Index_ID__c);
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
     
     for(Related_Contact__c rc : Trigger.new)
     {
         if(rc.Master_Index_ID__c != null && mIContactMap.get(rc.Master_Index_ID__c) != null)
         {
             system.debug('Updating Login History');
             rc.Contact__c = mIContactMap.get(rc.Master_Index_ID__c).Id;
         }
     }
}