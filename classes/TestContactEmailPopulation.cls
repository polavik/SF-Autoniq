@isTest
public class TestContactEmailPopulation {

        static testmethod void test1() {
             
           Test.startTest();
           
           Account a = TestUtility.createAccount(1, false);
           insert a;
           Contact c = TestUtility.createContact(1, false);
           insert c;
           ContactEmailPopulation objContactEmailPopulation = new ContactEmailPopulation();
           Database.executeBatch(objContactEmailPopulation);
           Test.stopTest();            
        }
    
}