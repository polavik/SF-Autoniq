trigger ProxyBidBeforeInsertUpdate on Proxy_Bid__c (before insert, before update) {

    List<Contact> contactList = new List<Contact>();
    List<String> loginIdList = new List<String>();
    Map<String, Contact> loginIdContactMap = new Map<String, Contact>();
    
    for(Proxy_Bid__c p : Trigger.new)
    {
        if(p.Contact_Login_Id__c != null)
        {
            loginIdList.add(p.Contact_Login_Id__c);
        }
    }
    
    system.debug('Login Id List: ' + loginIdList);
    
    contactList =     
    [
        SELECT Id, Login_ID__c
        FROM Contact
        WHERE Login_ID__c in : loginIdList
    ];
    
    system.debug('Contact List: ' + contactList );
    
    for(Contact c : contactList)
    {
        if(c.Login_ID__c != null)
        {
            loginIdContactMap.put(c.Login_ID__c, c);
        }
     }
     
     system.debug('Login ID Contact Map: ' + loginIdContactMap);
     
     for(Proxy_Bid__c p : Trigger.new)
     {
         if(p.Contact_Login_Id__c != null && loginIdContactMap.get(p.Contact_Login_Id__c) != null)
         {
             system.debug('Updating Proxy');
             p.Contact__c = loginIdContactMap.get(p.Contact_Login_Id__c).Id;
         }
     }


}