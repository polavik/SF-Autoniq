public class InspectionRequestCancelController {

//This Class will be called every time the IR is viewed.  It will do nothing unless the IR is in the 'Cancel' status AND we have not attempted to redirect the user before
//It's used for the automated creation of APs for Canceled PSI IRs.

Inspection_Request__c ir;
private ApexPages.StandardController controller;

public InspectionRequestCancelController(ApexPages.StandardController controller) 
{
    this.controller = controller;
}

public PageReference redirect() 
{
     ID irId = controller.getId();
     ir = 
            [
            SELECT ID,
            PSI_Passed__c,
            PSI_Cancel_Redirect__c,
            Vehicle_Id__c
            FROM Inspection_Request__c WHERE Id = :irId
            FOR UPDATE
            ];
            
    if(ir.PSI_Passed__c == 'Cancel' && ir.PSI_Cancel_Redirect__c == false)
    {
		
		 //Story B-44003 : FLS UPDATE ACCESS CHECK
		 Set<String> ListFLSUpdate = new Set<String>();
		 Boolean blnFLSOverride = Utils.GetFLS();
		 if (Schema.sObjectType.Inspection_Request__c.fields.PSI_Cancel_Redirect__c.isUpdateable() || blnFLSOverride)
		 {						 
			 ir.PSI_Cancel_Redirect__c = true;  //We only ever want to try this once, reguardless of success or failure.
		 }
		 else
		 {						
			ListFLSUpdate.add(Schema.sObjectType.Inspection_Request__c.getName()+'.'+Schema.sObjectType.Inspection_Request__c.fields.PSI_Cancel_Redirect__c.getName());
		 }
		 if(ListFLSUpdate.size()>0)
		 {
		 	Utils.SendEmailforFLS('FLS_UPDATE','CLASS:InspectionRequestCancelController', ListFLSUpdate);
		 }
         update ir;
		 
		
                  
         Action_Package__c pkg =
         [
         SELECT ID
         FROM Action_Package__c
         WHERE Vehicle_Id__c = :ir.Vehicle_Id__c
         AND Auto_Approve_Override__c = true
         ORDER BY CreatedDate ASC
         LIMIT 1
         ];
         
         if(pkg != null)
         {
             PageReference pr = Page.dispatcher_action_pkg_details;
             pr.getParameters().put('id', pkg.Id);
             return pr;
         }
         

    }
      
    //If anything goes wrong or there is nothing to do, we simply display the IR normally.    
    PageReference ref = controller.view();
    Map<String, String> params = ref.getParameters();
    params.put('nooverride','1');
    return ref;
}



}