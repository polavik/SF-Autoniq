// ============================================================================================//
//      THIS APEX TEST CLASS IS USED BY IAA Buyer Services APP
// ============================================================================================//

@isTest (seealldata=true)
public class MergeGuestBuyerLeadsTrigger_Test{
static testMethod void MergeGuestBuyerLeadsTrigger() {
         
    //Get the Public Dealer Record Type id
    RecordType SetRecordTypeid = [select name, id 
                                  from recordtype 
                                  where name='Public' 
                                  and SobjectType='Account' 
                                  and isactive=true limit 1];

    //Get Flosum Deployment user id
    User SetUserid;
    SetUserid = [Select id, name from user where alias='fdepl' Limit 1];

    //Create Account with Flosum Deployment user       
    System.runAs(SetUserid ) 
    {
      //Insert Account
              
       Account accnt = new Account (name='TestAccount', 
                                    Buyer_ID__c = '9000', 
                                    recordtypeid=SetRecordTypeid.id, 
                                    IAARecordTypes__c='IAA Remarketing',
                                    CA_AMG_Payment_Method__c = 'None',
                                    CA_AMG_Subscription__c=true,
                                    BillingPostalCode='12345');
       insert accnt;
       
       //BEGIN: S-444340 T-562123 - Process only IAA Buyer Services data
       id LeadRecordTypeid = [Select Id 
                                       From RecordType 
                                       Where SObjectType='Lead' 
                                       and Name='IAA Buyer Services' limit 1].id;
        
       Lead L1 = new Lead (lastname = 'BI DEV Leads from BI', 
                           firstname = 'Test For',
                           email = 'ththt@hafhdkj.com',
                           company = 'Company ABC',
                           contract_Type__c = 'CFF',
                           street ='test',
                           city = 'test',
                           state = 'IL',
                           postalCode = '12345',
                           leadsource = 'Matching Campaign',
                           RegistrantID__c ='12345',
                           Verified_Create_Account__c=true,
                           Buyer_ID__c = '9000',
                           TIN__c='test',
                           recordtypeid=LeadRecordTypeid,
                           Lead_Type__c='test');
       //if(LeadRecordTypeid !=null && LeadRecordTypeid.size()>0){
          //L1.LRecordTypeid = LeadRecordTypeid.get(0).Id;
       //}
       
       //END: S-444340 T-562123 - Process only IAA Buyer Services data
       
       Insert L1;

       //Lead Coversion 
       Database.LeadConvert lc = new Database.LeadConvert();
       lc.setLeadId(L1.Id);
       lc.setdoNotCreateOpportunity(false);
       lc.setConvertedStatus('Converted');

       //Database.LeadConvertResult lcr = Database.convertLead(lc);
       //System.assert(lcr.isSuccess());



       //system.debug('L1.LRecordTypeId:' + L1.LRecordTypeid);

       contact cont = new contact(lastname = l1.lastname, 
                                  firstname = l1.firstname,
                                  accountid=accnt.id);
       insert cont;
    }
  }  

}