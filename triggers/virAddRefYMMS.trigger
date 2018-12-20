trigger virAddRefYMMS on VIR__c (before insert, before update) {
    List<String> vIds = new List<String>();
    ID mpsRecType = Utils.getRecordTypeId('VIR__c', 'MPS_VIR');
    for (VIR__c vir : Trigger.new) {
        if (vir.Asset__c == null)
            vIds.add(vir.Vehicle_Id__c);
        if (vir.MPS_Source__c != null) {
          vir.recordTypeId = mpsRecType;
        }    
    }

    List<Asset__c> vaList = 
        [select id, Vehicle_Id__c, CurrencyIsoCode
         from Asset__c
         where Vehicle_Id__c in : vIds];
    
    Map<String, Asset__c> vaMap = new Map<String, Asset__c>();
    
    for (Asset__c va : vaList) {
        vaMap.put(va.Vehicle_Id__c, va);
    }

    for (VIR__c vir: Trigger.new) {
        if (vir.Asset__c == null) {
            Asset__c v = vaMap.get(vir.Vehicle_Id__c);
            if (v != null) {
                vir.Asset__c = v.Id; 
                vir.CurrencyIsoCode = v.CurrencyIsoCode;
            }
        } 
    } 
    
}