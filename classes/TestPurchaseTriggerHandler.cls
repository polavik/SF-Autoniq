@isTest
public class TestPurchaseTriggerHandler{
    static testMethod void testUpdateRecordType() {
        ID REC_TYPE_RECENT = Utils.getRecordTypeId('Purchase__c', 'Recent Purchase');
        ID REC_TYPE_US = Utils.getRecordTypeId('Purchase__c', 'US Purchase');
        ID REC_TYPE_CA = Utils.getRecordTypeId('Purchase__c', 'Canadian Purchase');
        String COUNTRY_US='United States';
        String COUNTRY_CA='Canada';
         
        Purchase__c p = new Purchase__c();
        p.Vehicle_ID__c = '123456';
        p.ATC_Sale_Date__c = Datetime.now().addDays(-2);
        p.Country__c=COUNTRY_US;
        p.RecordTypeId = REC_TYPE_RECENT;
        p.Source_Id__c = '12345678';
        PurchaseTriggerHandler.updateRecordType(p);
        System.assertEquals(p.RecordTypeId,REC_TYPE_US);

        p.RecordTypeId = REC_TYPE_RECENT;
        p.Country__c=COUNTRY_CA;
        PurchaseTriggerHandler.updateRecordType(p);
        System.assertEquals(p.RecordTypeId,REC_TYPE_CA);

        p.RecordTypeId = REC_TYPE_RECENT;
        p.ATC_Sale_Date__c = Datetime.now();
        PurchaseTriggerHandler.updateRecordType(p);
        System.assertEquals(p.RecordTypeId,REC_TYPE_RECENT);
        
    }
}