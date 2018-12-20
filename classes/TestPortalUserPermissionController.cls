@istest
private class TestPortalUserPermissionController
{   
    /*
     public static testMethod void testMyController1()
     { 
        PageReference pageRef = Page.PortalUserPermission;
        Test.setCurrentPage(pageRef);      
         
        PortalUserPermissionController  Objcontroller = new PortalUserPermissionController();
        Objcontroller.strSearch1 ='TestLoginName';
        Objcontroller.strSearch2 ='123456';
        Objcontroller.strSearch3 ='100';
        Objcontroller.EnableSellerPortal();   
        Objcontroller.GrantSellerPermission();   
        
        
     }
     */
     public static testMethod void testMyController11()
     { 
        PageReference pageRef = Page.PortalUserPermission;
        Test.setCurrentPage(pageRef);      
         
        PortalUserPermissionController  Objcontroller = new PortalUserPermissionController();
        Objcontroller.strSearch1 ='TestLoginName';
        Objcontroller.strSearch2 ='123456';
        Objcontroller.strSearch3 ='100';   
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            InsertProp1();
            InsertProp2();
            InsertContact1();
        }       
        Objcontroller.EnableSellerPortal();   
        Objcontroller.GrantSellerPermission(); 
        
        Objcontroller.strSearch1 ='TESTLOGINNAME';
        Objcontroller.strSearch2 ='789632';
        Objcontroller.strSearch3 ='200';  
        System.runAs ( thisUser ) {
            InsertContact2();
        }   
        Objcontroller.EnableSellerPortal();   
        Objcontroller.GrantSellerPermission(); 
        
     }
     
     public static testMethod void testMyController2()
     { 
        PageReference pageRef = Page.PortalUserPermission;
        Test.setCurrentPage(pageRef);      
         
        PortalUserPermissionController  Objcontroller = new PortalUserPermissionController();
        Objcontroller.strSearch1 ='TestLoginName';
        Objcontroller.strSearch2 ='123456abc';
        Objcontroller.strSearch3 ='100';        
        Objcontroller.EnableSellerPortal();   
        Objcontroller.GrantSellerPermission();   
        
        
     }
     
    
     public static testMethod void testMyController3()
     { 
        PageReference pageRef = Page.PortalUserPermission;
        Test.setCurrentPage(pageRef);      
         
        PortalUserPermissionController  Objcontroller = new PortalUserPermissionController();
        Objcontroller.strSearch1 ='TestLoginName';
        Objcontroller.strSearch2 ='123456';
        Objcontroller.strSearch3 ='100abc';        
        Objcontroller.EnableSellerPortal();   
        Objcontroller.GrantSellerPermission();   
        
        
     }
     
     public static testMethod void testMyController4()
     { 
        PageReference pageRef = Page.PortalUserPermission;
        Test.setCurrentPage(pageRef);      
         
        PortalUserPermissionController  Objcontroller = new PortalUserPermissionController();
        Objcontroller.strSearch1 ='';
        Objcontroller.strSearch2 ='123456';
        Objcontroller.strSearch3 ='100';        
       Objcontroller.EnableSellerPortal();   
        Objcontroller.GrantSellerPermission(); 
        
        
     }
     public static testMethod void testMyController5()
     { 
        PageReference pageRef = Page.PortalUserPermission;
        Test.setCurrentPage(pageRef);      
         
        PortalUserPermissionController  Objcontroller = new PortalUserPermissionController();
        Objcontroller.strSearch1 ='TestLoginName';
        Objcontroller.strSearch2 ='';
        Objcontroller.strSearch3 ='100';        
        Objcontroller.EnableSellerPortal();   
        Objcontroller.GrantSellerPermission();  
        
        
     }
    
    public static testMethod void testMyController6()
     { 
        PageReference pageRef = Page.PortalUserPermission;
        Test.setCurrentPage(pageRef);      
         
        PortalUserPermissionController  Objcontroller = new PortalUserPermissionController();
        Objcontroller.strSearch1 ='TestLoginName';
        Objcontroller.strSearch2 ='123456';
        Objcontroller.strSearch3 ='';        
        Objcontroller.EnableSellerPortal();   
        Objcontroller.GrantSellerPermission();    
        
        
     }
        
    public static void InsertContact1()
    {
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
        Insert acct1;  
        
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='100',Account__c=acct1.Id);
        Insert Adesa1;
        
        
        Contact con1 = new Contact(LastName='Test Contact1',Master_Index__c='100',Active__c = true,Login_Name__c ='TestLoginName',email='test@openlane.com', accountid=acct1.Id);
        Insert con1;
        
    }
    public static void InsertContact2()
    {
        Account acct2 = new Account(Name='Test Account2',Master_Index__c='200');
        Insert acct2;  
        
        Adesa_com_Detail__c Adesa2 = new Adesa_com_Detail__c(Name='Adesa2',ATC_Organization_ID__c='200',Account__c=acct2.Id);
        Insert Adesa2;
        
        
        Contact con2 = new Contact(LastName='Test Contact2',Master_Index__c='200',Active__c = true,Login_Name__c ='TESTLOGINNAME',email='test@openlane.com', accountid=acct2.Id);
        Insert con2;
        
    }
    
    public static void InsertProp1()
    {
       Property__c objProperty = new Property__c(Property_Id__c='portalutils.us.cp.profile.id',Property_Value_Encrypted__c='00e13000001sink',Property_Value__c='00e13000001sink');
        insert objProperty ;  
    }  
    public static void InsertProp2()
    {
       Property__c objProperty = new Property__c(Property_Id__c='portalutils.seller.profile.id',Property_Value_Encrypted__c='00e13000001sinj',Property_Value__c='00e13000001sinj');
        insert objProperty ;  
    }   
}