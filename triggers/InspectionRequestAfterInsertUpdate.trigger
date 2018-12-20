trigger InspectionRequestAfterInsertUpdate on Inspection_Request__c (after insert, after update) 
{
    boolean IsMigrationRuning = false;           
    IsMigrationRuning = Utils.getIsMigrationRuning('is.migration.running');
  if (!IsMigrationRuning )  {
    List<ID> purchaseIds = new List<ID>();//List to hold all purchases assocaited with IRs
    List<Inspection_Request__c> irs = new List<Inspection_Request__c>();
    
    for (Inspection_Request__c i : Trigger.new) 
        {
            irs.add(i);
        }
    
    List<Inspection_Request__c> irsToPassFail = //A list of all IRs to send to the Pass/Fail/Cancel code 
    [
        SELECT Id,
        Purchase__c,
        process_PSI__c,
        PSI_Passed__c,
        Purchase__r.ATC_Buyer_Contact__c,
        Purchase__r.ATC_Buyer__c,
        Purchase__r.ATC_Seller__c,
        Purchase__r.Country__c,
        Purchase__r.Inspection_Fee__c,
        PSI_Review_Comments__c,
        Inspection_Type__c,
        Ownerid,
        Inspection_Fee__c,
        LoggedUser__c
        FROM Inspection_Request__c
        WHERE Id IN :irs
    ];
    
    
    // B-16452: PSI Workflow in Salesforce.  Check for PSI Passed, Failed, or Canceled, and call Mediator appropriately.  
        List<ID> irsToUpdate = new List<ID>();
        for (Inspection_Request__c newIr : irsToPassFail)
        {
    
            if (newIr.process_PSI__c)
            {
                InspectionRequestHelper irh = new InspectionRequestHelper(newIr);
                if ('PASS'.equalsIgnoreCase(newIr.PSI_Passed__c))
                {
                    irh.psiPassed();
                }
                else if('FAIL'.equalsIgnoreCase(newIr.PSI_Passed__c))
                {
                    irh.psiFailed();
                }
                else if ('CANCEL'.equalsIgnoreCase(newIr.PSI_Passed__c))
                {
                    irh.psiCanceled();
                }
                irsToUpdate.add(newIr.id);
            }
            
        }
        
        List<Inspection_Request__c> inspectionsToUpdate =  [SELECT process_PSI__C
                                                            FROM Inspection_Request__c
                                                            WHERE Id IN :irsToUpdate
                                                          ];
      
        for (Inspection_Request__c ir : inspectionsToUpdate){
           ir.process_PSI__C = false;
        }
      
        if (inspectionsToUpdate.size() > 0){
           Database.update(inspectionsToUpdate);
        }
  
  }
}