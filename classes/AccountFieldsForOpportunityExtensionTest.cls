/*
*Appirio Inc. 2016
*Name  : AccountFieldsForOpportunityExtension
*Author: Amit SanWariya (Appirio)
*Date  : 29 Sept, 2016
*Description: Test class for AccountFieldsForOpportunityExtension
*/
@isTest
public class AccountFieldsForOpportunityExtensionTest {
    static testMethod void OpportunityExtension() {
        Account acc =  TestUtility.createAccount(2 ,true);         
        Opportunity opp =TestUtility.createOpportunity(2 , acc.Id , true);
        
 		Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            AccountFieldsForOpportunityExtension controller = new AccountFieldsForOpportunityExtension(sc);
            System.assert(controller.accFieldSet.size() > 0);
            sc = new ApexPages.StandardController(opp);
  		Test.stopTest();
	}
                          
}