@isTest(seeAllData = false)
public class TestCaseDetailController {
       static testMethod void TestCaseDetailController () {
        User user = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +6), true);
        System.runAs(user){
            User user1 = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +5), true);
            CollaborationGroup testGroup = IntranetTestUtility.createGroup(true);
            CollaborationGroupMember testGroupMember =  IntranetTestUtility.createGroupMember(user1.Id, testGroup.Id, true);

            ApexPages.currentPage().getParameters().put('g', testGroup.Id);
            Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-1234567',Source_ID__c = '-1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
            insert p;
        
            Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
            c.Validation_Outcome_Reason__c = 'test';
            insert c;
                    
            CaseDetailController controller = new CaseDetailController(new ApexPages.Standardcontroller(c));
    }
  }
}