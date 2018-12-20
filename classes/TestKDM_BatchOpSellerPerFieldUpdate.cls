@isTest
private class TestKDM_BatchOpSellerPerFieldUpdate {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOpSellerPermissionFieldUpdate b = new KDM_BatchOpSellerPermissionFieldUpdate('',false,'');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
    
    static testmethod void test2() {
    
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
        Insert acct1;        
        
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='100',Account__c=acct1.Id);
        Insert Adesa1;      
       
        List<User> ListUser = [SELECT UserName, Id FROM User WHERE IsPortalEnabled=true LIMIT 1];
       
       User ObjUser;
       if(ListUser.size()>0)
       {
            ObjUser = ListUser[0];
       
        Property__c objProperty2 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=ObjUser.UserName);
        insert objProperty2 ; 
        
        Property__c objProperty3 = new Property__c(Property_Id__c='username.patch',Property_Value__c='.kar@');
        insert objProperty3 ;   

        
        
        Seller_Permission__c obj = new Seller_Permission__c();
        obj.Op_Account_ATC_Org_ID__c='100';        
        obj.Op_User_Username__c = ObjUser.UserName;
        obj.Is_Migrated_Record__c = true;        
        Insert obj;
        }
        Test.startTest();
        KDM_BatchOpSellerPermissionFieldUpdate b = new KDM_BatchOpSellerPermissionFieldUpdate('',true,'');
        Database.executeBatch(b);
        Test.stopTest();       
    }
}