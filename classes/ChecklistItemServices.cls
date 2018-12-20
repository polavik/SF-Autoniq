public with sharing class ChecklistItemServices
{
	//Called from AttachmentTrigger after insert
	public static void updateCLIItemStatusWhenAttachmentUploaded(Attachment[] attachments)
	{
    	String  cliPrefix				= 	SObjectType.Checklist_Item__c.getkeyprefix();
        Map<Id,Id> cliIdtoAttIdMap 		= 	new Map<Id,Id>();
        List<Checklist_Item__c> clisToBeUpdated = new List<Checklist_Item__c>();
        for(Attachment a : attachments)
        {
        	if(String.valueof(a.ParentId).startsWithIgnoreCase(cliPrefix))
            {
            	cliIdtoAttIdMap.put(a.ParentId, a.Id);
            }
        }
        for(Checklist_Item__c cli : [select Id,Item_Status__c from Checklist_Item__c where Id IN :cliIdtoAttIdMap.keyset() and Item_Status__c != 'Submitted'])
        {
        	clisToBeUpdated.add(new Checklist_Item__c(Id = cli.Id, Item_Status__c = 'Submitted', Document_Attached__c = true));
        }
    	if(!clisToBeUpdated.isEmpty())
        {
        	update clisToBeUpdated;
        }
	}
    /*
	//Called from ChecklistItemTrigger
	public static string triggerErrorMessages;
	public static void updateCLIAssignedDepartmentUser(list<Checklist_Item__c> checkListItems,  map<Id,Checklist_Item__c> oldMap )
	{
		//2. Department User, time stammped, update user value
		//3. accepted, excluded item is closed, get date/time (Ryan)

		map<string, Checklist__c> clMap = new map<string, Checklist__c>();
		for(Checklist_Item__c c : checkListItems)
		{
			clMap.put(c.CheckList__c, new Checklist__c());
		}

		for(Checklist__c cl : [SELECT id, Name, Application__c, Application__r.OwnerId, Application__r.AFC_Branch__c, Application__r.AFC_Region__c FROM Checklist__c WHERE Id IN: clMap.keyset()])
		{
			clMap.put(cl.Id, cl);
		}

		for(Checklist_Item__c cli : checkListItems)
		{
			//if(cli.Item_Status__c = 'Submitted' && cli.Item_Status__c != oldMap.get(cli.Id).Item_Status__c)
			//{

			//}
			User localUser = userQuery(clMap.get(cli.CheckList__c).Application__r.AFC_Region__c, clMap.get(cli.CheckList__c).Application__r.AFC_Branch__c, cli.For_Department__c);

			if(LocalUser != null)
			{
				if((cli.For_Department__c == 'Credit' || cli.For_Department__c == 'CT Processing') && (localUser.Credit_or_Contract__c == 'Credit' || localUser.Credit_or_Contract__c == 'CT Processing'))
				{
					cli.Assigned_Department_User__c = localUser.Id;
					cli.Date_Assigned_Department__c = Date.Today();
				}
			}


		}
	}

	public static User userQuery(string region, string branch, string department)
    {
    	triggerErrorMessages = '';

    	try
		{
	 	    User userToReturn = new User();

		    string queryString = '';
		    queryString = 'SELECT id, name, AFC_Region_Responsible__c, AFC_Branch_Responsible__c, Credit_or_Contract__c';
		    queryString += ' FROM User';
		    queryString += ' WHERE AFC_Region_Responsible__c INCLUDES (:region)';
		    if(branch != null)
		    {
		    	queryString += ' AND AFC_Branch_Responsible__c INCLUDES (:branch)';
		    }
		    if(department != null)
		    {
	    		queryString += ' AND Credit_or_Contract__c = :department';
		    }

			//userToReturn = Database.query(queryString);
			for(User u : Database.query(queryString))
			{
				userToReturn = u;
			}

			if(userToReturn.Id != null)
			{
				return userToReturn;
			}
			else
			{
				triggerErrorMessages += 'No users match this combination of parameters: ';
				triggerErrorMessages += '{Region: ' + region;
				triggerErrorMessages += ', Branch: ' + branch;
				triggerErrorMessages += ', Department: ' + department + '}';
				return null;
			}
		}
		catch (Exception e)
		{
			//triggerErrorMessages += '\ngetMessage: ' + e.getMessage();
			//triggerErrorMessages += '\ngetLine: ' + e.getLineNumber();
			//triggerErrorMessages += '\ngetCause: ' + e.getCause();
			//triggerErrorMessages += '\ngetStackTraceString: ' + e.getStackTraceString();
			//triggerErrorMessages += '\ngetTypeName: ' + e.getTypeName();

			system.debug('getMessage: ' + e.getMessage());
			system.debug('getLine: ' + e.getLineNumber());
			system.debug('getCause: ' + e.getCause());
			system.debug('getStackTraceString: ' + e.getStackTraceString());
			system.debug('getTypeName: ' + e.getTypeName());

			return null;
		}
    }
    */
	public static Database.SaveResult insertAttachment(Blob fileData, String fileName, Id parentId){
		Database.SaveResult result;
		Attachment attachment = new Attachment();

		//Story B-44003 : FLS CREATE ACCESS CHECK
		Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
		if (Schema.sObjectType.Attachment.fields.Body.isCreateable() || blnFLSOverride)
		{		
			attachment.Body = fileData;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Attachment.getName()+'.'+Schema.sObjectType.Attachment.fields.Body.getName());
		}
		if (Schema.sObjectType.Attachment.fields.Name.isCreateable() || blnFLSOverride)
		{		
			attachment.Name = fileName;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Attachment.getName()+'.'+Schema.sObjectType.Attachment.fields.Name.getName());
		}
		if (Schema.sObjectType.Attachment.fields.ParentId.isCreateable() || blnFLSOverride)
		{		
			attachment.ParentId = parentId;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Attachment.getName()+'.'+Schema.sObjectType.Attachment.fields.ParentId.getName());
		}

		if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:ChecklistItemServices', ListFLSCreate);
		}
		
		
		result = Database.insert(attachment);
		//Clear Blog Data to avoid View State Size Limit
		fileData = Blob.valueOf(' ');
		return result;
	}
}