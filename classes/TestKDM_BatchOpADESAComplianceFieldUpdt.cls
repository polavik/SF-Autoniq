@isTest
private class TestKDM_BatchOpADESAComplianceFieldUpdt{

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOpADESAComplianceFieldUpdate objKDM_BatchOpADESAComplianceFieldUpdate = new KDM_BatchOpADESAComplianceFieldUpdate('',true,'djpatel@openlane.com');
       Database.executeBatch(objKDM_BatchOpADESAComplianceFieldUpdate);
       Test.stopTest();
       
    }
    static testmethod void test2() {
    
       
        
       Account acct1 = new Account(Name='Test Account1',Master_Index__c='270');
       Insert acct1;
        
       Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='270',Account__c=acct1.Id);
       Insert Adesa1;
        
       ADESA_Compliance__c obj = new ADESA_Compliance__c(
                                Op_Account_ATC_ORG_ID__c = '270',
                                Is_Migrated_Record__c = true
                                );
       insert obj; 
        
        
       Test.startTest();
       KDM_BatchOpADESAComplianceFieldUpdate objKDM_BatchOpADESAComplianceFieldUpdate = new KDM_BatchOpADESAComplianceFieldUpdate('',true,'djpatel@openlane.com');
       Database.executeBatch(objKDM_BatchOpADESAComplianceFieldUpdate);
       Test.stopTest();
       
    }   
}