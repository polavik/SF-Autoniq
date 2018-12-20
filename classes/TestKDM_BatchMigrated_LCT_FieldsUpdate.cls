@isTest
private class TestKDM_BatchMigrated_LCT_FieldsUpdate {

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchMigrated_LCT_FieldsUpdate b = new KDM_BatchMigrated_LCT_FieldsUpdate('',true,'dipesh.patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
    static testmethod void test2() {
        
       //UserName
        User ObjUser = [SELECT UserName, Id FROM User WHERE IsPortalEnabled=false LIMIT 1];
        
        Property__c objProperty3 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=ObjUser.Username);
        Insert objProperty3 ;  
        
        Property__c objProperty1 = new Property__c(Property_Id__c='username.patch',Property_Value__c='@');
        Insert objProperty1 ;  

        Property__c objProperty2 = new Property__c(Property_Id__c='sandbox.suffix',Property_Value__c='');
        Insert objProperty2 ;       
        
        
        //Account
        Account acct1 = new Account(Name='Test Account1',Master_Index__c='1200');
        Insert acct1;
        
        Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='1200',Account__c=acct1.Id);
        Insert Adesa1;
        
        //Contact
        Contact objContact = new Contact(LastName='Patel',Login_ID__c='1400');
        Insert objContact;
        
        //LiveChatVisitor   
        LiveChatVisitor objLiveChatVisitor = new LiveChatVisitor();
        //objLiveChatTranscript.SessionKey = ;
        Insert objLiveChatVisitor;
        
        //LiveChatTranscript      
        LiveChatTranscript objLiveChatTranscript = new LiveChatTranscript();
        objLiveChatTranscript.OL_LC_Trascript_SF_ID__c = 'OL_SF_ID_TEST';
        objLiveChatTranscript.OL_Account_ATC_ORG_ID__c = '1200';
        objLiveChatTranscript.OL_Contact_Login_ID__c = '1400';
        objLiveChatTranscript.OL_Owner_Username__c = ObjUser.Username;
        objLiveChatTranscript.LiveChatVisitorId = objLiveChatVisitor.Id;
        //objLiveChatTranscript.LiveChatDeploymentId = ;
        //objLiveChatTranscript.LiveChatButtonId = ;
        Insert objLiveChatTranscript;
        
        
       Test.startTest();
       KDM_BatchMigrated_LCT_FieldsUpdate b = new KDM_BatchMigrated_LCT_FieldsUpdate('WHERE OL_LC_Trascript_SF_ID__c!=\'\' ',true,'dipesh.patel@openlane.com');
       Database.executeBatch(b);
       Test.stopTest();
       
    }
}