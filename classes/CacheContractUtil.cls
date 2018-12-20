public class CacheContractUtil { 
    
    public static Id autoniqContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Autoniq').getRecordTypeId();        


    public static CacheContract populateUserDetail(CacheContract cc, Contact c){
        System.debug('=========> populateUserDetail Entered');
        if(cc.userDetail==null){
            cc.userDetail = new CacheContract.UserDetail();
        }
        CacheContract.UserDetail u = cc.userDetail;
            u.Id = c.Id;
            u.firstName = c.FirstName;
            u.lastName = c.LastName;
            u.email = c.Email;
            u.altEmail = c.Alternate_Email__c;
            u.autoniqUserId = c.Autoniq_User_ID__c;
            //Autoniq_Account__c = a.Id;
            //u.password = Password__c;
            u.mobile = c.MobilePhone;
            u.altPhone  = c.Alternate_Phone__c;                  
            u.internalUser = (c.Internal_User__c==null?false:c.Internal_User__c);
            if(String.ISNOTBLANK(c.Rep_Auction_Access_Number__c)){
                u.repAuctionAccessNumber = Integer.valueOf(c.Rep_Auction_Access_Number__c);
            }
        return cc;
    }
    
    public static CacheContract.UserDetail populateUserDetail(Contact c){
        CacheContract.UserDetail ccu = new CacheContract.UserDetail();
        
        return ccu;
    }
    
    public static CacheContract clearUserDetail(CacheContract c){
        
        c.userDetail = new CacheContract.UserDetail();
        return c;
    }
    
    public static CacheContract populateAccountDetail(CacheContract c, Autoniq_Account__c a){
        return populateAccountDetail(c, a, null);
    }
    
    public static CacheContract populateAccountDetail(CacheContract c, Autoniq_Account__c a, String ref){
        System.debug('=========> populateAccountDetail Entered');
        if(c.accountDetail == null){
            c.accountDetail = new CacheContract.AccountDetail();
        }
        CacheContract.AccountDetail cca = c.accountDetail;
        cca.accountStatus = a.AccountStatus__c;
        cca.id = a.Id;
        cca.autoniqAccountName = a.Name;
        cca.accountType = a.Account_Type__c; 
        cca.latitude = a.Latitude__c;
        cca.longitude = a.Longitude__c;
        cca.auctionAccessNumber = a.Dealership_AuctionACCESS_Number__c;
        cca.address = a.Street__c;
        cca.address2 = a.Street_2__c;
        cca.city = a.City__c;
        cca.state = a.State__c;
        cca.country = a.Country__c; 
        cca.postCode = a.PostalCode__c;
        cca.email = a.Email__c;
        cca.referrer = ref;
        return c;
    }
    
    public static CacheContract.AccountDetail populateAccountDetail(Autoniq_Account__c a){
        CacheContract.AccountDetail cca = new CacheContract.AccountDetail();
        return cca;
    }
    
    public static CacheContract clearAccountDetail(CacheContract c){
        
        c.accountDetail = new CacheContract.AccountDetail();
        return c;
    }
    
    public static CacheContract populatePreferences(CacheContract c){
        
        return c;
    }
    
    public static CacheContract populateCacheContractPaymentProfile(CacheContract cache, Autoniq_Subscription_Payment_Profile__c pp){
        System.debug('=========> populateCacheContractPaymentProfile Entered');
        if(cache.PaymentProfile==null){
            cache.PaymentProfile = new CacheContract.paymentProfile();
        }
        cache.PaymentProfile.paymentType = pp.Payment_Type__c;
        cache.PaymentProfile.creditCardType = pp.Credit_Card_Type__c;
        cache.PaymentProfile.billingFirstName = pp.Billing_First_Name__c;
        cache.PaymentProfile.billingLastName = pp.Billing_Last_Name__c;
        cache.PaymentProfile.billingAddress1 = pp.Billing_Street__c;
        cache.PaymentProfile.billingAddress2 = pp.Billing_Street_2__c;
        cache.PaymentProfile.billingCity = pp.Billing_City__c;
        cache.PaymentProfile.billingState = pp.Billing_State__c;
        cache.PaymentProfile.billingCountry = pp.Billing_Country__c;
        cache.PaymentProfile.billingZip = pp.Billing_Postal_Code__c;
        cache.PaymentProfile.ccNumberMasked = pp.Credit_Card_Number__c;
        cache.paymentProfile.ccExp = pp.CC_Expiration_Date__c;
        if(pp.Last_Four_Digits__c!=null){
            cache.paymentProfile.ccNumberMasked = String.valueOf(pp.Last_Four_Digits__c);
        }
        cache.paymentProfile.creditCardCode = pp.CVV_Code__c;

        return cache;
    }
    
    public static CacheContract populateVhrSettings(CacheContract cc, List<Autoniq_Third_Party_Item__c> atpiList){
        System.debug('=========> populateVhrSettings Entered');
        if(cc.vhrSettings == null){
            cc.vhrSettings = new CacheContract.vhrSettings();
        }
        if(cc.aax == null){
            cc.aax = new CacheContract.AAX();
        }
        
        for(Autoniq_Third_Party_Item__c atpi: atpiList){
            System.debug('=======> populateVhrSettings  processing: ' + atpi);
            if(atpi.Autoniq_Subscription_Item__r.Product__r.ProductCode==ATNQConstants.ATNQ_PRODUCT_CODE_AC){
                //cc.VhrSettings.Id = atpi.Id,
                cc.VhrSettings.autoCheckId = atpi.Username__c;
                cc.VhrSettings.autoCheckPasswd = atpi.Password__c;
                if(atpi.Auto_Purchase__c=='True'){
                    cc.VhrSettings.autoCheckAutoPurchase = true;
                }else{
                    cc.VhrSettings.autoCheckAutoPurchase = false;
                }
            }else if(atpi.Autoniq_Subscription_Item__r.Product__r.ProductCode==ATNQConstants.ATNQ_PRODUCT_CODE_CARFAX){
                //cc.VhrSettings.id = atpi.Id;
                cc.VhrSettings.carfaxId = atpi.Username__c;
                cc.VhrSettings.carfaxPasswd = atpi.Password__c;
                if(atpi.Auto_Purchase__c=='True'){
                    cc.VhrSettings.carfaxAutoPurchase = true;
                }else{
                    cc.VhrSettings.carfaxAutoPurchase = false;
                }
            }else if(atpi.Autoniq_Subscription_Item__r.Product__r.ProductCode==ATNQConstants.ATNQ_PRODUCT_CODE_AAX){
                cc.aax.aaxClientId = atpi.AAX_Client_ID__c;
                cc.aax.aaxSecurityToken = atpi.AAX_Security_Token__c;
                cc.aax.aaxDealerId = atpi.AAX_Dealer_ID__c;
                cc.aax.aaxUserId = atpi.AAX_User_ID__c;
            }else if(atpi.Autoniq_Subscription_Item__r.Product__r.ProductCode==ATNQConstants.ATNQ_PRODUCT_CODE_BB){
                
            }else if(atpi.Autoniq_Subscription_Item__r.Product__r.ProductCode==ATNQConstants.ATNQ_PRODUCT_CODE_KBB){
                
            }else if(atpi.Autoniq_Subscription_Item__r.Product__r.ProductCode==ATNQConstants.ATNQ_PRODUCT_CODE_NADA){
                
            }else if(atpi.Autoniq_Subscription_Item__r.Product__r.ProductCode==ATNQConstants.ATNQ_PRODUCT_CODE_MR){
                
            }else if(atpi.Autoniq_Subscription_Item__r.Product__r.ProductCode==ATNQConstants.ATNQ_PRODUCT_CODE_MMR){
                
            }else if(atpi.Autoniq_Subscription_Item__r.Product__r.ProductCode==ATNQConstants.ATNQ_PRODUCT_CODE_GALVES){
                
            }else if(atpi.Autoniq_Subscription_Item__r.Product__r.ProductCode==ATNQConstants.ATNQ_PRODUCT_CODE_APG){
                
            }else if(atpi.Autoniq_Subscription_Item__r.Product__r.ProductCode==ATNQConstants.ATNQ_PRODUCT_CODE_DISC){
                
            }
        }
        
        return cc;
    }
    
    
    public static CacheContract clearPreferences(CacheContract c){
        
        c.preferences = new CacheContract.Preferences();
        return c;
    }
    
    public static Contact populateContactObject(CacheContract.UserDetail u, Contact user){
        System.debug('=========> populateContactObject Entered');
        if(u.firstName!=null){
            user.FirstName = u.firstName;
        }
        if(u.lastName!=null){
            user.LastName = u.lastName;
        }
        if(u.email!=null){
            user.Email = u.email;
        }
        
    user.RecordTypeId = autoniqContactRecordTypeId;

        user.Active__c = true;
        if(u.autoniqUserId!=null){
          user.Autoniq_User_ID__c = u.autoniqUserId;    
        }
        if(u.autoniqAccountId!=null){
            user.Autoniq_Account__c = u.autoniqAccountId;
        }
        if(u.password!=null){
            user.Password__c = u.password;
        }
        if(u.mobile!=null){
            user.MobilePhone = u.mobile;
        }
        if(u.altPhone!=null){
            user.Alternate_Phone__c = u.altPhone;
        }
        if(u.internalUser!=null){
          user.Internal_User__c = u.internalUser;    
        }else{
          user.Internal_User__c = false;
        }
        if(u.repAuctionAccessNumber!=null){
          user.Rep_Auction_Access_Number__c = String.valueOf(u.repAuctionAccessNumber);    
        }
        user.Process_Identifier__c = 'Autoniq';
        return user;
        
    }
    
    public static Contact createContact(CacheContract contract){
        System.debug('=========> createContact Entered');
        CacheContract.UserDetail u = contract.userDetail;
        CacheContract.Preferences p = contract.preferences;
        CacheContract.AccountDetail a = contract.accountDetail;
        String repAutionAccessNumber;
        if(u.repAuctionAccessNumber!=null){
            repAutionAccessNumber = String.valueOf(u.repAuctionAccessNumber);
        }
        Contact c = new Contact(Id = u.Id,
                                Process_Identifier__c = 'Autoniq',
                                FirstName   = u.firstName, 
                                LastName    = u.lastName,
                                Email       = u.email,
                                Alternate_Email__c = u.altEmail,
                                RecordTypeId = autoniqContactRecordTypeId,
                                Active__c = true,
                                Autoniq_User_ID__c  = u.autoniqUserId,
                                Autoniq_Account__c = a.Id,
                                Password__c = u.password,
                                MobilePhone         = u.mobile,
                                Alternate_Phone__c  = u.altPhone,                                
                                Internal_User__c    = (u.internalUser==null?false:u.internalUser),
                                Rep_Auction_Access_Number__c = repAutionAccessNumber);
        
        if(p!=null){
            Autoniq_User_Applilcation_Setting__c  appSettings = new Autoniq_User_Applilcation_Setting__c(
                                        Contact__c = u.Id,
                                        peRegion__c = p.regionSelected,
                                        Default_Black_Book__c =p.peBBKTable,
                                        Default_Kelley_Blue_Book__c = p.peKBBTable,
                                         Default_NADA__c  = p.peNADATable,
                                        Mobile_Device_Type__c  = p.phoneType,
                                        Vehicle_Selector_Style__c = p.menuStyle);
            insert appSettings;
        }
        
        
        return c;
    }
    
    public static Contact createContact(CacheContract.UserDetail u){
        System.debug('=========> createContact Entered');
        Contact c;
        String repAuctionAccessNumber;
        if(u.repAuctionAccessNumber!=null){
            repAuctionAccessNumber = String.valueOf(u.repAuctionAccessNumber);
        }
        c = new Contact(Id=u.Id,
                        Process_Identifier__c = 'Autoniq',
                        FirstName   = u.firstName, 
                                LastName    = u.lastName,
                                Email       = u.email,
                                Alternate_Email__c = u.altEmail,
                                RecordTypeId = autoniqContactRecordTypeId,
                                Active__c = true,
                                Autoniq_User_ID__c  = u.autoniqUserId,
                                //Autoniq_Account__c = a.Id,
                                Password__c = u.password,
                                MobilePhone         = u.mobile,
                                Alternate_Phone__c  = u.altPhone,                                
                                Internal_User__c    = (u.internalUser==null?false:u.internalUser),
                                Rep_Auction_Access_Number__c = repAuctionAccessNumber);
        return c;
    }
    
    public static Contact updateContact(Contact c,CacheContract.UserDetail u){
        System.debug('=========> updateContact Entered with Contact: ' + c);
        c.Id = u.id;
        c.Process_Identifier__c = 'Autoniq';
        c.FirstName   = u.firstName;
        c.LastName    = u.lastName;
        c.Email         = u.email;
        c.Alternate_Email__c = u.altEmail;
        c.MobilePhone        = u.mobile;
        c.Alternate_Phone__c = u.altPhone;
        c.Autoniq_User_ID__c = u.autoniqUserId;
        c.Internal_User__c   = u.internalUser==null?false:u.internalUser;
        if(u.repAuctionAccessNumber!=null){
            c.Rep_Auction_Access_Number__c = String.valueOf(u.repAuctionAccessNumber);
        }
        update c;
        System.debug('=========> updateContact updated Contact to: ' + c);
        return c;
    }
    
    public static Account createAccount(CacheContract contract){
        Account acc = new Account();
        return acc;
    }
    Autoniq_Account__c at = new Autoniq_Account__c();

    public static Autoniq_Account__c createAutoniqAccount(CacheContract contract){
        System.debug('=========> createAutoniqAccount(c) Entered');
        CacheContract.AccountDetail aac = contract.accountDetail;    
        String address = aac.address;
        if(!String.ISBLANK(aac.address2)){
            address = address + ' , ' + aac.address2;
        }
        Autoniq_Account__c  atnqAcc = new Autoniq_Account__c(AccountStatus__c  = (aac.accountStatus==null?'Active':aac.accountStatus),
                                                            Id = aac.id,
                                                            Name = aac.autoniqAccountName,
                                                            Account_Type__c = aac.accountType,
                                                            //Auction_Access_Number__c = aac.auctionAccessNumber,
                                                            Dealership_AuctionACCESS_Number__c = aac.auctionAccessNumber,
                                                            Street__c = aac.address,
                                                            Street_2__c = aac.address2,
                                                            City__c = aac.city,
                                                            Country__c = aac.country,
                                                            Email__c = aac.email,
                                                            //Alternate_Email__c = aac.altEmail,
                                                            Latitude__c = aac.latitude,
                                                            Longitude__c = aac.longitude,
                                                            //No_Of_Subscriptions__c  = aac.noOfSubscriptions,
                                                            //Phone__c = aac.phone,
                                                            //Alternate_Phone_Country__c = aac.altPhoneCountryCode,
                                                            PostalCode__C = aac.postCode,
                                                            State__c = aac.state);

        insert atnqAcc;
        return atnqAcc;
    }
    
    public static Autoniq_Account__c populateCAutoniqAccountObject(CacheContract.AccountDetail aac, Autoniq_Account__c account){
        System.debug('=========> populateCAutoniqAccountObject(aac, account) Entered');
        if(aac.address!=null){
          account.Street__c =  aac.address;
        }
        if(aac.state!=null){
          account.State__c = aac.state;    
        }
        if(aac.state!=null){
          account.State__c = aac.state;    
        }
        if(aac.postCode!=null){
          account.PostalCode__C = aac.postCode;
        }
        if(aac.country!=null){
          account.Country__c = aac.country;    
        }
        
        return account;
        
    }
    public static Autoniq_Account__c updateAutoniqAccount(CacheContract contract){
        System.debug('=======> updateAutoniqAccount entered with null autoniq Id');
        return updateAutoniqAccount(contract, null);
    }
    public static Autoniq_Account__c updateAutoniqAccount(CacheContract contract, String autoniqUserId){
        System.debug('=======> updateAutoniqAccount entered with autniq Id: ' + autoniqUserId);
        CacheContract.AccountDetail aac = contract.accountDetail;
        list<Contact> contactList;
        List<Autoniq_Account__c> atnqAccountList;
        if(contract.userDetail!=null){
            contactList = [SELECT Autoniq_Account__r.Id FROM Contact WHERE id = :contract.UserDetail.Id]; 
            if(contract.accountDetail!=null && contactList.size()>0){
                atnqAccountList = [select Id, Name, City__c, State__c, Country__c, Street__c,Street_2__c,PostalCode__C, No_Of_Subscriptions__c from Autoniq_Account__c where Id=:contactList[0].Autoniq_Account__r.Id];
            }
        }else{
            if(contract.accountDetail!=null){
                atnqAccountList = [select Id, Name, City__c, State__c, Country__c, Street__c,Street_2__c,PostalCode__C, No_Of_Subscriptions__c from Autoniq_Account__c where Id=: autoniqUserId];
            }
        }
        if(atnqAccountList!=null && atnqAccountList.size()>0){
            Autoniq_Account__c a = atnqAccountList[0];
            a.Name = aac.autoniqAccountName;
            a.No_Of_Subscriptions__c = aac.noOfSubscriptions;
            a.Street__c = aac.address;
            a.Street_2__c = aac.address2;
            a.City__c   = aac.city;
            a.State__c  = aac.state;
            a.PostalCode__C = aac.postCode;
            a.Country__c = aac.country;
            a.Email__c  = aac.email;
            //a.Phone__c  = aac.phone;
            a.AccountStatus__c = (aac.accountStatus==null?'Active':aac.accountStatus);
            a.Dealership_AuctionACCESS_Number__c = aac.auctionAccessNumber;
            update a;
            return a;
        }else{
            return null;
        }
    }
    
    public static Subscription__c createSubscription(CacheContract cache, Id contactId, Id autoniqAccountId){
        System.debug('=========> createSubscription(cache,contactId,autoniqAccountId) Entered');
        // Consideration for annual subscriptions
        String term;
        Date nextBillDate;
        String promo;
        //Cache.Subscriptions subs = cache.subscriptions;
        CacheContract.AccountDetail aac = cache.accountDetail;
        if(cache.packages!=null){
            term = cache.packages.term;
            nextBillDate = cache.Packages.expires.addDays(1).Date();
        }
        
        if(cache.paymentProfile!=null){
            promo = cache.paymentProfile.promotionalCode;
        }
        
        Subscription__c sub = new Subscription__c(Promo_Code__c = promo,
                                                  Status__c = Constants.SUBSCRIPTION_STATUS_ACTIVE,
                                                  Autoniq_Account__c = autoniqAccountId,
                                                  Referral__c  = aac.referrer,
                                                  Contact__c = contactId,
                                                  Term__c = 'Monthly',
                                                  Sign_Up_Date__c = Date.today(),
                                                  Next_Bill_Date__c = Date.today().addMonths(1));
        insert sub;
        
        
        
        return sub;
    }
    
    //public static List<Subscr
    
    public static List<Subscription_Item__c> createSubscriptionItems(CacheContract cache, Subscription__c sub){ 
        System.debug('=========> createSubscriptionItems(cache,sub) Entered');
        List<Subscription_Item__c>  subItemList = new List<Subscription_Item__c>();
        Map<String, Subscription_Item__c> codeSubItemMap = new Map<String, Subscription_Item__c>();
        Id subId;
        if(sub!=null){
            subId = sub.Id;
        }
        CacheContract.SubscriptionItems sItems = cache.subscriptionItems;
        System.debug('========> sub Items' + sItems);
        if(sItems!=null && sItems.subscriptionItemList != null && sItems.subscriptionItemList.size()>0){
            for(String code: sItems.subscriptionItemList){
                System.debug('========> Code: ' + code);
                Product2 prod = getProductCodeMap().get(code);
                System.debug('========> prod: ' + prod);
                Id prodId;
                if(prod!=null){
                    prodId = prod.Id;
                }
                Subscription_Item__c si = new Subscription_Item__c(
                        Status__c=Constants.SUBSCRIPTION_STATUS_ACTIVE,
                        Recurring__c ='Yes' ,
                        Product__c = prodId, 
                        iSActive__c = true, 
                        Subscription__c=subId,
                        Start_Date__c = Date.today());
                System.debug('========> SI: ' + si);
                insert si;
                subItemList.add(si);
                codeSubItemMap.put(code, si);
            }
        }
        
        if(cache.vhrSettings != null && cache.vhrSettings.carfaxEnabled==true){
            Product2 carfaxProd = getProductNameMap().get('CarFax');
            Id carfaxProdId;
            if(carfaxProd!=null){
                carfaxProdId = carfaxProd.Id;
            }
            /*
            Subscription_Item__c si = new Subscription_Item__c(
                        Status__c=Constants.SUBSCRIPTION_STATUS_ACTIVE,
                        Recurring__c ='Yes' ,
                        Product__c = carfaxProdId, 
                        iSActive__c = true, 
                        Subscription__c=subId,
                        Start_Date__c = Date.today());
            insert si;
            */
            Subscription_Item__c carFaxSitem;
            if(carfaxProd!=null){
                carFaxSitem = codeSubItemMap.get(carfaxProd.ProductCode);
            }
            if(carFaxSitem!=null){
                createThirdPartyItem(carFaxSitem, cache.VhrSettings.carfaxId, cache.VhrSettings.carfaxPasswd, (cache.VhrSettings.carfaxAutoPurchase==true?'True':'False'), cache.VhrSettings.autoCheckGateway);
            }
        }
        
        if(cache.vhrSettings != null && cache.VhrSettings.autoCheckEnabled==true){
            Id autoCheckProdId;
            Product2 autoCheckProd = getProductNameMap().get('AutoCheck');
            if(autoCheckProd!=null){
                autoCheckProdId = autoCheckProd.Id;
            }
            /*
            Subscription_Item__c si = new Subscription_Item__c(Status__c=Constants.SUBSCRIPTION_STATUS_ACTIVE,
                                                               Product__c=autoCheckProdId, 
                                                               iSActive__c = true, 
                                                               Subscription__c=subId,
                                                               Start_Date__c=Date.today());
            insert si;
            */
            Subscription_Item__c autoCheckSitem;
            if(autoCheckProd!=null){
                autoCheckSitem = codeSubItemMap.get(autoCheckProd.ProductCode);
            }
            if(autoCheckSitem!=null){
                createThirdPartyItem(autoCheckSitem, cache.VhrSettings.autoCheckId, cache.VhrSettings.autoCheckPasswd, (cache.VhrSettings.autoCheckAutoPurchase==true?'True':'False'), cache.VhrSettings.autoCheckGateway);
            }
        }
        
        if(cache.aax!=null && String.ISNOTBLANK(cache.aax.aaxClientId)){
            Product2 aaxProd = getProductNameMap().get('AAX Integration');
            Id aaxProdId;
            if(aaxProd!=null){
                aaxProdId = aaxProd.Id;
            }
            /*
            Subscription_Item__c si = new Subscription_Item__c(Status__c=Constants.SUBSCRIPTION_STATUS_ACTIVE,
                                                               Product__c=aaxProdId, 
                                                               iSActive__c = true, 
                                                               Subscription__c=subId, 
                                                               Start_Date__c = Date.today());
            insert si;
            */
            Subscription_Item__c aaxSitem;
            if(aaxProdId!=null){
                aaxSitem = codeSubItemMap.get(aaxProd.ProductCode);
            }
            if(aaxSitem!=null){
                Autoniq_Third_Party_Item__c atpi = new Autoniq_Third_Party_Item__c(Username__c=cache.userDetail.autoniqUserId,Autoniq_Subscription_Item__c = aaxSitem.Id, AAX_Client_ID__c = cache.aax.aaxClientId, AAX_Dealer_ID__c = cache.aax.aaxDealerId, AAX_User_ID__c = cache.aax.aaxUserId, AAX_Security_Token__c = cache.aax.aaxSecurityToken);
                insert atpi;
            //subItemList.add(si);
            }
        }
        
        
        if(cache.Options!=null && cache.Options.cICL==true){
            Subscription_Item__c si = new Subscription_Item__c();
            subItemList.add(si);
        }
        
        if(cache.Options != null && cache.Options.dcAL==true){
            Subscription_Item__c si = new Subscription_Item__c();
            subItemList.add(si);
        }
        //insert subItemList;
        return subItemList;
    }

    public static Autoniq_Third_Party_Item__c createThirdPartyItem(Subscription_Item__c subItem,String name, String password, String autoPurchase, String uri){  
        System.debug('=========> createThirdPartyItem(sunItem, Name, password,autoPurchase,uri) Entered');
        Id subItemId;
        if(subItem!=null){
            subItemId = subItem.Id;
        }
        Autoniq_Third_Party_Item__c atpi = new Autoniq_Third_Party_Item__c(Autoniq_Subscription_Item__c = subItemId,
                                                                           Username__c=name, 
                                                                           Password__c=password,
                                                                           Auto_Purchase__c=autoPurchase, 
                                                                           URI__c = uri);
        insert atpi;
        return atpi;
    }
    
    public static Autoniq_Third_Party_Item__c updateThirdPartyItem_CarFax(CacheContract cache,Autoniq_Third_Party_Item__c atpiTemp){  
        Autoniq_Third_Party_Item__c atpi = new Autoniq_Third_Party_Item__c(
                                            Id = atpiTemp.Id,
                                            Username__c= cache.VhrSettings.carfaxId,
                                            Password__c= cache.VhrSettings.carfaxPasswd,
                                            Auto_Purchase__c= (cache.VhrSettings.carfaxAutoPurchase==true?'True':'False'));
        update atpi;
        return atpi;
    }
    public static Autoniq_Third_Party_Item__c InsertThirdPartyItem_CarFax(CacheContract cache, Id sub_ItemId){  
        Autoniq_Third_Party_Item__c atpi = new Autoniq_Third_Party_Item__c(
                                            Autoniq_Subscription_Item__c = sub_ItemId,
                                            Username__c= cache.VhrSettings.carfaxId,
                                            Password__c= cache.VhrSettings.carfaxPasswd,
                                            Auto_Purchase__c= (cache.VhrSettings.carfaxAutoPurchase==true?'True':'False'));
        insert atpi;
        return atpi;
    }
 
    public static Autoniq_Third_Party_Item__c updateThirdPartyItem_AutoCheck(CacheContract cache,Autoniq_Third_Party_Item__c atpiTemp){  
        Autoniq_Third_Party_Item__c atpi = new Autoniq_Third_Party_Item__c(
                                            Id = atpiTemp.Id,
                                            Username__c= cache.VhrSettings.autoCheckId,
                                            Password__c= cache.VhrSettings.autoCheckPasswd,
                                            Auto_Purchase__c= (cache.VhrSettings.autoCheckAutoPurchase==true?'True':'False'));
        update atpi;
        return atpi;
    }
    public static Autoniq_Third_Party_Item__c insertThirdPartyItem_AutoCheck(CacheContract cache,Id Sub_ItemId){  
        Autoniq_Third_Party_Item__c atpi = new Autoniq_Third_Party_Item__c(
                                             Autoniq_Subscription_Item__c = sub_ItemId,
                                            Username__c= cache.VhrSettings.autoCheckId,
                                            Password__c= cache.VhrSettings.autoCheckPasswd,
                                            Auto_Purchase__c= (cache.VhrSettings.autoCheckAutoPurchase==true?'True':'False'));
        insert atpi;
        return atpi;
    }
 
    public static Autoniq_Third_Party_Item__c updateThirdPartyItem_AAX(CacheContract cache,Autoniq_Third_Party_Item__c atpiTemp){  
        Autoniq_Third_Party_Item__c atpi = new Autoniq_Third_Party_Item__c(
                                            Id = atpiTemp.Id,
                                            AAX_Client_ID__c= cache.aax.aaxClientId,
                                            AAX_Dealer_ID__c = cache.aax.aaxDealerId,
                                            AAX_User_ID__c = cache.aax.aaxUserId,
                                            AAX_Security_Token__c = cache.aax.aaxSecurityToken
                                            );
        update atpi;
        return atpi;
    }
     public static Autoniq_Third_Party_Item__c insertThirdPartyItem_AAX(CacheContract cache,Id Sub_itemId){  
        Autoniq_Third_Party_Item__c atpi = new Autoniq_Third_Party_Item__c(
                                            Autoniq_Subscription_Item__c = sub_ItemId,
                                            AAX_Client_ID__c= cache.aax.aaxClientId,
                                            AAX_Dealer_ID__c = cache.aax.aaxDealerId,
                                            AAX_User_ID__c = cache.aax.aaxUserId,
                                            AAX_Security_Token__c = cache.aax.aaxSecurityToken
                                            );
        insert atpi;
        return atpi;
    }
 
    
    //public static Autoniq_User_Application_Setting__c createAutoniqUserApplicationSetting(CacheContract cache){
    //    Cache.Preferences p = new Cache.Preferences(Vehicle_Selector_Style__c =, 
    //                                                Valuation_Region__c = , 
    //                                                Default_Blabk_Book__c =, 
    //                                                Default_NADA__c =, 
    //                                                Default_Kelly_Blue_Book__c =, 
    //                                                Mobile_Device_Type= );
    //     Cache.Preferences p = cache.Preferences;    
    //     Cache.UserDetail u  = cache.userDetail;  
    //     Cache.Options o = cache.options; 
    //     Cache.Aax a = cache.aax;                                   
    //     Autoniq_User_Application_Setting__c auas = new Autoniq_User_Application_Setting__c(
    //                                                   AAX_Client_ID__c = a.aaxClientId,
    //                                                   AAX_Dealer_ID__c = a.aaxDealerId,
    //                                                   aaxIntegration__c  = o.aaxIntegration ,
    //                                                   AAX_Security_Token__c  = a.aaxSecurityToken,
    //                                                   AAX_User_ID__c =  a.aaxUserId,
    //                                                   aqPro__c  = o.aqPro ,
    //insclCars__c = o.cICARS ,
    //                                                   clSMC__c =  o.cISMC,
    //                                                   CLCL__c =  o.cICL,
    //                                                   Contact__c  = u.Id,
    //                                                   CurrencyIsoCode  =  ,
    //                                                   dcAPI__c = o.dcAPI ,
    //                                                   dcAL__c = o.dcAL ,
    //                                                   demoAccount__c = o.demoAccount,
    //                                                   GDMS__c = o.GDMS,
    //                                                   Home_region_zip_code__c = ,
    //                                                   immrLink__c = o.immrLink,
    //                                                   menuStyle__c  = p.menuStyle,
    //                                                   Mobile_Device_Type__c = p.phoneType,
    //                                                   multipleLogin__c  = o.multipleLogin,
    //                                                   My_vehicle_bucket_size__c  = ,
    //                                                   optOut__c  =  o.optOut,
    //                                                   peBBKTable = p.peBBKTable,
    //                                                   peRegion__c  =  p.homeRegionSelected,
    //                                                   peKBBTable__c = p.peKBBTable,
    //                                                   peNADATable__c  = p.peNADATable,
    //                                                   Valuation_region__c = ,
    //                                                   webSite__c  = o.webSite
    //                                                  );                                          
    //}

    public static Map<String, Product2> getProductNameMap(){
        if(nameToProductMap.isEmpty()){
            for(Product2 p: ATNQQueryUtil.getProducts()){
                nameToProductMap.put(p.Name, p);
            }
        }
        System.debug('=======> getProductNameMap: ' + nameToProductMap);
        return nameToProductMap;
    }
    
    public static Map<String, Product2> getProductCodeMap(){
        if(codeToProductMap.isEmpty()){
            for(Product2 p: ATNQQueryUtil.getProducts()){
                codeToProductMap.put(p.ProductCode, p);
            }
        }
        System.debug('=======> getProductCodeMap: ' + codeToProductMap);
        return codeToProductMap;
    }
    
    public static Autoniq_Subscription_Payment_Profile__c  createPaymentProfile(CacheContract cache, Subscription__c sub){
        System.debug('=========> createPaymentProfile(cache,sub) Entered');
        String num = cache.paymentProfile.ccNumberMasked;
        Decimal last4Decimal;
        if(num!=null && num.length()>=4){
            String last4 = num.substring((num.length()-4),num.length());
            last4Decimal = Decimal.valueOf(last4);
        }
        Autoniq_Subscription_Payment_Profile__c  pp = 
            new Autoniq_Subscription_Payment_Profile__c(Payment_Type__c = cache.PaymentProfile.paymentType,
                                                        Credit_Card_Type__c = cache.PaymentProfile.creditCardType,
                                                        Billing_First_Name__c = cache.PaymentProfile.billingFirstName,
                                                        Billing_Last_Name__c = cache.PaymentProfile.billingLastName,
                                                        Billing_Street__c = cache.PaymentProfile.billingAddress1,
                                                        Billing_Street_2__c  = cache.PaymentProfile.billingAddress2,
                                                        Billing_City__c = cache.PaymentProfile.billingCity,
                                                        Billing_State__c = cache.PaymentProfile.billingState,
                                                        Billing_Country__c = cache.PaymentProfile.billingCountry,
                                                        Billing_Postal_Code__c = cache.PaymentProfile.billingZip,
                                                        Credit_Card_Number__c = cache.PaymentProfile.ccNumberMasked, 
                                                        CC_Expiration_Date__c  = cache.paymentProfile.ccExp,
                                                        Last_Four_Digits__c = last4Decimal,
                                                        CVV_Code__c = cache.paymentProfile.creditCardCode,
                                                        Autoniq_Subscription__c =sub.Id,
                                                        //Referral__c = cache.paymentProfile.referrer,
                                                        IsActive__c  = true);
        System.debug('==========> ccNumberMasked: ' + cache.paymentProfile.ccNumberMasked);
        
        insert pp;
        return pp;
    }
    
    public static ATNQCacheContractResponse setupErrorResponse(String msg, String src, String uniqId){
        ATNQCacheContractResponse aResp = new ATNQCacheContractResponse();
        ATNQCacheContractResponse.ResponseError respError= new ATNQCacheContractResponse.ResponseError();
        respError.message = msg;
        respError.source = src;
        aResp.resp.errors.add(respError);
        aResp.resp.success = false;
        aResp.resp.salesforceId = uniqId;//need to change response fields, and change salesforce Id to uniq Id.
        System.debug('==========> Response: ' + aResp);
        if(!Test.isRunningTest()){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(Json.serialize(aResp));
        }
        return aResp;
    }
    
    public static ATNQCacheContractResponse setupSuccessResponse(String uniqId){ 
        ATNQCacheContractResponse aResp = new ATNQCacheContractResponse();
        aResp.resp.salesforceId = uniqId;//need to change response fields, and change salesforce Id to uniq Id.
        aResp.resp.success = true;
        System.debug('==========> Response: ' + aResp);
        if(!Test.isRunningTest()){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(Json.serialize(aResp));
        }
        return aResp;
    }
    
    public static Autoniq_Account__c getMatchingATNQAccount(CacheContract cache){
        //List<Autoniq_Account__c> atnqAccountList = [select Id, Name, City__c, Street__c, No_Of_Subscriptions__c from Autoniq_Account__c where Name=:cache.accountDetail.autoniqAccountName AND City__c=:cache.accountDetail.city AND Street__c=:cache.accountDetail.address limit 1];
        List<Autoniq_Account__c> atnqAccountList = [select Id, Dealership_AuctionACCESS_Number__c, Name, Street__c,Street_2__c,City__c,Country__c,State__c,Email__c,Phone__c,PostalCode__c, No_Of_Subscriptions__c,AccountStatus__c from Autoniq_Account__c where Name=:cache.accountDetail.autoniqAccountName limit 1];

        if(atnqAccountList.size()>0){
            return atnqAccountList[0];
        }
        return null;
    }
    
    public static Autoniq_Subscription_Payment_Profile__c  updatePaymentProfile(CacheContract cache,Autoniq_Subscription_Payment_Profile__c ppTemp){
        Autoniq_Subscription_Payment_Profile__c  pp = 
            new Autoniq_Subscription_Payment_Profile__c(Payment_Type__c = cache.PaymentProfile.paymentType,
                                        Billing_First_Name__c = cache.PaymentProfile.billingFirstName,
                                        Billing_Last_Name__c = cache.PaymentProfile.billingLastName,
                                        Billing_Street__c = cache.PaymentProfile.billingAddress1,
                                        Billing_Street_2__c = cache.PaymentProfile.billingAddress2,
                                        Billing_City__c = cache.PaymentProfile.billingCity,
                                        Billing_State__c = cache.PaymentProfile.billingState,
                                        Billing_Country__c = cache.PaymentProfile.billingCountry,
                                        Billing_Postal_Code__c = cache.PaymentProfile.billingZip,
                                        Credit_Card_Number__c = cache.PaymentProfile.ccNumberMasked,
                                        CVV_Code__c = cache.paymentProfile.creditCardCode, 
                                        Credit_Card_Type__c = cache.PaymentProfile.creditCardType, 
                                        CC_Expiration_Date__c  = cache.PaymentProfile.ccExp,
                                        Id = ppTemp.id
                                        );
        update pp;
        return pp;
    }
    public static Map<Id, Product2> idToProductMap = new Map<Id, Product2>();
    
    public static Map<String, Product2> nameToProductMap = new Map<String, Product2>();
    public static Map<String, Product2> codeToProductMap = new Map<String, Product2>();
    
    /* public static Autoniq_User_Applilcation_Setting__c updateUserApplicationSetting(CacheContract cache){
        
        list<Contact> contactList = [SELECT Name, (SELECT Id FROM Autoniq_User_Applilcation_Settings__r) FROM Contact WHERE id = :cache.UserDetail.Id]; 
        Autoniq_User_Applilcation_Setting__c uas = new Autoniq_User_Applilcation_Setting__c(
                                                        Id = contactList[0].Autoniq_User_Applilcation_Settings__r[0].id,
                                                        Vehicle_Selector_Style__c = cache.preferences.menuStyle,
                                                        Valuation_region__c = cache.preferences.peRegion,
                                                        Default_Black_Book__c = cache.preferences.peBBKTable,
                                                        Default_NADA__c = cache.preferences.peNADATable,
                                                        Default_Kelley_Blue_Book__c = cache.preferences.peKBBTable
                                                    );
        update uas;
        return uas;
    } */
    
    public static void updateProfile(CacheContract cache, String autoniqUserId){
        //Some non-key user details can change, but user cannot change
        //Autoniq Account non-key details can change
        //Autoniq Account key details can chage
        //  to another existing AAccount? --> associate Contact with the otherAAccount.
        //  What happens to Sub, SubItems, and other objects
        //    
        //  to a new AAccount? --> create and associate Contact to the new AAcount
        //    What happens to Sub, SubItems, and other objects
        System.debug('=========> updateProfile entered');
        System.debug('=========> updateProfile Cache: ' + cache);
        
        CacheContract.UserDetail c = cache.UserDetail;
        list<Contact> contactList;
        if(c!=null && c.autoniqUserId!=null){
            System.debug('=========> updateProfile c.autoniqUserId: ' + cache.userDetail.autoniqUserId);
            contactList = [SELECT firstName, lastName,Autoniq_User_ID__c, (SELECT Id FROM Subscription__r limit 1) FROM Contact WHERE Autoniq_User_ID__c = :c.autoniqUserId];
        }else{
            contactList = [SELECT firstName, lastName,Autoniq_User_ID__c, (SELECT Id FROM Subscription__r limit 1) FROM Contact Where Autoniq_User_ID__c=: autoniqUserId];
        }
        System.debug('=======> updateProfile contactList ' + contactList);
        if(!contactList.isEmpty()){
            Contact con = contactList[0];
            if(c!=null){
                c.id= con.id;
            }
            // update contact
            if(c!=null && (c.lastName != null || c.firstName != null || c.email != null || c.mobile != null || c.altPhone != null || c.repAuctionAccessNumber!= null)){
                CacheContractUtil.updateContact(con,c);
            } 
            // update Autoniq Account
            if(cache.accountDetail != null){
                CacheContractUtil.updateAutoniqAccount(cache, autoniqUserId);
            }
        }else{
            ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
            String msg = 'No contact exists by the given autoniqUserId';
            CacheContractUtil.setupErrorResponse(msg, ATNQConstants.USER_NOT_FOUND_ERROR, (c!=null?c.Id:null));
            return;
        }
        if(c!=null && c.autoniqUserId!=null){
            CacheContractUtil.setupSuccessResponse(c.autoniqUserId);
        }else{
            CacheContractUtil.setupSuccessResponse(null);
        }
        //return;
    }
    
    /*public static CacheContract updatePassword(CacheContract cache){
        //self explanatory
        return null;
    } */
    
    public static void updateBillingDetails(CacheContract cache, String autoniqUserId){
        // Which Objects are changing
        if(cache.userDetail == null){
            cache.userDetail = new CacheContract.UserDetail();
        }
        cache.userDetail.autoniqUserId = autoniqUserId;
 
        list<Contact> contactList = [SELECT firstName, lastName, (SELECT Id FROM Subscription__r limit 1) FROM Contact 
                                            WHERE Autoniq_User_ID__c = :autoniqUserId];
 
        System.debug('=======> contactList ' + contactList);
        if(!contactList.isEmpty()){
            Contact con = contactList[0];
            if(con.Subscription__r != null && !con.Subscription__r.isEmpty()){
                if(cache.PaymentProfile != null){
                    List<Autoniq_Subscription_Payment_Profile__c> existingPaymentProfileList = [SELECT id FROM Autoniq_Subscription_Payment_Profile__c WHERE Autoniq_Subscription__c = :con.Subscription__r[0].id ];
                    if(!existingPaymentProfileList.isEmpty()){
                        Autoniq_Subscription_Payment_Profile__c existingPaymentProfile = existingPaymentProfileList[0];
                        CacheContractUtil.updatePaymentProfile(cache,existingPaymentProfile);

                    }else{
                        ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
                        String msg = 'Subscription under the given contact does not have a payment profile defined';
                        CacheContractUtil.setupErrorResponse(msg, ATNQConstants.ATNQ_PAYMENTPROFILE_PROCESSING_EXCEPTION, cache.userDetail.autoniqUserId);
                        return;
                    }
                }
            }
            
        }else{
            ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
            String msg = 'No contact exists by the given autoniqUserId';
            CacheContractUtil.setupErrorResponse(msg, ATNQConstants.USER_NOT_FOUND_ERROR, cache.userDetail.autoniqUserId);
            return;
        }
        CacheContractUtil.setupSuccessResponse(cache.userDetail.autoniqUserId);
    }
    
   /* public static CacheContract updateSubscriptions(CacheContract cache){
        //Not changed through the App - so nothing to do here
        //placeholder for possible future changes
        return null;
    }
    */
    
    public static void updateIntegrations(CacheContract cache, String autoniqUserId){
        // Which Object(s) are changing.
        if(cache.userDetail == null){
            cache.userDetail = new CacheContract.UserDetail();
        }
        cache.userDetail.autoniqUserId = autoniqUserId;
        list<Contact> contactList = [SELECT firstName, lastName, (SELECT Id FROM Subscription__r limit 1) FROM Contact 
                                            WHERE Autoniq_User_ID__c = :autoniqUserId];
        if(!contactList.isEmpty()){
            Contact con = contactList[0];
            list<Subscription_Item__c> siList = [SELECT Id FROM Subscription_Item__c WHERE Subscription__c = :con.Subscription__r[0].id];
            if(!siList.isEmpty()){
                if(cache.VhrSettings != null){
                    if(cache.VhrSettings.carfaxEnabled==true){
                        List<Subscription_Item__c> subscriptionItemList = [SELECT Product__r.Name, 
                                (SELECT Username__c, Password__c, Auto_Purchase__c FROM Autoniq_Third_Party_Items__r)
                            FROM Subscription_Item__c WHERE Subscription__c = :con.Subscription__r[0].id AND Product__r.Name = 'CarFax'];
                        
                        if(!subscriptionItemList.isEmpty()){
                            if(!subscriptionItemList[0].Autoniq_Third_Party_Items__r.isEmpty()){
                                CacheContractUtil.updateThirdPartyItem_CarFax(cache,subscriptionItemList[0].Autoniq_Third_Party_Items__r[0]);
                            }else{
                               // ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
                               // String msg = 'The subscription item does not have a third party item for the product CarFax.';
                               // CacheContractUtil.setupErrorResponse(msg, ATNQConstants.ATNQ_THIRD_PARTY_ITEM_ERROR, cache.userDetail.autoniqUserId);
                               CacheContractUtil.insertThirdPartyItem_CarFax(cache,subscriptionItemList[0].id);

                                //return;
                            }   
                            
                        }else{
                            ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
                            String msg = 'The subscription under the given contact does not have a subscription item for the product CarFax.';
                            CacheContractUtil.setupErrorResponse(msg, ATNQConstants.ATNQ_SUBSCRIPTION_ITEM_ERROR, cache.userDetail.autoniqUserId);
                            return;
                        }
                        
                    }
                    if(cache.VhrSettings.autoCheckEnabled==true){
                        List<Subscription_Item__c> subscriptionItemList = [SELECT Product__r.Name, 
                                (SELECT Username__c, Password__c, Auto_Purchase__c FROM Autoniq_Third_Party_Items__r)
                            FROM Subscription_Item__c WHERE Subscription__c = :con.Subscription__r[0].id AND Product__r.Name = 'AutoCheck'];
                        if(!subscriptionItemList.isEmpty()){
                            if(!subscriptionItemList[0].Autoniq_Third_Party_Items__r.isEmpty()){
                                CacheContractUtil.updateThirdPartyItem_AutoCheck(cache,subscriptionItemList[0].Autoniq_Third_Party_Items__r[0]);
                            }else{
                               // ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
                               // String msg = 'The subscription item does not have a third party item for the product AutoCheck.';
                               // CacheContractUtil.setupErrorResponse(msg, ATNQConstants.ATNQ_THIRD_PARTY_ITEM_ERROR, cache.userDetail.autoniqUserId);
                               // return;
                               CacheContractUtil.insertThirdPartyItem_AutoCheck(cache,subscriptionItemList[0].id);

                            }
                        }else{
                            ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
                            String msg = 'The subscription under the given contact does not have a subscription item for the product AutoCheck.';
                            CacheContractUtil.setupErrorResponse(msg, ATNQConstants.ATNQ_SUBSCRIPTION_ITEM_ERROR, cache.userDetail.autoniqUserId);
                            return;
                        }
                    }

                }
                
                //Update AAX

                if(cache.aax!=null && String.ISNOTBLANK(cache.aax.aaxClientId)){
                    List<Subscription_Item__c> subscriptionItemList = [SELECT Product__r.Name, 
                            (SELECT AAX_Client_ID__c, AAX_Dealer_ID__c, AAX_User_ID__c, AAX_Security_Token__c FROM Autoniq_Third_Party_Items__r)
                        FROM Subscription_Item__c WHERE Subscription__c = :con.Subscription__r[0].id AND Product__r.Name = 'AAX Integration'];
                    if(!subscriptionItemList.isEmpty()){
                        if(!subscriptionItemList[0].Autoniq_Third_Party_Items__r.isEmpty()){
                            CacheContractUtil.updateThirdPartyItem_AAX(cache,subscriptionItemList[0].Autoniq_Third_Party_Items__r[0]);
                        }else{
                            ////ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
                            //String msg = 'The subscription item does not have a third party item for the product AAX Integration.';
                            //CacheContractUtil.setupErrorResponse(msg, ATNQConstants.ATNQ_THIRD_PARTY_ITEM_ERROR, cache.userDetail.autoniqUserId);
                           // return;
                           CacheContractUtil.insertThirdPartyItem_AAX(cache,subscriptionItemList[0].id);

                        }
                        
                    }else{
                        ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
                        String msg = 'The subscription under the given contact does not have a subscription item for the product AAX Integration.';
                        CacheContractUtil.setupErrorResponse(msg, ATNQConstants.ATNQ_SUBSCRIPTION_ITEM_ERROR, cache.userDetail.autoniqUserId);
                        return;
                    }
                                    
                } 

            }else{
                ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
                String msg = 'The subscription under the given contact does not have any subscription item.';
                CacheContractUtil.setupErrorResponse(msg, ATNQConstants.ATNQ_SUBSCRIPTION_ITEM_ERROR, cache.userDetail.autoniqUserId);
                return;
            }
        }else{
            ATNQCacheContractResponse.ResponseError excptionError= new ATNQCacheContractResponse.ResponseError();
            String msg = 'No contact exists by the given autoniqUserId';
            CacheContractUtil.setupErrorResponse(msg, ATNQConstants.USER_NOT_FOUND_ERROR, cache.userDetail.autoniqUserId);
            return;
        } 
        CacheContractUtil.setupSuccessResponse(cache.userDetail.autoniqUserId);
    }
    
    public static List<Contact> createContactByUserIdIndex(Integer firstValue, Integer count){
        if(firstValue<0 || firstValue>5){
            firstValue = 1;
        }
        if(count>4){
            count = 4;
        }
        List<Contact> cList = new List<Contact>();
        Contact c;
        for(integer i=firstValue; i<firstValue+count; i++){
            
            c = new Contact(
                Process_Identifier__c = 'Autoniq',
                FirstName   = 'Fname_' + i, 
                LastName    = 'Lname_' + i, 
                Email       = 'Email_' + i + '@test.com',
                Alternate_Email__c = 'AltEmail_' + i + '@test.com',
                RecordTypeId = autoniqContactRecordTypeId,
                Active__c = true,
                Autoniq_User_ID__c  = 'User_Id_' + i + '@test.com',
                MobilePhone = '20' + i + '555123' + i,
                Alternate_Phone__c  = '30' + i + '777123' + i,
                Internal_User__c    = false,
                Rep_Auction_Access_Number__c = '123' + i + '789');
            cList.add(c);
        }
        insert cList;
        return cList;
    }
    
    public static List<Autoniq_Account__c> createAutoniqAccountByNameIndex(Integer firstValue, Integer count){
        if(firstValue<0 || firstValue>5){
            firstValue = 1;
        }
        if(count>4){
            count = 4;
        }
        List<Autoniq_Account__c> contactList = new List<Autoniq_Account__c>();
        for(integer i=firstValue; i<firstValue+count;i++){
            contactList.add(getIndexedAAccoount(i));
        }
        insert contactList;
        return contactList;
    }
    
    public static Autoniq_Account__c getIndexedAAccoount(Integer i){
        Autoniq_Account__c  anAcc = new Autoniq_Account__c(
            AccountStatus__c  = 'Active',
            Name = 'AAccName_' + i,
            //Account_Type__c = aac.accountType,
            Dealership_AuctionACCESS_Number__c = 'DAAN_' + i,
            Street__c = 'line1Add_' + i,
            Street_2__c = 'line2Add_' + i,
            City__c = 'City_' + i,
            Country__c = 'United States',
            Email__c = 'acc_' + i + '_email@test.com',
            //Latitude__c = '8.00' + i,
            //Longitude__c = '0.80' + i,
            Phone__c = '201333678' + i,
            PostalCode__C = '60061',
            State__c = 'Illinois');

            return anAcc;
    }
    
    public static String getIndexedCacheContract(integer i){
        
        String cache = '{' + 
        '"vhrSettings": {' +
        '"carfaxPasswd": "carfaxpaswrd34' + i + '",'+
        '"carfaxId": "C52109234' + i + '",'+
        '"carfaxEnabled": null,'+
        '"carfaxAutoPurchase": true,'+
        '"autoCheckPasswd": "autochk23' + i + '",'+
        '"autoCheckId": "C52109234' + i + '",'+
        '"autoCheckGateway": null,'+
        '"autoCheckEnabled": null,'+
        '"autoCheckAutoPurchase": true'+
    '},'+
    '"userDetail": {'+
        '"userAuctionAccessNumber": null,'+
        '"salutation": null,'+
        '"repAuctionAccessNumber": ' + 44 + i + ','+
        '"password": null,'+
        '"mobile": "31211177731",'+
        '"lastName": "Man3' + i + '",'+
        '"internalUserId": null,'+
        '"internalUser": true,'+
        //'"id": "0032D00000CNJ9SQAX",'+
        '"firstName": "demo3' + i + '",'+
        '"email": "demo3' + i +'@autoniq.com",'+
        '"autoniqUserId": "UserX' + i + '@email.com",'+
        '"autoniqAccountId": null,'+
        '"altPhone": "8472225531",'+
        '"altEmail": "man13' + i + '@email.com"'+
    '},'+
    '"transactions": null,'+
    '"tableDomains": null,'+
    '"subscriptionItems": {'+
        '"subscriptionItemList": ['+
            '"CF",'+
            '"AAX",'+
            '"AC"'+
        ']'+
    '},'+
    '"preferences": null,'+
    '"paymentProfile": {'+
        '"paymentType": "Credit Card",'+
        '"creditCardType": "Visa",'+
        '"customerShippingAddressId": null,'+
        '"customerProfileId": null,'+
        '"customerPaymentProfileId": null,'+
        '"creditCardCode": "631",'+
        '"ccNumberMasked": "4735",'+
        '"ccLastError": null,'+
        '"ccExp": "11/12",'+
        '"billingZip": "60634",'+
        '"billingState": "Nebraska",'+
        '"billingLastName": "bLastNameX' + i + '",'+
        '"billingFirstName": "bFirstNameX' + i + '",'+
        '"billingCountry": "US",'+
        '"billingCity": "Benton Harbor",'+
        '"billingAddress2": "Billing Suite X' + i + '",'+
        '"promotionalCode":"someText' + i + '",'+
        '"billingAddress1": "13' + i + ' Billing Street"'+
    '},'+
    '"packages": null,'+
    '"options": null,'+
    '"doWeNeedThese": null,'+
    '"accountDetail": {'+
        '"state": "Illinolis",'+
        '"referrer": "myself",'+
        '"postCode": "60031",'+
        '"phone": "3125556789",'+
        '"noOfSubscriptions": null,'+
        '"longitude": 13' + i + ','+
        '"latitude": 83' + i + ','+
        //'"id": "a5R2D000000KoMrUAK",'+
        '"fax": null,'+
        '"email": "testdemo3' + i + '@emailnew.com",'+
        '"country": "United States",'+
        '"city": "Loment",'+
        '"autoniqAccountName": "Test Account demo3' + i + '",'+
        '"auctionAccessNumber": "1234",'+
        '"altPhoneCountryCode": "United States",'+
        '"address2": "Account 3' + i + '",'+
        '"address": "20203' + i + ' Account Terrace",'+
        '"accountType": "Franchise Dealer",'+
        '"accountStatus": "Active"'+
    '},'+
    '"aax": {"aaxUserId": null,"aaxSecurityToken": null,"aaxDealerId": null,"aaxClientId": null}'+
'}';
    System.debug('==================> getIndexedCacheContract returning: ' + cache);
    return cache;
    }
    
    public static String getIndexedCacheContractUpdate(integer i, integer j){
        
        String cache = '{' + 
        '"vhrSettings": {' +
        '"carfaxPasswd": "carfaxpaswrd34' + (i+j) + '",'+
        '"carfaxId": "C52109234' + (i+j) + '",'+
        '"carfaxEnabled": null,'+
        '"carfaxAutoPurchase": true,'+
        '"autoCheckPasswd": "autochk23' + (i+j) + '",'+
        '"autoCheckId": "C52109234' + (i+j) + '",'+
        '"autoCheckGateway": null,'+
        '"autoCheckEnabled": null,'+
        '"autoCheckAutoPurchase": true'+
    '},'+
    '"userDetail": {'+
        '"userAuctionAccessNumber": null,'+
        '"salutation": null,'+
        '"repAuctionAccessNumber": null,'+
        '"password": null,'+
        '"mobile": "3121117773' + (i+j) + '",'+
        '"lastName": "Man3' + (i+j) + '",'+
        '"internalUserId": null,'+
        '"internalUser": true,'+
        //'"id": "0032D00000CNJ9SQAX",'+
        '"firstName": "demo3' + (i+j) + '",'+
        '"email": "demo3' + (i+j) +'@autoniq.com",'+
        '"autoniqUserId": "men3' + i + '@email.com",'+
        '"autoniqAccountId": null,'+
        '"altPhone": "847222553' + (i+j) + '",'+
        '"altEmail": "man13' + (i+j) + '@email.com"'+
    '},'+
    '"transactions": null,'+
    '"tableDomains": null,'+
    '"subscriptionItems": {'+
        '"subscriptionItemList": ['+
            '"CF",'+
            '"AAX",'+
            '"AC"'+
        ']'+
    '},'+
    '"preferences": null,'+
    '"paymentProfile": {'+
        '"paymentType": "Credit Card",'+
        '"creditCardType": "Visa",'+
        '"customerShippingAddressId": null,'+
        '"customerProfileId": null,'+
        '"customerPaymentProfileId": null,'+
        '"creditCardCode": "63' + (i+j) + '",'+
        '"ccNumberMasked": "473' + (i+j) + '",'+
        '"ccLastError": null,'+
        '"ccExp": "11/1' + (i+j) + '",'+
        '"billingZip": "60634",'+
        '"billingState": "Nebraska",'+
        '"billingLastName": "bLastName3' + (i+j) + '",'+
        '"billingFirstName": "bFirstName3' + (i+j) + '",'+
        '"billingCountry": "US",'+
        '"billingCity": "Benton Harbor",'+
        '"promotionalCode":"someText' + (i+j) + '",'+
        '"billingAddress2": "Billing Suite 23' + (i+j) + '",'+
        '"billingAddress1": "13' + (i+j) + ' Billing Street"'+
    '},'+
    '"packages": null,'+
    '"options": null,'+
    '"doWeNeedThese": null,'+
    '"accountDetail": {'+
        '"state": "Illinolis",'+
        '"referrer": null,'+
        '"postCode": "6003' + (i+j) + '",'+
        '"phone": null,'+
        '"noOfSubscriptions": null,'+
        '"longitude": 13' + (i+j) + ','+
        '"latitude": 83' + (i+j) + ','+
        //'"id": "a5R2D000000KoMrUAK",'+
        '"fax": null,'+
        '"email": "testdemo3' + (i+j) + '@emailnew.com",'+
        '"country": "United States",'+
        '"city": "Loment",'+
        '"autoniqAccountName": "Test Account demo3' + i + '",'+
        '"auctionAccessNumber": null,'+
        '"altPhoneCountryCode": null,'+
        '"address2": "Account 3' + (i+j) + '",'+
        '"address": "20203' + (i+j) + ' Account Terrace",'+
        '"accountType": "Franchise Dealer",'+
        '"accountStatus": "Active"'+
    '},'+
    '"aax": {"aaxUserId": null,"aaxSecurityToken": null,"aaxDealerId": null,"aaxClientId": null}'+
'}';
    return cache;
    }
}