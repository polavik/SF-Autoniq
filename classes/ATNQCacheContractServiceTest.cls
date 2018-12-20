@isTest
public class ATNQCacheContractServiceTest {
    
    private static List<Product2> prods;
    @testSetup
    private static void setupCommonObjects(){
        prods = createProducts();
    }
    
    @isTest
    private static void processPostTest(){
        CacheContract cache = new CacheContract();
        CacheContract.UserDetail u = getOriginalUserDetail();
        cache.userDetail = u;
        CacheContract.AccountDetail a = getOriginalAccountDetail();
        cache.accountDetail = a;
        cache.PaymentProfile = getOriginalPaymentProfile();
        cache.subscriptionItems = getOriginalSubscriptionItems();
        String rawJson = Json.serialize(cache);
        Test.startTest();
        ATNQCacheContractService.processPost(rawJson);
        List<Contact> contactList = [Select FirstName, 
                                     		LastName, 
                                     		MobilePhone,
                                     		Email, 
                                     		Alternate_Phone__c, 
                                     		OtherPhone,
                                     		Internal_User__c,
                                     		Rep_Auction_Access_Number__c 
                                    From Contact limit 100];
        List<Autoniq_Account__c> acountList = [Select 
                                                Dealership_AuctionACCESS_Number__c,
												Street__c,
                                                Street_2__c,
                                               	City__c,
                                                Country__c,
                                                Email__c,
                                                Phone__c,
                                                PostalCode__C
                                               From Autoniq_Account__c limit 100
                                              ];
        System.assert(acountList.size()==1,'Expecting 1, actual number of Accounts created: ' + acountList.size());
        System.debug('==========> number of accounts created: ' + acountList.size());
        System.debug('==========> contactList: ' + acountList);
        Autoniq_Account__c aac = acountList[0];
        
        System.assert(contactList.size()==1,'Expecting 1, actual number of contacts created: ' + contactList.size());
        System.debug('==========> number of contacts created: ' + contactList.size());
        System.debug('==========> contactList: ' + contactList);
        Contact c = contactList[0];
        System.debug('==========> contact[0]: ' + c);
        System.assert(UserAndContactHaveTheSameValues(u, c));
        System.assert(AccountDetailsAndAutoniqAccountHaveTheSameValues(a, aac));
        Test.stopTest();
        
        
    }
    
    @isTest
    private static void processPostNullJsonTest(){

        Test.startTest();
        ATNQCacheContractResponse res = ATNQCacheContractService.processPost(null);
        System.assert(res.resp.errors[0].source == ATNQConstants.JSON_DESERIALIZATION_ERROR);
        System.assert(res.resp.errors[0].message == ATNQConstants.JSON_DESERIALIZATION_ERROR_MSG);
        System.assert(res.resp.success==false);
        System.debug('=======> res: ' + ATNQCacheContractService.testResponse);
        Test.stopTest();
    }
    
    @isTest
    private static void processPutTest(){
        CacheContract cache = new CacheContract();
        CacheContract.UserDetail u = getOriginalUserDetail();
        cache.userDetail = u;
        CacheContract.AccountDetail a = getOriginalAccountDetail();
        cache.accountDetail = a;
        cache.PaymentProfile = getOriginalPaymentProfile();
        cache.subscriptionItems = getOriginalSubscriptionItems();
        String rawJson = Json.serialize(cache);
        ATNQCacheContractService.processPost(rawJson);
        
        List<Contact> oContactList = [Select FirstName, 
                                     		LastName, 
                                     		MobilePhone,
                                     		Email, 
                                     		Alternate_Phone__c, 
                                      		OtherPhone,
                                     		Internal_User__c,
                                     		Rep_Auction_Access_Number__c 
                                    From Contact limit 100];
        List<Autoniq_Account__c> oAcountList = [Select 
                                                Dealership_AuctionACCESS_Number__c,
												Street__c,
                                                Street_2__c,
                                               	City__c,
                                                Country__c,
                                                Email__c,
                                                Phone__c,
                                                PostalCode__C
                                               From Autoniq_Account__c limit 100
                                              ];
        
        CacheContract updatedCache = new CacheContract();
        CacheContract.UserDetail uu = getUpdatedUserDetails();
        updatedCache.userDetail = uu;
        CacheContract.AccountDetail ua = getUpdatedAccountDetail();
        updatedCache.accountDetail = ua;
        updatedCache.PaymentProfile = getUpdatedPaymentProfile();
        updatedCache.subscriptionItems = getUpdatedSubscriptionItems();
        String updatedRawJson = Json.serialize(updatedCache);
        ATNQCacheContractService.processPut(updatedRawJson, 'profile', null);
        
        List<Contact> uContactList = [Select
                                      		Id,
                                      		FirstName, 
                                     		LastName, 
                                     		MobilePhone,
                                     		Email, 
                                     		Alternate_Phone__c, 
                                      		OtherPhone,
                                     		Internal_User__c,
                                     		Autoniq_User_Id__c,
                                     		Autoniq_Account__c,
                                     		Rep_Auction_Access_Number__c 
                                    From Contact limit 1];
        List<Autoniq_Account__c> uAcountList = [Select 
                                                Id,
                                                Dealership_AuctionACCESS_Number__c,
												Street__c,
                                                Street_2__c,
                                               	City__c,
                                                Country__c,
                                                Email__c,
                                                Phone__c,
                                                PostalCode__C
                                               From Autoniq_Account__c Where Id =: oAcountList[0].Id
                                              ];
        Test.startTest();
        System.assert(oContactList.size()==1,'Expecting 1 Orginal Contact , actual count: ' + oContactList.size());
        System.assert(oAcountList.size()==1,'Expecting 1 Originl Account, actual count: ' + oAcountList.size());
        System.assert(uContactList.size()==1,'Expecting a total of 1 Contact , actual count: ' + uContactList.size());
        System.assert(uAcountList.size()==1,'Expecting a total of 1 Account, actual count: ' + uAcountList.size());
        
        System.debug('========> orginal user ' + u);
        System.debug('========> updated user ' + uu);
        System.debug('========> Orginal Contact ' + oContactList[0]);
        System.debug('========> Updated Contact ' + uContactList[0]);
        System.debug('========> Original accDetail ' + a);
        System.debug('========> updated accDetail ' + ua);
        System.debug('========> Original Autoniq Account ' + oAcountList[0]);
        System.debug('========> Updated Autoniq Account ' + uAcountList[0]);
        
        System.assert(UserAndContactHaveTheSameValues(uu, uContactList[0]));
        System.assert(AccountDetailsAndAutoniqAccountHaveTheSameValues(ua, uAcountList[0]));
        Test.stopTest();
    }

    @isTest
    private static void processParameterGetTest(){
        
        CacheContract cache = new CacheContract();
        List<Product2> prods = createProducts();
        cache.userDetail = getOriginalUserDetail();
        cache.accountDetail = getOriginalAccountDetail();
        String rawJson = Json.serialize(cache);
        Test.startTest();
        ATNQCacheContractService.processPost(rawJson);
        CacheContract  rCache = ATNQCacheContractService.processParameterGet(cache.userDetail.autoniqUserId);
        System.debug('========> Original User:       ' + cache.userDetail);
        System.debug('========> User rturned by GET: ' + rCache.userDetail);
        
        System.assert(UsersHaveTheSameValues(cache.userDetail, rCache.userDetail), 'Expecting the same user to be retuned, but field values are different');
        Test.stopTest();
    }
    
    
    private static CacheContract.UserDetail getOriginalUserDetail(){
        CacheContract.UserDetail c = new CacheContract.UserDetail();
        c.firstName = 'oFirstName';
        c.lastName 	= 'oLastName';
        c.autoniqUserId = 'oAtnqUserId';
        c.mobile 	= '2021234444';
        c.email 	= 'oEmail@test.com';
        c.altEmail	= 'oAltEmail@test.com';
        //c = autoniqAccountId;
        c.altPhone	= '2024567777';
        //c = password;//Maybe Required if available (Encryptedstring)
        //salutation;
        c.internalUser	= false;
        //internalUserId;//Not Used
        c.repAuctionAccessNumber	= 12345;
        c.userAuctionAccessNumber	= 98765;
        return c;
    }
    
    private static CacheContract.accountDetail getOriginalAccountDetail(){
        CacheContract.AccountDetail a = new CacheContract.AccountDetail();
        a.accountStatus = 'Active';
   		a.autoniqAccountName = 'oAccName';
		a.auctionAccessNumber= '890';
        a.phone = '8471111234';
        a.accountType = 'Franchise Dealer';
		a.address = 'oAddress1';
        a.address2 = 'oAddress2';
		a.city = 'oAccCity';
        a.state = 'oState';
		a.country = 'oAccCountry';
		a.postCode = '90001';
        a.email = 'oAccEmail@test.com';
        a.referrer = 'oReferrer';
        return a;
    }
    
    private static CacheContract.PaymentProfile getOriginalPaymentProfile(){
        CacheContract.PaymentProfile p = new CacheContract.PaymentProfile();
        p.billingFirstName = 'oBillingFName';
        p.billingLastName = 'oBillingLName';
        p.billingAddress1 = '123 oBillingAddress';
        p.billingAddress2 = 'oBillingAddress2';
        p.billingCity = 'oBillingCity';
        p.billingState = 'oBillingState';
        p.billingCountry = 'US';
        p.billingZip = '60626';
        p.creditCardCode = '626'; 
        p.paymentType = 'Visa'; 
        p.ccNumberMasked = '1234567890124726';
        p.ccExp='11/26';
        p.customerPaymentProfileId = 'oCustomerPPId';
        p.customerProfileId = 'oCustomerPId';
        p.customerShippingAddressId='oCustomerShippingAddressId';
        return p;
    }
    
    private static CacheContract.PaymentProfile getUpdatedPaymentProfile(){
        CacheContract.PaymentProfile p = new CacheContract.PaymentProfile();
        p.billingFirstName = 'uBillingFName';
        p.billingLastName = 'uBillingLName';
        p.billingAddress1 = '123 uBillingAddress';
        p.billingAddress2 = 'uBillingAddress2';
        p.billingCity = 'uBillingCity';
        p.billingState = 'uBillingState';
        p.billingCountry = 'US';
        p.billingZip = '60627';
        p.creditCardCode = '627'; 
        p.paymentType = 'Visa'; 
        p.ccNumberMasked = '1234567890124727';
        p.ccExp='11/27';
        p.customerPaymentProfileId = 'uCustomerPPId';
        p.customerProfileId = 'uCustomerPId';
        p.customerShippingAddressId='uCustomerShippingAddressId';
        return p;
    }
    
    private static CacheContract.SubscriptionItems getOriginalSubscriptionItems(){
        CacheContract.SubscriptionItems si = new CacheContract.SubscriptionItems();
        si.subscriptionItemList = new List<String>();
        si.subscriptionItemList.add('CF');
        si.subscriptionItemList.add('AAX');
        si.subscriptionItemList.add('AC');
        return si;
    }
    
    private static CacheContract.SubscriptionItems getUpdatedSubscriptionItems(){
        CacheContract.SubscriptionItems si = new CacheContract.SubscriptionItems();
        si.subscriptionItemList = new List<String>();
        si.subscriptionItemList.add('CF');
        si.subscriptionItemList.add('AAX');
        return si;
    }
    
    private static CacheContract.accountDetail getUpdatedAccountDetail(){
        CacheContract.AccountDetail a = new CacheContract.AccountDetail();
        a.accountStatus = 'Active';
   		a.autoniqAccountName = 'oAccName';// same account updated details
		a.auctionAccessNumber= '567';
        a.phone = '3125559876';
        a.accountType = 'Franchise Dealer';
		a.address = 'uAddress1';
        a.address2 = 'uAddress2';
		a.city = 'uAccCity';
        a.state = 'uState';
		a.country = 'uAccCountry';
		a.postCode = '60002';
        a.email = 'uAccEmail@test.com';
        a.referrer = 'uReferrer';
        return a;
    }
    
    private static CacheContract.UserDetail getUpdatedUserDetails(){
        CacheContract.UserDetail c = new CacheContract.UserDetail();
        c.firstName = 'uFirstName';
        c.lastName 	= 'uLastName';
        c.mobile 	= '20232141111';
        c.email 	= 'uEmail@test.com';
        c.altEmail	= 'uAltEmail@test.com';
        c.autoniqUserId = 'oAtnqUserId';// Same user, updated details
        //c = autoniqAccountId;
        c.altPhone	= '2026544444';
        //c = password;//Maybe Required if available (Encryptedstring)
        //salutation;
        c.internalUser	= true;
        //internalUserId;//Not Used
        c.repAuctionAccessNumber	= 54321;
        c.userAuctionAccessNumber	= 56789;
        return c;
    }
    
    private static boolean UserAndContactHaveTheSameValues(CacheContract.UserDetail u, Contact c){
        if(u.firstName 	== c.FirstName &&
          u.lastName 	== c.LastName &&
          u.mobile 		== c.MobilePhone &&
          u.email 		== c.Email &&
          u.altPhone 	== c.Alternate_Phone__c &&
          ((u.internalUser==null || c.Internal_User__c==null) ||
          (u.internalUser== c.Internal_User__c)) &&
          u.repAuctionAccessNumber == Integer.valueOf(c.Rep_Auction_Access_Number__c)){
			System.debug('===========> UserAndContactHaveTheSameValues returning true');
			return true;
        }
        System.debug('===========> UserAndContactHaveTheSameValues returning false');
        return false;
    }
    
    private static boolean UsersHaveTheSameValues(CacheContract.UserDetail u1, CacheContract.UserDetail u2){
        if(u1.firstName 	== u2.firstName &&
          u1.lastName 		== u2.lastName &&
          u1.mobile 		== u2.mobile &&
          u1.email 			== u2.email &&
          u1.altPhone 		== u2.altPhone &&
          ((u1.internalUser == null ||  u2.internalUser==null) ||
          (u1.internalUser	== u2.internalUser)) &&
          u1.repAuctionAccessNumber == u2.repAuctionAccessNumber){
			System.debug('===========> UsersHaveTheSameValues returning true');
            return true;
        }
        System.debug('===========> UsersHaveTheSameValues returning false');
        return false;
    }
    
    private static List<Product2> createProducts(){
        List<Product2> prodList = new List<Product2>();
        Product2 p1 = new Product2(Family='Products', ProductCode='CF',Name='CarsFax');
        Product2 p2 = new Product2(Family='Products', ProductCode='AC',Name='AutoCheck');
        Product2 p3 = new Product2(Family='Products', ProductCode='AAX',Name='AAX Integration');
        prodList.add(p1);
        prodList.add(p2);
        prodList.add(p3);
        insert prodList;
        return prodList;
    }
    
    private static boolean AccountDetailsAndAutoniqAccountHaveTheSameValues(CacheContract.AccountDetail ad, Autoniq_Account__c aa){
        if(ad.auctionAccessNumber == aa.Dealership_AuctionACCESS_Number__c &&
          ad.address 	== aa.Street__c &&
          ad.address2 	== aa.Street_2__c &&
          ad.city 		== aa.City__c &&
          ad.country 	== aa.Country__c &&
          ad.email 		== aa.Email__c &&
          ad.phone 		== aa.Phone__c &&
          ad.postCode 	== aa.PostalCode__C){
            return true;
        }
        return false;
    }
    
}