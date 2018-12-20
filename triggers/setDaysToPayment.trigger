trigger setDaysToPayment on Purchase__c (before insert, before update) {
    
  Date referenceDate = Date.newInstance(1900,1,6); // A Saturday for reference
  
  for (Purchase__c p : Trigger.new) {
    if (p.ATC_Sale_Date__c != null && p.Payment_Received__c != null) {
      Date startDate = Date.newInstance(p.ATC_Sale_Date__c.Year(), p.ATC_Sale_Date__c.Month(), p.ATC_Sale_Date__c.Day());
  
      p.Days_To_Payment__c = Utils.countWeekDays(startDate, p.Payment_Received__c);
    }
  }
}