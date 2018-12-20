@isTest
public class PalsWebServiceVOTriggerTest{
    static testMethod void test(){

        Opportunity opp = new Opportunity();
        opp.name =  'Test Pals Listing';
        opp.stageName = 'Open';
        //opp.recordTypeId = '01260000000DezKAAS';
        opp.closeDate = System.today();
        
        opp.leadSource = '2010 S.A.M. Lead';
        //opp.list_Source__c = 'Pals Pending Listing';
        insert opp;
        

        Asset__c At = new Asset__c(Name='VIN1234567980Test', Source_Id__c='OL-123456789', Vehicle_Id__c ='123456789');
        Insert At;
        
          
        Vehicles_Opportunities__c vo = new Vehicles_Opportunities__c (
            Buyer_Org_Id__c='123456', External_Id__c='1234', Opportunity__c = Opp.Id,Vehicle__c = At.Id);
        insert vo;
    }
}