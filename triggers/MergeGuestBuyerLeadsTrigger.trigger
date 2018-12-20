// ============================================================================================//
//      THIS TRIGGER IS USED BY IAA Buyer Services APP
// ============================================================================================//
//***********************************************************************************************************************//
// User Story 173582:Buyer Marketing - Auto Convert Guest Leads
// Description: 
// -Auto convert (merge) guest registration leads to their buyer accounts when:
//    1) Lead record has both registrant id and ASAP buyer id
//            and
//    2) (Buyer) Account record exists and matches the ASAP buyer id from (buyer) lead reord.
//-Ensure all activities recorded are associated to the buyer account
//-Converted (merged) leads do not create an opportunity record
//-If Lead and Account records have mismatched data, the values from the Account record will be used.
//Created By: John Britto S (jbritto)
//Created Date(MM/DD/YYYY): 06/09/2016
//***********************************************************************************************************************//

trigger MergeGuestBuyerLeadsTrigger on Lead (After Insert, After update) 
{

//Get BI_Dev user id
          User SetUserid = [Select id, name from user where alias='BI_Dev'];

//Get the BUYER Record Type id
                   
          Map<ID,Schema.RecordTypeInfo> rt_Map = Lead.sObjectType.getDescribe().getRecordTypeInfosById();

//Declaration
         List<Lead> LeadsToConvert=new List<Lead>();
         set<String> LeadBuyerID = new set<String>();
         set<String> LeadName = new set<String>();
         set<ID> Leadid = new set<ID>();
         string GetRegistrantID;    
    
//============= BEGIN: Part 1: Merge the Lead with existing account============================================================================//      

    //*******************************************Get Bulk LEAD records from BI****************************************************//

    for(Lead LeadRecord: Trigger.new)
    {
        // BEGIN: S-444340, T-562121 - Changed REcord Type to IAA Buyer Services from BUYER
        if(LeadRecord.isConverted == false && LeadRecord.convertedAccountid==null && (LeadRecord.createdbyid==setuserid.id || LeadRecord.lastmodifiedbyid==setuserid.id)
        &&  rt_map.get(LeadRecord.recordTypeID).getName().containsIgnoreCase('IAA Buyer Services') &&LeadRecord.Buyer_ID__c !=null && LeadRecord.RegistrantID__c !=null)
       // END: S-444340, T-562121 - Changed REcord Type to IAA Buyer Services from BUYER
      {
        LeadsToConvert.add(LeadRecord);
        LeadName.add (leadrecord.firstname + ' ' + leadrecord.lastname);
        Leadid.add(Leadrecord.id);
        LeadBuyerID.add(LeadRecord.Buyer_ID__c);
       }
     }
    
    //*******************************************Get Bulk LEAD records from BI****************************************************//
    
    
    //*****************************************Check the existing Accounts with LEAD Buyer ID and get the corresponding Account ID & Buyer Id *****************//
    if(!LeadsToConvert.isEmpty())
    {  
        
        //********************************* Get existing Accounts by matchs with Buyer ID************************************************//
        Map<string,Id> BuyeridAccountMap = new Map<string,Id>();
        set<ID> AcctID = new set<ID>();
        
        // BEGIN: S-444340, T-567203 - IAA Remarketing is common for Buyer & Remarketing in Account -recordtype custom field IAARecordTypes__c=='IAA Remarketing'//
        for (Account Acct :[SELECT ID, Buyer_ID__c 
                            FROM Account 
                            WHERE Buyer_ID__c != null 
                            and Buyer_ID__c in :LeadBuyerID 
                            ])//and IAARecordTypes__c='IAA Remarketing'

        {
            BuyeridAccountMap.put(Acct.Buyer_ID__c, Acct.Id);
            AcctID.add(Acct.id);
        }
        
        //**********************************Get existing contacts with Name*************************************************************//
         Map<string,id> ContactMap = new Map<string,ID>();
         for (contact Cont:[select name, id,accountid from Contact where name != null and name in :LeadName and accountid in :AcctID])
         {
         ContactMap.put(cont.name,cont.id);
         }
        //**********************************Get existing contacts with Name************************************************************//
     
        //Convert/Merge the Lead into Account
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
    
        
        for(Lead myLead : LeadsToConvert){
        Database.LeadConvert lc = new database.LeadConvert();    
        if(mylead.convertedaccountid == null)
        {
        //Merge Leads with existing Accounts
        if(BuyeridAccountMap.containsKey(mylead.Buyer_ID__c)){
            
            lc.setLeadId(myLead.Id);
            lc.setConvertedStatus('Converted');
            lc.setDoNotCreateOpportunity(true);
            ID IDs = BuyeridAccountMap.get(mylead.Buyer_ID__c);
            lc.setAccountId(ids);
            
            //Merge with existing Contacts if Name matches
            if (ContactMap.containskey(myLead.firstname + ' ' + myLead.lastname))
            {
            ID contid = ContactMap.get(myLead.firstname + ' ' + myLead.lastname);
            lc.setcontactid(contid);
            }
            
            leadConverts.add(lc);
        }
    } 
    }
    try
    {
    List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);    
   
    }catch(DMLexception DM)
    {
    System.debug('Error on while converting leads:'+DM.getMessage());
    }
     
  }
//============= END: Part 1: Merge the Lead with existing account============================================================================//     
    MapGuestBuyerLeadsClass.MapRegistrantID(Leadid);
}