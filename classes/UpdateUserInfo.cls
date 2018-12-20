global class UpdateUserInfo {

@future
public static void InfoAdd(Set<Id> userIds) {

    List<User> user = [select Id, firstname, lastname, email, contactid from user where Id IN :userIds];
    List<Portal_User_Info__c> userinfo = new List<Portal_User_Info__c>();
	//Story B-44003 : FLS CREATE ACCESS CHECK
	Set<String> ListFLSCreate = new Set<String>();
	Boolean blnFLSOverride = Utils.GetFLS();
    for (User newuser : user)
    {
        Portal_User_Info__c tuser = new Portal_User_Info__c();
 
		if (Schema.sObjectType.Portal_User_Info__c.fields.First_Name__c.isCreateable() || blnFLSOverride)
		{
			tuser.First_Name__c = newuser.FirstName;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Portal_User_Info__c.getName()+'.'+Schema.sObjectType.Portal_User_Info__c.fields.First_Name__c.getName());
		}
		if (Schema.sObjectType.Portal_User_Info__c.fields.Last_Name__c.isCreateable() || blnFLSOverride)
		{
			tuser.Last_Name__c = newuser.LastName;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Portal_User_Info__c.getName()+'.'+Schema.sObjectType.Portal_User_Info__c.fields.Last_Name__c.getName());
		}
		if (Schema.sObjectType.Portal_User_Info__c.fields.Contact__c.isCreateable() || blnFLSOverride)
		{
			tuser.Contact__c = newuser.ContactId;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Portal_User_Info__c.getName()+'.'+Schema.sObjectType.Portal_User_Info__c.fields.Contact__c.getName());
		}
		if (Schema.sObjectType.Portal_User_Info__c.fields.Email__c.isCreateable() || blnFLSOverride)
		{
			tuser.Email__c = newuser.Email;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Portal_User_Info__c.getName()+'.'+Schema.sObjectType.Portal_User_Info__c.fields.Email__c.getName());
		}
		if (Schema.sObjectType.Portal_User_Info__c.fields.User__c.isCreateable() || blnFLSOverride)
		{
			tuser.User__c = newuser.Id;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Portal_User_Info__c.getName()+'.'+Schema.sObjectType.Portal_User_Info__c.fields.User__c.getName());
		}           
        userinfo.add(tuser); 
     }
	if(ListFLSCreate.size()>0)
	{
		Utils.SendEmailforFLS('FLS_CREATE','CLASS:UpdateUserInfo', ListFLSCreate);
	}
	else
	{
		insert userinfo;
	}
         
}   
    
@future
public static void InfoUpdate(Set<Id> userIds) {

         
       List<User> user = [select Id, firstname, lastname, email, contactid from user where Id IN :userIds];
       List<Portal_User_Info__c> userinfo =  [  SELECT Id, First_Name__c, Last_Name__c, Contact__c, Email__c, User__c 
                                                FROM Portal_User_Info__c
                                                WHERE User__c != null AND User__c IN : userIds  ];
       List<Portal_User_Info__c> updateduserinfo = new List<Portal_User_Info__c>();
	   Set<String> ListFLSUpdate = new Set<String>();
	   Boolean blnFLSOverride = Utils.GetFLS();
	   
       for (Portal_User_Info__c eu : userinfo)  // existing User
       {
           for (User cu : user)  //Changed User
           {
             if (eu.User__c == cu.Id )
             {   
				//Story B-44003 : FLS UPDATE ACCESS CHECK
				if (Schema.sObjectType.Portal_User_Info__c.fields.First_Name__c.isUpdateable() || blnFLSOverride)
				{
					eu.First_Name__c = cu.FirstName;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Portal_User_Info__c.getName()+'.'+Schema.sObjectType.Portal_User_Info__c.fields.First_Name__c.getName());
				}
				if (Schema.sObjectType.Portal_User_Info__c.fields.Last_Name__c.isUpdateable() || blnFLSOverride)
				{
					eu.Last_Name__c = cu.LastName;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Portal_User_Info__c.getName()+'.'+Schema.sObjectType.Portal_User_Info__c.fields.Last_Name__c.getName());
				}
				if (Schema.sObjectType.Portal_User_Info__c.fields.Contact__c.isUpdateable() || blnFLSOverride)
				{
					eu.Contact__c = cu.ContactId;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Portal_User_Info__c.getName()+'.'+Schema.sObjectType.Portal_User_Info__c.fields.Contact__c.getName());
				}
				if (Schema.sObjectType.Portal_User_Info__c.fields.Email__c.isUpdateable() || blnFLSOverride)
				{
					eu.Email__c = cu.Email;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Portal_User_Info__c.getName()+'.'+Schema.sObjectType.Portal_User_Info__c.fields.Email__c.getName());
				}
				
                updateduserinfo.add(eu); 

             }
            

           }
        }
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:UpdateUserInfo', ListFLSUpdate);
		}
        update updateduserinfo;
         
      
     }
}