@RestResource(urlMapping='/autoniq/cacheContract/*')
global class ATNQCacheContractService {
   
    private static String getKeyFromUri(String uri){
        String key;
        String lastSection = uri.substring(uri.lastIndexOf('/')+1);
        if(lastSection.indexOf('?')>0){           
            key =  lastSection.substring(lastSection.lastIndexOf('/')+1, lastSection.lastIndexOf('?')); 
        }else{
            key =  lastSection.substring(lastSection.lastIndexOf('/')+1);                 
        } 
        return key;
    }
    
    public static ATNQCacheContractResponse testResponse;
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        string rawJson = req.requestBody.toString().trim();
        rawJson = rawJson.replace('""', 'null');
        processPost(rawJson);
    }
    
    public static ATNQCacheContractResponse processPost(String rawJson){
        System.debug('=======> rawJson ' + rawJson);
        CacheContract cacheContract;
        //RestRequest req = RestContext.request;
        ATNQCacheContractResponse aResp = new ATNQCacheContractResponse();
        String jsonResponse;
        CacheContract cache;
        try{
            cache = (CacheContract) JSON.deserialize(rawJson, CacheContract.class);
        }Catch(Exception e){
            System.debug('=======> deserialize failed at line ' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString());
            testResponse = CacheContractUtil.setupErrorResponse('deserialization of input json failed', ATNQConstants.JSON_DESERIALIZATION_ERROR,  e.getMessage());
            return testResponse;
        }
        System.debug('=======> jsonMap ' + cache);
        Contact c;
        Autoniq_Account__c aac;
        Autoniq_Account__c existingATNQAccount;
        Subscription__c sub;
        Autoniq_Subscription_Payment_Profile__c spp;
        List<Subscription_Item__c> subItemList;
        
        try{
            CacheContract.UserDetail u = cache.UserDetail;
            List<Contact> existingContacts;
            if(String.ISBLANK(u.autoniqUserId)){
                    testResponse = CacheContractUtil.setupErrorResponse('Autoniq User Id is a required field', ATNQConstants.USER_REQUIRED_FIELD_MISSING_ERROR,  null);
                    return testResponse;
            }
            existingContacts = [select Id,Autoniq_User_ID__c,OtherPhone,FirstName,LastName,Email,Active__c,Password__c,MobilePhone,Alternate_Phone__c,Internal_User__c,Internal_User_ID__c,Rep_Auction_Access_Number__c from Contact where Autoniq_User_ID__c =: u.autoniqUserId limit 1];
            if(existingContacts.size()>0){
                testResponse = CacheContractUtil.setupErrorResponse('Autoniq User Id Already Exists', ATNQConstants.USER_ALREADY_EXISTS_ERROR,  existingContacts[0].Autoniq_User_ID__c);
                return testResponse;
            }

            Savepoint sp = Database.setSavepoint();
            try{

                c = CacheContractUtil.createContact(cache); 
                insert c;
                System.debug('=================> Contact: '+ c);
                System.debug('=================> Contact Query result: ' + [SELECT FirstName, LastName, Email,Alternate_Email__c, MobilePhone, Alternate_Phone__c,
                                    Rep_Auction_Access_Number__c, Autoniq_User_ID__c from Contact where Autoniq_User_ID__c=: u.autoniqUserId]);
                existingATNQAccount = CacheContractUtil.getMatchingATNQAccount(cache);
                boolean usingExistingAutoniqAccount = false;
                if(existingATNQAccount!=null){
                   aac =  existingATNQAccount;
                   usingExistingAutoniqAccount = true;
                }else{
                    aac = CacheContractUtil.createAutoniqAccount(cache);
                }
                System.debug('=================> Autoniq Account: '+ aac);
                c.Autoniq_Account__c = aac.Id;
                c.Process_Identifier__c = 'Autoniq';
                update c;
                System.debug('=================> Updated Contact: '+ c);
                System.debug('=================> Updated Contact Query result: ' + [SELECT FirstName, LastName, Email,Alternate_Email__c, MobilePhone, Alternate_Phone__c,
                                    Rep_Auction_Access_Number__c, Autoniq_User_ID__c from Contact where Autoniq_User_ID__c=: u.autoniqUserId]);
                sub = CacheContractUtil.createSubscription(cache, c.Id, aac.Id);
                System.debug('=================> Subscription: '+ sub);
                
                if(usingExistingAutoniqAccount==true){
                    if(aac.No_Of_Subscriptions__c==null){
                        aac.No_Of_Subscriptions__c = 1;
                    }else{
                        aac.No_Of_Subscriptions__c = aac.No_Of_Subscriptions__c +1;
                    }    
                }
                if(aac.No_Of_Subscriptions__c==null){
                    aac.No_Of_Subscriptions__c = 1;
                }
                update aac;
                if(cache.paymentProfile!=null){
                    spp = CacheContractUtil.createPaymentProfile(cache, sub);
                }
                subItemList = CacheContractUtil.createSubscriptionItems(cache, sub);
                /*
                if(cache.vhrSettings!=null){
                  subItemList = CacheContractUtil.createSubscriptionItems(cache, sub);
                }else{
                    System.debug('=================> No VHR Setting data, skipping Creation of Subscription Items');
                }
                */
            }catch(Exception e){
                Database.RollBack(sp);
                String msg = e.getMessage()
                 + ' - ' + e.getStackTraceString().subString(0,(e.getStackTraceString().length()<200?e.getStackTraceString().length():200));
                System.debug('==========> Exception at line 82: ' + msg);
                testResponse = CacheContractUtil.setupErrorResponse(msg, ATNQConstants.ATNQ_REGISTRATION_OBJECT_CREATION_ERROR, (c!=null?c.Autoniq_User_ID__c:null));
                return testResponse;
            }

            testResponse = CacheContractUtil.setupSuccessResponse(c.Autoniq_User_ID__c);
            return testResponse;
        }Catch(Exception e){
            ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
            String msg = e.getMessage()
                 + ' - ' + e.getStackTraceString().subString(0,(e.getStackTraceString().length()<200?e.getStackTraceString().length():200));
            System.debug('==========> Exception at line 92: ' + msg);
            testResponse = CacheContractUtil.setupErrorResponse(msg, ATNQConstants.ATNQ_ACCOUNT_PROCESSING_EXCEPTION, (c!=null?c.Autoniq_User_ID__c:null));
            return testResponse;
        }
    }
    
        
    @HttpPut
    global static void doPutNew(){
        RestRequest req = RestContext.request;
        String autoniqUserId = req.params.get('autoniqUserId');
        System.debug('======> doPUt parameter: ' + autoniqUserId);
        string rawJson = req.requestBody.toString().trim();
        rawJson = rawJson.replace('""', 'null');
        System.debug('=======> rawJson ' + rawJson);
        //String key = req.params.get('key'); 
        String key = getKeyFromUri(req.requestURI);   
        //String key = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(key!='CacheContract'){
            processPut(rawJson, key, autoniqUserId);
        }else{
            //figure out what chaged in code
        }
    }
    
    public static ATNQCacheContractResponse processPut(String rawJson, String key, String autoniqUserId){
        System.debug('=======> processPut Entered');
        System.debug('=======> processPut key: ' + key);
        System.debug('=======> processPut Id: ' + autoniqUserId);
        System.debug('=======> processPut rawJson: ' + rawJson);
        
        CacheContract cache = (CacheContract) JSON.deserialize(rawJson, CacheContract.class);
        System.debug('=======> processPut jsonMap ' + cache);
        //cache = processKeyForUpdate(key, cache);
        processKeyForUpdate(key, cache, autoniqUserId);
        //CacheContractUtil.setupSuccessResponse(cache.userDetail.autoniqUserId);
        return null;
    }
    
    /*
    global static void doGetOld(){
        ///services/apexrest/autoniq/cacheContract?key=profile&autoniqUserId=testuser123@xyz.com
        RestRequest req = RestContext.request;
        CacheContract cache = new CacheContract();
        String autoniqUserId = RestContext.request.params.get('autoniqUserId');
        String key = RestContext.request.params.get('key');
        //CacheContractUtil.setupSuccessResponse(autoniqUserId+' - '+key);

        //String key = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        cache.userDetail = new CacheContract.UserDetail();
        cache.userDetail.autoniqUserId = autoniqUserId;
        cache = processKeyForGet(key, cache);
        RestContext.response.addHeader('Content-Type', 'application/json');
        if(cache!=null){
            RestContext.response.responseBody = Blob.valueOf(Json.serialize(cache));
        }
    }
    */
    @HttpGet
    global  static void doParameterGet(){
        ///services/apexrest/autoniq/cacheContract?autoniqUserId=testuser123@xyz.com
        RestRequest req = RestContext.request;
        //CacheContract cache = new CacheContract();
        String autoniqUserId = RestContext.request.params.get('autoniqUserId');
        System.debug('=========> user Id: ' + autoniqUserId);
        CacheContract cache = processParameterGet(autoniqUserId);
        System.debug('=========> cache: ' + cache);
        RestContext.response.addHeader('Content-Type', 'application/json');
        if(cache!=null){
            RestContext.response.responseBody = Blob.valueOf(Json.serialize(cache));
        }else{
            ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
            String msg = 'Could not find User';
            testResponse = CacheContractUtil.setupErrorResponse(msg, ATNQConstants.USER_NOT_FOUND_ERROR, null);
        }
        
    }
    
    public static void processKeyForUpdate(String k,CacheContract c, String autoniqUserId){
        System.debug('=========> processKeyForUpdate entered');
        System.debug('=========> processKeyForUpdate k:  ' + k);
        System.debug('=========> processKeyForUpdate Id: ' + autoniqUserId);
        
        System.debug('=========> processKeyForUpdate cache: ' + c);             
        switch on k{
            when 'profile' {
                CacheContractUtil.updateProfile(c, autoniqUserId);
            }
            
           // when 'password' {
               // CacheContractUtil.updatePassword(c);
            //}
            
            when 'PaymentProfile' {
                 CacheContractUtil.updateBillingDetails(c, autoniqUserId);
            }
            
            when 'paymentProfile' {
                 CacheContractUtil.updateBillingDetails(c, autoniqUserId);
            }
            
            //when 'subscriptions' {
                //CacheContractUtil.updateSubscriptions(c);
            //}
            
            when 'integrations' {
                CacheContractUtil.updateIntegrations(c, autoniqUserId);
            }
            
            when else{
                //return;

            }
        }
        
    }
        
    public static CacheContract processKeyForGet(String k, CacheContract c){
        CacheContract result;
        switch on k{
            when 'profile' {// currently GET is only used to get the current values for Contact
                //Populate values for userDetail, and accountDetail and return CachContract
                //CacheContractUtil.setupSuccessResponse(key);
                System.debug('========================> processKeyForGet cache: ' + c);
                list<Contact> conList = [SELECT FirstName, LastName, Email, Alternate_Email__c, MobilePhone, Alternate_Phone__c,
                                            Rep_Auction_Access_Number__c, Autoniq_User_ID__c, Internal_User__c, OtherPhone,
                                            Autoniq_Account__c, Autoniq_Account__r.Name, Internal_User_ID__c,
                                            Autoniq_Account__r.Auction_Access_Number__c, Autoniq_Account__r.Street__c, Autoniq_Account__r.Account_Type__c,
                                            Autoniq_Account__r.City__c, Autoniq_Account__r.State__c, Autoniq_Account__r.PostalCode__c, 
                                            Autoniq_Account__r.Country__c 
                                            FROM Contact WHERE Autoniq_User_ID__c = :c.userDetail.autoniqUserId
                                        ];
                if(conList.size()>0){
                    Contact con = conList[0];
                    c.userDetail.firstName = con.FirstName;
                    c.userDetail.lastName = con.LastName;
                    c.userDetail.email = con.Email;
                    c.userDetail.altEmail = con.Alternate_Email__c;
                    if(!String.isBlank(con.Rep_Auction_Access_Number__c)){
                        c.userDetail.repAuctionAccessNumber = Integer.valueOf(con.Rep_Auction_Access_Number__c);
                    }
                    c.userDetail.mobile = con.MobilePhone;
                    c.userDetail.altPhone = con.Alternate_Phone__c;
                    c.userDetail.autoniqUserId = con.Autoniq_User_ID__c;
                    c.userDetail.internalUser = con.Internal_User__c;
                    if(!String.isBlank(con.Internal_User_ID__c)){
                        c.userDetail.internalUserId = Integer.valueOf(con.Internal_User_ID__c);
                    }
                    if(con.Autoniq_Account__c != null){
                        c.accountDetail = new CacheContract.AccountDetail();
                        c.accountDetail.Id = con.Autoniq_Account__r.Id;
                        c.accountDetail.accountStatus = con.Autoniq_Account__r.AccountStatus__c;
                        c.accountDetail.autoniqAccountName = con.Autoniq_Account__r.Name;
                        c.accountDetail.auctionAccessNumber = con.Autoniq_Account__r.Auction_Access_Number__c;
                        c.accountDetail.address = con.Autoniq_Account__r.Street__c;
                        c.accountDetail.city = con.Autoniq_Account__r.City__c;
                        c.accountDetail.state = con.Autoniq_Account__r.State__c;
                        c.accountDetail.country = con.Autoniq_Account__r.Country__c;
                        c.accountDetail.postCode = con.Autoniq_Account__r.PostalCode__c;
                    }
                    /*else{
                        List<Autoniq_Account__c> aacList = [select Id, ,Account_Type__c,Auction_Access_Number__c, Latitude__c, Longitude__c, Dealership_AuctionACCESS_Number__c, Name, Street__c,Street_2__c,City__c,State__c,Country__c,Email__c,Phone__c,PostalCode__c, No_Of_Subscriptions__c from Autoniq_Account__c where Id=: con.Autoniq_Account__c];    
                        if(aacList.size()>0){
                            c.accountDetail = ATNQJsonParserUtil.createAccountDetailWithAutoniqAccountData(aacList[0]);
                            //c.accountDetail.Id = con.Autoniq_Account__r.Id;
                            c.accountDetail.autoniqAccountName = con.Autoniq_Account__r.Name;
                            c.accountDetail.auctionAccessNumber = con.Autoniq_Account__r.Auction_Access_Number__c;
                            c.accountDetail.address = con.Autoniq_Account__r.Street__c;
                            c.accountDetail.city = con.Autoniq_Account__r.City__c;
                            c.accountDetail.state = con.Autoniq_Account__r.State__c;
                            c.accountDetail.country = con.Autoniq_Account__r.Country__c;
                            c.accountDetail.postCode = con.Autoniq_Account__r.PostalCode__c;
                        }
                    }*/
                    
                }else{
                    ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
                    String msg = 'Could not find User';
                    //CacheContractUtil.setupErrorResponse(msg, ATNQConstants.USER_NOT_FOUND_ERROR, (c!=null?c.Id:null));
                    testResponse = CacheContractUtil.setupErrorResponse(msg, ATNQConstants.USER_NOT_FOUND_ERROR, null);
                    c = null;
                }
                result = c;
            }       
        }
        return result;
    }
    
    public static  CacheContract processParameterGet(String autoniqUserId){ 
        CacheContract c = new CacheContract();
        c.userDetail = new CacheContract.UserDetail();
        c.accountDetail = new CacheContract.AccountDetail();
        
        list<Contact> conList = [SELECT FirstName, LastName, Email,Alternate_Email__c, MobilePhone, Alternate_Phone__c,
                                    Rep_Auction_Access_Number__c, Autoniq_User_ID__c, Internal_User__c, OtherPhone,
                                    Autoniq_Account__c, Autoniq_Account__r.Name, Internal_User_ID__c,Autoniq_Account__r.AccountStatus__c,
                                    Autoniq_Account__r.Auction_Access_Number__c, Autoniq_Account__r.Street__c, 
                                    Autoniq_Account__r.City__c, Autoniq_Account__r.State__c, Autoniq_Account__r.PostalCode__c, 
                                    Autoniq_Account__r.Country__c
                                FROM Contact WHERE Autoniq_User_ID__c = :autoniqUserId];
        System.debug('========> contact List: ' + conList);
                if(!conList.isEmpty()){
                    Contact con = conList[0];
                    c.userDetail.firstName = con.FirstName;
                    c.userDetail.lastName = con.LastName;
                    c.userDetail.autoniqUserId = con.Autoniq_User_ID__c;
                    c.userDetail.email = con.Email;
                    c.userDetail.altEmail = con.Alternate_Email__c;
                    if(con.Rep_Auction_Access_Number__c!=null){
                        c.userDetail.repAuctionAccessNumber = Integer.valueOf(con.Rep_Auction_Access_Number__c);
                    }
                    c.userDetail.mobile = con.MobilePhone;
                    c.userDetail.altPhone = con.Alternate_Phone__c;
                    c.userDetail.autoniqAccountId = con.Autoniq_Account__c;
                    c.userDetail.internalUser = con.Internal_User__c;
                    //c.userDetail.internalUserId = Integer.valueOf(con.Internal_User_ID__c);

                System.debug('========> Cache User: ' + c);
                    if(con.Autoniq_Account__c != null){
                        
                        c = ATNQQueryUtil.getLatestCacheContractForContact(con);
                        /*
                        c.accountDetail = new CacheContract.AccountDetail();
                        c.accountDetail.id = con.Autoniq_Account__r.id;
                        c.accountDetail.autoniqAccountName = con.Autoniq_Account__r.Name;
                        c.accountDetail.auctionAccessNumber = con.Autoniq_Account__r.Auction_Access_Number__c;
                        c.accountDetail.address = con.Autoniq_Account__r.Street__c;
                        c.accountDetail.city = con.Autoniq_Account__r.City__c;
                        c.accountDetail.state = con.Autoniq_Account__r.State__c;
                        c.accountDetail.country = con.Autoniq_Account__r.Country__c;
                        c.accountDetail.postCode = con.Autoniq_Account__r.PostalCode__c;
                        */
                        
                    }
                    System.debug('========> Cache Autoniq Account: ' + c);
                }else{
                    c = null;
                }
            return c;
            }       
}