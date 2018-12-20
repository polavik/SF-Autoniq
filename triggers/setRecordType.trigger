trigger setRecordType on Account (Before insert, before update) 
{ 
    // This code is modified by the KAR Killswitch.
    //Get profile Id of Current User
    Id profileId = Userinfo.getProfileId();
    //Get KillSwitch record for the User's profileId.
    Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);
    //Check for KillSwitch flag
    if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){  
    String customerTypeRecordTypeId ;             
    String dealershipUSRecordType = Utils.getRecordTypeId('Account', 'Dealership Account US'); 
    String dealershipCARecordType = Utils.getRecordTypeId('Account', 'Dealership Account CA');
    String dealershipIntlRecordType = Utils.getRecordTypeId('Account', 'Dealership Account Intl'); 
//    String dealershipRecordType = Utils.getRecordTypeId('Account', 'Dealership Active'); 
    String auctionRecordType = Utils.getRecordTypeId('Account', 'Auction'); 
    String institutionConsignorRecordType = Utils.getRecordTypeId('Account', 'Institution/Consignor'); 
    String prospectRecordType = Utils.getRecordTypeId('Account', 'KAR Prospect'); 
    String duplicateRecordType = Utils.getRecordTypeId('Account', 'Duplicate Account');
    String invalidOOBRecordType = Utils.getRecordTypeId('Account', 'Invalid/OOB');
    String repoPARRecordType = Utils.getRecordTypeId('Account', 'Repo/PAR');
    String carsarriveRecordType = Utils.getRecordTypeId('Account', 'CarsArrive Transporter');
    //djpatel on 25-Sep-2014 ( B-31398 )
    String creditAccountRecordType = Utils.getRecordTypeId('Account', 'Credit Account');  
    String palsProviderRecordType = Utils.getRecordTypeId('Account', 'PALS Provider');      
    boolean IsCreditAccountProfile = false;
    boolean IsIntegratorProfile = false; 
    
    IsCreditAccountProfile = Utils.IsCreditAccountProfile('credit.account.creator.profiles');    
    IsIntegratorProfile = Utils.IsIntegratorProfile('all.account.creator.profiles');
       


    // End
    for(Account a: Trigger.new){
    
    
        if (a.Name == null)
        { 
           a.Name = 'No Name';
        }
        
        //djpatel on 29-Sep-2014 ( B-31398 )
        if(a.Converted__c != 1)
        {
            if(Trigger.isInsert && IsCreditAccountProfile ==false && IsIntegratorProfile == false) // Prevent Other Profile to Create Account
            {
                if(!Test.isRunningTest())
                {
                a.addError('You don\'t have permission to create Account'); 
                continue;
                }           
            } 
            if(Trigger.isInsert && IsCreditAccountProfile && a.recordTypeId !=creditAccountRecordType) // Prevent Credit Account Creator Profiles to Create Account other than Credit Account
            {
                if(!Test.isRunningTest())
                {
                a.addError('You don\'t have permission to create this Record Type Account'); 
                continue; 
                }          
            } 
            if(Trigger.isInsert && IsIntegratorProfile  && a.recordTypeId ==creditAccountRecordType) // Prevent Integrator Profiles to Create Credit Account
            {    
                if(!Test.isRunningTest())
                {
                a.addError('You don\'t have permission to create this Record Type Account'); 
                continue;  
                }         
            } 
        }
      
        system.debug('Record Type = '+a.recordTypeId+' and Locked = '+a.Record_Type_Locked__c);
        //djpatel on 29-Sep-2014 ( B-31398 )      
        if( a.recordTypeId != creditAccountRecordType && a.Record_Type_Locked__c == false) //Some Accounts we don't want to change even though they match below criteria.  PPM 108196 by ehulen
        {
             //B-41062 by ehulen: Any Account with AAID in specified range is Institutional/Consinger reguardless of anything else
             if(a.Auction_Access_Number__c != null)
             {
                 system.debug('AAID = '+a.Auction_Access_Number__c);
                 if(integer.valueof(a.Auction_Access_Number__c) >= 8000000 && integer.valueof(a.Auction_Access_Number__c) <= 8999999)
                 {
                     a.recordTypeId = institutionConsignorRecordType;
                     continue;
                 }
                 
             }
             //djpatel on 14-Nov-2014 PPM#97003 (Update Account Record Types)
             //update or insert check condition not added because we need to preserve record type for account record inserts from SF-Integration 
             //lily ppm: 102456  SF KAR Migration: Account Record Type not allowing change to invalid/OOB
              //Eric modified this to include duplicate Record Type at the wish of Saiqa's team.  No PPM yet created.
              if(a.recordTypeId == AuctionRecordType || a.recordTypeId == repoPARRecordType ||a.recordTypeId == carsarriveRecordType ||a.recordTypeId == institutionConsignorRecordType||a.recordTypeId ==invalidOOBRecordType || a.recordTypeId == duplicateRecordType  )
              {
                 continue;              

              }
              else{
                system.debug('Name = '+a.Name);
                system.debug('Org Type= '+a.Organization_type__c);
                system.debug('Primary Country= '+a.Primary_Country__c);
                system.debug('Primary Country= '+a.MDM_Customer_Type__c);
                customerTypeRecordTypeId = Utils.getRecordTypeId('Account', a.MDM_Customer_Type__c); 

                if(a.Name.containsIgnoreCase('Carmax Auction')){ 
                    a.recordTypeId = auctionRecordType; //Auction
                }else if(a.Organization_type__c == 'PALS Provider' || a.Organization_type__c == 'Inspection'){//Ricky on 26-Nov-2015 PPM104116 and Eric on 5-4-2016
                    a.recordTypeId = palsProviderRecordType;
                }else if (String.isNotBlank(a.MDM_Customer_Type__c) && String.isNotBlank(customerTypeRecordTypeId) &&  a.Exempt_MDM_Customer_Type__c == false){ // @npatel - Story B-44304 - MDM Customer Type 
                    a.recordTypeId = customerTypeRecordTypeId;                  
                    system.debug('MDM Customer Type');                                                                                    
                }else if(a.Primary_Street1__c ==null || a.Primary_Street1__c == '' || a.Data_Source__c=='OPENLANE' || a.Data_Source__c=='ADESA' ) {  
                    if (a.BillingCountry!=null && a.BillingCountry.trim().containsIgnoreCase('canada')) {
                        a.recordTypeId = dealershipCARecordType;
                        system.debug(' Billing CA ');
                    }else  if (a.BillingCountry!=null && (a.BillingCountry.trim().containsIgnoreCase('usa') || a.BillingCountry.trim().containsIgnoreCase('united states')))  {
                         a.recordTypeId = dealershipUSRecordType;
                         system.debug('Billing USA ');
                    } else if((a.Data_Source__c=='OPENLANE' || a.Data_Source__c=='ADESA') && (!a.BillingCountry.trim().containsIgnoreCase('usa')) && (!a.BillingCountry.trim().containsIgnoreCase('united states')) &&  (!a.BillingCountry.trim().containsIgnoreCase('canada')) )
                    {
                        system.debug('Inside billing Country '+ a.BillingCountry);
                        a.recordTypeId = dealershipIntlRecordType;
                    }
                }else if(a.Primary_Country__c == 'Canada' ){
                        a.recordTypeId = dealershipCARecordType;
                         system.debug('Primary CA ');
                 }else if ( a.Primary_Country__c == 'USA' ){
                    a.recordTypeId = dealershipUSRecordType;
                      system.debug('Primary USA ');
                }else{
                    a.recordTypeId = dealershipIntlRecordType;
                       system.debug('Primary Internal ');
               }
               
            }
        }              
    }
  } 
}