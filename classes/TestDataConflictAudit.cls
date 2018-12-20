@isTest
public class TestDataConflictAudit {

    public static testMethod void testDataConflictAudit() {
        
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='100',Data_Conflict_Checked__c=false);
        Insert acct1;
       
        Account acct2 = new Account(Name='Test Account2',Master_Index__c='200',Data_Conflict_Checked__c=true);
        Insert acct2;
        
        Test.startTest();
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        
        String jobId = System.schedule('TestDataConflictAudit',CRON_EXP, new DataConflictAudit());
                        
        Test.stopTest();
        
    }       
}