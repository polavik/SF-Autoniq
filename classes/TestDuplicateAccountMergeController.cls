@istest
private class TestDuplicateAccountMergeController
{
     public static testMethod void testMyController()
     {
         //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
         
        PageReference pageRef = Page.DuplicateAccountMerge;
        Test.setCurrentPage(pageRef);
        
        Property__c objProperty = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='prod');
        insert objProperty ;  
        
        Property__c objProperty2 = new Property__c(Property_Id__c='mi.service.token',Property_Value_Encrypted__c='1234');
        insert objProperty2 ; 
        
        Property__c objProperty4 = new Property__c(Property_Id__c='prod.instance.node',Property_Value_Encrypted__c='NA19',Property_Value__c='NA19');
        insert objProperty4 ;     
        
        DuplicateAccountMergeController  Objcontroller = new DuplicateAccountMergeController();
        Objcontroller.strOut ='Test Output';
        
        Objcontroller.Search();
        Objcontroller.searchDuplicate();
        Objcontroller.mergeAccount();
        
        InsertAccount1();
        InsertAccount2();       
        InsertAccount3();
        
        Objcontroller.searchText = '900';
        Objcontroller.Search();
        
        Objcontroller.searchText = '100';
        Objcontroller.Search();
        
        Objcontroller.searchTextDuplicate= '800';
        Objcontroller.searchDuplicate();    
        
        Objcontroller.searchTextDuplicate= '200';
        Objcontroller.searchDuplicate();    
        Objcontroller.mergeAccount();
        
        Objcontroller.accDuplicate.Duplicate__c = true;     
        Objcontroller.mergeAccount();
        
        Delete objProperty;
        Property__c objProperty3 = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='stg');
        insert objProperty3 ;  
        
        Objcontroller.mergeAccount();
        
        Objcontroller.searchTextDuplicate= '300';
        Objcontroller.searchDuplicate();
        Objcontroller.mergeAccount();
        
        Objcontroller.accMaster.Master_Index__c = Objcontroller.accDuplicate.Master_Index__c;
        Objcontroller.mergeAccount();
            
        Objcontroller.MasterIndex = Objcontroller.accMaster.Master_Index__c;
        Objcontroller.mergeAccount();
        
        Objcontroller.accMaster = null;
        Objcontroller.mergeAccount();        
       
        
        Objcontroller.MasterIndex = null;
        Objcontroller.mergeAccount();
        
        
     }
    
        
    public static void InsertAccount1()
    {
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
        Insert acct1;        
        
    }
    public static void InsertAccount2()
    {      
        
        Account acct2 = new Account(Name='Test Account2',Master_Index__c='200');
        Insert acct2;
       
    }
    public static void InsertAccount3()
    {
        
        Account acct3 = new Account(Name='Test Account3',Master_Index__c='300');
        acct3.Duplicate_with_Master_Index__c = '100';
        acct3.Duplicate__c= true;
        Insert acct3;
    }
    
}