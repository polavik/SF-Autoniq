global class PortalUtils {
    webservice static String getUsername(String login_name, Long loginID) {
        Set<String> ListFLSUpdate = new Set<String>();
		Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
        login_name = login_name.trim();
        
        // First check to see if there is already a licensed User for this login
        List<User> users = 
            [select Username, Contact.Person_Id__c, Contact.Login_Name__c
             from User
             where Contact.Login_Name__c = :login_name
             and Contact.Active__c = true
             and (not Contact.Person_Id__c like '-%')];
        
        System.debug('Existing users: ' + users.size());
        
        if (users.size() > 0) {
            String strUsername = '';
            for(User objUser :users)
            {
                //Story B-41177 (2016.7a)
                if(objUser.Contact.Login_Name__c.equals(login_name))
                {
                    System.debug('User Match: ' + objUser);
                    strUsername = objUser.Username;
                    break;
                }
            }               
            if(strUsername=='')
            {
                System.debug('User not Matched, Creating new one... ');
            }else{
                return strUsername;
            }               
        }
        // If there is a licensed user, return their customer portal Username
        //if (users.size() == 1) {
        //    return users.get(0).Username;
        //} 
        
        // If user does not currently exist, check Contacts for match
        List<Contact> contacts = 
            [select FirstName, LastName, Email, Login_Name__c, Person_Id__c,Country__c
             from Contact
             where Login_Name__c = :login_name
             and Contact.Active__c = true
             and (not Person_Id__c like '-%')];
             
        System.debug('Matching contacts: ' + contacts.size());
        
        
        if (contacts.size() == 0) { //No Contact matched, return empty string
            return '';
        } 
        else 
        { //Contact matched, create new Customer Portal User license
        
            Contact contact ;
            if (contacts.size() > 0) {
                for(Contact objContact :contacts)
                {
                    //Story B-41177 (2016.7a)
                    if(objContact.Login_Name__c.equals(login_name))
                    {
                        System.debug('Contact Match: ' + objContact);
                        contact = objContact;
                        break;
                    }
                }               
                if(contact==null)
                {
                    System.debug('Contact doen\'t Match');
                    return '';
                }           
            }
                    
            //Contact contact = contacts.get(0);
            
            User usr = new User();
            
            // Append suffix to username and email address to avoid accidentally sending email from sandbox
            String sandboxSuffix = Utils.getProperty('sandbox.suffix');
            if (sandboxSuffix == null) { // Production instance will have no suffix
                sandboxSuffix = '';
            }
                
            
			 //Story B-44003 : FLS UPDATE ACCESS CHECK
			 if (Schema.sObjectType.User.fields.Username.isUpdateable() && Schema.sObjectType.User.fields.Username.isCreateable() || blnFLSOverride)
			 {						 
				usr.Username = contact.Login_Name__c + '@openlanecp.com' + sandboxSuffix;
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.Username.getName());
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.Username.getName());
			 }
			if(ListFLSUpdate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_UPDATE','CLASS:PortalUtils', ListFLSUpdate);
			}
			
			if (Schema.sObjectType.User.fields.Email.isCreateable() || blnFLSOverride)
			{
				usr.Email = contact.Email + sandboxSuffix;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.Email.getName());
			}
			if (Schema.sObjectType.User.fields.FirstName.isCreateable() || blnFLSOverride)
			{
				usr.FirstName = contact.FirstName;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.FirstName.getName());
			}
			if (Schema.sObjectType.User.fields.LastName.isCreateable() || blnFLSOverride)
			{
				usr.LastName = contact.LastName;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.LastName.getName());
			}
			if (Schema.sObjectType.User.fields.CommunityNickname.isCreateable() || blnFLSOverride)
			{
				usr.CommunityNickname = contact.Login_Name__c;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.CommunityNickname.getName());
			}
			if (Schema.sObjectType.User.fields.FederationIdentifier.isCreateable() || blnFLSOverride)
			{
				usr.FederationIdentifier = String.valueOf(loginID);
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.FederationIdentifier.getName());
			}
			if (Schema.sObjectType.User.fields.ContactId.isCreateable() || blnFLSOverride)
			{
				 usr.ContactId = contact.Id;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.ContactId.getName());
			}
			if (Schema.sObjectType.User.fields.ProfileId.isCreateable() || blnFLSOverride)
			{
				usr.ProfileId = Utils.getProperty('portalutils.us.cp.profile.id');//Default to US
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.ProfileId.getName());
			}
			
			if (Schema.sObjectType.User.fields.TimeZoneSidKey.isCreateable() || blnFLSOverride)
			{
				usr.TimeZoneSidKey = 'America/Los_Angeles';
				
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.TimeZoneSidKey.getName());
			}
			if (Schema.sObjectType.User.fields.LocaleSidKey.isCreateable() || blnFLSOverride)
			{
				usr.LocaleSidKey = 'en_US';				
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.LocaleSidKey.getName());
			}
			if (Schema.sObjectType.User.fields.EmailEncodingKey.isCreateable() || blnFLSOverride)
			{
				usr.EmailEncodingKey = 'ISO-8859-1';				
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.EmailEncodingKey.getName());
			}
			if (Schema.sObjectType.User.fields.LanguageLocaleKey.isCreateable() || blnFLSOverride)
			{				
				usr.LanguageLocaleKey = 'en_US';
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.LanguageLocaleKey.getName());
			}
			
			if (Schema.sObjectType.User.fields.Alias.isCreateable() || blnFLSOverride)
			{
				if (contact.login_Name__c.length() < 8) {
					usr.Alias = contact.Login_Name__c.toLowerCase();
				} else {
					usr.Alias = contact.Login_Name__c.toLowerCase().substring(0, 7);
				}
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.Alias.getName());
			}
            
            if (Schema.sObjectType.User.fields.ProfileId.isCreateable() || blnFLSOverride)
			{
				if(contact.Country__c != null){
					if(contact.Country__c.toUpperCase() == 'CANADA')//Set to correct profile depending on Country
					{
						usr.ProfileId = Utils.getProperty('portalutils.ca.cp.profile.id');
					}
				}
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.ProfileId.getName());
			}
            

            
            
            //Check for dupliucate username and alias 
            Integer intI = 1;
            
            List<User> ListDuplicateUser = new List<User>();    
            
            do 
            {
                System.debug('>>> In check Duplicate intI:'+intI);
                ListDuplicateUser = [SELECT Id, Username FROM User WHERE username = :usr.username OR Alias =:usr.Alias];             
                if(ListDuplicateUser.size()>0)
                {
                    System.debug('>>> Duplicate found :'+ListDuplicateUser);
                    String strAppend = String.valueOf(intI);
                    usr.username = contact.Login_Name__c + strAppend + '@openlanecp.com' + sandboxSuffix;
                    if (contact.login_Name__c.length() < 8) {
                        usr.Alias = contact.Login_Name__c.toLowerCase() + strAppend;
                    } else {
                        usr.Alias = contact.Login_Name__c.toLowerCase().substring(0, 6) + strAppend;
                    }                   
                }
                intI +=1 ;
            } while (ListDuplicateUser.size()>0);
            
            try {
				
				if(ListFLSCreate.size()>0)
				{
					Utils.SendEmailforFLS('FLS_CREATE','CLASS:PortalUtils', ListFLSCreate);
					return '';
				}
                insert usr;
				
            } catch (Exception e) {
                System.debug(e);
                return '';
            }
            
            return usr.username;
        }
    }
    
    public static boolean enableSellerPortal(String loginName, Long loginID)
    {
        try
        {
            // Start with a regular Customer Portal user
            String username = getUsername(loginName, loginID);
            Set<String> ListFLSUpdate = new Set<String>();
			Boolean blnFLSOverride = Utils.GetFLS();
			
            // Convert to Limited Seller Portal User profile if necessary
            User u = [SELECT ProfileId FROM User WHERE Username = :username];
            if (!Utils.getProperty('portalutils.seller.profile.id').equals(u.ProfileId))
            {                
				//Story B-44003 : FLS UPDATE ACCESS CHECK
				 if (Schema.sObjectType.User.fields.ProfileId.isUpdateable() || blnFLSOverride)
				 {						 
					u.ProfileId = Utils.getProperty('portalutils.seller.profile.id');
				 }
				 else
				 {						
					ListFLSUpdate.add(Schema.sObjectType.User.getName()+'.'+Schema.sObjectType.User.fields.ProfileId.getName());
				 }
				 if(ListFLSUpdate.size()>0)
				 {
				 	Utils.SendEmailforFLS('FLS_UPDATE','CLASS:PortalUtils', ListFLSUpdate);
				 }
                update u;
                
            }
            return true;
        }
        catch (Exception e)
        {
            System.debug(e);
            return false;
        }
    }
    
    public static boolean grantSellerPermission(String loginName, Long organizationId)
    {
        try
        {
            loginName = loginName.trim();
            List<User> ListUsers =
                [SELECT Username, ProfileId, Contact.Login_Name__c
                 FROM User
                 WHERE Contact.Login_Name__c = :loginName
                 AND Contact.Active__c = true
                 AND ProfileId = :Utils.getProperty('portalutils.seller.profile.id')
                 AND (NOT Contact.Person_Id__c LIKE '-%')];
            
            if(ListUsers.size() > 0 )
            {
                User u ;
                for(User objUser :ListUsers)
                {
                    //Story B-41177 (2016.7a)
                    if(objUser.Contact.Login_Name__c.equals(loginName))
                    {
                        System.debug('User Match for grant seller permission: ' + objUser);
                        u = objUser;
                        break;
                    }
                }               
                if(u==null)
                {
                    System.debug('User not Matched.. Seller Permission not set');
                    return false;
                }
            
                // Check to make sure user does not already have access for this org
                List<Seller_Permission__c> existingPermissions = 
                    [SELECT Id FROM Seller_Permission__c 
                     WHERE User__c = :u.Id 
                     AND Adesa_com_Detail__r.ATC_Organization_Id__c = :String.valueOf(organizationId)];
                     
                if (existingPermissions.size() == 0)
                {
				    Set<String> ListFLSUpdate = new Set<String>();
				    Set<String> ListFLSCreate = new Set<String>();
					Boolean blnFLSOverride = Utils.GetFLS();
                    System.debug('No existing Permissions..  Creating Seller Permission...');
                    Seller_Permission__c sp = new Seller_Permission__c();

                    Adesa_com_Detail__c a = new Adesa_com_Detail__c(ATC_Organization_Id__c = String.valueOf(organizationId));
					
                    //Story B-44003 : FLS UPDATE ACCESS CHECK
					if(sp.Id != null)
					{
						 if (Schema.sObjectType.Seller_Permission__c.fields.User__c.isUpdateable() || blnFLSOverride)
						 {
							sp.User__c = u.Id;
						 }
						 else
						 {						
							ListFLSUpdate.add(Schema.sObjectType.Seller_Permission__c.getName()+'.'+Schema.sObjectType.Seller_Permission__c.fields.User__c.getName());
						 }
						 
						 if (Schema.sObjectType.Seller_Permission__c.fields.Adesa_com_Detail__c.isUpdateable() || blnFLSOverride)
						 {
							sp.Adesa_com_Detail__r = a;
						 }
						 else
						 {						
							ListFLSUpdate.add(Schema.sObjectType.Seller_Permission__c.getName()+'.'+Schema.sObjectType.Seller_Permission__c.fields.Adesa_com_Detail__c.getName());
						 }
					}
					else
					{
						 if (Schema.sObjectType.Seller_Permission__c.fields.User__c.isCreateable() || blnFLSOverride)
						 {
							sp.User__c = u.Id;
						 }
						 else
						 {						
							ListFLSCreate.add(Schema.sObjectType.Seller_Permission__c.getName()+'.'+Schema.sObjectType.Seller_Permission__c.fields.User__c.getName());
						 }
						 if (Schema.sObjectType.Seller_Permission__c.fields.Adesa_com_Detail__c.isCreateable() || blnFLSOverride)
						 {
							sp.Adesa_com_Detail__r = a;
						 }
						 else
						 {						
							ListFLSCreate.add(Schema.sObjectType.Seller_Permission__c.getName()+'.'+Schema.sObjectType.Seller_Permission__c.fields.Adesa_com_Detail__c.getName());
						}

					}
					 
					if(ListFLSUpdate.size()>0)
					{
						Utils.SendEmailforFLS('FLS_UPDATE','CLASS:PortalUtils', ListFLSUpdate);
						return false;
					}
					else if(ListFLSCreate.size()>0)
					{
						Utils.SendEmailforFLS('FLS_CREATE','CLASS:PortalUtils', ListFLSCreate);
						return false;
					}
					else
					{
						upsert sp;
						CaseEscalationSharing ces = new CaseEscalationSharing(String.valueOf(organizationId));
						Database.executeBatch(ces);
					}
                }               
                return true;
            }
            else
            {
                return false;
            }
            
        }
        catch (Exception e)
        {
            System.debug(e);
            return false;
        }
    }
    
    webservice static boolean getSellerPortalPermission(String loginName, Long organizationId) 
    {
        List<Seller_Permission__c> permissions = 
            [SELECT Id
             FROM Seller_Permission__c
             WHERE Adesa_com_Detail__r.ATC_Organization_Id__c = :String.valueOf(organizationId)
             AND User__r.Contact.Login_Name__c = :loginName
             AND (NOT User__r.Contact.Person_Id__c LIKE '-%')
             LIMIT 1];
        
        return (permissions.size() > 0);
    }
    
    webservice static String getSfOrganizationId() 
    {
        return UserInfo.getOrganizationId();
    }
}