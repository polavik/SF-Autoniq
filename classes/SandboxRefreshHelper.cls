global class SandboxRefreshHelper implements SandboxPostCopy 
{
    global void runApexClass(SandboxContext context) 
    {
        System.debug('Hello Admin, This is Org.Id : ' + context.organizationId() + ' SandboxId/Name :' + context.sandboxId() +' / '+ context.sandboxName());
        
        String strSandboxName = context.sandboxName();
        
        // ***** (1) Freeze User 
        // Get List from Custom Setting "(Non-Prod) User-Profile to keep Active" and Freeze other non portal 
        
        SandboxRefreshHelperUtil_Sync.DeactiveUser();
        
        // ***** (2)Email Update 
        // Fix the user email addresses so they're not in the format username@something=example.com
        // CustomSetting : (Non-Prod) User-Profile to Change Email              
        SandboxRefreshHelperUtil_Sync.UpdateEmail(strSandboxName);
                   
        //existing 
        try {
            //String strSandboxName = 'dipesh1';  
            boolean IsValidSandbox = false ;
            List<User_Create_Update_Sandbox__c> List_User_Update_Sandbox = User_Create_Update_Sandbox__c.getAll().values();     
            for(User_Create_Update_Sandbox__c objUser_Create_Update_Sandbox :  List_User_Update_Sandbox){
                if(objUser_Create_Update_Sandbox.Name.equalsIgnoreCase(strSandboxName)){
                    IsValidSandbox = true;
                }
            }
            if(Test.isRunningTest())
            {
                IsValidSandbox = true;
            }           
            if(IsValidSandbox) 
            {    
                // ***** (3)( AFC QA )   
                 // CustomSetting :(Non-Prod) AFC Branch Record ID
                 // CustomSetting :(Non-Prod) AFC User to update
                String strBranchID =  SandboxRefreshHelperUtil_Sync.AFC_User(strSandboxName);
                SandboxRefreshHelperUtil_Async.AFC_User(strSandboxName,strBranchID);
                
                // ***** (4)( ADESA QA ) 
                // CustomSetting :(Non-Prod) QA CreateUpdate in Sandbox
                SandboxRefreshHelperUtil_Async.ADESA_QA_User(strSandboxName);            
                
                                               
            } // IsValid Sandbox End 
            
        }
        Catch(Exception UserEx)
        {
            System.debug('>> UserEx:'+UserEx);
        }
        
        // ***** (5) ( Assign Permission Set )
        // CustomSetting :(Non-Prod) Permission Set Name
        // CustomSetting :(Non-Prod) User-Profile to get Per. Set
        SandboxRefreshHelperUtil_Async.AssignPermissionSet(strSandboxName);
        
        
        // ***** (6) ( Change Profile ) 
        SandboxRefreshHelperUtil_Async.UpdateProfile(strSandboxName);
        
        // ***** (7) ( Hub URL Clean-up Batch Job )
        // ***** AA: W-000042 Hawkins, Justin
        SandboxRefreshHelperUtil_Sync.CleanHubUrls();
        
    }
}