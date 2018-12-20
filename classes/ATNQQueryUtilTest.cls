@isTest
public class ATNQQueryUtilTest {
    
    private static List<Product2> prods = new List<Product2>();
    //private static List<Id> subIdList = new List<Id>();
    //private static List<Autoniq_Account__c> AAccIdList = new List<Autoniq_Account__c>();
    //private static List<Contact> contactIdList = new List<Contact>();
    
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
        
        String json1 = CacheContractUtil.getIndexedCacheContract(1);
        String updatedJson1 = CacheContractUtil.getIndexedCacheContractUpdate(1,4);
        
        String json2 = CacheContractUtil.getIndexedCacheContract(2);
        String updatedJson2 = CacheContractUtil.getIndexedCacheContractUpdate(2,4);
        
        String json3 = CacheContractUtil.getIndexedCacheContract(3);
        String updatedJson3 = CacheContractUtil.getIndexedCacheContractUpdate(3,4);
        
        String json4 = CacheContractUtil.getIndexedCacheContract(4);
        String updatedJson4 = CacheContractUtil.getIndexedCacheContractUpdate(4,4);
        
		ATNQCacheContractService.processPost(json1);        
        ATNQCacheContractService.processPost(json2);        
        ATNQCacheContractService.processPost(json3);        
        ATNQCacheContractService.processPost(json4); 
    }
    
    private static Id autoniqContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Autoniq').getRecordTypeId();        


    @isTest
    private static void getContactsByAutoniqUserIdTest(){
        
        Test.startTest();
        List<Contact> cList = CacheContractUtil.createContactByUserIdIndex(1,5);
        ATNQQueryUtil.getContactsByAutoniqUserId('User_Id_3@test.com');
        Contact testContact = cList[2];
        System.assert(testContact.FirstName=='Fname_3','Excpected Fname_3, Actual value: ' + testContact.FirstName);
        System.assert(testContact.Alternate_Phone__c=='3037771233', 'Excpected 3037771233 actual value: ' + testContact.Alternate_Phone__c);
        Test.stopTest();
        
    }
    
    @isTest
    private static void getAutoniqAccountsByNameTest(){
        Test.startTest();
        List<Autoniq_Account__c> aList = CacheContractUtil.createAutoniqAccountByNameIndex(1,5);
        ATNQQueryUtil.getAutoniqAccountsByName('AAccName_2');
        Autoniq_Account__c testAccount = aList[1];
        System.assert(testAccount.Name=='AAccName_2','Excpected AAccName_2, Actual value: ' + testAccount.Name);
        System.assert(testAccount.Phone__c == '2023336782', 'Excpected 2023336782 actual value: ' + testAccount.Phone__c);
        Test.stopTest();
    }
    
    @isTest
    private static void getProductsTest(){
        Map<String,Product2> codeProductMap = new Map<String,Product2>();
        Test.startTest();
        List<Product2> prodList = ATNQQueryUtil.getProducts();
        for(Product2 p: prodList){
            codeProductMap.put(p.ProductCode,p);
        }
        System.assert(codeProductMap.get('CF')!=null, 'Expected CarFax entry missing');
        System.assert(codeProductMap.get('AC').Name=='AutoCheck', 'Expected name AutoCheck, actual value: ' + codeProductMap.get('AC').Name);
        Test.stopTest();
    }
    
    @isTest
    private static void getPaymentProfilesBySubscriptionIdTest(){
        
        List<Subscription__c> sl = [Select Promo_Code__c, Status__c,Autoniq_Account__c,Contact__c,Next_Bill_Date__c  From Subscription__c ];
        System.debug('=======================> sl: ' + sl);
        if(sl.size()>0){
        	ATNQQueryUtil.getPaymentProfilesBySubscriptionId(sl[0].Id);
        }
    }
    @isTest
    private static void getUserApplicationSettingsByIdTest(){
        
    }
    @isTest
    private static void getSubscriptionsByAutoniqAccountIdTest(){
        List<Autoniq_Account__c> accIdLIst = [Select Id From Autoniq_Account__c];
        if([Select Id From Autoniq_Account__c].size()>0){
        	ATNQQueryUtil.getSubscriptionsByAutoniqAccountId([Select Id From Autoniq_Account__c][0].Id);
        }
    }
    
    @isTest
    private static void getSubscriptionItemsBySubscriptionIdTest(){
        List<Subscription__c> sl = [Select Promo_Code__c, Status__c,Autoniq_Account__c,Contact__c,Next_Bill_Date__c  From Subscription__c ];
        if(sl.size()>0){
            ATNQQueryUtil.getSubscriptionItemsBySubscriptionId(sl[0].Id);
        }
    }
    
    @isTest
    private static void getLatestCacheContractForContactTest(){

        List<Contact> cList = [Select Id From Contact];
        
        if(cList.size()>0){
            cList = [SELECT FirstName, LastName, Email, Alternate_Email__c, MobilePhone, Alternate_Phone__c,
                                            Rep_Auction_Access_Number__c, Autoniq_User_ID__c, Internal_User__c, OtherPhone,
                                            Autoniq_Account__c, Autoniq_Account__r.Name, Internal_User_ID__c,
                                            Autoniq_Account__r.Auction_Access_Number__c, Autoniq_Account__r.Street__c, 
                                            Autoniq_Account__r.City__c, Autoniq_Account__r.State__c, Autoniq_Account__r.PostalCode__c, 
                                            Autoniq_Account__r.Country__c
                                            FROM Contact WHERE Id=: cList[0].Id
                                        ];
                    	}
        if(cList.size()>0){
        	ATNQQueryUtil.getLatestCacheContractForContact(cList[0]);
        }
    }
    
}