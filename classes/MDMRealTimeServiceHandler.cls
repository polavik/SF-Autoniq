global class MDMRealTimeServiceHandler {

    global class AccountInfo {
        webService String  MasterIdx;
        webService String  integrationID;              // Integration_ID__c                             MATCH
        webService String  COSMOS_Id;                  // AFC_Dealer_ID__c COSMOS Source System         NO MATCH
        webService String  AUCTION_ACCESS_Id;          // AA_Id AUCTION ACCESS Source System  Done      NO MATCH
        webService String  OPENLANE_Id;                // V1_Id OPENLANE Source System       Done       NO MATCH
        webService String  partyUID;                   // partyUID = Mdm_ID__c
        WebService String  AMS_Id;                     // AMS_Buyer_Id  ???????????????????????????
        webService String  IAA_Id;                     // ??
        webService datetime createdDTM;                   // CREATED DATETIME = CreatedDate
        webService datetime lastUpdatedDTM;               // LAST UPDATED DATETIME = LastModifiedDate
        webService String customerName;                   // Name                                       MATCH
        webService String customerLegalName;              // Legal_Name__c                              MATCH
        webService String phoneNumber;                   // Phone                                       MATCH
        webService String accountType;                   // organization_Type__c                        MATCH
        webService String auctionAccessID;                // Auction_Access_Number__c                   MATCH
        webService String faxNumber ;                     // Fax                                        MATCH
        webService String federalTaxId;                   // Tax_Identification_Number__c               MATCH
        webService Boolean outOfBusinessIndicator;        // out_Of_Business__c  Boolean.valueOf()
        webService date    outOfBusinessDate;             // Out_of_Business_Date__c
        webService String addressLine1 ;                  // billingStreet                              MATCH
        webService String addressLine2 ;                  // billingStreet                              MATCH
        webService String City ;                          // billingCity                                MATCH
        webService String state;                          // billingState                               MATCH
        webService String zipcode;                        // billingPostalCode                          MATCH
        webService String country ;                       // billingCountry                             MATCH
    }

    global class ContactInfo {
        webService String  MasterIdx;
        webService String  integrationID;              // Integration_ID__c
        webService String  COSMOS_Id;                  // AFC_Dealer_ID__c COSMOS Source System
        webService String  AUCTION_ACCESS_Id;          //  AA_Id AUCTION ACCESS Source System  Done
        webService String  OPENLANE_Id;                // V1_PersonID OPENLANE Source System       Done
        webService String  partyUID;                   // partyUID = Mdm_ID__c
        WebService String  AMS_Id;                     // AMS_Buyer_Id  ???????????????????????????
        webService String  IAA_Id;                     // ??
        webService datetime createdDTM;                 
        webService datetime updatedDTM;                 
        webService String firstName;                      // FirstName
        webService String lastName;                       // LastName
        webService String middleName;                     // Middle_Name__c
        webService date   birthDate;                      // Birthdate
        webService String jobTitle;                       // Title
        webService String PrimaryWorkPhone;               // Phone           
        webService String emailAddress;                   // Email
        webService String auctionAccessID;                // Auction_Access_Number__c
        webService Boolean deceasedIndicator;             // 0 or 1
        webService Boolean activeflg;                     // 0 or 1
        webService String addressLine1;                   // MailingStreet
        webService String addressLine2;                   // MailingStreet 
        webService String City;                           // MailingCity      
        webService String state;                          // MailingState 
        webService String zipcode;                        // MailingPostalCode         
        webService String country;                        // MailingCountry
    }

    webService static List<Contact> createContact(List<ContactInfo> ListOfContacts) {
        List<Contact> result = new List<Contact>();

        if(listOfContacts.size() > 0){

            ContactInfo contactInfo = listOfContacts[0];
            List<String> personIdList = (contactInfo == null)?new List<String>():contactInfo.OPENLANE_Id.split(',');
            List<String> aanList = (contactInfo == null)?new List<String>():contactInfo.auctionAccessID.split(',');
            List<String> afcDealerIdList = (contactInfo == null)?new List<String>():contactInfo.COSMOS_Id.split(',');

            String contactQuery = 'Select Id,Mdm_ID__c,Party_Id__c,Person_ID__c, Deceased__c, Active__c,Login_ID__c, Login_Name__c, Master_Index__c,Middle_Name__c, FirstName, LastName, Birthdate, Title, Phone, Email, ';
            contactQuery += ' MailingCity, MailingCountry, MailingState, MailingStreet, MailingPostalCode, Rep_Auction_Access_Number__c From Contact where Integration_Id__c = \''+contactInfo.integrationId+'\' ';
            contactQuery += (personIdList.size() > 0)?'OR Person_ID__C in :personIdList':'';
            contactQuery += (aanList.size() > 0)?' OR Rep_Auction_Access_Number__c in :aanList':'';
            contactQuery += (afcDealerIdList.size() > 0)?' OR AFC_Dealer_Id__c in :afcDealerIdList':'';

            // Update all records with that integration id.  If none of them have it, then update if there is a single response. (???)
            result = Database.query(contactQuery);

            if(result.size() == 0){
                // If we cannot find an existing Contact, create a new one
                result.add(new Contact());
            } 

            for(Contact c : result){
                upsertContactInfo(c,contactInfo);
            }
            upsert result;

               //if(cont.COSMOS_Id != null && cont.COSMOS_Id !='') {
               //     String strCOSMOSId = cont.COSMOS_Id;
               //     strMDM_CrossReferenceId=strMDM_CrossReferenceId+cont.COSMOS_Id+'|';
               //     COSMOSIdList =   strCOSMOSId.split(','); 
               //     //o.setSource_Id__c("AFC-" + (String)map.get("PARTYID"));            // e.g. AFC-433084 Ali Abbasi  

               //     for ( Integer cnt = 0;cnt < COSMOSIdList.size() ; cnt++ ){
               //         COSMOSIdList[cnt]='AFC-'+COSMOSIdList[cnt]; 
               //     } 
               //     query = query + ' OR Source_Id__c in :COSMOSIdList ';
               // } 
        }
        return result;
    }

    webService static List<Account> createAccount(List<AccountInfo> ListOfAccounts) {
        List<Account> result = new List<Account>();

        // The initial implementation will assume a single record sent at one time (per the MDM team).
        if(listOfAccounts.size() > 0){
            // Transform the new data into an MDMServiceHelper object
            MDMServiceHelper.MDMAccount mdmAccount = getMDMAccount(listOfAccounts[0]);
            // Query all Accounts that might match the record (by any key)

            AccountInfo accountInfo = listOfAccounts[0];
            List<String> aanIdList = (accountInfo == null)?new List<String>():accountInfo.auctionAccessID.split(',');
            List<String> openlaneOrgIdList = (accountInfo == null)?new List<String>():accountInfo.OPENLANE_Id.split(',');
            List<String> afcDealerIdList = (accountInfo == null)?new List<String>():accountInfo.COSMOS_Id.split(',');

            String accountQuery = 'select id, Name, Integration_Id__c, Auction_Access_Number__c, Tax_Identification_Number__c, Dba__c,Legal_Name__c, AFC_Dealer_Id__c, ATC_Organization_ID__c, Openlane_Org_Id__c,';
            accountQuery += 'BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, phone, fax, Mdm_Refresh_Date__c, Mdm_Compliant__c from Account where Integration_Id__c = \''+mdmAccount.integrationId+'\' ';
            accountQuery += (aanIdList.size() > 0)?'OR Auction_Access_Number__c in :aanIdList':'';
            accountQuery += (openlaneOrgIdList.size() > 0)?' OR Openlane_Org_Id__c in :openlaneOrgIdList':'';
            accountQuery += (afcDealerIdList.size() > 0)?' OR AFC_Dealer_Id__c in :afcDealerIdList':'';

            // Update all records with that integration id.  If none of them have it, then update if there is a single response. (???)
            result = Database.query(accountQuery);

            if(result.size() == 0){
                // If we cannot find an existing Account, create a new one
                result.add(MDMServiceHelper.updateAccountValues(new Account(),mdmAccount));
            } else {
                // If there is more than one record with one of the key elements from the incoming Account, they are ALL
                // updated AND a new Stewardship Case is created to research the possible duplicate.
                List<Id> accountIdList = new List<Id>();
                for(Account a : result){
                    MDMServiceHelper.updateAccountValues(a, mdmAccount);
                    accountIdList.add(a.id);
                }
                if(result.size() > 1){
                    StewardshipHelper.createPossibleDuplicatesCase(mdmAccount.integrationId,accountIdList);
                }
            }
            upsert result;
        }
        return result;
    }

    private static MDMServiceHelper.MDMAccount getMDMAccount(AccountInfo accountInfo){
        MDMServiceHelper.MDMAccount result = new MDMServiceHelper.MDMAccount();
        result.dbaName = accountInfo.customerName;
        result.legalName = accountInfo.customerLegalName;
        result.phone = accountInfo.phoneNumber;
        result.fax = accountInfo.faxNumber;
        result.taxIdNumber = accountInfo.federalTaxId;
        result.accountType = accountInfo.accountType;
        result.auctionAccessNumber = accountInfo.auctionAccessID;
        result.integrationId = accountInfo.integrationID;
        result.afcDealerId = accountInfo.COSMOS_Id;
        result.openlaneOrgId = accountInfo.OPENLANE_Id;

        MDMServiceHelper.MDMAccountAddress address = new MDMServiceHelper.MDMAccountAddress();
        address.isPrimary = true;
        address.streetAddress = accountInfo.addressLine1 + ' ' + accountInfo.addressLine2;
        address.city = accountInfo.city;
        address.state = accountInfo.state;
        address.postalCode = accountInfo.zipcode;
        address.country = accountInfo.country;

        result.addressList.add(address);
        return result;
    }

    private static void upsertContactInfo(Contact c , ContactInfo ci){
        c.Integration_ID__c = ci.integrationID ;
        c.Mdm_ID__c = ci.partyUID;
        c.Active__c = ci.activeflg  ;
        c.FirstName = ci.firstName ;                               
        c.LastName = ci.lastName ;             
        c.Deceased__c = ci.deceasedIndicator ;
        c.Phone = ci.PrimaryWorkPhone ;                            
        c.Rep_Auction_Access_Number__c  = ci.auctionAccessID ;     
        c.MailingStreet = ci.addressLine1 + ' ' + ci.addressLine2;   
        c.MailingCity = ci.City ;                                    
        c.MailingState = ci.state;                        
        c.MailingPostalCode = ci.zipcode ;                     
        c.MailingCountry = ci.country ;
        c.Birthdate = ci.birthDate ;                               
        c.Middle_Name__c = ci.middleName ;
        c.Title = ci.jobTitle ;
        c.Email = ci.emailAddress ;        
    }
}