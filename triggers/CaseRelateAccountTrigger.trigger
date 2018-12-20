//PROD Backup Code------------------------------------------------------------------------------------------------
//    THIS TRIGGER IS USED BY CORP - BUYER App Only
//------------------------------------------------------------------------------------------------
//Story: User Story 160435:Relate Case to Account
//Date: 07-04-2016
//Created by: John Britto (jbritto)
//Trigger Name: CaseRelateAccountTrigger
//Purpose: Relate a case to Account when the case is coming from Auction Center - Contact Us page
//------------------------------------------------------------------------------------------------
trigger CaseRelateAccountTrigger on Case (before insert, before update) 
{
   
   //BEGIN: S-444999, T-566622 - Add CASE Record Type
     //Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
     
     /*RecordType recordtypes = [SELECT Id, name
                               FROM RecordType
                               WHERE SobjectType = 'Case' 
                               AND Name = 'IAA Buyer Services'
                               LIMIT 1];*/
    Id recordtypes = [SELECT Id, name
                               FROM RecordType
                               WHERE SobjectType = 'Case' 
                               AND Name = 'IAA Buyer Services'
                               LIMIT 1].Id;


    for(case cas : trigger.new)
    {
    
    //BEGIN: S-444999, T-566622 - Add CASE Record Type
    //if (recordtypes.name == 'IAA Buyer Services')
      //if (cas.recordtype.name == recordtypes.name)
      if (cas.recordtypeId == recordtypes)
    {
  // (rt_map.get(cas.recordTypeID).getName().containsIgnoreCase('IAA Buyer Services'))
            //Check whether the case is coming from Auction Center - 'Contact Us' page           
    if(cas.type=='Contact Us')
        {
    try
        {
        //Case Accountid should be null
        if(cas.accountId == null){
            //Check if Buyer ID available
            if(cas.Buyer_ID_Contactus__c != null){
            //Ignore if Buyer id =0 from Contact us since “0” represents guest accounts

            if (cas.Buyer_ID_Contactus__c != '0') { 

            //Get Account from Account object based on Buyer ID Contactus from AC
            
            //BEGIN: S-444999, T-566622 - IAA Remarketing is common for Buyer & Remarketing in Account -recordtype custom field IAARecordTypes__c=='IAA Remarketing'//
            List<Account> accnts = [Select Id 
                                    from Account 
                                    where Buyer_ID__c=:cas.Buyer_ID_Contactus__c 
                                    and IAARecordTypes__c = 'IAA Remarketing'];   
            /*Id accnts = [Select Id 
                        from Account 
                        where Buyer_ID__c=:cas.Buyer_ID_Contactus__c 
                        and IAARecordTypes__c = 'IAA Remarketing' limit 1].Id;*/   
                        system.debug('equals' + accnts);                      
            if (accnts.size()==1)
            //if (accnts !=null)
            {
                cas.accountId = accnts[0].id;
                //cas.accountId = accnts;
             }
                }  
                }
                }             
            }
    catch (System.NullPointerException e){
     system.debug ('Error Relating Case to Account');
   }
   } 
   
 }
 }
  }