@isTest
private class TestKDM_BatchOpTerritoryFieldUpdate {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOpTerritoryFieldUpdate b = new KDM_BatchOpTerritoryFieldUpdate('',false,'');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
    
    static testmethod void test2() {
    
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
        Insert acct1;        
        
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='100',Account__c=acct1.Id);
        Insert Adesa1;      
       
        User ObjUser = [SELECT UserName, Id FROM User WHERE IsPortalEnabled=false LIMIT 1];
       
        Property__c objProperty2 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=ObjUser.UserName);
        insert objProperty2 ; 
        
        Property__c objProperty3 = new Property__c(Property_Id__c='username.patch',Property_Value__c='.kar@');
        insert objProperty3 ;   

        
        
        Territory__c obj = new Territory__c();
        obj.Op_Assinged_Auction_ATC_Org_Id__c='100';
        obj.Op_Account_Owner_Username__c = ObjUser.UserName;
        obj.Op_DST_Outside_Sales_Rep_Username__c = ObjUser.UserName;
        obj.Op_D2D_Specialist_Username__c = ObjUser.UserName;
        obj.Op_DOSS_Username__c = ObjUser.UserName;
        obj.Op_ISS_Username__c = ObjUser.UserName;
        obj.Op_Owner_Username__c = ObjUser.UserName;        
        Insert obj;
        
        Test.startTest();
        KDM_BatchOpTerritoryFieldUpdate b = new KDM_BatchOpTerritoryFieldUpdate('',true,'');
        Database.executeBatch(b);
        Test.stopTest();       
    }
}