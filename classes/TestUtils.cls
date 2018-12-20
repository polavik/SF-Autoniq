public class TestUtils {

	static Integer offset = 0;

    public static testMethod void test_getMiServiceEndpointUrl(){
        Property__c objProperty2 = new Property__c(Property_Id__c='mi.service.url1',Property_Value__c='1234',Property_Value_Encrypted__c='1234');
        insert objProperty2 ;
        String strEndpointUrl= Utils.getMiServiceEndpointUrl('mi.service.url1');   
        System.assertEquals(strEndpointUrl, '1234');
    }
    public static testMethod void test_getOrganizationType(){
        Property__c objProperty1 = new Property__c(Property_Id__c='org.type1',Property_Value__c='abc',Property_Value_Encrypted__c='abc');
        insert objProperty1 ;       
        String strOrgType= Utils.getOrganizationType('org.type1'); 
        System.assertEquals(strOrgType, 'abc');
    }
    
    public static testMethod void test_IsCreditAccountProfile(){
        Property__c objProperty1 = new Property__c(Property_Id__c='credit.account.creator.profiles1',Property_Value__c='abc,xyz',Property_Value_Encrypted__c='abc,xyz');
        insert objProperty1 ;       
        Boolean blnIsCreditProfile = Utils.IsCreditAccountProfile('credit.account.creator.profiles1'); 
        System.assertEquals(blnIsCreditProfile, false);
    }
    
    public static testMethod void test_IsIntegratorProfile(){
        Property__c objProperty1 = new Property__c(Property_Id__c='all.account.creator.profiles1',Property_Value__c='abc,xyz1',Property_Value_Encrypted__c='abc,xyz1');
        insert objProperty1 ;       
        Boolean blnIsAllAccountCreatorProfile = Utils.IsIntegratorProfile('all.account.creator.profiles1'); 
        System.assertEquals(blnIsAllAccountCreatorProfile, false);
    }
    
    static testMethod void testDateTime(){
        Date startDate = Date.newInstance(2008,8,9);
        System.assertEquals(Utils.getDateTime(startDate), DateTime.newInstance(startDate , Time.newInstance(0,0,0,0)));
    }
    
    static testMethod void testDateTimeNull(){
        Date startDate = null;
        System.assertEquals(Utils.getDateTime(startDate), null);
    }    
    
    static testMethod void testReverse(){
        System.assertEquals(Utils.reverse('12345'), '54321');
    }

    //static testMethod void testFormat0(){
    //    System.assertEquals(Utils.format(DateTime.newInstance(1960, 2, 18),'dd/MM/yyyy', 'PST'),'18/02/1960');
    //}
    
    static testMethod void testFormat0Null(){
        DateTime D = null;
        System.assertEquals(Utils.format(D,'dd/MM/yyyy', 'PST'), '');
    }
    
    static testMethod void testFormat1(){
        Double D = 19;
        System.assertEquals(Utils.format(D,3), '19.000');
    }
    
    static testMethod void testFormat1Null(){
        Double D = null;
        System.assertEquals(Utils.format(D,3), null);
    }    
    
    static testMethod void testFormat2(){
        Decimal D = 19;
        System.assertEquals(Utils.format(D,3), '19.000');
    }
    
    static testMethod void testFormat2null(){
        Decimal D = null;
        System.assertEquals(Utils.format(D,3), null);
    }    
    
    static testMethod void testPicklistMapping(){
        System.assertEquals(Utils.getPicklistMapping('fake', 'fake', 'fake'),null);
    }

    static testMethod void testRecordTypeId(){
        System.assertEquals(Utils.getRecordTypeId('fake', 'fake'),null);
    }
    
    static testMethod void testProperty(){
        System.assertEquals(Utils.getProperty('fake'),null);
    }    

    static testMethod void testJoinList(){
        List<Object> listA = new List<Object>();
        listA.add('A');
        listA.add('B');        
        System.assertEquals(Utils.joinList(listA,'*'),'A*B');
    }
    
    static testMethod void testSublist(){
        List<Account> listA = new List<Account>();
        Account b = new Account(Name='Salesforce');
        listA.add(b);
        System.assertEquals(Utils.getSublist(listA,0,1),listA);
    }

    static testMethod void testSatToSat() {
        Date startDate = Date.newInstance(2008,8,9);
        date endDate = Date.newInstance(2008,8,9);
        System.assertEquals(Utils.countWeekDays(startDate, endDate), 0.0);
    }
    
    static testMethod void testSatToSun() {
        Date startDate = Date.newInstance(2008,8,9);
        date endDate = Date.newInstance(2008,8,10);
        System.assertEquals(Utils.countWeekDays(startDate, endDate), 0.0);
    }
    
    static testMethod void testSatToMon() {
        Date startDate = Date.newInstance(2008,8,9);
        date endDate = Date.newInstance(2008,8,11);
        System.assertEquals(Utils.countWeekDays(startDate, endDate), 0.0);
    }
    
    static testMethod void testSunToMon() {
        Date startDate = Date.newInstance(2008,8,10);
        date endDate = Date.newInstance(2008,8,11);
        System.assertEquals(Utils.countWeekDays(startDate, endDate), 0.0);
    }
    
    static testMethod void testMonToFriday() {
        Date startDate = Date.newInstance(2008,8,11);
        date endDate = Date.newInstance(2008,8,15);
        System.assertEquals(Utils.countWeekDays(startDate, endDate), 4.0);
    }
    
    static testMethod void testMonToMon() {
        Date startDate = Date.newInstance(2008,8,11);
        date endDate = Date.newInstance(2008,8,11);
        System.assertEquals(Utils.countWeekDays(startDate, endDate), 0.0);
    }
    
    static testMethod void testFriToMon() {
        Date startDate = Date.newInstance(2008,8,8);
        date endDate = Date.newInstance(2008,8,11);
        System.assertEquals(Utils.countWeekDays(startDate, endDate), 1.0);
    }
    
    static testMethod void threeWeeks() {
        Date startDate = Date.newInstance(2008,8,4);
        date endDate = Date.newInstance(2008,8,25);
        System.assertEquals(Utils.countWeekDays(startDate, endDate), 15.0);
    }
    
    static testMethod void testSatToNull() {
        Date startDate = Date.newInstance(2008,8,9);
        System.assertEquals(Utils.countWeekDays(startDate, null), null);
    }
    
    static testMethod void testNullToSat() {
        date endDate = Date.newInstance(2008,8,11);
        System.assertEquals(Utils.countWeekDays(null, endDate), null);
    }
    
    static testMethod void backwardsInTime() {
        Date startDate = Date.newInstance(2008,8,12);
        date endDate = Date.newInstance(2008,8,6);
        System.assertEquals(Utils.countWeekDays(startDate, endDate), -4.0);
    }

    static testMethod void GetFLSTest() {
        System.assertEquals( Utils.GetFLS(), true);
        Set<String> ListFLSUpdate  = new Set<String>();
        ListFLSUpdate.add('Vehicles_Opportunities__c.opportunity__c');        
        ListFLSUpdate.add('Vehicles_Opportunities__c.Buyer_Org_Id__c');        
        ListFLSUpdate.add('Vehicles_Opportunities__c.Purchase__c');        
        Utils.SendEmailforFLS('FLS_UPDATE', 'CLASS:BatchCreateLinkOppsToVehicleOpps',ListFLSUpdate);
        Utils.SendEmailforFLS('FLS_CREATE', 'CLASS:BatchCreateLinkOppsToVehicleOpps',ListFLSUpdate);
    }

    static testMethod void getDummyCaseIdTest() {
 		Property__c prop = TestUtility.createProperty('dummy.case.id','somecaseowner');
        System.assertEquals( Utils.getDummyCaseId('dummy.case.id'),'somecaseowner');
        
    }    
    
    static testMethod void sendSingleMailTest() {
 		Utils.sendSingleMail('Testing');
    }    
    
    public static List<Application__c> createApplications( Integer size, Boolean doInsert )
    {
    	List<Application__c> appsToCreate = new List<Application__c>();
    	for( Integer i = 0; i < size; i++ )
    		appsToCreate.add( new Application__c ( AFC_Region__c = 'Test', AFC_Branch_Old__c = 'Test'));
    	
    	if( doInsert )
    		insert appsToCreate;
    		
    	return appsToCreate;
    }

    public static List<Checklist__c> createChecklists( Integer size, Id applicationId, Boolean doInsert )
    {
    	List<Checklist__c> listsToCreate = new List<Checklist__c>();
    	for( Integer i = 0; i < size; i++ )
    		listsToCreate.add( new Checklist__c (Application__c=applicationId ));
    	
    	if( doInsert )
    		insert listsToCreate;
    		
    	return listsToCreate;
    }

    public static List<Checklist_Item__c> createChecklistItems( Integer size, Id checklistId, Boolean doInsert )
    {
    	List<Checklist_Item__c> itemsToCreate = new List<Checklist_Item__c>();
    	for( Integer i = 0; i < size; i++ )
    		itemsToCreate.add( new Checklist_Item__c (Checklist__c=checklistId ));
    	
    	if( doInsert )
    		insert itemsToCreate;
    		
    	return itemsToCreate;
    }
    
    public static List<User> createUsers(Integer howMany, String profileName, boolean doInsert){
        List<User> testUsers = new List<User>();
        
        Profile pf = [SELECT Id FROM Profile WHERE Name=:profileName LIMIT 1];
        
        for(Integer i=0;i<howMany;i++){
            testUsers.add(new User(Username=i+'test@test.com'+offset, Email=offset+'test@test.com', LastName='test'+offset, Alias='test'+offset, CommunityNickname='test'+offset, TimeZoneSidKey='GMT', LocaleSidKey='en_US',
                                    EmailEncodingKey='ISO-8859-1', ProfileId=pf.id, LanguageLocaleKey='en_US', isActive=true));
            offset++;
        }
        
        if(doInsert){
            insert testUsers;
        }
        
        return testUsers;
    }
    
    
}