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
@isTest(SeeAllData=true)
private class TestDeactivateActionPackageController {
      


    static testMethod void UnitTest1() {

        Account acct = new Account(Name='Account-test');
        Insert acct;
        Contact cntct = new Contact(LastName='Contact-test', AccountId = acct.Id);
        Insert cntct;

        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-798754645',Source_ID__c = '-798754645', 
                                                Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, 
                                                Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
//        Case c = new Case(AccountId=acct.Id,ContactId=cntct.Id,VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        Case c = new Case(AccountId=acct.Id,ContactId=cntct.Id,VIN__c = p.Id, Type = 'Ownership Inquiry', Description='PSI FAILED:Description', Reason='CAP Title', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void', Status__c = 'Approved', Approved__c = true, 
                                                        House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, 
                                                        Directions_For_Accounting__c = null,
                                                        Void_House_Transport__c =true, Emailed_To__c ='dontcare@sandbox.com');
        insert pkg;

        Attachment attach = new Attachment( Name='test',  ParentId = pkg.Id); 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        insert attach;
        
        p.Transport_Void_Package__c  = pkg.Id;
        p.Vehicle_Void_Package__c = pkg.Id;
        update p;

        Auction_Credit__c auctionCredit = new Auction_Credit__c(Action_Package__c=pkg.Id,
                                                                Credit_Amount__c = 260.0,
                                                                 Expires__c = date.today(),
                                                                 Status__c='Available') ;
        insert auctionCredit;
        system.debug('-------------auctionCredit ' + auctionCredit.Id);

        Test.StartTest();
        User usr = TestUtility.createUser('dAct' , 'Operations User', true);                    

        system.runAs(usr)
        {        
               DeactivateActionPackageController dapc2 = new DeactivateActionPackageController(new ApexPages.StandardController(pkg)); 
        }        


        
        DeactivateActionPackageController dapc = new DeactivateActionPackageController(new ApexPages.StandardController(pkg));
        dapc.back();
        dapc.deactivate();
        dapc.validateProfile();

        Test.StopTest();
    }

    static testMethod void UnitTest2() {

             
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-999754645',Source_ID__c = '-999754645', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;

        
        Case c = new Case(VIN__c = p.Id, 
                          Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', 
                          Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', 
                          Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void', Status__c = 'Deactivated', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        insert pkg;
        
        DeactivateActionPackageController dapc = new DeactivateActionPackageController(new ApexPages.StandardController(pkg));



    }


   static testMethod void UnitTest3() {




        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-999754645',Source_ID__c = '-999754645', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;


        Case c = new Case(VIN__c = p.Id, 
                          Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', 
                          Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', 
                          Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void', Status__c = 'Rejected', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        insert pkg;
        Test.StartTest();
        DeactivateActionPackageController dapc = new DeactivateActionPackageController(new ApexPages.StandardController(pkg));
        dapc.getIsUnavailable();
        dapc.deactivate();
        Test.stopTest();  
    }

/*
   static testMethod void UnitTest4() {


        Account acct = new Account(Name='Account-test');
        Insert acct;
        Contact cntct = new Contact(LastName='Contact-test', AccountId = acct.Id);
        Insert cntct;

        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-987987987',Source_ID__c = '-987987987', 
                                                Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, 
                                                Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Case c = new Case(AccountId=acct.Id,ContactId=cntct.Id,VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void', Status__c = 'Pending...', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        insert pkg;
        
        Test.StartTest();
            DeactivateActionPackageController dapc = new DeactivateActionPackageController(new ApexPages.StandardController(pkg));
        Test.stopTest();    
    }
*/

  static testMethod void testValidateProfile() {

/*                
		List<String> approvers = new List<String> { 'ADESA System Administrator',
			'ADESA Canada Admin',
			'Program Coordination-US',
			'Arbitration Manager - Canada',
			'Arbitration Manager - US',
			'Openlane Super User',
			'Openlane-Admin Canada',
			'Openlane Operations Manager Canada',
			'Openlane Operations Manager US',
			'Openlane Sales Manager Canada',
			'Openlane Sales Manager US',
			'Program Coordination Manager-Canada',
			'Transportation Manager',
			'System Administrator',
			'Dealer Service/Arb Coordinator-Canada',
			'ADESA Delegated Support',
			'ADESA Canada Super User'} ;

*/        		
        String pname = 'Deployment';
        String pname1 = 'ADESA Canada Super User';
        String pname2 = 'Arbitration Manager - US';

        Profile prof = [SELECT Name,Id FROM Profile WHERE name =: pname ];
        Profile prof1 = [SELECT Name,Id FROM Profile WHERE name = : pname1  ];
        Profile prof2 = [SELECT Name,Id FROM Profile WHERE name =: pname2  ];

        User user = TestUtils.createUsers(1, pname, false)[0];   
        User user1 = TestUtils.createUsers(1, pname1, false)[0];  
        User user2 = TestUtils.createUsers(1, pname2, false)[0];  
		insert new List<User>{user, user1};


        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-999754645',Source_ID__c = '-999754645', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;

        Case c = new Case(VIN__c = p.Id, 
                          Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', 
                          Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', 
                          Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void', Status__c = 'Rejected', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        insert pkg;
		
		DeactivateActionPackageController dapc = null;
		
		Test.StartTest();
        System.debug('-------new DeactivateActionPackageController Starting--');			
		system.runAs(user){
			
	    	dapc = new DeactivateActionPackageController(new ApexPages.StandardController(pkg));
            System.debug('-------new DeactivateActionPackageController Done');			
	        System.debug('user: id (' + user.Id + ')  Name = (' + user.Name + ')' + 'ProfileId =' + user.ProfileId);			
	        if (dapc.validateProfile()) 
	        {
	            System.debug('------user-----  it is  isAvailable = false');			
	        } 
	        else 
	        {
	            System.debug('-------user-----  it is  isAvailable = true');			
	        }
		}
		system.runAs(user1){
			
	    	dapc = new DeactivateActionPackageController(new ApexPages.StandardController(pkg));
            System.debug('-------new DeactivateActionPackageController Done');			
	        System.debug(' user1: id (' + user1.Id + ')  Name = (' + user1.Name + ')' + 'ProfileId =' + user1.ProfileId);            
	        if (dapc.validateProfile()) 
	        {
	            System.debug('------user1-----  it is  isAvailable = false');			
	        } 
	        else 
	        {
	            System.debug('-------user1-----  it is  isAvailable = true');			
	        }
		}

		        
 		Test.stopTest();   
		
    }

}