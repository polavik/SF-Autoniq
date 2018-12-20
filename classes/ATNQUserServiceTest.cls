@isTest
public class ATNQUserServiceTest {
    
    private static final String USER_ID_1 = 'testUserId1';
    private static final String USER_ID_2 = 'testUserId2';
    
    private static final String ATNQ_ACC_NAME_1 = 'atnqAccountName1';
    private static final String ATNQ_ACC_NAME_2 = 'atnqAccountName2';
    
    private static final String ACCOUNT_NAME = 'AccountName';
    
    @testsetup 
    private static void createTestData() {
        
        Account a = new Account();
        a.Name = ACCOUNT_NAME;
        insert a;
        
        Autoniq_Account__c atnqAct1 = new Autoniq_Account__c(Account__c = a.Id, Name = ATNQ_ACC_NAME_1);
        insert atnqAct1;
        
        Autoniq_Account__c atnqAct2 = new Autoniq_Account__c(Account__c = a.Id, Name = ATNQ_ACC_NAME_2);
        insert atnqAct2;
    
        Contact c = new Contact (Lastname = 'test', AccountId = atnqAct1.Id, Autoniq_User_ID__c = USER_ID_1);
        insert c;
    }
    
    
    @isTest
    private static void validateUserIdAvailabilitySuccessTest(){
        
    }
    
    @isTest
    private static void validateUserIdAvailabilityFailureTest(){
        
    }

}