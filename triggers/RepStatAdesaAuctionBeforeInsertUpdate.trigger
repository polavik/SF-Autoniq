trigger RepStatAdesaAuctionBeforeInsertUpdate on Rep_Status_ADESA_Auction__c (before insert, before update) {

    List<Contact> contactList = new List<Contact>();
    List<String> personIdList= new List<String>();
    Map<String, Contact> personIdContactMap = new Map<String, Contact>();
    
    for(Rep_Status_ADESA_Auction__c r : Trigger.new)
    {
        if(r.Contact_Person_Id__c!= null)
        {
            personIdList.add(r.Contact_Person_Id__c);
        }
    }
    
    system.debug('Person Id List: ' + personIdList);
    
    contactList =     
    [
        SELECT Id, Person_ID__c
        FROM Contact
        WHERE Person_ID__c in : personIdList
    ];
    
    system.debug('Contact List: ' + contactList );
    
    for(Contact c : contactList)
    {
        if(c.Person_ID__c != null)
        {
            personIdContactMap .put(c.Person_ID__c, c);
        }
     }
     
     system.debug('Person ID Contact Map: ' + personIdContactMap);
     
     for(Rep_Status_ADESA_Auction__c r : Trigger.new)
     {
         if(r.Contact_Person_Id__c != null && personIdContactMap.get(r.Contact_Person_Id__c) != null)
         {
             system.debug('Updating Identification Document');
             r.Contact__c = personIdContactMap.get(r.Contact_Person_Id__c).Id;
         }
     }


}