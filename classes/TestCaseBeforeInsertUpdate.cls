@isTest
private class TestCaseBeforeInsertUpdate {

    static testmethod void testDSSFStewardshipDuplicateCases() {
             
        String StewardshipRecordTypeId = Utils.getRecordTypeId('Case', 'Stewardship'); 
        Case C1 = new Case(recordtypeid=StewardshipRecordTypeId,subject='Purchase Upsert Error 12345',description='TEST 12345');
        Case C2 = new Case(recordtypeid=StewardshipRecordTypeId,subject='Purchase Upsert Error 56785',description='TEST 56789');
        Case C3 = new Case(recordtypeid=StewardshipRecordTypeId,subject='Purchase Upsert Error 56785',description='TEST 567890');        
        Case C4 = new Case(recordtypeid=StewardshipRecordTypeId,subject='Purchase Upsert Error 56785',description='TEST 56789');     

        List<Case> cases1 = new List<Case>();
        cases1.Add(c1);
        Cases1.Add(c2);
        
        List<Case> cases2 = new List<Case>();
        cases2.Add(c3);
        Cases2.Add(c4);
        
        Test.startTest();   
        
        Database.Upsert(Cases1,Case.Id,false);  
        Database.Upsert(Cases2,Case.Id,false);  
        
        Test.stopTest();
       
    }    
}