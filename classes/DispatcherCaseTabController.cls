public class DispatcherCaseTabController {
    private final ApexPages.StandardSetController controller;  
        
    public DispatcherCaseTabController(ApexPages.StandardSetController controller) {  
        this.controller = controller;  
    }      
    

    public PageReference redirect() {   

        String profileName = [select Name from Profile where Id = :UserInfo.getProfileId()].Name;  
  
  
        if (profileName.equals('Limited Customer Portal User') || profileName.equals('Limited US Portal User') || profileName.equals('Limited Canadian Portal User')) 
        {  
            return new PageReference('/500');
        } 
        else if (profileName.equals('Limited Seller Portal User'))
        {
            return Page.open_case_escalations;
        }
        else 
        {  
            String url = '/500/o?';
            
            // Forward along parameters that were passed to this page,
            //  while removing some parameters that we don't want to pass along
            for(String key : ApexPages.currentPage().getParameters().keySet()) {
                if (!key.equalsIgnoreCase('_CONFIRMATIONTOKEN') 
                    && !key.equalsIgnoreCase('sfdc.override')
                    && !key.equalsIgnoreCase('save_new'))
                    url = url + key + '=' + ApexPages.currentPage().getParameters().get(key) + '&';
            }
            url = url + 'nooverride=1';
            return new PageReference(url);
        }  
    }  
}