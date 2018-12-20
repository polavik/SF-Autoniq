/**
* Created for Marketing Cloud Connector Trigger on the Contact object 
*/
@isTest
private class Trig_ContactTest {
  private static testmethod void Trig_ContactTest() {     
           insert new et4ae5__Configuration__c(et4ae5__Support_Ticket_Recipient__c = 'info@adesa.com');
           Test.startTest();
           Contact c = new Contact(LastName='TestExample');

           // Insert contact
           insert c;

           // If no exceptions occurred, it was successful 
           System.assert(!String.isBlank(c.Id));
           Test.stopTest();
  }
}