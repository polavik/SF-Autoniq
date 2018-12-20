@isTest
public class Test_livehelp {
	static testmethod void testLiveHelpNow()
	{
		// S-444999 and T-570980
		Id casRecordTyepeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IAA Buyer Services').getRecordTypeId();

		Case cas = new Case();
		cas.RecordTypeId = casRecordTyepeId;	// S-444999 and T-570980
		cas.Description ='testing by Neil Bodak';
		cas.Case_owner__c = 'Ruben Flores';
		//cas.OwnerId = '005170000019wxE';
		cas.Status = 'New';
		cas.Type = 'Contact Us';
		cas.Origin = 'Web';
		insert cas;

		// S-444999 and T-570980
		cas = [Select OwnerID, Owner.Id, Case_owner__c
			   From Case
			   where Id = :cas.id];

		Map<String, Id> userOwner = new Map<String,Id>();
		//for(Case record : cas)
		//{
			userOwner.put(cas.Case_owner__c,null);
		//}

		for(User u : [select name, Id 
					  from User	
					  where name = 'Ruben Flores'])	//Ruben's Id
		{
			userOwner.put(u.name, u.Id);
		}
		if(userOwner.get(cas.Case_owner__c) != null)
		{
			cas.OwnerId = userOwner.get(cas.Case_owner__c);
		}
	}
}