trigger IdentificationDocumentBeforeInsertUpdate on Identification_Document__c (before insert, before update) {

    List<Contact> contactList = new List<Contact>();
    List<String> personIdList= new List<String>();
    Map<String, Contact> personIdContactMap = new Map<String, Contact>();
    
    for(Identification_Document__c i : Trigger.new)
    {
        if(i.Contact_Person_Id__c!= null)
        {
            personIdList.add(i.Contact_Person_Id__c);
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
     
     for(Identification_Document__c i : Trigger.new)
     {
         if(i.Contact_Person_Id__c != null && personIdContactMap.get(i.Contact_Person_Id__c) != null)
         {
             system.debug('Updating Identification Document');
             i.Contact__c = personIdContactMap.get(i.Contact_Person_Id__c).Id;
         }
     }


}