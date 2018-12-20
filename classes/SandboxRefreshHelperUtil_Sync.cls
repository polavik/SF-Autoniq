public class SandboxRefreshHelperUtil_Sync {
    
    
    public static String AFC_User(String strSandboxName) {
        
          
        String strAFCBranchSFID ='';
        List<AFC_Branch_Record_ID__c> List_AFC_Branch_Record = AFC_Branch_Record_ID__c.getAll().values();
        if(List_AFC_Branch_Record.size() == 1)
        {
            strAFCBranchSFID = List_AFC_Branch_Record[0].Name ;
        }
        
        if(Test.isRunningTest())// && strAFCBranchSFID=='')
        {
            Profile p = [select id from profile where name='Standard User'];
            
            List<User> InsertTestUsers = new List<User>();
            User testUser1 = new User(alias = 'dtu1', email='dtestUser1@example.com',emailencodingkey='UTF-8', lastname='UserLastName', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,  country='United States', CommunityNickname = 'dtu1',timezonesidkey='America/Los_Angeles', username='dtestUser1.kar@example.com'+strSandboxName);
            InsertTestUsers.Add(testUser1);
            
            User testUser2 = new User(alias = 'dtu2', email='dtestUser2@example.com',emailencodingkey='UTF-8', lastname='UserLastName', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,  country='United States', CommunityNickname = 'dtu2',timezonesidkey='America/Los_Angeles', username='dtestUser2.kar@example.com'+strSandboxName);
            InsertTestUsers.Add(testUser2);
            
            User testUser3 = new User(alias = 'dtu3', email='dtestUser3@example.com',emailencodingkey='UTF-8', lastname='UserLastName', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,  country='United States', CommunityNickname = 'dtu3',timezonesidkey='America/Los_Angeles', username='dtestUser3.kar@example.com'+strSandboxName);
            InsertTestUsers.Add(testUser3);
            
            Insert InsertTestUsers;
            
            AFC_Branch__c Testbranch = new AFC_Branch__c(Name='Test_DENVER',Branch_Manager_1__c=testUser1.id,Gold_Credit_Analyst__c=testUser2.Id,Contract_Specialist__c=testUser3.Id);
            insert Testbranch;                  
            
            strAFCBranchSFID = Testbranch.Id;
        }
        
        return strAFCBranchSFID ;
                
    }
    
    public static void DeactiveUser() {
        String Query= 'Select Id,UserId FROM UserLogin ' + 
                                ' where UserId in :List_Make_DeActive_User_in_Sandbox ' +  
                                ' and IsFrozen=false ';
        if(Test.isRunningTest())
        {
            Query = Query + ' limit 200 ';
        }
		Id batchJobId = Database.executeBatch(new BatchSandboxFreshHelperFreeze(Query));		
        System.debug('>> DeactiveUser Done. batchJobId:'+ batchJobId);
	}   
    
     public static void UpdateEmail(String strSandboxName) {
        List<String> ListEmailUserIds = new List<String>();
        List<String> ListEmailUserNames = new List<String>();
        List<String> ListEmailProfileNames = new List<String>();
        for(Users_to_change_Email__c objEmailProfileUserIds  : Users_to_change_Email__c.getAll().values())
        {
            if(objEmailProfileUserIds.Sandbox_Name__c!=null && objEmailProfileUserIds.Sandbox_Name__c!='' && objEmailProfileUserIds.Sandbox_Name__c.containsIgnoreCase('"'+strSandboxName+'"') )
            {
                if(objEmailProfileUserIds.UserName_UserId_ProfileName__c.startsWithIgnoreCase('005'))
                {           
                    ListEmailUserIds.Add(objEmailProfileUserIds.UserName_UserId_ProfileName__c);
                }
                else if(objEmailProfileUserIds.UserName_UserId_ProfileName__c.containsIgnoreCase('@'))
                {           
                    ListEmailUserNames.Add(objEmailProfileUserIds.UserName_UserId_ProfileName__c);
                }
                else
                {
                    ListEmailProfileNames.Add(objEmailProfileUserIds.UserName_UserId_ProfileName__c);
                }
            }            
        }
        System.debug('>> ListEmailUserIds:'+ListEmailUserIds);
        System.debug('>> ListEmailUserNames:'+ListEmailUserNames);
        System.debug('>> ListEmailProfileNames:'+ListEmailProfileNames);
        
        
        List<User> UsersForUpdateEmail = [Select Id,ProfileId, Profile.Name, Email  From User where IsActive = true and ( profile.name IN :ListEmailProfileNames OR Id IN :ListEmailUserIds OR username IN :ListEmailUserNames)];
        System.debug('>> UsersForUpdateEmail Size :'+UsersForUpdateEmail.size());
        System.debug('>> UsersForUpdateEmail:'+UsersForUpdateEmail);        
        
        for ( User objUser : UsersForUpdateEmail )
        {
            objUser.Email = objUser.Email.replace('@example.com','').replace('=','@');
        }
        Update UsersForUpdateEmail;
     }
    
    // AA: W-000042 Hawkins, Justin
    public static void CleanHubUrls()
    {
        String query;
        String fieldToUpdate;
        
        Hub_Sandbox_Refresh_Settings__c cs = Hub_Sandbox_Refresh_Settings__c.getValues('IntranetContentVersion');
        if(cs != null)
        {
            query = cs.Batch_Query__c;
            fieldToUpdate = cs.Field_To_Update__c;
        }
        else
        {
            // Default these values if the custom setting has not be configured
            query = 'SELECT Id, URL__c FROM Intranet_Content_Version__c WHERE URL__c != \'\'';
            fieldToUpdate = 'URL__c';
        }

        if(Test.isRunningTest())
        {
            query += ' Limit 200 ';
        }

        Id batchJobId = Database.executeBatch(new BatchSandboxRefreshHelperHubUrlCleanup(query, fieldToUpdate));
        System.debug('>> BatchSandboxRefreshHelplerHubUrlCleanup queued.  APEX Job ID: ' + batchJobId);
    }
    
}