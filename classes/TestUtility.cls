/*
*Appirio Inc. 2016
*Name  : TestUtility
*Author: Amit SanWariya (Appirio)
*Date  : 12 Oct, 2016
*Description: For test data creation
*/
@isTest
public class TestUtility {
    //Method to create Opportunity
    public static Opportunity createOpportunity(Integer i, Id accountId, Boolean isInsert){
        Opportunity opp = new Opportunity(Name = 'Opportunity'+i,
                                          AccountId = accountId,
                                          StageName = 'C - Customer Identification',
                                          CloseDate = System.Today()+45);
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    
    //Method to create Account
    public static Account createAccount(Integer i, Boolean isInsert ){
        Account acc = new Account(Name='Account'+i);
        if(isInsert){
            insert acc;
        }
        return acc;
    }
    
    //Method to create Purchase
    public static Purchase__c createPurchase( Integer i, Id accountId,  Boolean isInsert){
      Purchase__c Pur=new Purchase__c(Name= 'Purcahse'+i,
                                ATC_Seller__c=AccountId,
                                Segment_Name__c='ADESA INLANE',
                                Source_Id__c='Id'+i);
        
        if(isInsert){
           insert pur; 
        }  
        return Pur;
          
    }
    
    
    //Method to create Territory
    public static Territory__c createTerritory(String zipCode, String territory, Boolean isInsert) {
        Territory__c tert = new Territory__c(Name = zipCode,
                                             Zipcode__c = zipCode,
                                             ADESA_Territory_Name__c = territory);
        if(isInsert){
            insert tert;
        }
        return tert;
    }
    

    //Method to create Auction Detail
    public static Auction_Detail__c createAuctionDetail(Integer i, Id accountId, Boolean isInsert){
        Auction_Detail__c aucDetail = new Auction_Detail__c(Name = 'AuctionDetail'+i,
                                                            Account__c = accountId,
                                                            Source_Id__c = 'Source'+i,
                                                            Buyer_Category__c=' Never Purchased',
                                                            Last_Sell_Date__c=system.today()-30);
        if(isInsert){
            insert aucDetail;
        }
        return aucDetail;
    }    
    
    //Method to create a user to run test as
    public static User createTestUser(Boolean isInsert){
        User usr = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                            LastName = 'last',
                            Email = 'testuser@mail.com',
                            Username = 'testuseradesa@adesa.com',
                            Alias = 'alias',
                            Title = 'title',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US',
                            CompanyName = 'TEST');
        if(isInsert){
            insert usr;
        }
        return usr;
    }

    //creating test data account for AccountTriggerHandler_Test.cls
    public static List<Account> createAccountRecords(String name, Integer count, Boolean isInsert){
        List<Account> AccountList = new List<Account>();
        for(integer i=0; i<count; i++){
            Account acc = new Account();
            acc.name = name + String.valueOf(i);
            AccountList.add(acc);
        }
        if(isInsert){
            insert AccountList;
        }
        return AccountList;
    }
    //creating test data purchases for AccountTriggerHandler_Test.cls
    public static List<Purchase__c> createPurchaseRecords(String name, String sourceId, Id SellerId, Id BuyerId, Integer count, Boolean isInsert){
        List<Purchase__c> PurchaseList = new List<Purchase__c>();
        for(integer i=0; i<count; i++){
            Purchase__c pur = new Purchase__c();
            pur.name = name + String.valueOf(i);
            pur.Source_Id__c = sourceId + String.valueOf(i);
            pur.ATC_Seller__c = SellerId;
            pur.ATC_Buyer__c = BuyerId;
            PurchaseList.add(pur);
        }
        if(isInsert){
            insert PurchaseList;
        }
        return PurchaseList;
    }
    //creating test data Auction Details for AccountTriggerHandler_Test.cls
    public static List<Auction_Detail__c> createAuctionDetailRecords(String name, Id AccountId, String SourceId, Integer count, Boolean IsInsert){
        List<Auction_Detail__c> AuctionDetailList = new List<Auction_Detail__c>();
        for(integer i=0; i<count; i++){
            Auction_Detail__c aucD = new Auction_Detail__c();
            aucD.name = name + String.valueOf(i);
            aucD.Account__c = AccountId;
            aucD.Source_Id__c = SourceId + String.valueOf(i);
            AuctionDetailList.add(aucD);
        }
        if(isInsert){
            insert AuctionDetailList;
        }
        return AuctionDetailList;
    }


    //creating test data for SellerPortalConfigHelperTest
    public static List<Seller_Portal_Config__c> createSellerPortalConfig(){

         Account acc =  TestUtility.createAccount(1, true );

         List<Seller_Portal_Config__c> listCustObj = new List<Seller_Portal_Config__c>();
  
         listCustObj.add(new Seller_Portal_Config__c(Edit_Case_Comments__c = true,
                Edit_Case_Status__c = true, 
                Escalate_On__c = 'Case Created', 
                Internal_Owner__c = '00G13000004BZ82', 
                Private_Label__c ='AudiDirect', 
                Seller_Account__c = acc.Id,
                Send_Comment_Notifications__c = true));

         listCustObj.add(new Seller_Portal_Config__c(Edit_Case_Comments__c = true,
                Edit_Case_Status__c = true, 
                Escalate_On__c = 'Case Created', 
                Internal_Owner__c = '00G13000004BZ82', 
                Private_Label__c ='VolkswagenDirect', 
                Seller_Account__c = acc.Id,
                Send_Comment_Notifications__c = true));

        system.debug('--- listCustObj' + listCustObj);   
        insert listCustObj;

        return listCustObj;

    }

    //creating test data purchases for BatchUpdateAFCPurchase.cls
    public static List<Purchase__c> createPurchaseForAFCUpdate(String name, String sourceId, Integer count){

        List<Purchase__c> PurchaseList = new List<Purchase__c>();
        for(integer i=0; i<count; i++){
            Purchase__c pur = new Purchase__c();
            pur.name = name + String.valueOf(i);
            pur.Purchase_Type__c = 'testType123';
            pur.IAA_Branch_Name__c = null;
            pur.Car_Group__c = null;
            pur.Source_Id__c = sourceId + String.valueOf(i);
            PurchaseList.add(pur);
        }

        insert PurchaseList;
        return PurchaseList;
    }


    //Method to create a user to run test as
    public static User createUser(String preFix ){
        User usr = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                            LastName = 'last'+ preFix,
                            Email = 'testuser-'+ preFix +'@mail.com',
                            Username = 'testuseradesa-'+ preFix +'@adesa.com',
                            Alias = 'alias',
                            Title = 'title',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US',
                            CompanyName = 'TEST');
            insert usr;
               return usr;
    }


    //Method to create CarGroup
    public static Car_Group_Config__c createCarGroup(Integer i, Boolean isInsert, Integer grpType ){
        Car_Group_Config__c obj = new Car_Group_Config__c(Name='Car Group'+i, Car_Group_Type__c = grpType);
        if(isInsert){
            insert obj;
        }
        return obj;
    }


    //Method to create Asset for VehicleAfterInsertUpdateTest
    public static List<Asset__c> createAssets(Boolean isInsert, Integer count, String AuctionStatus, String systemId, String sourcePrefix, Id buyerAccId, Integer vehStatusId, Id CarGroupId, Date lstVehStatDt){
        List<Asset__c> assetList = new List<Asset__c>();
        for(integer i=0; i<count; i++){
            Asset__c asset = new Asset__c();
            asset.name = String.valueOf(i) + sourcePrefix;
            asset.Auction_Status__c = AuctionStatus;
            asset.System_id__c = systemId;
            asset.Source_Id__c = String.valueOf(i) + sourcePrefix;
            asset.Buyer_Account__c = buyerAccId;
            asset.Seller_account__c = buyerAccId;
            asset.Last_Vehicle_Status_Change__c = lstVehStatDt;
            asset.Vehicle_Status_Id__c = vehStatusId;
            asset.Car_Group__c = CarGroupId;
            assetList.add(asset);
        }
        if(isInsert){
            insert assetList;
        }
        return assetList;
    }

    //Method to create Property__c
    public static Property__c createProperty(String key, String value ){
        Property__c property = new Property__c(Name=Key, Property_Id__c = Key, Property_Value__c = value);
        insert property;
        return property;
    }    

    //Method to create Contact
    public static Contact createContact(Integer i, Boolean isInsert ){
        Contact con = new Contact(LastName='LastName'+i, FirstName='FirstName'+i);
        if(isInsert){
            insert con;
        }
        return con;
    }


    //Method to create Lead
    public static Lead createLead(Integer i, Boolean isInsert ){
        Lead lid = new Lead(LastName='LastName'+i, FirstName='FirstName'+i, Company='Company' + i);
        if(isInsert){
            insert lid;
        }
        return lid;
    }


    //Method to create Task
    public static Task createTask(Integer i, Boolean isInsert , Id WhoID){
        Task tsk = new Task(Subject='Subject'+i, Description='Description'+i, WhoId=WhoID);
        if(isInsert){
            insert tsk;
        }
        return tsk;
    }
    
    //Method to create Adesa_com_Detail__c
    public static Adesa_com_Detail__c createAdesaComDetail(Integer i, Boolean isInsert, String AtcOrganizationID, Id accountId){
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa'+i, ATC_Organization_ID__c=AtcOrganizationID,Account__c=accountId);
        if(isInsert){
            insert Adesa1;
        }
        return Adesa1;
    }

   //Method to create Asset__c
    public static Asset__c createAsset(Integer i, Boolean isInsert, String sourceId){
        Asset__c  asset = new Asset__c(Name='Asset'+i, Source_Id__c=sourceId);
        if(isInsert){
            insert asset;
        }
        return asset;
    }
    
    //Method to create Auction_Credit__c
    public static Auction_Credit__c createAuctionCredit(Boolean isInsert){
        Auction_Credit__c ac = new Auction_Credit__c();
        if(isInsert){
            insert ac;
        }
        return ac;        
    }
    
    //Method to create Rep_Status_ADESA_Auction__c
    public static Rep_Status_ADESA_Auction__c createRepStatusAdesaAuction(Integer i, Boolean isInsert){
        Rep_Status_ADESA_Auction__c objRepStatus = new Rep_Status_ADESA_Auction__c(Name='Rep_Status-ADESA_Auction' + i);
        if(isInsert){
            insert objRepStatus;
        }
        return objRepStatus;          
    } 
        
    //Method to create Vehicles_Sold_ADESA_Auction__c
    public static Vehicles_Sold_ADESA_Auction__c createVehiclesSoldAdesaAuction(Integer i, Boolean isInsert){
        Vehicles_Sold_ADESA_Auction__c objVehilceSold = new Vehicles_Sold_ADESA_Auction__c(Name='Vehicles_Sold-ADESA_Auction' + i);
        if(isInsert){
            insert objVehilceSold;
        }
        return objVehilceSold;            
    }
    
    //Method to create Vehicles_Purchased_ADESA_Auction__c
    public static Vehicles_Purchased_ADESA_Auction__c createVehiclesPurchasedAdesaAuction(Integer i, Boolean isInsert){
        Vehicles_Purchased_ADESA_Auction__c  objVehiclePurchased = new Vehicles_Purchased_ADESA_Auction__c(Name='Vehicles_Purch-ased_ADESA_Auction' + i);
        if(isInsert){
            insert objVehiclePurchased;
        }
        return objVehiclePurchased;           
    }
    
    //Method to create Case
    public static Case createCase(Boolean isInsert){
        Case ca = new Case();
        if(isInsert){
            insert ca;
        }
        return ca;        
    }  
    
    //Method to create Temp_Openlane_KAR_Case_Mapper__c
    public static Temp_Openlane_KAR_Case_Mapper__c createKarCaseMapper(Boolean isInsert){
        Temp_Openlane_KAR_Case_Mapper__c karCaseMapper = new Temp_Openlane_KAR_Case_Mapper__c();
        if(isInsert){
            insert karCaseMapper;
        }
        return karCaseMapper;        
    }     
    
    //Method to create Case_Escalation__c
    public static Case_Escalation__c createCaseEscalation(Boolean isInsert){
        Case_Escalation__c caseEscalation = new Case_Escalation__c();
        if(isInsert){
            insert caseEscalation;
        }
        return caseEscalation;        
    }
    
   //Method to create Cleanup_Properties__c
    public static Cleanup_Properties__c createCleanProperties(String name, Boolean isInsert ){
        Cleanup_Properties__c cp = new Cleanup_Properties__c(Name=name);
        if(isInsert){
            insert cp;
        }
        return cp;
    }
    
   //Method to create Call_Outcome_Log__c
    public static Call_Outcome_Log__c createCallOutcomeLog(Boolean isInsert ){
        Call_Outcome_Log__c callOutcomeLog = new Call_Outcome_Log__c();
        if(isInsert){
            insert callOutcomeLog;
        }
        return callOutcomeLog;
    } 
    
   //Method to create MVG_Price__c
    public static MVG_Price__c createMvgPrice(Boolean isInsert ){
        MVG_Price__c mvgPrice = new MVG_Price__c();
        if(isInsert){
            insert mvgPrice;
        }
        return mvgPrice;
    } 
    
    //Method to create Inspection__c
    public static Inspection__c createInspection(Boolean isInsert ){
        Inspection__c inspection = new Inspection__c();
        if(isInsert){
            insert inspection;
        }
        return inspection;
    }
    
        
     //Method to create Purchase 
    public static Purchase__c createPurchaseRec( Integer i, Map<String, String> purchase,  Boolean isInsert){

      Purchase__c Pur=new Purchase__c(Name= purchase.get('Name') + i,                                
                                Vehicle_ID__c= purchase.get('Vehicle_ID__c') + i,
                                Handles_Payment__c= purchase.get('Handles_Payment__c'),
                                Transport_Type__c= Integer.valueof(purchase.get('Transport_Type__c')),
                                Transport_Preference__c= purchase.get('Transport_Preference__c'),
                                sale_Class__c= purchase.get('sale_Class__c'),
                                Source_Id__c= purchase.get('Source_ID__c') + i);
        
        if(isInsert){
           insert pur; 
        }  
        return Pur;
          
    }

    //Method to create Vehicle Exception Report 
    public static Vehicle_Exception_Report__c createVehicalExceptionReport( Integer i, Map<String, String> vhcrep,  Boolean isInsert){

      Vehicle_Exception_Report__c objRec =new Vehicle_Exception_Report__c(Vehicle_ID__c= vhcrep.get('Vehicle_ID__c') + i,                                
                                Purchase__c= null);
        
        if(isInsert){
           insert objRec; 
        }  
        return objRec;
          
    } 
 
    //Method to create a users
    public static User createUser(String preFix , String ProfName, Boolean isInsert){
        User usr = new User(ProfileId = [SELECT Id FROM Profile WHERE Name =: ProfName ].Id,
                            LastName = 'last'+ preFix,
                            Email = 'testuser-'+ preFix +'@mail.com',
                            Username = 'testuseradesa-'+ preFix +'@adesa.com',
                            Alias = 'alias',
                            Title = 'title',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US',
                            CompanyName = 'TEST');
        if(isInsert){
            insert usr;
        }
               return usr;
    }


}