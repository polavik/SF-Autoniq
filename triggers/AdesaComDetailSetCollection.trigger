trigger AdesaComDetailSetCollection on Adesa_com_Detail__c (after insert, after update) {

    List<Collection__c> newColl = new List<Collection__c>();
    List<Collection__c> updateColl = new List<Collection__c>(); 
    Map<String, Adesa_com_Detail__c> orgsMap = new Map<String, Adesa_com_Detail__c>();
    for (Adesa_com_Detail__c org : Trigger.new) {
        if (org.ATC_Organization_Id__c != null) {
            orgsMap.put(org.ATC_Organization_Id__c, org);
        }   
    } 
    
    if (orgsMap.size() == 0) {
        return;
    }
    
    Set<String> orgIds = orgsMap.keySet();
    List<Collection__c> colls = [SELECT Organization_ID__c
                                      FROM Collection__c WHERE Organization_ID__C in :orgIds];
    Map<String, Collection__c> collMap = new Map<String, Collection__c>();
    for (Collection__c c : colls) {
        collMap.put(c.Organization_Id__c, c);
    } 
    
    for (Adesa_com_Detail__c org : orgsMap.values()) {
        Collection__c c = collMap.get(org.ATC_Organization_ID__c);
        if (c == null) {
            c = new Collection__c();
            newColl.add(c);
        } else {
            updateColl.add(c);
        }
        c.ADESA_com_Detail__c = org.Id;
        c.Account__c = org.Account__c;
        String name = org.Name;
        if (name != null && name.length() > 68) 
        {
          name = name.substring(0, 68); 
        }
        c.Name = name + ' Collections';
        c.Organization_Id__c = org.ATC_Organization_Id__c;
    }
    insert newColl;
    update updateColl; 
}