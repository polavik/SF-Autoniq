/*
*Appirio Inc. 2016
*Name  : AccountsFieldsForLeadExtension
*Author: Amit SanWariya (Appirio)
*Date  : 7 Oct, 2016
*Description: Test Class for AccountsFieldsForLeadExtension
*/
@isTest
public class AccountsFieldsForLeadExtensionTest {
    private static testMethod void LeadExtension() {
        Account acc =  TestUtility.createAccount(2 ,true);
        lead l = new lead(LastName ='LastLaed' ,
                          Account__c = acc.Id,
                          Company = 'TestApprio',
                          Status = 'New',
                          CurrencyIsoCode = 'USD');
        insert l;
        Territory__c terr =TestUtility.createTerritory('54321', 'test' , true);
        
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(l);
            AccountsFieldsForLeadExtension controller = new AccountsFieldsForLeadExtension(sc);
            System.assert(controller.accFieldSet.size() > 0);
            System.assert(controller.territoryFieldSet.size() > 0);
            sc = new ApexPages.StandardController(l);
        Test.stopTest();
	}  
}