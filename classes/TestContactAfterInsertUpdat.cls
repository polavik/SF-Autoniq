@isTest
private class TestContactAfterInsertUpdat {
    static testMethod void myTest() {
        DateTime dT = System.now();
        Contact c = new Contact(FirstName='Test', LastName='Test', Last_Login_from_PL__c = 'TEST', Last_Login_Time_to_PL__c = dT);
        insert c;
    }
}