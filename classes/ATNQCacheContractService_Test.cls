@isTest
private class ATNQCacheContractService_Test {
    public static Contact con;
    
    public static void setup(){
        // create Autoniq Account
        Autoniq_Account__c aac = new Autoniq_Account__c();
        aac.Name = 'test';
        insert aac;
        system.assertEquals(aac.id != null,true);

        // create contact
        con = new Contact(FirstName   = 'test', 
                                LastName    = 'test',
                                Email       = 'testUser@abc.com',
                                Autoniq_User_ID__c  = 'testuserId1',
                                MobilePhone         = '1234567890',
                                Alternate_Phone__c  = '1212121212',
                                Internal_User__c    = true,
                                Internal_User_ID__c = '1234',
                                Rep_Auction_Access_Number__c = '123',
                                Autoniq_Account__c = aac.Id);
        insert con;
        system.assertEquals(con.id != null,true);

        // create user application setting
        Autoniq_User_Applilcation_Setting__c uas = new Autoniq_User_Applilcation_Setting__c(Vehicle_Selector_Style__c = 'NADA',
                                                                                            Valuation_region__c = 'Home',
                                                                                            Default_Black_Book__c = 'Retail',
                                                                                            Default_NADA__c = 'Auction',
                                                                                            Default_Kelley_Blue_Book__c = 'Auction',
                                                                                            Contact__c = con.Id );

        insert uas;
        system.assertEquals(uas.id != null,true);
        
        
        //create Subscription
        Subscription__c sub = new Subscription__c(Promo_Code__c = 'test',
                                                  Status__c = Constants.SUBSCRIPTION_STATUS_ACTIVE,
                                                  Autoniq_Account__c = aac.Id,
                                                  Contact__c = con.Id,
                                                  Next_Bill_Date__c = system.today());
        insert sub;
        system.assertEquals(sub.id != null,true);
        
        // create Payment Profile
        Autoniq_Subscription_Payment_Profile__c  pp = new Autoniq_Subscription_Payment_Profile__c(
                                                        Payment_Type__c= 'Credit Card',
                                                        Credit_Card_Type__c = 'Visa',
                                                        Autoniq_Subscription__c =sub.Id,
                                                        CC_Expiration_Date__c  = '11/28');
        insert pp;
        system.assertEquals(pp.id != null,true);

        //create products
        
        Product2 p_CarFax = new Product2(Name = 'CarFax',ProductCode = 'test');
        insert p_CarFax ;
        system.assertEquals(p_CarFax.id != null,true);

        Product2 p_AutoCheck = new Product2(Name = 'AutoCheck',ProductCode = 'test');
        insert p_AutoCheck ;
        system.assertEquals(p_AutoCheck.id != null,true);

        Product2 p_AAX_Integration = new Product2(Name = 'AAX Integration',ProductCode = 'test');
        insert p_AAX_Integration ;
        system.assertEquals(p_AAX_Integration.id != null,true);

        //create Subscription Item and Third Party Item
        Product2 carfaxProd = CacheContractUtil.getProductNameMap().get('CarFax');
        Subscription_Item__c si_CarFax = new Subscription_Item__c(Product__c=carfaxProd.Id, iSActive__c = true, Subscription__c=sub.Id, Start_Date__c = Date.today());
        insert si_CarFax;

        Autoniq_Third_Party_Item__c atpi_CarFax = CacheContractUtil.createThirdPartyItem(si_CarFax,'TestCarfaxId', 'TestCarfaxPasswd', 'True', '');
        system.assertEquals(atpi_CarFax.id != null,true);

        Product2 autoCheckProd = CacheContractUtil.getProductNameMap().get('AutoCheck');
        Subscription_Item__c si_AutoCheck = new Subscription_Item__c(Product__c=autoCheckProd.Id, iSActive__c = true, Subscription__c=sub.Id);
        insert si_AutoCheck;

        Autoniq_Third_Party_Item__c atpi_AutoCheck = CacheContractUtil.createThirdPartyItem(si_AutoCheck,'TestAutoCheckId', 'TestAutoCheckPasswd', 'True', '');
        system.assertEquals(atpi_AutoCheck.id != null,true);

        Product2 aaxProd = CacheContractUtil.getProductNameMap().get('AAX Integration');
        Subscription_Item__c si_AAX_Integration = new Subscription_Item__c(Product__c=aaxProd.Id, iSActive__c = true, Subscription__c=sub.Id);
        insert si_AAX_Integration;

        Autoniq_Third_Party_Item__c atpi_AAX_Integration = CacheContractUtil.createThirdPartyItem(si_AAX_Integration,'TestAAX_IntegrationId', 'TestAAX_IntegrationPasswd', 'True', '');
        system.assertEquals(atpi_AAX_Integration.id != null,true);

    }
    
     @isTest
    private static void processParameterGetTest(){
        setup(); 
        ATNQCacheContractService.processParameterGet('testuserId1');
    }
    
    @isTest
    private static void processKeyForGetTest(){
        
        List<Product2> prodList = new List<Product2>();
        Product2 p1 = new Product2(Family='Products', ProductCode='CF',Name='CarsFax');
        Product2 p2 = new Product2(Family='Products', ProductCode='AC',Name='AutoCheck');
        Product2 p3 = new Product2(Family='Products', ProductCode='AAX',Name='AAX Integration');
        prodList.add(p1);
        prodList.add(p2);
        prodList.add(p3);
        insert prodList;
        
        String json1 = CacheContractUtil.getIndexedCacheContract(1);
        
        String json2 = CacheContractUtil.getIndexedCacheContract(2);
        
        String json3 = CacheContractUtil.getIndexedCacheContract(3);
        
        String json4 = CacheContractUtil.getIndexedCacheContract(4);
        
        ATNQCacheContractService.processPost(json1);        
        ATNQCacheContractService.processPost(json2);        
        ATNQCacheContractService.processPost(json3);        
        ATNQCacheContractService.processPost(json4); 
        list<Contact> conList = [SELECT FirstName, LastName, Email, Alternate_Email__c, MobilePhone, Alternate_Phone__c,
                                            Rep_Auction_Access_Number__c, Autoniq_User_ID__c, Internal_User__c, OtherPhone,
                                            Autoniq_Account__c, Autoniq_Account__r.Name, Internal_User_ID__c,
                                            Autoniq_Account__r.Auction_Access_Number__c, Autoniq_Account__r.Street__c, 
                                            Autoniq_Account__r.City__c, Autoniq_Account__r.State__c, Autoniq_Account__r.PostalCode__c, 
                                            Autoniq_Account__r.Country__c 
                                            FROM Contact
                                        ];
        System.debug('==================> conList size: ' + conList.size());
        System.debug('==================> conList : ' + conList);
        String CacheJson = CacheContractUtil.getIndexedCacheContract(1);
        CacheJson = CacheJson.replace('""', 'null');
        CacheContract cache = (CacheContract) JSON.deserialize(CacheJson, CacheContract.class);
        System.debug('====================> cache.userDetail.autoniqUserId: ' + cache.userDetail.autoniqUserId);
        Autoniq_Account__c aac = new Autoniq_Account__c();
        aac.Name = 'test';
        insert aac;
        Contact con = new Contact(FirstName   = 'test', 
                                LastName    = 'test',
                                Email       = 'testUser@abc.com',
                                Autoniq_User_ID__c  = 'testuserId1',
                                MobilePhone         = '1234567890',
                                Alternate_Phone__c  = '1212121212',
                                Internal_User__c    = true,
                                Internal_User_ID__c = '1234',
                                Rep_Auction_Access_Number__c = '123',
                                Autoniq_Account__c = aac.Id);
        insert con;
        Test.startTest();
        ATNQCacheContractService.processKeyForGet('profile', cache);
        Test.stopTest();
    }

    @isTest static void unitTest1() {
        setup();
        CacheContract cc = new CacheContract();
        cc.userDetail = createCacheContract_UserDetail();
        
        cc.accountDetail = createCacheContract_AccountDetail();

        //preferences
        CacheContract.Preferences uas = new CacheContract.Preferences();
        cc.preferences = uas;

        //payment profile
        CacheContract.PaymentProfile pp = new CacheContract.PaymentProfile();
        pp.billingFirstName = 'BillingFName';
        pp.billingLastName = 'BillingLName';
        pp.billingAddress1 = '123 BillingAddress';
        pp.billingAddress2 = 'BillingAddress2';
        pp.billingCity = 'BillingCity';
        pp.billingState = 'BillingState';
        pp.billingCountry = 'US';
        pp.billingZip = '60626';
        pp.creditCardCode = '626'; 
        pp.paymentType = 'Credit Card';
        pp.creditCardType = 'Visa';
        pp.ccExp='11/26';
        cc.paymentProfile = pp;
        
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'paymentProfile', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }
    
    // No payment profile
    @isTest static void unitTest2() {
        setup();
        delete [SELECT id FROM Autoniq_Subscription_Payment_Profile__c ];
        CacheContract cc = new CacheContract();

        cc.userDetail = createCacheContract_UserDetail();

        //accountDetail
        CacheContract.AccountDetail ad = new CacheContract.AccountDetail();
        ad.address = 'test';
        cc.accountDetail = ad;
        
        //payment profile
        CacheContract.PaymentProfile pp = new CacheContract.PaymentProfile();
        pp.billingFirstName = 'BillingFName';
        pp.billingLastName = 'BillingLName';
        pp.billingAddress1 = '123 BillingAddress';
        pp.billingAddress2 = 'BillingAddress2';
        pp.billingCity = 'BillingCity';
        pp.billingState = 'BillingState';
        pp.billingCountry = 'US';
        pp.billingZip = '60626';
        pp.creditCardCode = '626'; 
        pp.paymentType = 'Credit Card';
        pp.creditCardType = 'Visa';
        pp.ccExp='11/26';
        cc.paymentProfile = pp;
        
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'paymentProfile', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }
    
    // No Autoniq Contact for Billing Details
    @isTest static void unitTest3() {
        setup();
        delete [SELECT id FROM Contact WHERE Autoniq_User_Id__c = 'testuserId1'];
        CacheContract cc = new CacheContract();

        cc.userDetail = createCacheContract_UserDetail();

        cc.accountDetail = createCacheContract_AccountDetail();
        
        //payment profile
        CacheContract.PaymentProfile pp = new CacheContract.PaymentProfile();
        pp.billingFirstName = 'BillingFName';
        pp.billingLastName = 'BillingLName';
        pp.billingAddress1 = '123 BillingAddress';
        pp.billingAddress2 = 'BillingAddress2';
        pp.billingCity = 'BillingCity';
        pp.billingState = 'BillingState';
        pp.billingCountry = 'US';
        pp.billingZip = '60626';
        pp.creditCardCode = '626'; 
        pp.paymentType = 'Credit Card';
        pp.creditCardType = 'Visa';
        pp.ccExp='11/26';
        cc.paymentProfile = pp;
        
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'paymentProfile', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }
    
    
    
    // Update Integrations
    @isTest static void unitTest4() {
        setup();
        CacheContract cc = new CacheContract();

        cc.userDetail = createCacheContract_UserDetail();
        
        cc.accountDetail = createCacheContract_AccountDetail();
        
        cc.VhrSettings = createCacheContract_VhrSettings();
        
        cc.aax = createCacheContract_Aax();
        
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'integrations', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }
    
    // No ATNQ 3rd party item CarFax
    @isTest static void unitTest5() {
        setup();
        // Test service
        delete [select id from Autoniq_Third_Party_Item__c where Autoniq_Subscription_Item__r.Product__r.Name = 'CarFax'];
        
        CacheContract cc = new CacheContract();

        cc.userDetail = createCacheContract_UserDetail();
        
        cc.accountDetail = createCacheContract_AccountDetail();
        
        cc.VhrSettings = createCacheContract_VhrSettings();
        
        cc.aax = createCacheContract_Aax();
        
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'integrations', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }

    // No Subscription Item for CarFax
    @isTest static void unitTest6() {
        setup();
        // Test service
        delete [select id from Subscription_Item__c where Product__r.Name = 'CarFax'];
        
        CacheContract cc = new CacheContract();
        
        cc.userDetail = createCacheContract_UserDetail();
        
        cc.accountDetail = createCacheContract_AccountDetail();
        
        cc.VhrSettings = createCacheContract_VhrSettings();
        
        cc.aax = createCacheContract_Aax();
        
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'integrations', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }
    // No Subscription Item under CONTACT
    @isTest static void unitTest7() {
        setup();
        // Test service
        delete [select id from Subscription_Item__c];
        
        CacheContract cc = new CacheContract();

        cc.userDetail = createCacheContract_UserDetail();
        
        cc.accountDetail = createCacheContract_AccountDetail();
        
        cc.VhrSettings = createCacheContract_VhrSettings();
        
        cc.aax = createCacheContract_Aax();
        
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'integrations', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }
    
     // No Contact for Integrations
    @isTest static void unitTest8() {
         setup();
        // Test service
        delete [select id from Contact WHERE Autoniq_User_Id__c = 'testuserId1'];
        
        CacheContract cc = new CacheContract();

        cc.userDetail = createCacheContract_UserDetail();
        
        cc.accountDetail = createCacheContract_AccountDetail();
       
        cc.VhrSettings = createCacheContract_VhrSettings();
        
        cc.aax = createCacheContract_Aax();
        
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'integrations', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }
    
    // No Subscription Item for AutoCheck
    @isTest static void unitTest9() {
        setup();
        // Test service
        delete [select id from Subscription_Item__c where Product__r.Name = 'AutoCheck'];
        
        CacheContract cc = new CacheContract();

        cc.userDetail = createCacheContract_UserDetail();
        
        cc.accountDetail = createCacheContract_AccountDetail();
       
        cc.VhrSettings = createCacheContract_VhrSettings();
        
        cc.aax = createCacheContract_Aax();
        
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'integrations', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }
    
    // No ATNQ 3rd party item AutoCheck
    @isTest static void unitTest10() {
        setup();
        // Test service
        delete [select id from Autoniq_Third_Party_Item__c where Autoniq_Subscription_Item__r.Product__r.Name = 'AutoCheck'];
        
        CacheContract cc = new CacheContract();

        cc.userDetail = createCacheContract_UserDetail();
        
        cc.accountDetail = createCacheContract_AccountDetail();
       
        cc.VhrSettings = createCacheContract_VhrSettings();
        
        cc.aax = createCacheContract_Aax();
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'integrations', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }
    
    //No 3rd Party Item for AAX Integration
    @isTest static void unitTest11() {
        setup();
        // Test service
        delete [select id from Autoniq_Third_Party_Item__c where Autoniq_Subscription_Item__r.Product__r.Name = 'AAX Integration'];
        
        CacheContract cc = new CacheContract();

        cc.userDetail = createCacheContract_UserDetail();
        
        cc.accountDetail = createCacheContract_AccountDetail();
       
        cc.VhrSettings = createCacheContract_VhrSettings();
        
        cc.aax = createCacheContract_Aax();
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'integrations', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }

// No Subscription Item for AAX Integration
    @isTest static void unitTest12() {
        setup();
        // Test service
        delete [select id from Subscription_Item__c where Product__r.Name = 'AAX Integration'];
        
        CacheContract cc = new CacheContract();

        cc.userDetail = createCacheContract_UserDetail();
        
        cc.accountDetail = createCacheContract_AccountDetail();
       
        cc.VhrSettings = createCacheContract_VhrSettings();
        
        cc.aax = createCacheContract_Aax();
        
        string cc_json = JSON.serialize(cc);
        
        Test.startTest();
        testSetRestRequestContext(cc.userDetail.autoniqUserId, 'integrations', cc_json, 'PUT');
        ATNQCacheContractService.doPutNew();
        Test.stopTest();
    }    

    @isTest
    private static void populateUserDetailTest(){

        ATNQJsonParserUtil util = new ATNQJsonParserUtil();
        Contact c;
        c = (Contact)util.converJasonToSFsObject(jsonUserDetail,'Contact',util.jsonUserDetailToContactMap);
        CacheContractUtil.populateUserDetail(c);                                      
    } 
    @isTest 
    private static void populateAccountDetailTest(){
        
        CacheContract c = new CacheContract();
        //getIndexedAAccoount
        c.accountDetail = ATNQCacheContractService_Test.createCacheContract_AccountDetail();

        Autoniq_Account__c a = ATNQCacheContractService_Test.getTestAutoniqAccount();
        CacheContractUtil.populateAccountDetail( c,  a);                                      
    } 
    @isTest 
    private static void populateAccountDetailTest2(){
        Autoniq_Account__c a = getTestAutoniqAccount();
        CacheContractUtil.populateAccountDetail(a);                                      
    } 
    @isTest 
    private static void clearAccountDetailTest(){
        CacheContract c = getIndexedCacheContract();
        CacheContractUtil.clearAccountDetail(c);                                      
    } 
    @isTest 
    private static void populatePreferencesTest(){
        CacheContract c = getIndexedCacheContract();
        CacheContractUtil.populatePreferences(c);                                      
    } 
    @isTest 
    private static void clearPreferencesTest(){
        CacheContract c = getIndexedCacheContract();
        CacheContractUtil.clearPreferences(c);                                      
    } 
    @isTest 
    private static void createContactTest(){
        CacheContract c = getIndexedCacheContract();
        CacheContractUtil.createContact(c.userDetail);                                      
    } 
    @isTest 
    private static void updateContactTest(){
        ATNQJsonParserUtil util = new ATNQJsonParserUtil();
        Contact c;
        c = (Contact)util.converJasonToSFsObject(jsonUserDetail,'Contact',util.jsonUserDetailToContactMap);
        insert c;
        CacheContract cache = getIndexedCacheContract();
        CacheContract.UserDetail u = cache.userDetail;
        u.id = c.Id;
        CacheContractUtil.updateContact(c,u);                                      
    } 
    @isTest 
    private static void createAccountTest(){
        CacheContract contract;
        CacheContractUtil.createAccount(contract);                                      
    } 
    @isTest 
    private static void populateCAutoniqAccountObjectTest(){
        CacheContract.AccountDetail aac = createCacheContract_AccountDetail();
        Autoniq_Account__c account = ATNQCacheContractService_Test.getTestAutoniqAccount();
        CacheContractUtil.populateCAutoniqAccountObject(aac,account);                                      
    } 
    @isTest
    private static void updateAutoniqAccountTest(){
        CacheContract contract = getIndexedCacheContract();
        CacheContractUtil.updateAutoniqAccount(contract) ;                                     
    } 
    @isTest
    private static void updateAutoniqAccountTest2(){
        CacheContract contract = getIndexedCacheContract();
        String autoniqUserId;
        CacheContractUtil.updateAutoniqAccount(contract, autoniqUserId);                                      
    } 
    @isTest
    private static void updateAutoniqAccountTest3(){
        CacheContract contract = getIndexedCacheContract();
        String autoniqUserId;
        CacheContractUtil.updateAutoniqAccount(contract, autoniqUserId);                                     
    } 
    @isTest
    private static void updateProfileTest(){
        CacheContract contract = getIndexedCacheContract();
        String autoniqUserId;
        CacheContractUtil.updateProfile(contract, autoniqUserId);                                      
    } 
    @isTest
    private static void createContactByUserIdIndexTest(){
        CacheContractUtil.createContactByUserIdIndex(1, 2);                                     
    }
    @isTest
    private static void createAutoniqAccountByNameIndexTest(){
        CacheContractUtil.createAutoniqAccountByNameIndex(2,1);                                      
    }
    @isTest
    private static void getIndexedAAccoountTest(){
        CacheContractUtil.getIndexedAAccoount(3);                                      
    } 
    @isTest
    private static void getIndexedCacheContractUpdateTest(){
        CacheContractUtil.getIndexedCacheContractUpdate(2,3);                                    
    } 
    
    @isTest
    private static void repAuctionAccessNumberTest(){
        User u = getIntegrationUser();
        System.runAs(u) {
            
            CacheContract cache = new CacheContract();
            CacheContract.userDetail ud = new CacheContract.UserDetail();
            ud.autoniqAccountId = 'userId@email.com';
            ud.altEmail = 'altEmail.@test.com';
            ud.altPhone = '3125551234';
            ud.altPhoneCountryCode = 'United States';
            ud.email = 'email@test.com';
            ud.firstName = 'App';
            ud.internalUser = false;
            ud.lastName = 'User';
            ud.mobile = '2025551234';
            ud.mobileCountryCode = 'United States';
            ud.phoneType = 'Android';
            ud.repAuctionAccessNumber = 100000001;
            ud.salutation = 'Mr.';
            
            cache.userDetail = ud;
            
            CacheContract.AccountDetail ad = new CacheContract.AccountDetail();
            
            ad.accountStatus = 'Active';
            ad.accountType = 'Franchise Dealer';
            ad.address = '123 Hemingway Road';
            ad.address2 = 'Apartment 22';
            ad.auctionAccessNumber = '12345';
            ad.autoniqAccountName = 'My Dealership';
            ad.city = 'Chicago';
            ad.country = 'United States';
            ad.email = 'dealer@email.com';
            ad.postCode = '60061';
            ad.state = 'Illinois';
            ad.referrer = 'myself';
            
            cache.accountDetail = ad;
            
            Autoniq_Account__c aa = CacheContractUtil.createAutoniqAccount(cache); 
            Contact c = CacheContractUtil.createContact(cache);
            c.Autoniq_Account__c = aa.Id;
            Test.startTest();
            insert c;
             
            Contact insertedContact = [Select Id, Autoniq_User_Id__c, Rep_Auction_Access_Number__c,MailingAddress,MA_Clean_State__c,Active__c,Corrected_Mobile__c from Contact Where Autoniq_User_Id__c =: ud.autoniqUserId ];
            System.debug('Contact Read Back, rep Auction Access Number: ' + insertedContact.Rep_Auction_Access_Number__c);
            System.debug('Contact Read Back, MailingAddress: ' + insertedContact.MailingAddress);
            System.debug('Contact Read Back, Mailing State: ' + insertedContact.MA_Clean_State__c);
            System.debug('Contact Read Back, Active: ' + insertedContact.Active__c);
            System.debug('Contact Read Back, Corrected Mobile: ' + insertedContact.Corrected_Mobile__c);
            System.debug('Contact Read Back, UserDetail repAuctionAccessNumber: ' + ud.repAuctionAccessNumber);
            System.assert(insertedContact.Rep_Auction_Access_Number__c==String.valueOf(ud.repAuctionAccessNumber),'Expected ' + ud.repAuctionAccessNumber + ' Actual value: ' + insertedContact.Rep_Auction_Access_Number__c);
            Test.stopTest();
        }
    }
    
    private static Autoniq_Account__c createAutoniqAccount(CacheContract cache){
        Autoniq_Account__c aa = CacheContractUtil.createAutoniqAccount(cache);
        return aa;
    }
    
    private static User getIntegrationUser(){
        
        String uniqueUserName = 'integrate@email.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Integration'];
        User u = new User(Alias = 'aint', Email='autoniq.integration@testorg.com',
            EmailEncodingKey='UTF-8', LastName='integration', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Chicago',
            CommunityNickname = 'My Community',
            UserName=uniqueUserName);
        
        insert u;
        return u;
    }
    
    private static Autoniq_User_Applilcation_Setting__c getTestAutoniqUserApplicationSettings(){
        Autoniq_User_Applilcation_Setting__c uas = new Autoniq_User_Applilcation_Setting__c(Vehicle_Selector_Style__c = 'NADA',
            Valuation_region__c = 'Home',
            Default_Black_Book__c = 'Retail',
            Default_NADA__c = 'Auction',
            Default_Kelley_Blue_Book__c = 'Auction',
            Contact__c = con.Id );
        insert uas;
        return uas;
    }                                  
    
    private static Autoniq_Account__c getTestAutoniqAccount(){
        Autoniq_Account__c aac = new Autoniq_Account__c();
        aac.Name = 'test';
        insert aac;
        return aac;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
                                     
                                      
    public static void testSetRestRequestContext(string autoniqUserId, string key, string requestBody, string httpMethod){
        RestRequest req = new RestRequest();
        RestContext.response = new RestResponse();
        string reqUrl = '/services/apexrest/autoniq/cacheContract/'+key;
        req.requestURI = reqUrl; 
        req.httpMethod = httpMethod;
        req.requestBody = Blob.valueOf(requestBody);
        req.addParameter('autoniqUserId',autoniqUserId);
        RestContext.request = req;
    }
    
        public static CacheContract.UserDetail createCacheContract_UserDetail(){
        CacheContract.UserDetail ud = new CacheContract.UserDetail();
        ud.id = con.id;
        ud.lastName = 'test';
        ud.autoniqUserId = 'testuserId1';
        return ud;
    }
    public static CacheContract.AccountDetail createCacheContract_AccountDetail(){
        CacheContract.AccountDetail ad = new CacheContract.AccountDetail();
        ad.address = 'test';
        return ad;
    }
    
    public static CacheContract.VhrSettings createCacheContract_VhrSettings(){
        CacheContract.VhrSettings vhr = new CacheContract.VhrSettings();
        vhr.carfaxId = 'C521092345';
        vhr.carfaxPasswd = 'pass12345';
        vhr.carfaxAutoPurchase = false;
        vhr.carfaxEnabled = true;
        
        vhr.autoCheckId = 'C521092345';
        vhr.autoCheckPasswd = 'pass12345';
        vhr.autoCheckAutoPurchase = false;
        vhr.autoCheckEnabled = true;
        return vhr;
    }
    
    private static CacheContract getIndexedCacheContract(){
        String rawJson = CacheContractUtil.getIndexedCacheContract(1);
        return (CacheContract) JSON.deserialize(rawJson, CacheContract.class);
    }
    
    public static CacheContract.Aax createCacheContract_Aax(){
        CacheContract.Aax aax = new CacheContract.Aax();
        aax.aaxSecurityToken = '786848';
        aax.aaxClientId = '90975';
        aax.aaxDealerId = '7854489';
        aax.aaxUserId = '5636278';
        return aax;
    }
    
    private static final String userFirstName   = 'uFname';
    private static final String userLastName    = 'uLname';
    private static final String userMobile      = '8475551234';
    private static final String userAltPhone    = '8475554321';
    private static final String userAltEmail    = 'altUser@email.com';
    private static final String userEmail   = 'user@email.com';
    private static final String userAutoniqUserId = 'usr@autoniq.com';
    private static final String userPasswors    = 'uPassword';
    private static final String userRepAutionAccessNumber = '34567';
    private static final String userUserAuctionAccessNumber = '76543';
    private static final String userInternalUser = 'true';   
    
    private static final String jsonUserDetail = '{"firstName":"' + userFirstName + '","lastName":"' + userLastName + '","mobile":"' + userMobile + '","email":"' + userEmail + '","altEmail":"' + userAltEmail + '","altPhone":"' + userAltPhone + '","autoniqUserId":"' + userAutoniqUserId + '","password":"' + userPasswors + '","repAuctionAccessNumber":"' + userRepAutionAccessNumber + '","userAuctionAccessNumber":"' + userUserAuctionAccessNumber + '","internalUser":' + userInternalUser + '}';
    
}