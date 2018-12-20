/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestAuctionCreditHelper {

    static testMethod void myUnitTest() 
    {
        // Set up a user with approval permissions
        
        User usr = new User();
            
        usr.Username = 'mrawesome@openlane.com';
        usr.Email = 'mrawesome@openlane.com';
        
        usr.FirstName = 'Mr';
        usr.LastName = 'Awesome';
        usr.CommunityNickname = 'mrawesome';
        
        usr.Alias = 'mrawe';
        
        // 'Standard User' Profile Id
        //usr.ProfileId = '00e30000000gnd3';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.LanguageLocaleKey = 'en_US';
        usr.Max_Approval_Amount__c = 1000;
        
        //FIXME: insert usr;

        
        
        Account a = new Account();
        //a.ATC_Organization_ID__c = '123456';
        a.Name = 'Mr Stevebobs Volvo';
        insert a;
        
        Purchase__c p = new Purchase__c
        (
            Name = 'JNKCV54E33M212906', 
            Vehicle_Id__c = '12345',
            Source_id__c = '12345',
            Handles_Payment__c = 'Y', 
            Actual_Dropoff__c = Date.today(), 
            Transport_Preference__c = 'OPENLANE Arranged', 
            sale_Class__c = 'Closed - Grounding Dealer', 
            ATC_Sale_Date__c = Date.today()
        );
        insert p;
        
        Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c
        (
            Case__c = c.Id, 
            Package_Type__c = 'Auction Credit', 
            Status__c = 'Approved', 
            Approved__c = true, 
            Standard_SAP_Transactions__c = true, 
            Directions_For_Accounting__c = null, 
            Credit_Reason__c = 'TEST CREDIT REASON',
            Number_Of_Credits__c = 1, 
            Credit_Amount__c = 250,
            Manager_Approver__c = usr.Id
        );
        // insert pkg; // FIXME: check validation rule
        
        ID goodwillRT = Utils.getRecordTypeId('Auction_Credit__c', 'Auction Credit - Goodwill');
        
        Auction_Credit__c credit = new Auction_Credit__c();
        credit.Credit_Amount__c = 260;
        credit.Account__c = a.Id;
        credit.RecordTypeId = goodwillRT;
        credit.Purchase__c = p.id;
        credit.Action_Package__c = pkg.Id;
        insert credit;
        
        Picklist_Mapping__c mapping = new Picklist_Mapping__c(
            Field_Name__c = 'Credit_Reason__c',
            Object_Type__c = 'Action_Package__c',
            Mapping__c = '1',
            Name = 'TEST CREDIT REASON'
        );
        
        insert mapping;
        
        AuctionCreditHelper.createCreditsFromActionPackage(pkg);
        try
        {
            AuctionCreditHelper.applyCredit(credit.Id);
        }
        catch (Exception e)
        {
            
            System.debug('Ignoring the following exception:');
            System.debug(e);
        }
        
        try
        {
            AuctionCreditHelper.sendNotification(credit.Id);
        }
        catch (Exception e)
        {
            
            System.debug('Ignoring the following exception:');
            System.debug(e);
        }
        
        credit.Status__c = 'Available';
        AuctionCreditHelper.expireCredits(new Auction_Credit__c[] {credit});
        credit.Status__c = 'Available';        
        AuctionCreditHelper.deactivateCredits(new Auction_Credit__c[] {credit});
        credit.Status__c = 'Pending Application';
        AuctionCreditHelper.deactivateCredits(new Auction_Credit__c[] {credit});
        credit.Status__c = 'USED';
        AuctionCreditHelper.deactivateCredits(new Auction_Credit__c[] {credit});
        
        Mediator.applyAuctionCreditResponseType response = new Mediator.applyAuctionCreditResponseType();
        response.returnCode = 'ADJUSTMENT_SUCCESS';
        response.errorMsg = new String[]{'a'};
        response.sdDocument = new Mediator.SDDocument[] {new Mediator.SDDocument()};
        response.fiDocument = new Mediator.FIDocument[] {new Mediator.FIDocument()};
        
        new AuctionCreditHelper.SendResponse(response, credit);
        
    }
}