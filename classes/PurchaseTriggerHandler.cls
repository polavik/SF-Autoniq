public with sharing class PurchaseTriggerHandler {
    private static ID REC_TYPE_RECENT;
    private static ID REC_TYPE_US;
    private static ID REC_TYPE_CA;
    private static ID REC_TYPE_AFC;  
    private static ID REC_TYPE_AMS;  
    private static final String COUNTRY_US='United States';
    private static final String COUNTRY_CA='Canada';
    
    public static void updateRecordType(Purchase__c[] purchases) {
        for (Purchase__c p : purchases) {
            updateRecordType(p);
        }
    }
    
    public static void updateRecordType(Purchase__c p) {
// disable for 7a        
//        if (p.MPS_Vehicle_Id__c != null) {
//            p.RecordTypeId=Utils.getRecordTypeId('Purchase__c', 'MPS Purchase');
//            return;
//        }
//       
      
      
        if (p.Data_Source__c == 'AFC'){
          if (p.RecordTypeId == null) {
                REC_TYPE_AFC = Utils.getRecordTypeId('Purchase__c', 'AFC Purchase');
                p.RecordTypeId = REC_TYPE_AFC;
            } 
            return; 
        }


        if (REC_TYPE_RECENT == null) {
            loadRecordTypes();
        }
    
        if (p.Data_Source__c == 'ADESA' ){
          if (p.RecordTypeId == REC_TYPE_AFC){
              p.RecordTypeId = REC_TYPE_AFC;
              return;
          }
          if(p.RecordTypeId == null && p.AMS_Inventory_ID__c == null ){
              p.RecordTypeId = REC_TYPE_RECENT;
              return;
          }             
        }
        
        
        if (p.AMS_Inventory_ID__c != null && (p.RecordTypeId == null || p.RecordTypeId == REC_TYPE_RECENT)){
           p.RecordTypeId = REC_TYPE_AMS;
           return;
        }
        

        if (p == null || p.AMS_Inventory_ID__c != null || 
            p.ATC_Sale_Date__c == null || p.source_ID__c == null)
           return;


        if (Date.today().isSameDay(p.ATC_Sale_Date__c.date())) {
            if (p.RecordTypeId == null) {
                p.RecordTypeId = REC_TYPE_RECENT;
            } 
            return; 
        }
     
        if (REC_TYPE_RECENT == p.RecordTypeId) {
             if (COUNTRY_US.equals(p.Country__c)) {
                 p.RecordTypeId = REC_TYPE_US;
             }
             else if (COUNTRY_CA.equals(p.Country__c)) {
                 p.RecordTypeId = REC_TYPE_CA;
             }
        }
    }
    
    private static void loadRecordTypes()
    {
        REC_TYPE_RECENT = Utils.getRecordTypeId('Purchase__c', 'Recent Purchase');
        REC_TYPE_US = Utils.getRecordTypeId('Purchase__c', 'US Purchase');
        REC_TYPE_CA = Utils.getRecordTypeId('Purchase__c', 'Canadian Purchase');
        REC_TYPE_AMS = Utils.getRecordTypeId('Purchase__c', 'ADESA AMS Purchase');
        REC_TYPE_AFC = Utils.getRecordTypeId('Purchase__c', 'AFC Purchase');
        
    }    
    
}