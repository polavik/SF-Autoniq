@isTest
public class TestObjectLogPurgeBatch {
    static testMethod void testObjectLogPurgeBatch(){
                      
        List<Object_Log__c> objectLogs = new List<Object_Log__c>();
        for(Integer i=1 ;i < 5;i++)
        {
            Object_Log__c objectLog = new Object_Log__c();
            objectLog.Contents__c ='Test contents'+i;
            objectLog.CreatedDate = datetime.newInstance(2008, 1, i);
            objectLog.Object_Id__c = string.valueof(i);
            objectLogs.add(objectLog);           
        }
        
        insert objectLogs;

       Test.startTest();
       ObjectLogPurgeBatch c = new ObjectLogPurgeBatch();
       Database.executeBatch(c);
       Test.stopTest();        
        
    }
}