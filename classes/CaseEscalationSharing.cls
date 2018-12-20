global class CaseEscalationSharing implements Database.Batchable<SObject>, Database.Stateful {
    
    protected String query = 
        'SELECT Case__c, Case__r.Seller__c FROM Case_Escalation__c';
    
    public CaseEscalationSharing(){ /* Do nothing */ }
    
    public CaseEscalationSharing(String sellerOrgId)
    {   
        //PPM#99440 - There are no data in Seller_r.ATC_Organization_ID__c field, So finding Seller(Account) by Adesa_com_Detail__c object 
        //this.query = this.query + ' WHERE Case__r.Seller__r.ATC_Organization_ID__c = \'' + sellerOrgId + '\'';        
        List<Adesa_com_Detail__c> List_Adesa_com_Detail = [SELECT ID,Account__r.Master_Index__c FROM Adesa_com_Detail__c WHERE ATC_Organization_ID__c=:sellerOrgId];
        if(List_Adesa_com_Detail.size()>0)
        {
            if(List_Adesa_com_Detail[0].Account__r.Master_Index__c!=null && List_Adesa_com_Detail[0].Account__r.Master_Index__c!='')
            {
                this.query = this.query + ' WHERE Case__r.Seller__r.Master_Index__c = \'' + List_Adesa_com_Detail[0].Account__r.Master_Index__c + '\'';
            }
            System.debug('>>>> CaseEscalationSharing--> List_Adesa_com_Detail'+List_Adesa_com_Detail);
        }
        else
        {           
            this.query = this.query + ' LIMIT 0';
            System.debug('>>>> CaseEscalationSharing--> no records in List_Adesa_com_Detail');
        }
    }
    
    
    /**
     * Prerequisite: Case must have the following data items loaded:
     *   Seller__c
     *   Case_Escalations__r
     */
    public static void createAndShareEscalations(List<Case> cases)
    {
        System.debug('Determining whether Case should be escalated');
        Map<ID, List<ID>> caseIdSellerPermissionsMap = getSellerPermissions(cases);
        List<Case_Escalation__c> escalationsToInsert = new List<Case_Escalation__c>();
        for (Case c : cases)
        {
            List<ID> sellerPermissions = caseIdSellerPermissionsMap.get(c.Id);
            if (c.Case_Escalations__r.size() == 0 &&
                sellerPermissions != null && 
                sellerPermissions.size() > 0) 
            {
                escalationsToInsert.add(new Case_Escalation__c(Case__c = c.Id));
            }
        }
        
        System.debug('Escalations to be inserted: ' + escalationsToInsert.size());
        
        List<Database.SaveResult> sr = Database.insert(escalationsToInsert);
        for (Database.SaveResult saveResult : sr)
        {
            System.debug('isSuccess: ' + saveResult.isSuccess());
            for (Database.Error err : saveResult.getErrors())
            {
                System.debug('Error Message: ' + err.getMessage()); 
            }
        }
        
        System.debug('Sharing Cases that were Escalated');
        Map<ID, List<ID>> escalatedCaseIdUserIdMap = new Map<ID, List<ID>>();
        for (Case_Escalation__c escalation : escalationsToInsert)
        {
            ID caseId = escalation.Case__c;
            List<ID> userIds = caseIdSellerPermissionsMap.get(escalation.Case__c);
            escalatedCaseIdUserIdMap.put(caseId, userIds);
        }
        shareCases(escalatedCaseIdUserIdMap);
        
        System.debug('Sharing Case Escalations that were created');
        Map<ID, List<ID>> escalationIdUserIdMap = new Map<ID, List<ID>>();
        for (Case_Escalation__c escalation : escalationsToInsert)
        {
            List<ID> userIds = caseIdSellerPermissionsMap.get(escalation.Case__c);
            escalationIdUserIdMap.put(escalation.Id, userIds);
        }
        shareCaseEscalations(escalationIdUserIdMap); 
    }
    
    /* When a Case Owner changes, all custom Case shares get wiped out.  
     * This method should be called whenever the Case Owner changes to reinstate those shares.  
    */
    public static void resetCaseSharing(List<Case> cases)
    {
        Map<ID, List<ID>> caseIdSellerPermissionsMap = getSellerPermissions(cases);
        if (caseIdSellerPermissionsMap.size() > 0)
        {
            shareCases(caseIdSellerPermissionsMap);
        }
    }
    
    /** Returns a map from Case Id to a list of users who have seller permissions on those cases
     *  Prerequisite: Case must have "Seller__c" field populated
     */
    public static Map<ID, List<ID>> getSellerPermissions(List<Case> cases)
    {
        Map<ID, List<ID>> caseIdSellerPermissionsMap = new Map<ID, List<ID>>();
        
        // Generate a map from Account to all Cases where they are the Seller
        Map<ID, List<Case>> sellerIdCaseMap = new Map<ID, List<Case>>();
        for (Case c : cases)
        {
            List<Case> mappedCases = sellerIdCaseMap.get(c.Seller__c);
            if (mappedCases == null)
            {
                mappedCases = new List<Case>();
                sellerIdCaseMap.put(c.Seller__c, mappedCases);
            }
            mappedCases.add(c);
        }
        
        // Pull a map of Users who have Seller Permissions for each Seller
        for (Seller_Permission__c sp :
            [SELECT User__c, Account__c FROM Seller_Permission__c WHERE Account__c IN :sellerIdCaseMap.keySet() AND User__r.IsActive = true])
        {
            // For each User, determine which Cases they should be able to access
            List<Case> sellerCases = sellerIdCaseMap.get(sp.Account__c);
            for (Case c : sellerCases)
            {
                List<ID> permittedUsers = caseIdSellerPermissionsMap.get(c.Id);
                if (permittedUsers == null)
                {
                    permittedUsers = new List<ID>();
                    caseIdSellerPermissionsMap.put(c.Id, permittedUsers);
                }
                // Add user to list of permitted users for that case
                permittedUsers.add(sp.User__c);
            }
        }
        return caseIdSellerPermissionsMap;
    }
    
    /**
     * Returns a map from Case Escalation ID to users who have Seller Permissions visibility on
     * those escalations.  
     * Prerequisite: "Case__r.Seller__c" field must be populated on Case Escalation
     */
    public static Map<ID, List<ID>> getSellerPermissions(List<Case_Escalation__c> escalations)
    {   
        Map<ID, Case> escalationCaseMap = new Map<ID, Case>();
        for (Case_Escalation__c escalation : escalations)
        {
            escalationCaseMap.put(escalation.Id, escalation.Case__r);
        }
        
        Map<ID, List<ID>> escalationIdSellerPermissionsMap = new Map<ID, List<ID>>();
        Map<ID, List<ID>> caseIdSellerPermissionsMap = getSellerPermissions(escalationCaseMap.values());
        for (Case_Escalation__c escalation : escalations)
        {
            ID caseId = escalationCaseMap.get(escalation.Id).Id;
            escalationIdSellerPermissionsMap.put(escalation.Id, caseIdSellerPermissionsMap.get(caseId));
        }
                
        return escalationIdSellerPermissionsMap;
    }
    
    public static void shareCases(Map<ID, List<ID>> caseIdUserIdMap)
    {
        List<CaseShare> newCaseShares = new List<CaseShare>();
        Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
		
        for (ID caseId : caseIdUserIdMap.keySet())
        { /**
          *get case ownerId/userId and exclude from map to fix issue INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY
          */
            Case cc = [SELECT OwnerId FROM Case WHERE id IN :caseIdUserIdMap.keySet()];
            for (ID userId : caseIdUserIdMap.get(caseId))
            {   
                if (cc.OwnerId!=userId){
                    CaseShare cShare = new CaseShare();
					if (Schema.sObjectType.CaseShare.fields.CaseId.isCreateable() || blnFLSOverride)
					{
						cShare.CaseId = caseId;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.CaseShare.getName()+'.'+Schema.sObjectType.CaseShare.fields.CaseId.getName());
					}
					if (Schema.sObjectType.CaseShare.fields.UserOrGroupId.isCreateable() || blnFLSOverride)
					{
						cShare.UserOrGroupId = userId;
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.CaseShare.getName()+'.'+Schema.sObjectType.CaseShare.fields.UserOrGroupId.getName());
					}
					if (Schema.sObjectType.CaseShare.fields.CaseAccessLevel.isCreateable() || blnFLSOverride)
					{
						cShare.CaseAccessLevel = 'Read';
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.CaseShare.getName()+'.'+Schema.sObjectType.CaseShare.fields.CaseAccessLevel.getName());
					}					
                    newCaseShares.add(cShare);
                }
            }
        }
        
        System.debug('New Case Shares: ' + newCaseShares.size());
        if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:CaseEscalationSharing', ListFLSCreate);
		}
		else
		{	
			List<Database.SaveResult> sr = Database.insert(newCaseShares);
			for (Database.SaveResult saveResult : sr)
			{
				System.debug('isSuccess: ' + saveResult.isSuccess());
				for (Database.Error err : saveResult.getErrors())
				{
					System.debug('Error Message: ' + err.getMessage()); 
				}
			}
		}
    }
    
    public static void shareCaseEscalations(Map<ID, List<ID>> escalationIdUserIdMap)
    {
        
        System.debug('Deleting existing Case Escalation Shares');
        for (List<Case_Escalation__Share> existingShares : 
            [SELECT Id 
             FROM Case_Escalation__Share 
             WHERE ParentId IN :escalationIdUserIdMap.keySet()
             AND RowCause = 'Seller_Permission__c'])
        {
            List<Database.DeleteResult> results = Database.delete(existingShares);
            for (Database.DeleteResult deleteResult : results)
            {
                System.debug('isSuccess: ' + deleteResult.isSuccess());
                for (Database.Error err : deleteResult.getErrors())
                {
                    System.debug('Error Message: ' + err.getMessage()); 
                }
            }
        }
        
        List<Case_Escalation__Share> newEscalationShares = new List<Case_Escalation__Share>();
        for (ID escalationId : escalationIdUserIdMap.keySet())
        {
            for (ID userId : escalationIdUserIdMap.get(escalationId))
            {               
                Case_Escalation__Share escalationShare = new Case_Escalation__Share();
                escalationShare.ParentId = escalationId;
                escalationShare.UserOrGroupId = userId;
                escalationShare.AccessLevel = 'Edit';
                escalationShare.RowCause = Schema.Case_Escalation__Share.RowCause.Seller_Permission__c;
                newEscalationShares.add(escalationShare);
            }
        }
            
        System.debug('New Escalation Shares: ' + newEscalationShares.size());
        List<Database.SaveResult> sr = Database.insert(newEscalationShares);
        
        for (Database.SaveResult saveResult : sr)
        {
            System.debug('isSuccess: ' + saveResult.isSuccess());
            for (Database.Error err : saveResult.getErrors())
            {
                System.debug('Error Message: ' + err.getMessage()); 
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        List<Case_Escalation__c> escalations = new List<Case_Escalation__c>();
        for (SObject o : scope)
        {
            escalations.add((Case_Escalation__c) o);
        }
        
        Map<ID, List<ID>> escalationIdUserIdMap = getSellerPermissions(escalations);
        
        System.debug('Sharing Cases');
        Map<ID, List<ID>> caseIdUserIdMap = new Map<ID, List<ID>>();
        for (Case_Escalation__c escalation : escalations)
        {
            ID caseId = escalation.Case__c;
            List<ID> userIds = escalationIdUserIdMap.get(escalation.Id);
            caseIdUserIdMap.put(caseId, userIds);
        }
        shareCases(caseIdUserIdMap);
        
        System.debug('Sharing Case Escalations that were created');
        shareCaseEscalations(escalationIdUserIdMap);
    }

    global void finish(Database.BatchableContext bc) 
    {
    }
}