@isTest
public class TestBatchApplySharingRules {

      static testMethod void testBatch() {
        Test.StartTest();
        Case Case1 = TestUtility.createCase(false);
        Case1.Reason='Account';
        Case1.Is_Migrated_Openlane_Case__c=true;
        Case1.Openlane_Case_Owner_TYPE__c='User';
        Case1.Vehicle_Identification_Number__c='12345678901234567';
        Case1.Description='PSI FAILED:Description';
        Insert Case1;            
        Temp_Openlane_KAR_Case_Mapper__c obj_OL_KAR_Mapper = TestUtility.createKarCaseMapper(false);
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_Original_id__c = Case1.Id;
        obj_OL_KAR_Mapper.Migrated_Openlane_Case_KAR_id__c = Case1.Id;
        obj_OL_KAR_Mapper.Sharing_Rules_Applied__c = FALSE;
          
        List<Temp_Openlane_KAR_Case_Mapper__c> ListKarCaseMapper = new List<Temp_Openlane_KAR_Case_Mapper__c>();
        ListKarCaseMapper.add(obj_OL_KAR_Mapper);
        insert ListKarCaseMapper;          
          
        BatchApplySharingRules applySharingRules = new BatchApplySharingRules();
        Database.executeBatch(applySharingRules);
        Test.StopTest(); 
      }    
    
}