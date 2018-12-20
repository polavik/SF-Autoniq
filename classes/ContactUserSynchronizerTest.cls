@isTest(SeeAllData=false)
private class ContactUserSynchronizerTest {
	
	@isTest static void test_Data() {
		// Implement test code

		List<Contact> cntLst = new List<Contact>();
		List<User> userLst = new List<User>();
		Account acc =  TestUtility.createAccount(1, true );
		

		for(Integer i=1; i<4 ; i++)
		{
        	Contact cnt = TestUtility.createContact(i,false);
        	cnt.Email =  cnt.LastName + i + '@testcontacts.com.test'+i;
        	cnt.Person_Id__c = '4654' + i;
        	cnt.Login_Name__c = '4654' + i ;
            cnt.accountId = acc.Id;
        	cntLst.add(cnt);
        }
		for(Integer i=4; i<8 ; i++)
		{
        	Contact cnt = TestUtility.createContact(i,false);
        	cnt.Email =  cnt.LastName + i + '@testcontacts.com.test'+i;
        	cnt.Person_Id__c = '232' + i;
        	cnt.Login_Name__c = '9090907' + i ;
            cnt.accountId = acc.Id;
        	cntLst.add(cnt);
        }
        
		insert cntLst;

		cntLst.clear();
		cntLst = [Select Id, Email, Person_Id__c, Login_Name__c From Contact  ];
		system.debug('------' + cntLst);

		for(Contact cnt : cntLst )
		{
        	User usr = TestUtility.createUser(cnt.Person_Id__c, 'Limited US Portal User', false);
        	usr.FirstName = 'FN-test' + cnt.Person_Id__c;
        	usr.CommunityNickname = 'nick'+ cnt.Person_Id__c;
        	usr.ContactId = cnt.Id;
            usr.IsActive = true;
            usr.Alias = 'al'+ cnt.Person_Id__c;
        	userLst.add(usr);
		}
		insert userLst;
		userLst.clear();
		userLst = [SELECT Username, Email, FirstName, LastName, CommunityNickname, Alias, Contact.Person_Id__c, Contact.Login_Name__c, Contact.FirstName, Contact.LastName, Contact.Email FROM User Where User.FirstName LIKE '%FN-test%'];
		system.debug('------ userLst' + userLst);
        system.debug('------ userLst.size()' + userLst.size());


	}
	
	@isTest static void test_ContactUserSynchronizer() {
		test_Data();
        
        List<User> userLst =[SELECT Username, Email, FirstName, LastName, CommunityNickname, Alias, Contact.Person_Id__c, Contact.Login_Name__c, Contact.FirstName, Contact.LastName, Contact.Email FROM User WHERE ContactId != NULL AND Contact.Login_Name__c != NULL AND Contact.Email != NULL AND Contact.LastName != NULL AND User.IsActive = TRUE AND (NOT Contact.Person_Id__c LIKE '-%')];
        system.debug('------22' + userLst);
       Test.startTest(); 
	        ContactUserSynchronizer obj = new ContactUserSynchronizer();
	        DataBase.executeBatch(obj); 
	        // below is to cover lines of code in execute method;
	        SchedulableContext sc = null; 
	        obj.execute(sc);         
        Test.stopTest();		

	}
	
}