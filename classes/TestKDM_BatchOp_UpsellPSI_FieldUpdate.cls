@isTest
private class TestKDM_BatchOp_UpsellPSI_FieldUpdate{

    static testmethod void test1() {
             
       Test.startTest();
       KDM_BatchOp_UpsellPSI_FieldUpdate objKDM_BatchOp_UpsellPSI_FieldUpdate = new KDM_BatchOp_UpsellPSI_FieldUpdate(' and Loaded__c=1',true,'dipesh.patel@openlane.com');
       Database.executeBatch(objKDM_BatchOp_UpsellPSI_FieldUpdate);
       Test.stopTest();
       
    }
    static testmethod void test2() {
    
       Account acct1 = new Account(Name='Test Account1',Master_Index__c='470');
       Insert acct1;
        
       Adesa_com_Detail__c Adesa1 = new Adesa_com_Detail__c(Name='Adesa1',ATC_Organization_ID__c='470',Account__c=acct1.Id);
       Insert Adesa1;
        
        Contact c1 = new Contact
        (
            FirstName='all1',
            LastName='Checked'
        ); 
        Insert c1;
        
        Purchase__c p1 = new Purchase__c
        (
            Name = 'JNKCV54E33M212907', 
            Vehicle_Id__c = '12347',
            Source_Id__c = '12347',
            Private_Label__c = 'OPENLANE.ca Open Auction',
            ATC_Buyer_Contact__c = c1.Id,          
            ATC_Sale_Date__c = system.today()
        );  
        Insert p1;
        
       Upsell_PSI__c obj = new Upsell_PSI__c(
                                Purchase__c=p1.id,
                                Op_Account_ATC_ORG_ID__c = '470',
                                Op_Purchase_Source_Id__c = '12347',
                                Is_Purchase_Found__c = false,
                                Is_Migrated_Record__c = true,
                                Loaded__c=1
                                );
       insert obj; 
       
       Test.startTest();
       KDM_BatchOp_UpsellPSI_FieldUpdate objKDM_BatchOp_UpsellPSI_FieldUpdate = new KDM_BatchOp_UpsellPSI_FieldUpdate(' and Loaded__c=1',true,'dipesh.patel@openlane.com');
       Database.executeBatch(objKDM_BatchOp_UpsellPSI_FieldUpdate);
       Test.stopTest();
       
    }   
}