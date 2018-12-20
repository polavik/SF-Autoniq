trigger CaseAfterInsertUpdate on Case (after insert, after update) 
{
    // Set "Case Status History" field on Case Escalation object (if one exists), to track who has modified Case Status from the Case Escalation page

    // If these are stewardship Cases, update the appropriate "In_Stewardship__c flags for the related Accounts"
    Set<Id> accountIdSet = new Set<Id>();
    for(Case c : Trigger.new){
        if(c.RecordTypeId == StewardshipHelper.stewardshipRtId){
            accountIdSet.add(c.AccountId);
        }
    }
    if(!System.isFuture()){
      StewardshipHelper.updateAccountStewardship(accountIdSet);
    }
   
    if (Trigger.isUpdate)
    {
        System.debug('Checking for closed or re-opened cases.');
        Map<ID, Case> modifiedCaseMap = new Map<ID, Case>();
        for (Case newCase : Trigger.new)
        {
       
    // djpatel (10-Nov-14): Added condition for Case Migration Process
            if(!newCase.Is_Migrated_Openlane_Case__c)
            {
                Case oldCase = Trigger.oldMap.get(newCase.Id);
                // Only capture cases being moved to or from Closed status
                if (('CLOSED'.equalsIgnoreCase(newCase.Status) || 'CLOSED'.equalsIgnoreCase(oldCase.Status)) && !newCase.Status.equalsIgnoreCase(oldCase.Status))
                {
                    System.debug('Case closed or reopened: ' + newCase.Id + ', new Status: ' + newCase.Status);
                    modifiedCaseMap.put(newCase.Id, newCase);
                }
            }
        }
        
        List<Case_Escalation__c> caseEscalationsToModify = 
        [
            SELECT Case__c, Case_Status_History__c
            FROM Case_Escalation__c
            WHERE Case__c IN :modifiedCaseMap.keySet()
        ];
        System.debug('Retrieved ' + caseEscalationsToModify.size()  + ' Case Escalations with Case_Status_History__c to be modified');
        
        for (Case_Escalation__c escalation : caseEscalationsToModify)
        {
            String newStatus = 'CLOSED'.equalsIgnoreCase(modifiedCaseMap.get(escalation.Case__c).Status) ? 'Closed' : 'Open';
            escalation.Case_Status_History__c = newStatus;
        }
        
        if (caseEscalationsToModify.size() > 0)
        {
            Database.update(caseEscalationsToModify);
        }
    }
    
    System.debug('out side Checking for request for Lien release (Canada) case.');
    
    // If Trigger_Arb_Status_Change__c field is set (via Workflow Rule), the following block of code
    //  will trigger a webservice call to V1 to modify that vehicle's status in the post-sales system
    List<ID> caseIdsToArbitrate = new List<ID>();
    List<ID> caseIdsToRestore = new List<ID>();
    List<ID> caseIdsToCancelPSIAndArbitrate = new List<ID>();
    List<ID> caseIdsForDBNotificationEmail = new List<ID>();
    List<ID> caseIdsForLienReleaseCanada = new List<ID>();
    
    for (Case c : Trigger.new)
    {
     //Story B-36803: Sync Ownership Case Type to NGPS from SF for ADC Funding (after insert/update)
     System.debug('Case reason:'+c.reason);
     if (c.reason.equals('Request for Lien Release - Canada')){
      System.debug('Request for Lien Release - Canada case.');
      caseIdsForLienReleaseCanada.add(c.Id);
      }
    // djpatel (10-Nov-14): Added condition for Case Migration Process
        if(!c.Is_Migrated_Openlane_Case__c)
        {
            if (!'YES'.equalsIgnoreCase(c.Archived__c) && c.Trigger_Arb_Status_Change__c != null)
            {
                System.debug('Trigger.isInsert: ' + Trigger.isInsert);
                System.debug('Trigger_Arb_Status_Change__c: ' + c.Trigger_Arb_Status_Change__c);
                System.debug('Inspection_Request__c:' + c.Inspection_Request__c);
                Logger.info(c, 'Trigger_Arb_Status_Change__c set to: ' + c.Trigger_Arb_Status_Change__c);
                
                // For Cases being created as the result of a failed PSI, need to first restore from PSI and then arbitrate
                if (c.Trigger_Arb_Status_Change__c.equals('ARBITRATE') &&
                    c.Inspection_Request__c != null)
                {
                    System.debug('Adding case to caseIdsToCancelPSIAndArbitrate');
                    caseIdsToCancelPSIAndArbitrate.add(c.Id);
                }
                else if (c.Trigger_Arb_Status_Change__c.equals('ARBITRATE'))
                {
                    caseIdsToArbitrate.add(c.Id);
                }
                else if (c.Trigger_Arb_Status_Change__c.equals('RESTORE'))
                {
                    caseIdsToRestore.add(c.Id);
                }
                else
                {
                    Logger.error(c, 'Invalid Trigger_Arb_Status_Change__c value: ' + c.Trigger_Arb_Status_Change__c);
                }
            }
            if (Trigger.isInsert)
            {   
                System.debug('Checking for New DB Openend Cases .');
                caseIdsForDBNotificationEmail.add(c.Id);
                
            }
           
        }
    }
    //Story B-36803: Sync Ownership Case Type to NGPS from SF for ADC Funding (after insert/update)
    if (caseIdsForLienReleaseCanada.size() > 0)
    {
        System.debug('CaseHelper.openLienCase(caseIdsForLienReleaseCanada) --> send webservice call for updating Lien Flag');
        CaseHelper.openLienCase(caseIdsForLienReleaseCanada);
        System.debug('CaseHelper.openLienCase(caseIdsForLienReleaseCanada) -->DONE!!');
    }
    if (caseIdsToArbitrate.size() == 0 && 
        caseIdsToRestore.size() == 0 && 
        caseIdsToCancelPSIAndArbitrate.size() == 0)
    {
        return;
    }
    
    if (caseIdsToCancelPSIAndArbitrate.size() > 0)
    {
        ActionPackageHelper.cancelPSIAndArbitrateVehicle(caseIdsToCancelPSIAndArbitrate);
    }
    
    if (caseIdsToArbitrate.size() > 0)
    {
        ActionPackageHelper.arbitrateVehicle(caseIdsToArbitrate);
    }
    
    if (caseIdsToRestore.size() > 0)
    {
        ActionPackageHelper.restoreVehicleFromArbitration(caseIdsToRestore);
    }
    

    
    List<Case> casesToUpdate = 
        [SELECT Id, Trigger_Arb_Status_Change__c 
         FROM Case 
         WHERE Id IN :caseIdsToArbitrate
         OR Id IN :caseIdsToRestore
         OR Id IN :caseIdsToCancelPSIAndArbitrate];
    
    for (Case c : casesToUpdate)
    {
        c.Trigger_Arb_Status_Change__c = null;
    }
    
    update casesToUpdate;

        List<Case> DBCases = [select id, Secondary_Owner_Notification_Step__c, 
                                      Secondary_Owner_Notification_Recipient__c, 
                                      Secondary_Owner__c, vin__r.Is_Dealer_Block__c, Case_Comment_Id__c,
                                      ownerId,CaseNumber,Consignee__c,Type,Reason,Account.name,Secondary_Owner__r.name,
                                      Owner.name
                                      //Owner,Account,
                                 from case
                                where id in :caseIdsForDBNotificationEmail];        
    
    for (Case c : DBCases)
    {
        
      if   (c.vin__r.Is_Dealer_Block__c != null)
      {
        if (c.vin__r.Is_Dealer_Block__c.equalsIgnoreCase('yes'))
        {
            ID targetId = c.OwnerId;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String subject = 'Dealer Block Case Opened';
            String textBody = 'An ADESA Processing Auction vehicle has been entered into arbitration.\n\n' + 
                          'Please reference Case ' + c.CaseNumber + '\n\n' +
                          'Click on the link below to view the record.\n\n'+
                          ' \n'+
                          'Consignee: ' + c.Consignee__c + '\n' +
                          'Case Owner: ' + c.Owner.name + '\n' +
                          'Secondary Owner: ' + c.Secondary_Owner__r.name + '\n' +
                          'Account Name: ' + c.Account.name + '\n' +
                          'Case Type: ' + c.Type + '\n' +
                          'Case Reason:  ' + c.Reason + '\n' + 
                          'Case Number: <a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id + '>' + c.CaseNumber + '</a>';
                          
        
            String htmlBody = 'An ADESA Processing Auction vehicle has been entered into arbitration<p>' + 
                          'Please reference Case ' + c.CaseNumber + '<p>' +
                          'Click on the link below to view the record.<p>'+
                          ' <p>'+
                          'Consignee: ' + c.Consignee__c + '<p>' +
                          'Case Owner: ' + c.Owner.name + '<p>' +
                          'Secondary Owner: ' + c.Secondary_Owner__r.name + '<p>' +
                          'Account Name: ' + c.Account.name + '<p>' +
                          'Case Type: ' + c.Type + '<p>' +
                          'Case Reason:  ' + c.Reason + '<p>' + 
                          'Case Number: <a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id + '>' + c.CaseNumber + '</a>';
        
            mail.setTargetObjectId(targetId);
            mail.setToAddresses(new String[] {'kkempton@openlane.com'});
            mail.setSubject(subject);
            mail.setPlainTextBody(textBody);
            mail.setHtmlBody(htmlBody);
            mail.setSaveAsActivity(false);
            
            if(!Sandbox.isSandbox())
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });               
        }
      }
    }

    Logger.flush();
    public class RuntimeException extends Exception {}
    
}