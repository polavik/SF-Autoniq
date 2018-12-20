public class SandboxRefreshHelperUtil_Async {
    @future
    public static void ADESA_QA_User(String strSandboxName) {
        
        List<ADESA_User_to_Insert__c> List_ADESA_User_to_Insert = ADESA_User_to_Insert__c.getAll().values();        
        List<User> NewUserToInsert = new List<User>();
        Integer intCount = 1;
        for(ADESA_User_to_Insert__c objADESA_User_to_Insert :  List_ADESA_User_to_Insert){
            
            User NewUser = new User();
            NewUser.Username = objADESA_User_to_Insert.Username__c +'.'+ strSandboxName;
            NewUser.Email = objADESA_User_to_Insert.Email__c;
            NewUser.LastName = objADESA_User_to_Insert.Last_Name__c + strSandboxName;
            NewUser.ProfileId = objADESA_User_to_Insert.ProfileId__c;
            NewUser.UserRoleId = objADESA_User_to_Insert.RoleId__c;
            //NewUser.License_Type__c = objADESA_User_to_Insert.User_License__c;
            String strAlias = objADESA_User_to_Insert.Alias__c + strSandboxName;
            if(strAlias.length() > 8 )
            {
                strAlias = objADESA_User_to_Insert.Alias__c + String.valueof(intCount);
            }
            NewUser.Alias = strAlias; //objADESA_User_to_Insert.Alias__c + strSandboxName;
            NewUser.CommunityNickname = objADESA_User_to_Insert.Nickname__c + strSandboxName;
            
            NewUser.TimeZoneSidKey = 'America/Indiana/Indianapolis';
            NewUser.LocaleSidKey = 'en_US';
            NewUser.EmailEncodingKey = 'ISO-8859-1';
            NewUser.LanguageLocaleKey = 'en_US';
            
            
            NewUserToInsert.Add(NewUser);
            intCount ++;
        }   
        
        //if(!Test.isRunningTest())
        //{
            Insert NewUserToInsert;
            
            //for(User objUser : NewUserToInsert)
            //{
            //    system.resetPassword(objUser.Id,true);
            //}
        //}
                
    }
    
     
    @future
    public static void AFC_User(String strSandboxName, String strAFCBranchSFID ) {
        
        
        if(strAFCBranchSFID != '')
        { 
            
            List<AFC_Branch__c> ListAFCBranch = [SELECT ID, Gold_Credit_Analyst__c, BRANCH_MANAGER_1__C, Contract_Specialist__c   FROM AFC_Branch__c WHERE ID=:strAFCBranchSFID];  
            if(ListAFCBranch.size() == 1)
            {
                List<String> UserIds = new List<String>();
                if(ListAFCBranch[0].Gold_Credit_Analyst__c != null )
                {
                    UserIds.Add(ListAFCBranch[0].Gold_Credit_Analyst__c);
                }
                if(ListAFCBranch[0].BRANCH_MANAGER_1__C != null )
                {
                    UserIds.Add(ListAFCBranch[0].BRANCH_MANAGER_1__C);
                }
                if(ListAFCBranch[0].Contract_Specialist__c != null )
                {
                    UserIds.Add(ListAFCBranch[0].Contract_Specialist__c);
                }
                
                List<User> ListUserToUpdate = [ SELECT ID FROM USER WHERE ID IN :UserIds];
                if(ListUserToUpdate.size()>0)
                {
                    Map<String,AFC_User_to_Update__c> MapFieldToUserDetail = new Map<String,AFC_User_to_Update__c>();
                    
                    List<AFC_User_to_Update__c> List_AFC_User_to_Update = AFC_User_to_Update__c.getAll().values();                          
                    for(AFC_User_to_Update__c objAFC_User_to_Update :  List_AFC_User_to_Update){
                        MapFieldToUserDetail.put(objAFC_User_to_Update.AFC_Branch_User_field__c,objAFC_User_to_Update);
                    }                     
                    
                    for(User objUser : ListUserToUpdate)
                    {
                        if(objUser.Id == ListAFCBranch[0].Gold_Credit_Analyst__c)
                        {
                            AFC_User_to_Update__c objAFC_User_to_Update = MapFieldToUserDetail.get('Gold_Credit_Analyst__c');
                            if(objAFC_User_to_Update!=null)
                            {
                                objUser.FirstName =  objAFC_User_to_Update.First_Name__c;
                                objUser.LastName = objAFC_User_to_Update.Last_Name__c;
                                objUser.Username = objAFC_User_to_Update.Username__c +'.'+strSandboxName;
                                objUser.CommunityNickname = objAFC_User_to_Update.Nickname__c;
                                objUser.Alias = objAFC_User_to_Update.Alias__c;
                                objUser.Email = objAFC_User_to_Update.Email__c;
                                //system.resetPassword(objUser.Id,true);
                                //system.setPassword(Users[0].Id,'sandbox#@12345');
                                //system.setPassword(Users[0].Id,objAFC_User_to_Update.Default_Password__c);
                                if(Test.isRunningTest())
                                {
                                    objUser.Username = objAFC_User_to_Update.Username__c +'.qwsfds1'+strSandboxName;
                                    objUser.CommunityNickname = 'qwsfddfdss1';
                                }
                            }
                        }
                        
                        if(objUser.Id == ListAFCBranch[0].BRANCH_MANAGER_1__C)
                        {
                            AFC_User_to_Update__c objAFC_User_to_Update = MapFieldToUserDetail.get('BRANCH_MANAGER_1__C');
                            if(objAFC_User_to_Update!=null)
                            {
                                objUser.FirstName =  objAFC_User_to_Update.First_Name__c;
                                objUser.LastName = objAFC_User_to_Update.Last_Name__c;
                                objUser.Username = objAFC_User_to_Update.Username__c +'.'+strSandboxName;
                                objUser.CommunityNickname = objAFC_User_to_Update.Nickname__c;
                                objUser.Alias = objAFC_User_to_Update.Alias__c;
                                objUser.Email = objAFC_User_to_Update.Email__c; 
                                if(Test.isRunningTest())
                                {
                                    objUser.Username = objAFC_User_to_Update.Username__c +'.qwsfds2'+strSandboxName;
                                    objUser.CommunityNickname = 'qwsfddfdss2';
                                }                        
                            }
                        }
                        
                        if(objUser.Id == ListAFCBranch[0].Contract_Specialist__c)
                        {
                            AFC_User_to_Update__c objAFC_User_to_Update = MapFieldToUserDetail.get('Contract_Specialist__c');
                            if(objAFC_User_to_Update!=null)
                            {
                                objUser.FirstName =  objAFC_User_to_Update.First_Name__c;
                                objUser.LastName = objAFC_User_to_Update.Last_Name__c;
                                objUser.Username = objAFC_User_to_Update.Username__c +'.'+strSandboxName;
                                objUser.CommunityNickname = objAFC_User_to_Update.Nickname__c;
                                objUser.Alias = objAFC_User_to_Update.Alias__c;
                                objUser.Email = objAFC_User_to_Update.Email__c;   
                                if(Test.isRunningTest())
                                {
                                    objUser.Username = objAFC_User_to_Update.Username__c +'.qwsfds3'+strSandboxName;
                                    objUser.CommunityNickname = 'qwsfddfdss3';
                                }                     
                            }
                        }
                    }
                    
                    //if(!Test.isRunningTest())
                    //{
                        Update ListUserToUpdate;
                        
                        List<UserLogin> ListAFCUsersToUnFreeze = [Select Id FROM UserLogin where UserId in :ListUserToUpdate and IsFrozen=true];

                        System.debug('>>> ListAFCUsersToUnFreeze' + ListAFCUsersToUnFreeze.size());

                        for ( UserLogin objUserLogin:ListAFCUsersToUnFreeze )
                        {
                            objUserLogin.IsFrozen = false;
                        }

                        update ListAFCUsersToUnFreeze;
                    //}   
                    
                }
                
                //for(User objUser : ListUserToUpdate)
                //{
                //  system.resetPassword(objUser.Id,true);
                //}
                
            }
        }
                
    }
    @future
    public static void AssignPermissionSet(String strSandboxName) {
    
    //(1) Get User to Set Permission Set and change Profile 
        List<String> ListSetUserIds = new List<String>();
        List<String> ListSetUserNames = new List<String>();
        List<String> ListSetProfileNames = new List<String>();
        for(Users_to_get_Permission_Set__c objSetProfileUserIds  : Users_to_get_Permission_Set__c.getAll().values())
        {
            if(objSetProfileUserIds.Sandbox_Name__c!=null && objSetProfileUserIds.Sandbox_Name__c!='' && (!objSetProfileUserIds.Sandbox_Name__c.equalsIgnoreCase('EXCEPT-'+strSandboxName) || objSetProfileUserIds.Sandbox_Name__c.equalsIgnoreCase(strSandboxName))||!objSetProfileUserIds.Sandbox_Name__c.equalsIgnoreCase('ALL'))
            {
                if(objSetProfileUserIds.UserName_UserId_ProfileName__c.startsWithIgnoreCase('005'))
                {           
                    ListSetUserIds.Add(objSetProfileUserIds.UserName_UserId_ProfileName__c);
                }
                else if(objSetProfileUserIds.UserName_UserId_ProfileName__c.containsIgnoreCase('@'))
                {           
                    ListSetUserNames.Add(objSetProfileUserIds.UserName_UserId_ProfileName__c);
                }
                else
                {
                    ListSetProfileNames.Add(objSetProfileUserIds.UserName_UserId_ProfileName__c);
                }
            }
        }
        System.debug('>> ListSetUserIds:'+ListSetUserIds);
        System.debug('>> ListSetUserNames:'+ListSetUserNames);
        System.debug('>> ListSetProfileNames:'+ListSetProfileNames);
        
        List<User> ListSetUserROtoRW = [Select Id,ProfileId, Profile.Name  From User where IsActive = true and ( profile.name IN :ListSetProfileNames OR Id IN :ListSetUserIds OR username IN :ListSetUserNames)];
        System.debug('>> ListSetUserROtoRW Size :'+ListSetUserROtoRW.size());
        System.debug('>> ListSetUserROtoRW:'+ListSetUserROtoRW);
        
        //(2) Apply new permission set(s) to Users after checking exist or not 
        
        List<String> ListPermissionSetNames = new List<String>();
        for(All_Permission_Set_Name__c objPermissionSet  : All_Permission_Set_Name__c.getAll().values())
        {
            ListPermissionSetNames.Add(objPermissionSet.Permission_Set_Name__c);
        }
        System.debug('>> ListPermissionSetNames:'+ListPermissionSetNames);
        
        List<PermissionSet> ListPermissionSet = [Select Name,Id from PermissionSet where LABEL IN :ListPermissionSetNames];
        System.debug('>> ListPermissionSet:'+ListPermissionSet);
        
        List<String> PerSetIds = new List<String>();
        for(PermissionSet objPerSet  : ListPermissionSet)
        {
            PerSetIds.Add(objPerSet.Id);
        }
        List<PermissionSetAssignment> ListPermissionSetAssignmentDone = [Select Id,PermissionSetId,AssigneeId from PermissionSetAssignment where PermissionSetId=:PerSetIds];
        
        try{          
            List<PermissionSetAssignment> ListPermissionSetAssignment = new List<PermissionSetAssignment>();
            
            for ( PermissionSet objPerSet : ListPermissionSet )
            {     
                for ( User objUser : ListSetUserROtoRW )
                {
                    Boolean skip = false;
                    for(PermissionSetAssignment p :ListPermissionSetAssignmentDone)
                    {
                        if(p.AssigneeId == objUser.Id && objPerSet.Id == p.PermissionSetId)
                        {
                            skip=true;
                            break;
                        }
                    }
                    if(skip)
                    {
                        continue;
                    }
                    //Select Id, PermissionSetId, AssigneeId, SystemModstamp FROM PermissionSetAssignment 
                    PermissionSetAssignment objPermissionSetAssignment = new PermissionSetAssignment();
                    objPermissionSetAssignment.PermissionSetId = objPerSet.Id ; 
                    objPermissionSetAssignment.AssigneeId = objUser.Id ; 
                    ListPermissionSetAssignment.Add(objPermissionSetAssignment);
                }
            }
            Insert ListPermissionSetAssignment;         
        }
        catch(Exception e1)
        {
            System.debug(e1);  
        }
        
    }
    
    @future
    public static void UpdateProfile(String strSandboxName) {
    
    //(5) Get User to Change Profile
        
        List<String> ListRemUserIds = new List<String>();
        List<String> ListRemUserNames = new List<String>();
        List<String> ListRemProfileNames = new List<String>();
        for(Users_to_remove_Permission__c objRemProfileUserIds  : Users_to_remove_Permission__c.getAll().values())
        {
            
            if(objRemProfileUserIds.UserName_UserId_ProfileName__c.startsWithIgnoreCase('005'))
            {           
                ListRemUserIds.Add(objRemProfileUserIds.UserName_UserId_ProfileName__c);
            }
            else if(objRemProfileUserIds.UserName_UserId_ProfileName__c.containsIgnoreCase('@'))
            {           
                ListRemUserNames.Add(objRemProfileUserIds.UserName_UserId_ProfileName__c);
            }
            else
            {
                ListRemProfileNames.Add(objRemProfileUserIds.UserName_UserId_ProfileName__c);
            }           
            
        }
        System.debug('>> ListRemUserIds:'+ListRemUserIds);
        System.debug('>> ListRemUserNames:'+ListRemUserNames);
        System.debug('>> ListRemProfileNames:'+ListRemProfileNames);
        
        List<User> ListRemUserRWtoRO = [Select Id,ProfileId, Profile.Name  From User where IsActive = true and ( profile.name IN :ListRemProfileNames OR Id IN :ListRemUserIds OR username IN :ListRemUserNames)];
        System.debug('>> ListRemUserRWtoRO Size :'+ListRemUserRWtoRO.size());
        System.debug('>> ListRemUserRWtoRO:'+ListRemUserRWtoRO);
        
        
        //(6) Create Map User.ProfileName --> User.NewProfileName --> NewProfileNameId 
        //          MapRemOldProfileNameToNewProfileName
        //          MapRemNewProfileNameToId
        
        Map<String,String> MapRemOldProfileNameToNewProfileName = new Map<String,String>();     
        for(ReadWrite_to_ReadOnly_Profile_Mapping__c objRWtoROProfiles  : ReadWrite_to_ReadOnly_Profile_Mapping__c.getAll().values())
        {
            if(objRWtoROProfiles.Sandbox_Name__c!=null && objRWtoROProfiles.Sandbox_Name__c!='' && (objRWtoROProfiles.Sandbox_Name__c.equalsIgnoreCase('ALL')||objRWtoROProfiles.Sandbox_Name__c.equalsIgnoreCase(strSandboxName)  || !objRWtoROProfiles.Sandbox_Name__c.equalsIgnoreCase('EXCEPT-'+strSandboxName)))
            {
                MapRemOldProfileNameToNewProfileName.put(objRWtoROProfiles.RW_Profile_Name__c,objRWtoROProfiles.RO_Profile_Name__c);
            }
        }
        System.debug('>> MapRemOldProfileNameToNewProfileName:'+MapRemOldProfileNameToNewProfileName);
        
        List<String> ListProfileNameForSOQL2 = new List<String>();
        ListProfileNameForSOQL2 = MapRemOldProfileNameToNewProfileName.values();
        System.debug('>> ListProfileNameForSOQL:'+ListProfileNameForSOQL2);
        
        List<Profile> NewROProfileList =  [SELECT Name,Id FROM Profile WHERE name IN : ListProfileNameForSOQL2 ];
        Map<String,String> MapRemNewProfileNameToId = new Map<String,String>();
        for(Profile objProfile  : NewROProfileList)
        {
            MapRemNewProfileNameToId.put(objProfile.Name,objProfile.Id);
        }
        System.debug('>> MapRemNewProfileNameToId:'+MapRemNewProfileNameToId);
        
        
        //(7) Update Profile  
        
        for ( User objUser : ListRemUserRWtoRO )
        {       
            If(MapRemOldProfileNameToNewProfileName.get(objUser.Profile.Name)!=null)
            {
                String strNewProfileId = MapRemNewProfileNameToId.get(MapRemOldProfileNameToNewProfileName.get(objUser.Profile.Name));
                if(strNewProfileId!=null)
                {
                    objUser.ProfileId = strNewProfileId;
                }
            }else
            {
                //objUser.IsActive = false;
            }
        }
        
        //if(!Test.isRunningTest())
        //{
            Update ListRemUserRWtoRO;
        //}
    }
}