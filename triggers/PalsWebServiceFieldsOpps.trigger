trigger PalsWebServiceFieldsOpps on Opportunity (before insert, before update) {
    String prospectRecordTypeId = Utils.getRecordTypeId('Opportunity', 'Pals Prospect');
    String sellerRetentionRecordTypeId = Utils.getRecordTypeId('Opportunity', 'Retention-Seller');
    List<Opportunity> allNewOpps = Trigger.new;
    List<Opportunity> newOpps = new List<Opportunity>();
    
    Set<Id> Set_OwnerIds = new Set<Id>();
    Map<ID, User> map_OwnerId_User = new Map<ID, User>();
    
    for(Opportunity o: allNewOpps){
        if(o.opportunity_type__c != null && 
            (o.opportunity_type__c.equals('Pals Prospect') || 
             o.opportunity_type__c.equals('Pals Seller Retention')) ){
          newOpps.add(o);
        }
        
        // For Field Owner_Role (Owner.UserRole.Name) population 
        if(Trigger.isInsert){
            System.debug('>>>> Before Insert >>>> o.OwnerId: '+o.ownerId );
            Set_OwnerIds.add(o.ownerId);            
        }else if (Trigger.isUpdate){
            if(o.ownerid != Trigger.oldMap.get(o.Id).ownerid)
            {
                System.debug('>>>> Before update owner changed to>>>> o.OwnerId: '+o.ownerId );
                Set_OwnerIds.add(o.ownerId);
            }
        }
        //
        
    }
    Map<String, Id> accountOwners = new Map<String, Id>();
    List<String> sellerOrgs = new List<String>();
    for(Opportunity o: newOpps){
        if(o.opportunity_type__c.equals('Pals Seller Retention'))
            sellerOrgs.add(o.Organization_Look_Up__c);
        else if(o.opportunity_type__c.equals('Pals Prospect'))
            sellerOrgs.add(o.organization_id__c);
    }
    List<Account> accounts = [select atc_organization_id__c, ownerId from account where atc_organization_id__c in :sellerOrgs];
    
    for(Account a: accounts){
    
        accountOwners.put(a.atc_organization_id__c, a.OwnerId);
    }
    
    for(Opportunity o: newOpps){
       if(o.opportunity_type__c.equals('Pals Prospect')){
           o.recordTypeId = prospectRecordTypeId;
           o.ownerId = accountOwners.get(o.organization_id__c);
       }else if(o.opportunity_type__c.equals('Pals Seller Retention')){
           o.recordTypeId = sellerRetentionRecordTypeId;
           o.ownerId = accountOwners.get(o.Organization_Look_Up__c);
       }
       
    
    }
    
    if(Trigger.isUpdate){
       for(Opportunity o: newOpps){
          Opportunity oldOpp = Trigger.oldMap.get(o.Id);
          if(o.stageName.equals('Open') && !oldOpp.stageName.equals('Open')){
             o.stageName = oldOpp.stageName;
          }
         if(Utils.vehiclesDeleted.equals('0') ){
              if(oldOpp.stageName.equals('Closed Won') || oldOpp.stageName.equals('Closed Lost')){
                  o.addError('Opportunity id ' + o.id + ' for organization id ' + o.organization_id__c + ' is in ' + oldOpp.stageName);
              }
          }
          
       }      
    }
    
    // For Field Owner_Role (Owner.UserRole.Name) population 
    if(Set_OwnerIds.size()>0)
    {
        map_OwnerId_User = new Map<ID, User>([SELECT UserRole.Name FROM User Where Id in :Set_OwnerIds]);
        if(map_OwnerId_User!=null)
        {               
            for(Opportunity o: allNewOpps){
                if(map_OwnerId_User.get(o.ownerId)!=null)
                {
                    if(map_OwnerId_User.get(o.ownerId).UserRole!=null)
                    {
                        System.debug('>>>> Before Insert >>>> map_OwnerId_User: '+map_OwnerId_User);
                        System.debug('>>>> Before Insert >>>> map_OwnerId_User.get(o.ownerId).UserRole: '+map_OwnerId_User.get(o.ownerId).UserRole );
                        System.debug('>>>> Before Insert >>>> map_OwnerId_User.get(o.ownerId).UserRole.Name: '+map_OwnerId_User.get(o.ownerId).UserRole.Name );
                        o.Owner_Role__c = map_OwnerId_User.get(o.ownerId).UserRole.Name;                        
                    }
                }
            }
        }
    }
}