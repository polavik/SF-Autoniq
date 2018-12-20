@isTest(SeeAllData=false)
private class AuctionCreditExpirationNoticeCtrlTest {

	
	
	static void test_Data() {

		// creation of data
			//Savepoint sp = Database.setSavepoint();

			//try{
		

					Account acct = new Account(Name='Account-test');
					Insert acct;
					Contact cntct = new Contact(LastName='Contact-test', AccountId = acct.Id);
					Insert cntct;

					Account seller = new Account(Name='sellerAct-test', Organization_Type__c='Void');
					Insert seller;

					Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-1234567',Source_ID__c = '-1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
					insert p;
					    
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
																			 Expires__c = date.today()+2,
																			 Status__c='Available'));	
					auctionCreditList.add(new Auction_Credit__c(Action_Package__c=pkg.Id,																			
																			 Expires__c = date.today()-2,
																			 Status__c='Available'));																				 		
					insert auctionCreditList;																			 		

					system.debug('-------------auctionCreditList ' + auctionCreditList);

		//	} catch(exception ex){
		//	    Database.rollback(sp);
		//	}

	}
	
	@isTest static void test_AuctionCreditExpirationNoticeCtrl() {
		// Implement test code
		
		test_Data();
		Test.StartTest();
			AuctionCreditExpirationNoticeController controller = new AuctionCreditExpirationNoticeController();
			controller.actionPackageId =[Select Id From Action_Package__c limit 1].Id;
		Test.StopTest();
	}
	
}