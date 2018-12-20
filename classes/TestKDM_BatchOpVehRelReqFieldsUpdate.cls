@isTest
private class TestKDM_BatchOpVehRelReqFieldsUpdate{

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOpVehRelReqFieldsUpdate objKDM_BatchOpVehRelReqFieldsUpdate = new KDM_BatchOpVehRelReqFieldsUpdate(' and Loaded__c=1',true,'dipesh.patel@openlane.com');
       Database.executeBatch(objKDM_BatchOpVehRelReqFieldsUpdate);
       Test.stopTest();
       
    }
    static testmethod void test2() {
    
       Account acct1 = new Account(Name='Test Account1',Master_Index__c='570');
       Insert acct1;
        
       Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='570',Account__c=acct1.Id);
       Insert Adesa1;
        
        Contact c1 = new Contact
        (
            FirstName='Test570',
            LastName='Test570'
        ); 
        Insert c1;
        
        Purchase__c p1 = new Purchase__c
        (
            Name = 'JNKCV54E33M212908', 
            Vehicle_Id__c = '12348',
            Source_Id__c = '12348',         
            ATC_Buyer_Contact__c = c1.Id,          
            ATC_Sale_Date__c = system.today()
        );  
        Insert p1;
        
        String UserId = UserInfo.getUserId();
        String UserName = UserInfo.getUserName();
       
        Property__c objProperty1 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=UserName);
        insert objProperty1 ; 
        
        Property__c objProperty2 = new Property__c(Property_Id__c='username.patch',Property_Value__c='@');
        insert objProperty2 ;   
        
       Vehicle_Release_Request__c obj = new Vehicle_Release_Request__c(
                                Op_Purchase_Source_Id__c = '12348',
                                Is_Purchase_Found__c=false,
                                Op_Requesting_Manager_USERNAME__c=UserName,
                                Op_Requesting_Rep_USERNAME__c = UserName,
                                Is_Migrated_Record__c = true,
                                Loaded__c=1
                                );
       insert obj; 
       
       Test.startTest();
       KDM_BatchOpVehRelReqFieldsUpdate objKDM_BatchOpVehRelReqFieldsUpdate = new KDM_BatchOpVehRelReqFieldsUpdate(' and Loaded__c=1',true,'dipesh.patel@openlane.com');
       Database.executeBatch(objKDM_BatchOpVehRelReqFieldsUpdate);
       Test.stopTest();
       
    }  
    static testmethod void test3() {
        
           Account acct1 = new Account(Name='Test Account1',Master_Index__c='670');
           Insert acct1;
            
           Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='670',Account__c=acct1.Id);
           Insert Adesa1;
            
            Contact c1 = new Contact
            (
                FirstName='Test670',
                LastName='Test670'
            ); 
            Insert c1;
            
            Purchase__c p1 = new Purchase__c
            (
                Name = 'JNKCV54E33M212908', 
                Vehicle_Id__c = '12348',
                Source_Id__c = '12348',         
                ATC_Buyer_Contact__c = c1.Id,          
                ATC_Sale_Date__c = system.today()
            );  
            Insert p1;
            
            String UserId = UserInfo.getUserId();
            String UserName = UserInfo.getUserName();
           
            Property__c objProperty1 = new Property__c(Property_Id__c='migrated.case.default.owner.username',Property_Value__c=UserName);
            insert objProperty1 ;           
              
            
           Vehicle_Release_Request__c obj = new Vehicle_Release_Request__c(
                                    Op_Purchase_Source_Id__c = '12348',
                                    Is_Purchase_Found__c=false,
                                    Op_Requesting_Manager_USERNAME__c=UserName,
                                    Op_Requesting_Rep_USERNAME__c = UserName,
                                    Is_Migrated_Record__c = true,
                                    Loaded__c=1
                                    );
           insert obj; 
           
           Test.startTest();
           KDM_BatchOpVehRelReqFieldsUpdate objKDM_BatchOpVehRelReqFieldsUpdate = new KDM_BatchOpVehRelReqFieldsUpdate(' and Loaded__c=1',true,'dipesh.patel@openlane.com');
           Database.executeBatch(objKDM_BatchOpVehRelReqFieldsUpdate);
           Test.stopTest();
           
        }   
}