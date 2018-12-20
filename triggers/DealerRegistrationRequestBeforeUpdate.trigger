trigger DealerRegistrationRequestBeforeUpdate on Dealer_Registration_Request__c (before update) {

List<Dealer_Registration_User_Request__c> allUsers = new List<Dealer_Registration_User_Request__c>();
List<Id> drrErrorList = new List<Id>();

allUsers  =
[
    SELECT
    Id, Requested_Username__c, Dealer_Registration_Request__c
    FROM Dealer_Registration_User_Request__c
    WHERE Dealer_Registration_Request__c in :Trigger.new
];
for(Dealer_Registration_User_Request__c user : allUsers)
{
    if(user.Requested_Username__c != null && user.Requested_Username__c.containsAny('<>&\"\''))
    {
        boolean dupe = false;
        for(Id drrId : drrErrorList)
        {  
            
            if(user.Dealer_Registration_Request__c == drrId)
            dupe = true;
            break;
        }
        if(dupe == false)
        {
            drrErrorList.add(user.Dealer_Registration_Request__c);
        }
        
        //user.Dealer_Registration_Request__c.addError('Requested Username contains invalid characters ( < > & \' \")'); 
    }
}

//Adds Country ID to PDRUR
List<Parent_DRUR__c> pDRURList = new List<Parent_DRUR__c>();
List<Id> pDRURIdList = new List<Id>();
Map<Id, Parent_DRUR__c> finalPdrurToUpdateMap = new Map<Id, Parent_DRUR__c>();

for(Dealer_Registration_Request__c drr :Trigger.new)
{
    for(Id errorId : drrErrorList)
    {
        if(errorId == drr.Id)
        {
            
            drr.addError('Requested Username contains invalid characters ( < > & \' \")');
            break;
        }
    }
    
    if(drr.Parent_DRUR__c != null)
    {
        pDRURIdList.add(drr.Parent_DRUR__c);
    }
    
    

}

    pDRURList = 
    [    
        SELECT Id, Country__c
        FROM Parent_DRUR__c
        WHERE Id in : pDRURIdList
    ];
    
    for(Dealer_Registration_Request__c drr :Trigger.new)
    {
        for(Parent_DRUR__c pdrur : pDRURList)
        {
            if(drr.Parent_DRUR__c == pdrur.Id)
            {
                pdrur.Country__c = drr.Country__c;
                finalPdrurToUpdateMap.put(pdrur.Id, pdrur);
                break;
            }
        }
        
    
    }
    
    
    Database.update(finalPdrurToUpdateMap.values());
    
    

}