@isTest
private class TestBatchCaseFieldsRelationUpdate {

    static testmethod void test1() {
             
       Test.startTest();
       BatchCaseFieldsRelationUpdate b = new BatchCaseFieldsRelationUpdate('',true,'',false);
       Database.executeBatch(b);
       Test.stopTest();
       
    }
   
    static testmethod void test2() {
    
       //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());   
       
           
              
       Task[] ListTask = new List<Task>();
       
       for (Integer i=0;i<2;i++) {
            
            Contact objContact = new Contact(LastName='Patel'+ i,Login_ID__c='100'+i);
            Insert objContact;
        
           Task m = new Task(
                                Whoid=objContact.id                             
                            );
           ListTask.add(m);
       }
       insert ListTask;
       
       Account acct1 = new Account(Name='Test Account1',Master_Index__c='100');
       Insert acct1;
        
       Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='100',Account__c=acct1.Id);
       Insert Adesa1;
        
        Purchase__c Purchase1 = new Purchase__c(Name='Purchase1',Source_Id__c='OL',Consignee_Adesa_com_Detail__c=Adesa1.Id,Adesa_com__c=Adesa1.Id,ATC_Buyer_Adesa_com_Detail__c=Adesa1.Id,ATC_Seller_Adesa_com_Detail__c=Adesa1.Id,Transporter__c=Adesa1.Id);
        Insert Purchase1;
        
        Case Case1 = new Case(Reason='Account',Is_Migrated_Openlane_Case__c=true,Openlane_Case_Owner_TYPE__c='User',ADESA_com_Detail__c=Adesa1.Id,Vehicle_Identification_Number__c='12345678901234567',Description='PSI FAILED:Description');
        Insert Case1;
        
        Group gr1 = new Group(Name='Group1',Type='Regular');
        insert gr1;
    
       User ObjUser = [SELECT UserName, Id FROM User WHERE IsPortalEnabled=false LIMIT 1];
       
       Property__c objProperty3 = new Property__c(Property_Id__c='is.migration.running',Property_Value__c='YES');
        insert objProperty3 ;   
        
       Property__c objProperty = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=ObjUser.Username);
        insert objProperty ; 
        
        //Property__c objProperty2 = new Property__c(Property_Id__c='username.patch',Property_Value__c='');
        //insert objProperty2 ;  
        
       //Property__c objProperty4 = new Property__c(Property_Id__c='sandbox.suffix',Property_Value__c='');
       //insert objProperty4 ;
 
        
       Temp_Openlane_KAR_Case_Mapper__c obj_OL_KAR_Mapper = new Temp_Openlane_KAR_Case_Mapper__c();
        obj_OL_KAR_Mapper.RecordType_Name__c= [SELECT  Name, NamespacePrefix, Id, DeveloperName, SobjectType FROM RecordType where SobjectType='case' and IsActive=true LIMIT 1].Name;     
        obj_OL_KAR_Mapper.Contact_LOGIN_ID__c= [SELECT Login_ID__c, Id FROM Contact LIMIT 1].Login_ID__c;
        obj_OL_KAR_Mapper.Seller_Contact_LOGIN_ID__c=[SELECT Login_ID__c, Id FROM Contact LIMIT 1].Login_ID__c;
        obj_OL_KAR_Mapper.Seller_ATC_ORG_ID__c=Adesa1.ATC_Organization_ID__c;
        obj_OL_KAR_Mapper.PALS_ATC_ORG_ID__c=Adesa1.ATC_Organization_ID__c;
        obj_OL_KAR_Mapper.Transporter_ATC_ORG_ID__c=Adesa1.ATC_Organization_ID__c;
        obj_OL_KAR_Mapper.Account_ATC_ORG_ID__c=Adesa1.ATC_Organization_ID__c;
        obj_OL_KAR_Mapper.Purchase_VEHICLE_ID_SOURCE_ID__c=Purchase1.Source_Id__c;
        obj_OL_KAR_Mapper.Related_to_Enhancement_Case_ID__c='100';
        obj_OL_KAR_Mapper.Secondary_Owner_USERNAME__c = ObjUser.UserName;
        obj_OL_KAR_Mapper.Requested_By_Internal_USERNAME__c=ObjUser.UserName;
        obj_OL_KAR_Mapper.Owner_USERNAME__c=ObjUser.UserName;
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_KAR_id__c=Case1.Id;
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_Original_id__c = '500123456789012345';
        
        Insert obj_OL_KAR_Mapper;
        
        //Temp_Openlane_KAR_Case_Mapper__c obj_OL_KAR_Mapper2 = new Temp_Openlane_KAR_Case_Mapper__c();
        //obj_OL_KAR_Mapper2.RecordType_Name__c= [SELECT  Name, NamespacePrefix, Id, DeveloperName, SobjectType FROM RecordType where SobjectType='case' and IsActive=true LIMIT 1].Name;    
        //obj_OL_KAR_Mapper2.Contact_LOGIN_ID__c= [SELECT Login_ID__c, Id FROM Contact LIMIT 1].Login_ID__c;
        //obj_OL_KAR_Mapper2.Seller_Contact_LOGIN_ID__c=[SELECT Login_ID__c, Id FROM Contact LIMIT 1].Login_ID__c;
        //obj_OL_KAR_Mapper2.Seller_ATC_ORG_ID__c=Adesa1.ATC_Organization_ID__c;
        //obj_OL_KAR_Mapper2.PALS_ATC_ORG_ID__c=Adesa1.ATC_Organization_ID__c;
        //obj_OL_KAR_Mapper2.Transporter_ATC_ORG_ID__c=Adesa1.ATC_Organization_ID__c;
        //obj_OL_KAR_Mapper2.Account_ATC_ORG_ID__c=Adesa1.ATC_Organization_ID__c;
        //obj_OL_KAR_Mapper2.Purchase_VEHICLE_ID_SOURCE_ID__c=Purchase1.Source_Id__c;
        //obj_OL_KAR_Mapper2.Related_to_Enhancement_Case_ID__c=[SELECT Migrated_Openlane_Case_Original_id__c, Migrated_Openlane_Case_KAR_id__c FROM Temp_Openlane_KAR_Case_Mapper__c LIMIT 1].Id;
        //obj_OL_KAR_Mapper2.Secondary_Owner_USERNAME__c = ObjUser.UserName;
        //obj_OL_KAR_Mapper2.Requested_By_Internal_USERNAME__c=ObjUser.UserName;
        //obj_OL_KAR_Mapper2.Owner_USERNAME__c=gr1.Name;
        //obj_OL_KAR_Mapper2.Migrated_Openlane_Case_KAR_id__c=Case1.Id;
        //Insert obj_OL_KAR_Mapper2;
       

       Test.startTest();
       BatchCaseFieldsRelationUpdate b2 = new BatchCaseFieldsRelationUpdate('',true,'',false);
       Database.executeBatch(b2);
       Test.stopTest();
       
    }
    
}