trigger RelatedContactAfterInsertUpdate on Related_Contact__c (after insert, after update) {

     Set<String> loginIds = new Set<String>();
     Map<String, Contact> contactsMap = new Map<String, Contact>();
     Map<Id, Contact> cToUpdate = new Map<Id, Contact>();
     Set<ID> ids = new Set<ID>();
     
     for(Related_Contact__c rc: Trigger.new){
         ids.add(rc.id);
     }
     
     List<Related_Contact__c> relatedContacts = [select account__r.Master_Index__c, Contact__r.Login_ID__c,contact_owner__r.id, contact_owner__r.IsActive from related_contact__c where id in :ids];
     for (Related_Contact__c rc : relatedContacts){
          if(rc.Contact__r.login_id__c != null){
            loginIds.add(rc.Contact__r.Login_ID__c);
          }
          

     }
     
     
     List<Contact> contacts = [select id, login_id__c, ownerId from contact where login_id__c in :loginIds];
     for(Contact c: contacts){
        contactsMap.put(c.login_id__c, c);
     }

     
     
     for(Related_Contact__c rc: relatedContacts){
         Contact c = contactsMap.get(rc.contact__r.login_id__c);
         if(c!=null && rc.contact_Owner__c != null && rc.contact_owner__r.isactive){
            c.ownerId = rc.contact_owner__r.id;
            cToUpdate.put(c.id, c);
         }
     }
     try{
        update cToUpdate.values();
     }catch (System.DmlException e) {
        System.debug('##DEBUGGING##' + e.getMessage());
     }

}