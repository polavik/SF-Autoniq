@isTest
public class TestDeleteUtil {

    public static testMethod void testDeleteUtil() {
        Account acct1 = new Account(Name='TestName1',Master_Index__c='100');
        Insert acct1;
       
        Account acct2 = new Account(Name='TestName1',Master_Index__c='200');
        Insert acct2;
        List<String> strList = new List<String>{'TestName1','TestName2'};
        List<String> strListId = new List<String>{acct1.Id,acct2.Id};
        String Condition = 'Name=\'TestName1\'';
        DeleteUtil.deleteByExternalId('Account','Name',strList);
        DeleteUtil.deleteByConditions('Account',Condition,strListId);
        
    }       
}