@isTest
private class TestKDM_BatchOpOppDealerProfileFU{

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOpOppDealerProfileFieldsUpdt objKDM_BatchOpOppDealerProfileFieldsUpdt = new KDM_BatchOpOppDealerProfileFieldsUpdt(' ',true,'dipesh.patel@openlane.com');
       Database.executeBatch(objKDM_BatchOpOppDealerProfileFieldsUpdt);
       Test.stopTest();
       
    }
    static testmethod void test2() {
    
       Account acct1 = new Account(Name='Test Account1',Master_Index__c='490');
       Insert acct1;    
       
         Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='490',Account__c=acct1.Id);
        Insert Adesa1;
        
        
        Vehicle_Make__c objVM = new Vehicle_Make__c
        (
            Make_ID__c=1
        ); 
        Insert objVM;
        
        Vehicle_Model__c obj = new Vehicle_Model__c
        (
            Model_ID__c=1,
            Make__c = objVM.Id
        ); 
        Insert obj;     
        
        Contact Contact1 = new Contact(LastName='Patel',Login_ID__c='490');
        Insert Contact1;
        
       Survey__c objSurvey = new Survey__c(
                                
                                Op_Account_ATC_ORG_ID__c = '490',                               
                                Op_RecordType_NAME__c='Test RT',                                
                                Op_Contact_LOGIN_ID__c='490',
                                Op_Dealer_Profile_SF_ID__c='TestID',
                                Op_DP_5a_Make_ID__c='1',
                                Op_DP_5b_Model_ID__c='1',
                                Op_DP_5d_Make_ID__c='1',
                                Op_DP_5e_Model_ID__c='1',
                                Op_DP_5g_Make_ID__c='1',
                                Op_DP_5h_Model_ID__c='1',
                                Op_DP_9a_Make_ID__c='1',
                                Op_DP_9b_Model_ID__c='1',
                                Op_DP_9d_Make_ID__c='1',
                                Op_DP_9e_Model_ID__c='1',
                                Op_DP_9g_Make_ID__c='1',
                                Op_DP_9h_Model_ID__c='1'
                                );
       insert objSurvey; 
       
       Opportunity_Dealer_Profile__c  objOppDealerProf = new Opportunity_Dealer_Profile__c (
                                
                                Op_Account_ATC_ORG_ID__c = '490',                               
                                Op_Dealer_Profile_SF_ID__c='TestID',
                                Is_Migrated_Record__c=true 
                                );
       Insert objOppDealerProf; 
       
       Test.startTest();
       KDM_BatchOpOppDealerProfileFieldsUpdt objKDM_BatchOpOppDealerProfileFieldsUpdt = new KDM_BatchOpOppDealerProfileFieldsUpdt(' ',true,'dipesh.patel@openlane.com');
       Database.executeBatch(objKDM_BatchOpOppDealerProfileFieldsUpdt);
       Test.stopTest();
       
    }   
}