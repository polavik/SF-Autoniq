@isTest
public class ATNQJsonParserUtilTest {
    
    private static List<Product2> prods;
    
    @testSetup
    private static void setupCommonObjects(){

        List<Product2> prodList = new List<Product2>();
        Product2 p1 = new Product2(Family='Products', ProductCode='CF',Name='CarsFax');
        Product2 p2 = new Product2(Family='Products', ProductCode='AC',Name='AutoCheck');
        Product2 p3 = new Product2(Family='Products', ProductCode='AAX',Name='AAX Integration');
        prodList.add(p1);
        prodList.add(p2);
        prodList.add(p3);
        insert prodList;
        prods = prodList;
    }
    
    private static final String userFirstName 	= 'uFname';
    private static final String userLastName 	= 'uLname';
    private static final String userMobile 		= '8475551234';
    private static final String userAltPhone 	= '8475554321';
    private static final String userAltEmail 	= 'altUser@email.com';
    private static final String userEmail 	= 'user@email.com';
    private static final String userAutoniqUserId = 'usr@autoniq.com';
    private static final String userPasswors	= 'uPassword';
    private static final String userRepAutionAccessNumber = '34567';
    private static final String userUserAuctionAccessNumber = '76543';
    private static final String userInternalUser = 'true';   
    
    private static final String jsonUserDetail = '{"firstName":"' + userFirstName + '","lastName":"' + userLastName + '","mobile":"' + userMobile + '","email":"' + userEmail + '","altEmail":"' + userAltEmail + '","altPhone":"' + userAltPhone + '","autoniqUserId":"' + userAutoniqUserId + '","password":"' + userPasswors + '","repAuctionAccessNumber":"' + userRepAutionAccessNumber + '","userAuctionAccessNumber":"' + userUserAuctionAccessNumber + '","internalUser":' + userInternalUser + '}';
    
    private static final String accAccountStatus = 'Active';
	private static final String accAutoniqAccountName = 'Autoniq Account Name';
	private static final String accAuctionAccessNumber = '1234567';
	private static final String accCity = 'Account City';
	private static final String accState = 'Account State';
	private static final String accCountry = 'Account Country';
	private static final String accAddress = 'Account Address';
	private static final String accAddress2 = 'Account Address2';
	private static final String accFax = '2025554444';
	private static final Decimal accLattitude = 0.888;
	private static final Decimal accLongitude = 8.001;
	private static final String accEmail = 'Acc@email.com';
	private static final Integer accNoOfSubscriptions = 1;
	private static final String accPhone = '3125551111';
	private static final String accPostCode = '91111';
	private static final String accAccountYpe = 'Franchise Dealer';
    
	private static final String jsonAccountDetail = '{"accountStatus":"' + accAccountStatus + '","autoniqAccountName":"' + accAutoniqAccountName + '", "auctionAccessNumber":"'  + accAuctionAccessNumber + '", "city":"' + accCity + '","country":"' + accCountry + '","address":"' + accAddress + '","address2":"' + accAddress2 + '", "email":"' + accEmail + '","fax":"' + accFax + '","latitude":' + accLattitude + ',"longitude":' + accLongitude + ',"noOfSubscriptions":' + accNoOfSubscriptions + ',"phone":"' + accPhone + '","postCode":"' + accPostCode + '","state":"' + accState + '","accountType":"' + accAccountype + '"}';

    private static final String jsonCacheContract = '{"AccountDetail":{"accountStatus":"' + accAccountStatus + '","autoniqAccountName":"' + accAutoniqAccountName + '", "auctionAccessNumber":"'  + accAuctionAccessNumber + '", "city":"' + accCity + '","country":"' + accCountry + '","address":"' + accAddress + '","address2":"' + accAddress2 + '", "email":"' + accEmail + '","fax":"' + accFax + '","latitude":' + accLattitude + ',"longitude":' + accLongitude + ',"noOfSubscriptions":' + accNoOfSubscriptions + ',"phone":"' + accPhone + '","postCode":"' + accPostCode + '","state":"' + accState + '","accountType":"' + accAccountype + '"},"UserDetail":{"firstName":"' + userFirstName + '","lastName":"' + userLastName + '","mobile":"' + userMobile + '","email":"' + userEmail + '","altEmail":"' + userAltEmail + '","altPhone":"' + userAltPhone + '","autoniqUserId":"' + userAutoniqUserId + '","password":"' + userPasswors + '","repAuctionAccessNumber":"' + userRepAutionAccessNumber + '","userAuctionAccessNumber":"' + userUserAuctionAccessNumber + '","internalUser":' + userInternalUser + '}}';
	
    
    @isTest
    private static void converJasonUserToSFContactTest(){
        
        ATNQJsonParserUtil util = new ATNQJsonParserUtil();
        Contact myObject;
        myObject = (Contact)util.converJasonToSFsObject(jsonUserDetail,'Contact',util.jsonUserDetailToContactMap);
        System.assert(myObject!=null);
        System.debug('=========> Contact: ' + myObject);
        System.assert(myObject.Phone == userMobile,'Expecting ' + userMobile + ' actual: ' + myObject.Phone);
    }
    
    @isTest
    private static void converJasonToSFObjectsTest(){
        
        ATNQJsonParserUtil util = new ATNQJsonParserUtil();
        CacheContract cc = new CacheContract();
        CacheContract myObject;
        System.debug('========> testJsonInput : ' + jsonCacheContract);
        myObject = (CacheContract) JSON.deserialize(jsonCacheContract, CacheContract.class);
        System.debug('========> Cache Contract : ' + myObject);
        CacheContract.AccountDetail ad = myObject.accountDetail;
        System.debug('========> Cache Contrac Accountt : ' + ad);
        CacheContract.userDetail ud = myObject.userDetail;
        System.debug('========> Cache Contract Contact : ' + ud);
        String adJson = JSON.serialize(ad);
        
        System.debug('========> Accoiunt json : ' + adJson);
        String udJson = JSON.serialize(ud);
        System.debug('========> Contact Json : ' + udJson);
        Contact myContact = (Contact)util.converJasonToSFsObject(udJson,'Contact',util.jsonUserDetailToContactMap);
        System.debug('========> myContact : ' + myContact);
        Autoniq_Account__c myAccount = (Autoniq_Account__c)util.converJasonToSFsAutoniqAccount(adJson);
        System.debug('========> myAccount : ' + myAccount);
        System.assert(myObject!=null);
        System.assert(myContact!=null);
        System.assert(myAccount!=null);
        System.debug('========> Contact: ' + myContact);
        System.debug('========> Account: ' + myAccount);
        //Account testAccount = new Account();
        //insert testAccount;
        //myAccount.Account__c = testAccount.Id;
        insert myContact;
        insert myAccount;
        
        //Account account = [select Id from Account limit 1];
        Autoniq_Account__c acc;
        Contact c;
        try{
        	acc = [select Id,City__c, Phone__c from Autoniq_Account__c limit 1 ];
        }catch(Exception e){
            System.debug('========> No Autoniq Accout found');
            System.assert(false,'No Autoniq Accout found');
        }
        
        try{
        	 c = [select Id,Autoniq_User_Id__c, Phone, Alternate_Phone__c, OtherPhone from Contact limit 1 ];
        }catch(Exception e){
            System.debug('========> No Contact found');
            System.assert(false,'No Contact found');
        }
        System.assert(acc.City__c==accCity,'Expecting ' + accCity + ' actual ' + acc.City__c);
    }
    
    @isTest
    private static void converJasonToSFObjectsTest2(){
        
        ATNQJsonParserUtil util = new ATNQJsonParserUtil();
        CacheContract cc = new CacheContract();
        CacheContract myObject;
        System.debug('========> testJsonInput : ' + jsonCacheContract);
        myObject = (CacheContract) JSON.deserialize(jsonCacheContract, CacheContract.class);
        System.debug('========> Cache Contract : ' + myObject);
        CacheContract.AccountDetail ad = myObject.accountDetail;
        System.debug('========> Cache Contrac Accountt : ' + ad);
        CacheContract.userDetail ud = myObject.userDetail;
        System.debug('========> Cache Contract Contact : ' + ud);
        String adJson = JSON.serialize(ad);
        
        System.debug('========> Accoiunt json : ' + adJson);
        String udJson = JSON.serialize(ud);
        System.debug('========> Contact Json : ' + udJson);
        Contact myContact = (Contact)util.converJasonToSFsObject(udJson,'Contact',util.jsonUserDetailToContactMap);
        System.debug('========> myContact : ' + myContact);
        Autoniq_Account__c myAccount = (Autoniq_Account__c)util.converJasonToSFsAutoniqAccount(adJson);
        System.debug('========> myAccount : ' + myAccount);
        System.assert(myObject!=null);
        System.assert(myContact!=null);
        System.assert(myAccount!=null);
        System.debug('========> Contact: ' + myContact);
        System.debug('========> Account: ' + myAccount);
        //Account testAccount = new Account();
        //insert testAccount;
        //myAccount.Account__c = testAccount.Id;
        insert myContact;
        insert myAccount;
        
        //Account account = [select Id from Account limit 1];
        Autoniq_Account__c acc = [select Id,City__c, Phone__c, Fax__c from Autoniq_Account__c limit 1 ];
        Contact c = [select Id,login_Id__c, phone, otherPhone,Alternate_Phone__c, Autoniq_User_ID__c from Contact limit 1 ];
        System.assert(acc.City__c==accCity,'Expecting ' + accCity + ' Actual : ' + acc.City__c);
    }
    
    @isTest
    private static void createAccountDetailWithAutoniqAccountDataTest(){
        ATNQJsonParserUtil util = new ATNQJsonParserUtil();
        CacheContract cache = (CacheContract) JSON.deserialize(jsonCacheContract, CacheContract.class);
        String adJson = JSON.serialize(cache.accountDetail);
        Autoniq_Account__c account = (Autoniq_Account__c)util.converJasonToSFsAutoniqAccount(adJson);
        ATNQJsonParserUtil.createAccountDetailWithAutoniqAccountData(account);
    }
    
    @isTest
    private static void createUserDetailWithContactDataTest(){
        ATNQJsonParserUtil util = new ATNQJsonParserUtil();
        Contact myObject;
        myObject = (Contact)util.converJasonToSFsObject(jsonUserDetail,'Contact',util.jsonUserDetailToContactMap);
    }

    public Class TargetObject {
        public String Field1;
    }

    //private static final Map<String,String> jsonToTargetObjectFieldMap = new Map<String,String>{'fieldOne' => 'Phone'};
}