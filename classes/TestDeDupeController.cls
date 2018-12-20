@istest(SeeAllData=false)
private class TestDeDupeController
{
     public static testMethod void test1()
     {
        PageReference pageRef = Page.De_Dupe_Page;
        Test.setCurrentPage(pageRef);
        
        DeDupeController objDeDupeController = new DeDupeController();
        //objDeDupeController.DeDupeController();
        
        Test.startTest();               
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        objDeDupeController.getMiFact();
        objDeDupeController.getWinnerAccount(); 
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
        objDeDupeController.MigrateToWinerAccount();        
        Test.stopTest();         
     }
     
     
     // Commented this method as Deployment Error : 
        //System.LimitException: Too many SOQL queries: 101 
        //Stack Trace: Trigger.ContactAfterInsertUpdate: line 25, column 1

    public static testMethod void test2()
     {
     
     
        PageReference pageRef = Page.De_Dupe_Page;
        Test.setCurrentPage(pageRef);
        
        DeDupeController objDeDupeController = new DeDupeController();
        
        
        objDeDupeController.IndexOfList =0;
        objDeDupeController.MasterIndexSearch = '100';
        
        Property__c objProperty = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='prod',Property_Value__c='prod');
        insert objProperty ;          
        Property__c objProperty2 = new Property__c(Property_Id__c='mi.service.token.stg',Property_Value_Encrypted__c='1234',Property_Value__c='1234');
        insert objProperty2 ;         
        Property__c objProperty21 = new Property__c(Property_Id__c='mi.service.token.prod',Property_Value_Encrypted__c='1234',Property_Value__c='1234');
        insert objProperty21 ; 
        Property__c objProperty3 = new Property__c(Property_Id__c='prod.instance.node',Property_Value_Encrypted__c='NA19',Property_Value__c='NA19');
        insert objProperty3 ;         
        Delete objProperty;
        Property__c objProperty4 = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='stg',Property_Value__c='stg');
        insert objProperty4 ;
        Property__c objProperty5 = new Property__c(Property_Id__c='mi.service.url',Property_Value_Encrypted__c='https://www.test.com',Property_Value__c='https://www.test.com');
        insert objProperty5 ;
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        objDeDupeController.getMiFact();
        
        
        DeDupeController.clsMiFact objclsMiFact1 = new DeDupeController.clsMiFact();
        objclsMiFact1.Index=0;
        objclsMiFact1.masterIndex='100';
        objclsMiFact1.miFactType='ACCOUNT';
        objclsMiFact1.miFactId='100';
        objclsMiFact1.miDomain='OL';
        objclsMiFact1.domainUniqueId='123';
        objclsMiFact1.name='ADESA Account';
        objclsMiFact1.WinnerAccountMasterIndex='200';       
        objclsMiFact1.WinnerAccount = InsertAccount1();  
        
        
        DeDupeController.clsMiFact objclsMiFact2 = new DeDupeController.clsMiFact();
        objclsMiFact2.Index=1;
        objclsMiFact2.masterIndex='200';
        objclsMiFact2.miFactType='ACCOUNT';
        objclsMiFact2.miFactId='100';
        objclsMiFact2.miDomain='AFC';
        objclsMiFact2.domainUniqueId='123';
        objclsMiFact2.name='AFC Account';
        objclsMiFact2.WinnerAccountMasterIndex='200';       
        objclsMiFact2.WinnerAccount = InsertAccount2();

        objDeDupeController.ListclsMiFact = new List<DeDupeController.clsMiFact>();
        objDeDupeController.ListclsMiFact.Add(objclsMiFact1);
        objDeDupeController.ListclsMiFact.Add(objclsMiFact2);
        
        objDeDupeController.getWinnerAccount(); 
        
        
        String AdesaId = InsertAdesa1(objclsMiFact1.WinnerAccount).Id;      
        String WinnerAccId = objclsMiFact1.WinnerAccount.Id;
        Test.startTest();
        boolean blnSuccess = objDeDupeController.ReParentAccountOfAdesaDetailRelatedObject(AdesaId,WinnerAccId);
        
        Test.stopTest();
     }
   
  
    
    public static testMethod void test4()
     {
     
     
        PageReference pageRef = Page.De_Dupe_Page;
        Test.setCurrentPage(pageRef);
        
        DeDupeController objDeDupeController = new DeDupeController();
        
        
        objDeDupeController.IndexOfList =0;
        objDeDupeController.MasterIndexSearch = '100';
        
        Property__c objProperty = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='prod',Property_Value__c='prod');
        insert objProperty ;          
        Property__c objProperty2 = new Property__c(Property_Id__c='mi.service.token.stg',Property_Value_Encrypted__c='1234',Property_Value__c='1234');
        insert objProperty2 ;         
        Property__c objProperty21 = new Property__c(Property_Id__c='mi.service.token.prod',Property_Value_Encrypted__c='1234',Property_Value__c='1234');
        insert objProperty21 ; 
        Property__c objProperty3 = new Property__c(Property_Id__c='prod.instance.node',Property_Value_Encrypted__c='NA19',Property_Value__c='NA19');
        insert objProperty3 ;         
        Delete objProperty;
        Property__c objProperty4 = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='stg',Property_Value__c='stg');
        insert objProperty4 ;
        Property__c objProperty5 = new Property__c(Property_Id__c='mi.service.url',Property_Value_Encrypted__c='https://www.test.com',Property_Value__c='https://www.test.com');
        insert objProperty5 ;
        
               
        
        DeDupeController.clsMiFact objclsMiFact1 = new DeDupeController.clsMiFact();
        objclsMiFact1.Index=0;
        objclsMiFact1.masterIndex='100';
        objclsMiFact1.miFactType='ACCOUNT';
        objclsMiFact1.miFactId='100';
        objclsMiFact1.miDomain='OL';
        objclsMiFact1.domainUniqueId='123';
        objclsMiFact1.name='ADESA Account';
        objclsMiFact1.WinnerAccountMasterIndex='200';       
        objclsMiFact1.WinnerAccount = InsertAccount1();  
        
        
        DeDupeController.clsMiFact objclsMiFact2 = new DeDupeController.clsMiFact();
        objclsMiFact2.Index=1;
        objclsMiFact2.masterIndex='200';
        objclsMiFact2.miFactType='ACCOUNT';
        objclsMiFact2.miFactId='100';
        objclsMiFact2.miDomain='AFC';
        objclsMiFact2.domainUniqueId='123';
        objclsMiFact2.name='AFC Account';
        objclsMiFact2.WinnerAccountMasterIndex='200';       
        objclsMiFact2.WinnerAccount = InsertAccount2();
        
        objDeDupeController.ListclsMiFact = new List<DeDupeController.clsMiFact>();
        objDeDupeController.ListclsMiFact.Add(objclsMiFact1);
        objDeDupeController.ListclsMiFact.Add(objclsMiFact2);

        String AFCId2 = InsertAFC2(objclsMiFact1.WinnerAccount).Id;

        Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        objDeDupeController.getMiFact();
        
        objDeDupeController.getWinnerAccount(); 

        String AdesaId = InsertAdesa1(objclsMiFact1.WinnerAccount).Id;      
        String WinnerAccId = objclsMiFact1.WinnerAccount.Id;
        
        // Start from Here 
//        String AFCId = InsertAFC1(objclsMiFact1.WinnerAccount).Id;
        
        
        boolean blnSuccess2 = objDeDupeController.ReParentAccountOfAFCCotractRelatedObject(AFCId2,WinnerAccId);
        Test.stopTest();
     }
    
    
    public static testMethod void test3()
     {
     
     
     
        PageReference pageRef = Page.De_Dupe_Page;
        Test.setCurrentPage(pageRef);
        
        DeDupeController objDeDupeController = new DeDupeController();
        //objDeDupeController.DeDupeController();
        
        /*
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        objDeDupeController.getMiFact();
        objDeDupeController.getWinnerAccount(); 
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
        objDeDupeController.MigrateToWinerAccount();        
        */
        
        objDeDupeController.IndexOfList =0;
        objDeDupeController.MasterIndexSearch = '100';
        
        Property__c objProperty = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='prod',Property_Value__c='prod');
        insert objProperty ;          
        Property__c objProperty2 = new Property__c(Property_Id__c='mi.service.token.stg',Property_Value_Encrypted__c='1234',Property_Value__c='1234');
        insert objProperty2 ;         
        Property__c objProperty21 = new Property__c(Property_Id__c='mi.service.token.prod',Property_Value_Encrypted__c='1234',Property_Value__c='1234');
        insert objProperty21 ; 
        Property__c objProperty3 = new Property__c(Property_Id__c='prod.instance.node',Property_Value_Encrypted__c='NA19',Property_Value__c='NA19');
        insert objProperty3 ;         
        Delete objProperty;
        Property__c objProperty4 = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='stg',Property_Value__c='stg');
        insert objProperty4 ;
        Property__c objProperty5 = new Property__c(Property_Id__c='mi.service.url',Property_Value_Encrypted__c='https://www.test.com',Property_Value__c='https://www.test.com');
        insert objProperty5 ;
        
        
        DeDupeController.clsMiFact objclsMiFact1 = new DeDupeController.clsMiFact();
        objclsMiFact1.Index=0;
        objclsMiFact1.masterIndex='100';
        objclsMiFact1.miFactType='ACCOUNT';
        objclsMiFact1.miFactId='100';
        objclsMiFact1.miDomain='OL';
        objclsMiFact1.domainUniqueId='123';
        objclsMiFact1.name='ADESA Account';
        objclsMiFact1.WinnerAccountMasterIndex='100';       
        objclsMiFact1.WinnerAccount = InsertAccount1();  
        
        
        DeDupeController.clsMiFact objclsMiFact2 = new DeDupeController.clsMiFact();
        objclsMiFact2.Index=1;
        objclsMiFact2.masterIndex='200';
        objclsMiFact2.miFactType='ACCOUNT';
        objclsMiFact2.miFactId='100';
        objclsMiFact2.miDomain='AFC';
        objclsMiFact2.domainUniqueId='123';
        objclsMiFact2.name='AFC Account';
        objclsMiFact2.WinnerAccountMasterIndex='200';       
        objclsMiFact2.WinnerAccount = InsertAccount2();
        
        objDeDupeController.ListclsMiFact = new List<DeDupeController.clsMiFact>();
        objDeDupeController.ListclsMiFact.Add(objclsMiFact1);
        objDeDupeController.ListclsMiFact.Add(objclsMiFact2);
        
        List<DeDupeController.clsMiFact>  lcmf1= new List<DeDupeController.clsMiFact>();
        lcmf1.Add(objclsMiFact1);
        lcmf1.Add(objclsMiFact2);
        objDeDupeController.ListclsMiFact =  lcmf1;
        
        
        String AdesaId = InsertAdesa1(objclsMiFact1.WinnerAccount).Id;
        
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
        objDeDupeController.MigrateToWinerAccount();    
        Test.stopTest();
     }
     
    
    public static Account InsertAccount1()
    {
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
        Insert acct1;
        return acct1;
        
        
    }
    public static Account InsertAccount2()
    {
        Account acct2 = new Account(Name='Test Account2',Master_Index__c='200');
        Insert acct2;
        return acct2;
        
        
    }
    public static Adesa_com_Detail__c InsertAdesa1(Account acct1)
    {
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='123',Account__c=acct1.Id);
        Insert Adesa1;
        
        Payment_Method__c Pay1 = new Payment_Method__c(Name='Payment1',Adesa_com__c=Adesa1.Id);
        Insert Pay1;
        
        ADESA_Compliance__c Comp1 = new ADESA_Compliance__c(ADESA_com_Detail__c=Adesa1.Id);
        Insert Comp1;
        
        Asset__c Asset1 = new Asset__c(Name='Asset1',Source_Id__c='OL',Buyer_ADESA_com_Detail__c=Adesa1.Id,Consignee_ADESA_com_Detail__c=Adesa1.Id,Grounding_Dealer_ADESA_com_Detail__c=Adesa1.Id,Partner_ADESA_com_Detail__c=Adesa1.Id,Seller_ADESA_com_Detail__c=Adesa1.Id);
        Insert Asset1;
        
        Auction__c Aux1 = new Auction__c(Name='Aux1',Asset__c=Asset1.id,Highest_Bidder_Adesa_ORG__c=Adesa1.Id);
        Insert Aux1;
        
        //Collection__c Col1 = new Collection__c(Name='Col1',Organization_Id__c='101',ADESA_com_Detail__c=Adesa1.Id);
        //Insert Col1;
        
        Dealer_Registration_Request__c DRR1 = new Dealer_Registration_Request__c(Name='DRR1',Registration_Form_Id__c='101',ADESA_com_Detail__c=Adesa1.Id);
        Insert DRR1;
        
        Incentive__c Inc1 = new Incentive__c(ADESA_com_Detail__c=Adesa1.Id);
        Insert Inc1;
        
        Inside_Sales_Auction_Performance__c ISAP1 = new Inside_Sales_Auction_Performance__c(ADESA_com_Detail__c=Adesa1.Id);
        Insert ISAP1;
        
        Inspection__c Insp1 = new Inspection__c(Name='Insp1',Asset__c=Asset1.id,Inspector_ADESA_com_Detail__c=Adesa1.Id);
        Insert Insp1;
        
        Listing_Request__c ListReq1 = new Listing_Request__c(Number_of_Listings__c=100,ADESA_com_Detail__c=Adesa1.Id);
        Insert ListReq1;
        
        Proxy_Bid__c ProxBid1 = new Proxy_Bid__c(Name='ProxBid1',Auction__c=Aux1.Id, ADESA_com_Detail__c=Adesa1.Id);
        Insert ProxBid1;
        
        //Opportunity Opportunity1 = new Opportunity(Name='Case1',StageName='Not Started', CloseDate=Date.today(),ADESA_com_Detail__c=Adesa1.Id);
        //Insert Opportunity1;
        
        Contact Contact1 = new Contact(LastName='Patel',OpenLane_Details__c=Adesa1.Id);
        Insert Contact1;
        
        Case Case1 = new Case(Reason='Account',ADESA_com_Detail__c=Adesa1.Id,Vehicle_Identification_Number__c='12345678901234567',Description='PSI FAILED:Description');
        Insert Case1;
        
        Purchase__c Purchase1 = new Purchase__c(Name='Purchase1',Source_Id__c='OL',Consignee_Adesa_com_Detail__c=Adesa1.Id,Adesa_com__c=Adesa1.Id,ATC_Buyer_Adesa_com_Detail__c=Adesa1.Id,ATC_Seller_Adesa_com_Detail__c=Adesa1.Id,Transporter__c=Adesa1.Id);
        Insert Purchase1;
        
        return Adesa1;
    }
public static AFC_Contracts__c InsertAFC1(Account acct1)
    {
        AFC_Contracts__c AFC1 = new AFC_Contracts__c(Name='AFC147',Source_Id__c='AFB14-AFCC14',AFC_Branch__c='AFB14',
                        AFC_Dealer_ID__c='123', Contract_ID__c='AFCC14',Account__c=acct1.Id);
        Insert AFC1;
        
/*        
        RecordType accountRt = [Select Id From RecordType  Where SobjectType = 'Account' and DeveloperName = 'Dealership_Account_US' limit 1];
        RecordType opportunityRt = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'AFC_Dealer_Retention' limit 1];
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'u1', email='ewhipple@afc.com',emailencodingkey='UTF-8', lastname='UserLastName', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,  country='United States', CommunityNickname = 'u1',timezonesidkey='America/Los_Angeles', username='regionalmanager@autofinance.com');
        insert u;       
        AFC_Branch__c b = new AFC_Branch__c(Name='Detroit North',Branch_Manager_1__c = UserInfo.getUserId());
        insert b;
        Account a = new Account(name='Modern Apple',AFC_Dealer_ID__c='12345',AFCBranchSalesArea__c = b.Id,RecordTypeId=accountRt.id);
        insert a;
        Contact c = new Contact(firstName='Eric',lastName='Whipple',accountid=a.id);
        insert c;
        
        Opportunity Opportunity1 = new Opportunity(Name='Case1',StageName='Not Started', AccountId = a.id, CloseDate=Date.today(),AFC_Contracts__c=AFC1.Id);
        Insert Opportunity1;        
        
        
        Case Case1 = new Case(Reason='Account',AFC_Contracts__c=AFC1.Id);
        Insert Case1;
        
        Purchase__c Purchase1 = new Purchase__c(Name='Purchase1',Source_Id__c='OL',AFC_Contract_Number__c=AFC1.Id);
        Insert Purchase1;
        
        Contract_Versions__c CV1 = new Contract_Versions__c(Name='CV1',AFC_Contracts__c=AFC1.Id);
        Insert CV1;
        
        AFC_Contract_Shell__c AFCShell1 = new AFC_Contract_Shell__c(AFC_Area_Sales_Manager__c=AFC1.Id);
        Insert AFCShell1;
        
        
        Application__c App1 = new Application__c(Name='App1',AFC_Contract_Number__c=AFC1.Id);
        Insert App1;
        
        Application_Contact_Role__c AppConRole1 = new Application_Contact_Role__c(Name='AppConRole1',AFC_Contracts__c=AFC1.Id);
        Insert AppConRole1;
        
        Application_Account_Role__c AppAccRole1 = new Application_Account_Role__c(Name='AppAccRole1',AFC_Contracts__c=AFC1.Id);
        Insert AppAccRole1;     
 */       
        return AFC1;
    }
    
    public static AFC_Contracts__c InsertAFC2(Account acct1)
    {
        AFC_Contracts__c AFC1 = new AFC_Contracts__c(Name='AFC148',Source_Id__c='AFB14-AFCC148',AFC_Branch__c='AFB14',
                        AFC_Dealer_ID__c='123', Contract_ID__c='AFCC14',Account__c=acct1.Id);
        Insert AFC1;

        User testUser = TestServices.createTestUser('user1@afc.com','Shull','Indianapolis','Credit',true);
        User testCTUser = TestServices.createTestUser('user2@afc.com','Shull','Indianapolis','CT Processing',true);        
        Opportunity opp = TestServices.createTestOpportunity('Test Opp', 'Closed Won', 'Indianapolis', true);
        Application__c app = TestServices.createTestApplication(opp.Id, 'Shull', true);
        
        
        
        Contact aContact = new Contact(LastName = 'Test');
        insert aContact;
        
        Contract_Versions__c CV1 = new Contract_Versions__c(Name='CV1',AFC_Contracts__c=AFC1.Id,Account__c=acct1.Id);
        Insert CV1;
        
        AFC_Contract_Shell__c AFCShell1 = new AFC_Contract_Shell__c(AFC_Area_Sales_Manager__c=AFC1.Id,Account__c=acct1.Id);
        Insert AFCShell1;
        
        Application_Contact_Role__c AppConRole1 = new Application_Contact_Role__c(Name='AppConRole1',AFC_Contracts__c=AFC1.Id,
                    Relationship__c = 'Owner',       Application__c = app.Id, Contact__c = aContact.Id);
        Insert AppConRole1;
        
        return AFC1;
    }
        
    public static testMethod void test5()
     {
        
        String testlocation ='ADESA Atlanta;ADESA Austin;ADESA Birmingham;ADESA Boston;ADESA Buffalo;' + 
                'ADESA Calgary;ADESA Charlotte;ADESA Cleveland;ADESA Colorado Springs;ADESA Concord;' + 
                'ADESA Dallas;ADESA Des Moines;ADESA Edmonton;ADESA Fargo;ADESA Golden Gate;ADESA Halifax;' + 
                'ADESA Houston;ADESA Indianapolis;ADESA Jacksonville;ADESA Kansas City;ADESA Kitchener;' + 
                'ADESA Knoxville;ADESA Lansing;ADESA Lexington;ADESA Little Rock;ADESA Long Island;' + 
                'ADESA Los Angeles;ADESA Memphis;ADESA Minneapolis;ADESA Moncton;ADESA Montreal;' + 
                'ADESA Nashville;ADESA New Jersey;ADESA Ocala;ADESA Ottawa;ADESA PA;ADESA Phoenix;' + 
                'ADESA Pittsburgh;ADESA Quebec City;ADESA Raleigh;ADESA Sacramento;ADESA San Antonio;' + 
                'ADESA San Diego;ADESA Sarasota;ADESA Saskatoon;ADESA Seattle;ADESA Shreveport;' + 
                'ADESA Sioux Falls;ADESA St. Louis;ADESA Syracuse;ADESA Tampa;ADESA Toronto;ADESA Tulsa;' + 
                'ADESA Vancouver;ADESA Washington DC;ADESA Winnipeg;ADESA Wisconsin;' + 
                'ADESA Cincinnati/Dayton;ADESA Mercer;ADESA St. Johns;ADESA Mexico City'; 
        Contact obj = new Contact();
        obj.LastName='Test Contact1';
        obj.Master_Index__c='930561';
        obj.Location__c = testlocation;
        obj.Active__c = true;
        obj.sign_me_up__c = true;   
        obj.Consignor__c = 'Ford';
        Insert obj;  

        Property__c objProperty = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='prod',Property_Value__c='prod');
        insert objProperty ;          
        Property__c objProperty2 = new Property__c(Property_Id__c='mi.service.token.stg',Property_Value_Encrypted__c='1234',Property_Value__c='1234');
        insert objProperty2 ;         
        Property__c objProperty21 = new Property__c(Property_Id__c='mi.service.token.prod',Property_Value_Encrypted__c='1234',Property_Value__c='1234');
        insert objProperty21 ; 
        Property__c objProperty3 = new Property__c(Property_Id__c='prod.instance.node',Property_Value_Encrypted__c='NA19',Property_Value__c='NA19');
        insert objProperty3 ;         
        Delete objProperty;
        Property__c objProperty4 = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='stg',Property_Value__c='stg');
        insert objProperty4 ;
        Property__c objProperty5 = new Property__c(Property_Id__c='mi.service.url',Property_Value_Encrypted__c='https://www.test.com',Property_Value__c='https://www.test.com');
        insert objProperty5 ;


        PageReference pageRef = Page.De_Dupe_Page;
        Test.setCurrentPage(pageRef);
        DeDupeController.clsMiFact objclsMiFact2 = new DeDupeController.clsMiFact();
        objclsMiFact2.Index=0;
        objclsMiFact2.masterIndex='200';
        objclsMiFact2.miFactType='ACCOUNT';
        objclsMiFact2.miFactId='100';
        objclsMiFact2.miDomain='AFC';
        objclsMiFact2.domainUniqueId='123';
        objclsMiFact2.name='AFC Account';
        objclsMiFact2.WinnerAccountMasterIndex='200';       
        objclsMiFact2.WinnerAccount = InsertAccount2();
        objclsMiFact2.isDuplicate = false;
        
       
        AFC_Contracts__c afc = InsertAFC1(objclsMiFact2.WinnerAccount);
        System.debug('----- AFCId ='+afc.Id );
        System.debug('----- AFC AFC_Dealer_ID__c ='+afc.AFC_Dealer_ID__c );

        List<DeDupeController.clsMiFact>  lcmf1= new List<DeDupeController.clsMiFact>();
        lcmf1.Add(objclsMiFact2);

        Test.StartTest();
        
        DeDupeController objc = new DeDupeController();
        objc.MasterIndexSearch = '930561';
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
        objc.ListclsMiFact =  lcmf1;        
        
        objc.IndexOfList = 0;
        objc.MigrateToWinerAccount();    

        List<DeDupeController.clsMiFact>  lcmf2= new List<DeDupeController.clsMiFact>();
        objclsMiFact2.miDomain='IAA';
        lcmf2.Add(objclsMiFact2);
        objc.ListclsMiFact =  lcmf2;        
        objc.MigrateToWinerAccount();    

        List<DeDupeController.clsMiFact>  lcmf3= new List<DeDupeController.clsMiFact>();
        objclsMiFact2.miDomain='ADESA';
        lcmf3.Add(objclsMiFact2);
        objc.ListclsMiFact =  lcmf3;        
        objc.MigrateToWinerAccount();    

        List<DeDupeController.clsMiFact>  lcmf4= new List<DeDupeController.clsMiFact>();
        objclsMiFact2.miDomain='AFCCONVERT';
        lcmf4.Add(objclsMiFact2);
        objc.ListclsMiFact =  lcmf4;        
        objc.MigrateToWinerAccount();    

        List<DeDupeController.clsMiFact>  lcmf5= new List<DeDupeController.clsMiFact>();
        objclsMiFact2.miDomain='AUCTIONACCESS';
        lcmf5.Add(objclsMiFact2);
        objc.ListclsMiFact =  lcmf5;        
        objc.MigrateToWinerAccount();    

        List<DeDupeController.clsMiFact>  lcmf6= new List<DeDupeController.clsMiFact>();
        objclsMiFact2.miDomain='AUTOCOUNT';
        lcmf6.Add(objclsMiFact2);
        objc.ListclsMiFact =  lcmf6;        
        objc.MigrateToWinerAccount();    

        List<DeDupeController.clsMiFact>  lcmf7= new List<DeDupeController.clsMiFact>();
        objclsMiFact2.miDomain='CMDM';
        lcmf7.Add(objclsMiFact2);
        objc.ListclsMiFact =  lcmf7;        
        objc.MigrateToWinerAccount();    

        List<DeDupeController.clsMiFact>  lcmf8= new List<DeDupeController.clsMiFact>();
        objclsMiFact2.miDomain='DMV';
        lcmf8.Add(objclsMiFact2);
        objc.ListclsMiFact =  lcmf8;        
        objc.MigrateToWinerAccount();    

        List<DeDupeController.clsMiFact>  lcmf9= new List<DeDupeController.clsMiFact>();
        objclsMiFact2.miDomain='INFOUSA';
        lcmf9.Add(objclsMiFact2);
        objc.ListclsMiFact =  lcmf9;        
        objc.MigrateToWinerAccount();    

        List<DeDupeController.clsMiFact>  lcmf10= new List<DeDupeController.clsMiFact>();
        objclsMiFact2.miDomain='KARAFC';
        lcmf10.Add(objclsMiFact2);
        objc.ListclsMiFact =  lcmf10;        
        objc.MigrateToWinerAccount();    


        List<DeDupeController.clsMiFact>  lcmf11= new List<DeDupeController.clsMiFact>();
        objclsMiFact2.miFactType='CONTACT';
        objclsMiFact2.miDomain='KARAFC';
        lcmf11.Add(objclsMiFact2);
        objc.ListclsMiFact =  lcmf11;        
        objc.MigrateToWinerAccount();    


        objc.ListclsMiFact = null;
        objc.MigrateToWinerAccount();    


        
        Test.stopTest();
        
     }
         
    
}