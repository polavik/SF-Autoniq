@isTest
private class TestIdentificationDocument {

    static testMethod void myUnitTest() {   
               
        Contact con = new Contact(LastName='Mr. Anderson', Person_ID__c='112232123');
        insert con;       
        
        Identification_Document__c iDoc = new Identification_Document__c (Name='RelatedContactTest', Contact_Person_Id__c ='112232123');
        insert iDoc;
    
    }
}