public class ContactSyncHelper { 
	public Contact UpdateContactList(String strEmail,String strLocationList)
	{
		List<String> strLocationSplit   = new List<String>();
		Map<String, Contact> ContactLocationMap =  new Map<String, Contact>();
		List<Contact> ContactListtoUpdate = new List<Contact>() ;
		
		Contact contactfound ;
		Set<String> ListFLSUpdate = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
		
		for( Contact cont : [select Id,Location__c,Email,Login_ID__c from Contact where Email =: strEmail and Sync_Contact__c=False ])
		{
			
			//	if (cont.Location__c != strLocationList)		
			//		{	
						
						//Story B-44003 : FLS UPDATE ACCESS CHECK
						 if (Schema.sObjectType.Contact.fields.Location__c.isUpdateable() || blnFLSOverride)
						 {						 
							cont.Location__c = strLocationList;
						 }
						 else
						 {						
							ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Location__c.getName());
						 }
						 
						
						ContactListtoUpdate.add(cont);
						System.debug('Location.....'+ cont.location__c);
						System.debug('Contact with false '+ cont.Id);
										
			//		}
		
		}
		for( Contact Orignalcont : [select Id,Location__c,Email,Login_ID__c from Contact where Email =: strEmail and Sync_Contact__c=True ])
		{
			
						
						if (Schema.sObjectType.Contact.fields.Sync_Contact__c.isUpdateable() || blnFLSOverride)
						 {						 
							Orignalcont.Sync_Contact__c = False;
						 }
						 else
						 {						
							ListFLSUpdate.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Sync_Contact__c.getName());
						 }
						ContactListtoUpdate.add(Orignalcont);
						System.debug('Location.....'+ Orignalcont.location__c);
						System.debug('Contact with True '+ Orignalcont.Id);
		
		}
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ContactSyncHelper', ListFLSUpdate);
		}
		if (ContactListtoUpdate.size() > 0)
		{
			System.debug('To update');
			update ContactListtoUpdate;
		}
		
		 
	 	return contactfound;
	}
		
		
		
}