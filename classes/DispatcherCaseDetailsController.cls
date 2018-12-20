public class DispatcherCaseDetailsController {
    private final ApexPages.StandardController controller;  
        
    public DispatcherCaseDetailsController(ApexPages.StandardController controller) {  
        this.controller = controller;
    }
    

    public PageReference redirect() {   

        String profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;  
  
  
        if (profileName.equals('Limited Customer Portal User') || profileName.equals('Limited US Portal User') || profileName.equals('Limited Canadian Portal User'))
        {  
            PageReference pr = Page.case_details;
            pr.getParameters().put('id', controller.getId());
            return pr;
        }
        else if (profileName.equals('Limited Seller Portal User')) 
        {
            // This is a temporary workaround for the fact that Seller Portal users have view permissions
            // on Cases.  If a Seller Portal user tries to view the Case Detail Page directly, redirect to the
            // appropriate Case Escalation page on that Case.  
            Case_Escalation__c caseEscalation = 
                [SELECT Id FROM Case_Escalation__c WHERE Case__c = :controller.getId()];
            
            PageReference pr = Page.case_escalation;
            pr.getParameters().put('id', caseEscalation.Id);
            return pr;
        }
        else 
        {  
            PageReference pr = controller.view();
            pr.getParameters().put('nooverride','1');
            return pr;
        }  
    }  
}