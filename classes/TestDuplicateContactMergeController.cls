@istest
private class TestDuplicateContactMergeController
{
     public static testMethod void testMyController()
     {
         //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
         
        PageReference pageRef = Page.DuplicateContactMerge;
        Test.setCurrentPage(pageRef);
        
        Property__c objProperty = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='prod');
        insert objProperty ;  
        
        Property__c objProperty2 = new Property__c(Property_Id__c='mi.service.token',Property_Value_Encrypted__c='1234');
        insert objProperty2 ; 
        
        Property__c objProperty4 = new Property__c(Property_Id__c='prod.instance.node',Property_Value_Encrypted__c='NA19',Property_Value__c='NA19');
        insert objProperty4 ;   
        
        DuplicateContactMergeController  Objcontroller = new DuplicateContactMergeController();
        Objcontroller.strOut ='Test Output';
        
        Objcontroller.Search();
        Objcontroller.searchDuplicate();
        Objcontroller.mergeContact();
        
        InsertContact1();
        InsertContact2();       
        InsertContact3();
        
        Objcontroller.searchText = '900';
        Objcontroller.Search();
        
        Objcontroller.searchText = '100';
        Objcontroller.Search();
        
        Objcontroller.searchTextDuplicate= '800';
        Objcontroller.searchDuplicate();    
        
        Objcontroller.searchTextDuplicate= '200';
        Objcontroller.searchDuplicate();    
        Objcontroller.mergeContact();
        
        Objcontroller.conDuplicate.Duplicate__c = true;     
        Objcontroller.mergeContact();
        
        Delete objProperty;
        Property__c objProperty3 = new Property__c(Property_Id__c='org.type',Property_Value_Encrypted__c='stg');
        insert objProperty3 ;  
        
        Objcontroller.mergeContact();
        
        Objcontroller.searchTextDuplicate= '300';
        Objcontroller.searchDuplicate();
        Objcontroller.mergeContact();
        
        Objcontroller.conMaster.Master_Index__c = Objcontroller.conDuplicate.Master_Index__c;
        Objcontroller.mergeContact();
            
        Objcontroller.MasterIndex = Objcontroller.conMaster.Master_Index__c;
        Objcontroller.mergeContact();
        
        Objcontroller.conMaster = null;
        Objcontroller.mergeContact();        
       
        
        Objcontroller.MasterIndex = null;
        Objcontroller.mergeContact();
        
        
     }
    
        
    public static void InsertContact1()
    {
        Contact acct1 = new Contact(LastName='Test Contact1',Master_Index__c='100');
        Insert acct1;        
        
    }
    public static void InsertContact2()
    {      
        
        Contact acct2 = new Contact(LastName='Test Contact2',Master_Index__c='200');
        Insert acct2;
       
    }
    public static void InsertContact3()
    {
        
        Contact acct3 = new Contact(LastName='Test Contact3',Master_Index__c='300');
        acct3.Duplicate_with_Master_Index__c = '100';
        acct3.Duplicate__c= true;
        Insert acct3;
    }
    
}