trigger setDaysToTitle on Purchase__c (before insert, before update) {
    
    for (Purchase__c p : Trigger.new) {
        if (p.ATC_Sale_Date__c != null && p.Title_Received__c != null) {
            
            Date startDate = Date.newInstance(p.ATC_Sale_Date__c.Year(), p.ATC_Sale_Date__c.Month(), p.ATC_Sale_Date__c.Day());
    
            p.Days_To_Title__c = Utils.countWeekDays(startDate, p.Title_Received__c);
        }
    }
}