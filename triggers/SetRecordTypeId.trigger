trigger SetRecordTypeId on MVG_Price__c (before insert, before update) {

 for (MVG_Price__c mvg : Trigger.new)

  {
    if (mvg.CurrencyIsoCode =='CAD')
    {
        mvg.RecordTypeId = Utils.getRecordTypeId('MVG_Price__c', 'MVGCanada');
        
    }
    else
    {
        mvg.RecordTypeId = Utils.getRecordTypeId('MVG_Price__c', 'MVGUSA');
                   
    }
  }

}