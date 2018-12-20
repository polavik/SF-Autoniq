@isTest
public class TestActionPackageLockCase {
    static testMethod void TestActionPackageLockCase() {
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-1234567',Source_ID__c = '-1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
		insert p;
		
		Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
    	insert c;
    	
    	Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void', Status__c = 'Approved', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
    	insert pkg;        
        delete pkg;
    }
	
}