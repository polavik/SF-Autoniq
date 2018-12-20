@istest
private class TestDeDupeContactController
{
     public static testMethod void test1()
     {
        PageReference pageRef = Page.De_Dupe_Contact_Page;
        Test.setCurrentPage(pageRef);
        
        DeDupeContactController objDeDupeContactController = new DeDupeContactController();
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        objDeDupeContactController.getMiFact();
        objDeDupeContactController.getWinnerContact(); 
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
        objDeDupeContactController.MigrateToWinerContact();
     }
     
    public static testMethod void test2()
     {
     
     
        PageReference pageRef = Page.De_Dupe_Contact_Page;
        Test.setCurrentPage(pageRef);
        
        DeDupeContactController objDeDupeContactController = new DeDupeContactController();
        //objDeDupeContactController.DeDupeContactController();
        
        /*
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        objDeDupeContactController.getMiFact();
        objDeDupeContactController.getWinnerContact(); 
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
        objDeDupeContactController.MigrateToWinerContact();        
        */
        
        objDeDupeContactController.IndexOfList =0;
        objDeDupeContactController.MasterIndexSearch = '100';
        
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
               
        
        
        DeDupeContactController.clsMiFact objclsMiFact1 = new DeDupeContactController.clsMiFact();
        objclsMiFact1.Index=1;
        objclsMiFact1.masterIndex='100';
        objclsMiFact1.miFactType='Contact';
        objclsMiFact1.miFactId='100';
        objclsMiFact1.miDomain='OL';
        objclsMiFact1.domainUniqueId='123';
        objclsMiFact1.name='Contact1';
        objclsMiFact1.WinnerContactMasterIndex='200';       
        objclsMiFact1.WinnerContact = InsertContact1();  
        objclsMiFact1.isDuplicate = false;
        
        
        DeDupeContactController.clsMiFact objclsMiFact2 = new DeDupeContactController.clsMiFact();
        objclsMiFact2.Index=0;
        objclsMiFact2.masterIndex='200';
        objclsMiFact2.miFactType='Contact';
        objclsMiFact2.miFactId='100';
        objclsMiFact2.miDomain='AFC';
        objclsMiFact2.domainUniqueId='123';
        objclsMiFact2.name='Contact2';
        objclsMiFact2.WinnerContactMasterIndex='200';       
        objclsMiFact2.WinnerContact = InsertContact2();
        objclsMiFact2.isDuplicate = false;
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        objDeDupeContactController.getMiFact();        
        
        List<DeDupeContactController.clsMiFact>  lcmf1= new List<DeDupeContactController.clsMiFact>();
        lcmf1.Add(objclsMiFact1);
        lcmf1.Add(objclsMiFact2);
        objDeDupeContactController.ListclsMiFact =  lcmf1;
                        
        objDeDupeContactController.getWinnerContact(); 
        
        Test.stopTest();
     }
          
    public static testMethod void test3()
     {
     
        PageReference pageRef = Page.De_Dupe_Contact_Page;
        Test.setCurrentPage(pageRef);
        
        DeDupeContactController objDeDupeContactController = new DeDupeContactController();
        //objDeDupeContactController.DeDupeContactController();
        
       
        
        
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
        
        
        DeDupeContactController.clsMiFact objclsMiFact1 = new DeDupeContactController.clsMiFact();
        objclsMiFact1.Index=0;
        objclsMiFact1.masterIndex='100';
        objclsMiFact1.miFactType='Contact';
        objclsMiFact1.miFactId='100';
        objclsMiFact1.miDomain='OL';
        objclsMiFact1.domainUniqueId='123';
        objclsMiFact1.name='Contact1';
        objclsMiFact1.WinnerContactMasterIndex='100';       
        objclsMiFact1.WinnerContact = InsertContact1();  
        objclsMiFact1.isDuplicate = false;
        
        
        DeDupeContactController.clsMiFact objclsMiFact2 = new DeDupeContactController.clsMiFact();
        objclsMiFact2.Index=1;
        objclsMiFact2.masterIndex='200';
        objclsMiFact2.miFactType='Contact';
        objclsMiFact2.miFactId='100';
        objclsMiFact2.miDomain='AFC';
        objclsMiFact2.domainUniqueId='123';
        objclsMiFact2.name='Contact2';
        objclsMiFact2.WinnerContactMasterIndex='200';       
        objclsMiFact2.WinnerContact = InsertContact2();
        objclsMiFact2.isDuplicate = false;
        

        List<DeDupeContactController.clsMiFact>  lcmf1= new List<DeDupeContactController.clsMiFact>();
        lcmf1.Add(objclsMiFact1);
        lcmf1.Add(objclsMiFact2);
        objDeDupeContactController.ListclsMiFact =  lcmf1;
        objDeDupeContactController.IndexOfList =0;
        objDeDupeContactController.MasterIndexSearch = '100';
                
       
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
        objDeDupeContactController.MigrateToWinerContact();    
        Test.stopTest();
     }
          
    public static Contact InsertContact1()
    {
        String testlocation ='ADESA Atlanta;ADESA Austin;ADESA Birmingham;ADESA Boston;ADESA Buffalo;' ;
    	
        Contact con1 = new Contact(LastName='Test Contact1',Master_Index__c='100');

        con1.Location__c = testlocation;
        con1.Active__c = true;
        con1.sign_me_up__c = true;   
        con1.Consignor__c = 'Honda';

        Insert con1;
        return con1;
        
        
    }
    public static Contact InsertContact2()
    {
        String testlocation ='ADESA Atlanta;ADESA Austin;ADESA Birmingham;ADESA Boston;ADESA Buffalo;' ;
    	
        Contact con2 = new Contact(LastName='Test Contact2',Master_Index__c='200');
        con2.Location__c = testlocation;
        con2.Active__c = true;
        con2.sign_me_up__c = true;   
        con2.Consignor__c = 'Ford';
        Insert con2;
        return con2;
        
        
    }
    
    }