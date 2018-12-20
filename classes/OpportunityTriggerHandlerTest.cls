/*
*Appirio Inc. 2016
*Name  : OpportunityTriggerHandlerTest
*Author: Amit SanWariya (Appirio)
*Date  : 11 Oct, 2016
*Description: Test Class for OpportunityTriggerHandler
*Modified By: Amit Sanwariya (Appirio) Ref T-550099 - Using the limits from Custom Metadata Type now
*/
@isTest(SeeAllData=false)
public class OpportunityTriggerHandlerTest {
    
    private static final Id ADESADSTOPPORTUNITY = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ADESA DST CLOSE').getRecordTypeId();
    
    //Test Method: To test opportunity limits
    public static testmethod void OpportunityLimitTest() {
        //Get opportunity limits
       //Opportunity_Setting__mdt oppLimits = [SELECT Id, DeveloperName, Opportunity_Limit__c, Profies_Excluded_From_Limits__c
                                                            //FROM Opportunity_Setting__mdt 
                                                           //Where DeveloperName = 'Opportunity_Records_Limits' 
                                                           //LIMIT 1];
        //System.debug('oppLists ++++++++++++++ '+oppLimits);
        
        //Create test user
        User tstUser = TestUtility.createTestUser(false);
        tstUser.ADESAAUCTION__c='ADESA Atlanta';
        insert tstUser;
        //system.debug ('usertest'+[SELECT id,ADESAAUCTION__c FROM User]);
        
        //Create test Account
       Account acc= TestUtility.createAccount(0,false);
        acc.name='ADESA Atlanta';
        insert acc;
        //system.debug('AccountTest'+ [SELECT id,name  FROM Account]);
        acc.AccountSource='ADESA Calgary';
        update acc;
        
        //Create opportunity for update trigger test
        Opportunity oppToUpdate = TestUtility.createOpportunity(0, acc.Id, false);
        oppToUpdate.Bypass_Inlane_Seller_Status__c=true;
        oppToUpdate.RecordTypeId = ADESADSTOPPORTUNITY;
        oppToUpdate.Assigned_To_Auction__c = 'Assigned';
        insert oppToUpdate;
        
        //Create AuctionDetail
       Auction_Detail__c ad=TestUtility.createAuctionDetail(0,acc.Id,false);
        ad.Auction__c = acc.Id;
        insert ad;
        //system.debug ('auctiontest'+[SELECT id,Account__c, Inlane_Seller_Status__c,Buyer_Category__c,Auction__r.Name  FROM     Auction_Detail__c]);
                
         oppToUpdate.Account_Inlane_Seller_Status__c=ad.Inlane_Seller_Status__c;
         oppToUpdate.Account_Buyer_Category_Status__c=ad.Buyer_Category__c;
         update oppToUpdate;
        
        
   
        
        //Run test as standard user
        //
        System.runAs(tstUser){
            //Insert opportunities till limit
            List<Opportunity> oppList = new List<Opportunity>();
            for (Integer i=1; i<2; i++) {
                Opportunity opp = TestUtility.createOpportunity(i, acc.id, false);
                opp.RecordTypeId = ADESADSTOPPORTUNITY;
                oppList.add(opp);
            }
            insert oppList;

            
              test.startTest();

            //Test additional opportunity insert
            try {
                TestUtility.createOpportunity(100, acc.Id, true);               
            }
            catch (Exception e) {
                System.debug('Error Message'+e.getMessage());
                //Boolean expectedExceptionThrown =  e.getMessage().contains(Label.Opportunity_Limit_Error) ? true : false;
                //System.assertEquals(expectedExceptionThrown, true);
            }
            
            //Test opportunity owner update
            try {
                oppToUpdate.OwnerId = tstUser.Id;
                update oppToUpdate;
            }
            catch (Exception e) {
                System.debug('Error Message'+e.getMessage());
                //Boolean expectedExceptionThrown =  e.getMessage().contains(Label.Opportunity_Limit_Error) ? true : false;
                //System.assertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();
        }
    }
}