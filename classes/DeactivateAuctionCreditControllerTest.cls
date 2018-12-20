@isTest
private class DeactivateAuctionCreditControllerTest {
	
	static void test_Data() {

					Account acct = new Account(Name='Account-test');
					Insert acct;
					Contact cntct = new Contact(LastName='Contact-test', AccountId = acct.Id);
					Insert cntct;

					Account seller = new Account(Name='sellerAct-test', Organization_Type__c='Void');
					Insert seller;

					Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-1234567',Source_ID__c = '-1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
					insert p;
					    
				/*	RecordType CaseRecordTypeid = [Select Id From RecordType Where SObjectType='Case' and Name='Arbitration - New'];
					Case caseObj = new Case(Seller__c=seller.Id, AccountId=acct.Id,ContactId=cntct.Id,VIN__c = p.Id,RecordTypeId= CaseRecordTypeid.Id, 
					        				Type = 'Arbitration', 
					        				Description='PSI FAILED:Description', 
					        				Reason='Undisclosed Previous Repair', 
					        				Validation_Outcome_Override__c = true, 
					        				Claim_Resolution__c = 'Void', 
					        				Resolution_Subtype__c = 'Other', 
					        				Inspection_Company_Responsibility__c='Yes',
					        				Status = 'New');

					insert caseObj;
				*/

					RecordType CaseRecordTypeid = [Select Id From RecordType Where SObjectType='Case' and Name='Customer Service Inquiry - New'];
					Case caseObj = new Case(Seller__c=seller.Id, AccountId=acct.Id,ContactId=cntct.Id,VIN__c = p.Id,RecordTypeId= CaseRecordTypeid.Id, 
					        				Type = 'Ownership Inquiry', 
					        				Description='PSI FAILED:Description', 
					        				Reason='CAP Title',  
					        				Validation_Outcome_Override__c = true, 
					        				Claim_Resolution__c = 'Void', 
					        				Resolution_Subtype__c = 'Other', 
					        				Inspection_Company_Responsibility__c='Yes',
					        				Status = 'New');

					insert caseObj;        
					system.debug('-------------caseObj' + caseObj.Id);

					Action_Package__c pkg = new Action_Package__c(  RecordTypeId= [Select Id From RecordType Where SObjectType='Action_Package__c' and Name='Auction Void'].Id,
																	Case__c = caseObj.Id, 
																	Package_Type__c = 'Auction Void', 
																	Status__c = 'Open', 
																	Approved__c = false, 
																	Standard_SAP_Transactions__c = true, 
                                                					House_Transport_Responsible_Party__c = 'Seller',                                                      
																	Directions_For_Accounting__c = null);
					insert pkg; 
					system.debug('-------------pkg' + pkg.Id);

					List<Auction_Credit__c> auctionCreditList = new List<Auction_Credit__c>();
					auctionCreditList.add(new Auction_Credit__c(Action_Package__c=pkg.Id,
																			Credit_Amount__c = 260.0,
																			 Expires__c = date.today(),
																			 Status__c='Available'));
					auctionCreditList.add(new Auction_Credit__c(Action_Package__c=pkg.Id,																			
																			 Notification_Step__c = 'test notification',
																			 Deactivation_Comments__c  = 'test deactivate comment',
																			 Status__c='Deactivated'));	
					auctionCreditList.add(new Auction_Credit__c(	Notification_Step__c = 'test notification',
																			 Deactivation_Comments__c  = 'test deactivate comment',
																			 Status__c='Available'));	

																		 		
					insert auctionCreditList;																			 		

					system.debug('-------------auctionCreditList ' + auctionCreditList);




	}
	
	@isTest static void test_DeactivateAuctionCreditCtrl() {
		// Implement test code
		
		test_Data();
		Test.StartTest();
			
			Auction_Credit__c actionPkg =[Select Id From Auction_Credit__c where Status__c='Available' limit 1];

		    ApexPages.StandardController sc1 = new ApexPages.standardController(actionPkg);
		    DeactivateAuctionCreditController e1 = new DeactivateAuctionCreditController(sc1);	
		    PageReference  pg1 = e1.back();
		    PageReference  pg2 = e1.deactivate();


			actionPkg =[Select Id From Auction_Credit__c where Status__c='Deactivated' limit 1];
		    ApexPages.StandardController sc2 = new ApexPages.standardController(actionPkg);
		    DeactivateAuctionCreditController e2 = new DeactivateAuctionCreditController(sc2);	


			actionPkg =[Select Id From Auction_Credit__c where Action_Package__c=null limit 1];
		    ApexPages.StandardController sc3 = new ApexPages.standardController(actionPkg);
		    DeactivateAuctionCreditController e3 = new DeactivateAuctionCreditController(sc3);	

			User usr = TestUtility.createUser('dAct' , 'Openlane Super User', true);		    		

			system.runAs(usr)
			{

				actionPkg =[Select Id From Auction_Credit__c where Status__c='Available' limit 1];
			    ApexPages.StandardController sc4 = new ApexPages.standardController(actionPkg);
			    DeactivateAuctionCreditController e4 = new DeactivateAuctionCreditController(sc4);	
			}
		Test.StopTest();
	}
	

	
}