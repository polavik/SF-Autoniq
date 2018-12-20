public with sharing class BatchSandboxFreshHelperFreeze implements Database.Batchable<UserLogin>
{

	public  String Query;
  	public BatchSandboxFreshHelperFreeze(String q){
	      Query=q;
    }
   	
    public Iterable<UserLogin> start(Database.BatchableContext BC)
    {
        List<String> ListDeactiveUserIds = new List<String>();
        List<String> ListDeactiveUserNames = new List<String>();
        List<String> ListDeactiveProfileNames = new List<String>();
        for(Profile_to_keep_active__c objActiveUserProfileUserIds  : Profile_to_keep_active__c.getAll().values())
        {
            if(objActiveUserProfileUserIds.UserName_UserId_ProfileName__c.startsWithIgnoreCase('005'))
            {           
                ListDeactiveUserIds.Add(objActiveUserProfileUserIds.UserName_UserId_ProfileName__c);
            }
            else if(objActiveUserProfileUserIds.UserName_UserId_ProfileName__c.containsIgnoreCase('@'))
            {           
                ListDeactiveUserNames.Add(objActiveUserProfileUserIds.UserName_UserId_ProfileName__c);
            }
            else
            {
                ListDeactiveProfileNames.Add(objActiveUserProfileUserIds.UserName_UserId_ProfileName__c);
            }
            
        }
        // Can not Freeze this standard sf profile user
        ListDeactiveProfileNames.Add('Premier Support User');

        System.debug('>> ListDeactiveUserIds:'+ListDeactiveUserIds.size());
        System.debug('>> ListDeactiveUserNames:'+ListDeactiveUserNames.size());
        System.debug('>> ListDeactiveProfileNames:'+ListDeactiveProfileNames.size());
        
        List<User> List_Make_DeActive_User_in_Sandbox  = [Select Id  From User where IsActive = true and  IsPortalEnabled = false AND  profile.name NOT IN :ListDeactiveProfileNames AND Id NOT IN :ListDeactiveUserIds AND username NOT IN :ListDeactiveUserNames ];

        System.debug('>> List_Make_DeActive_User_in_Sandbox Size :'+List_Make_DeActive_User_in_Sandbox.size());
				
        List<UserLogin> ListActiveUserLoginsToFreeze = Database.query(this.Query);
                                
        System.debug('>> ListActiveUserLoginsToFreeze Size :'+ListActiveUserLoginsToFreeze.size());
        return ListActiveUserLoginsToFreeze;
    }

    public void execute(Database.BatchableContext info, List<UserLogin> scope)
    {
 		System.debug('>>> scope.size=' + scope.size());    	
 		List<UserLogin> ListActiveUserLoginsToFreeze_Upd = new List<UserLogin>();
        for ( UserLogin objUserLogin : scope )
        {
            if(objUserLogin.UserId != Userinfo.getUserId()){  
                objUserLogin.IsFrozen = true;
                ListActiveUserLoginsToFreeze_Upd.add(objUserLogin);
            }
        }
		 update ListActiveUserLoginsToFreeze_Upd;            
        System.debug('>>> ListActiveUserLoginsToFreeze_Upd.size=' + ListActiveUserLoginsToFreeze_Upd.size());    	
    }

	public void finish(Database.BatchableContext info) {
            }
            
}