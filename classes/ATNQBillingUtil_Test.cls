@isTest
public class ATNQBillingUtil_Test {
    
    @isTest
    public static void testATNQBillingUtilFromStartDateToNextBillDate(){
        
        Date subItemStartDate 	= Date.today();
        Date nextBillDate		= Date.today().addMonths(1).addDays(1);
        Date subItemEndDate 	= nextBillDate;
        
        
        System.assertEquals(false, ATNQBillingUtil.isInBillingPeriod(subItemStartDate, subItemEndDate, nextBillDate));
       
    }
    
    @isTest
    public static void testATNQBillingUtilFromStartDateToEarlierThanNextBillDate(){
        
        Date subItemStartDate 	= Date.today();
        Date subItemEndDate 	= subItemStartDate.addDays(14);
        Date nextBillDate		= Date.today();
        
        System.assertEquals(true, ATNQBillingUtil.isInBillingPeriod(subItemStartDate, subItemEndDate, nextBillDate));
       
    }
    
    @isTest
    public static void testATNQBillingUtilFromAfterStartDateToEarlierThanNextBillDate(){
        
        Date subItemStartDate 	= Date.today().addDays(2);
        Date subItemEndDate 	= subItemStartDate.addDays(14);
        Date nextBillDate		= Date.today();
        
        System.assertEquals(true, ATNQBillingUtil.isInBillingPeriod(subItemStartDate, subItemEndDate, nextBillDate));
       
    }
    
    @isTest
    public static void testATNQBillingUtilFromAfterStartDateToNextBillDate(){
        
        Date subItemStartDate 	= Date.today().addDays(2);
        Date nextBillDate		= Date.today();
        Date subItemEndDate 	= Date.today().addMonths(1);
        
        
        System.assertEquals(false, ATNQBillingUtil.isInBillingPeriod(subItemStartDate, subItemEndDate, nextBillDate));
       
    }
    
    @isTest
    public static void testATNQBillingUtilFromBeforeStartDateToNextBillDate(){
        
        Date subItemStartDate 	= Date.today().addDays(-2);
        Date nextBillDate		= Date.today().addMonths(1).addDays(1);
        Date subItemEndDate 	= nextBillDate;

        System.assertEquals(false, ATNQBillingUtil.isInBillingPeriod(subItemStartDate, subItemEndDate, nextBillDate));
       
    }
    
    @isTest
    public static void testATNQBillingUtilFromAfterStartDateToAfterNextBillDate(){
        
        Date subItemStartDate 	= Date.today().addDays(1);
        Date nextBillDate		= Date.today();
        Date subItemEndDate 	= Date.today().addMonths(1);
        
        
        System.assertEquals(false, ATNQBillingUtil.isInBillingPeriod(subItemStartDate, subItemEndDate, nextBillDate));
       
    }
    
    @isTest
    public static void testATNQBillingUtilFromStartDateToAfterNextBillDate(){
        
        Date subItemStartDate 	= Date.today();
        Date nextBillDate		= Date.today();
        Date subItemEndDate 	= nextBillDate.addMonths(1);
        
        
        System.assertEquals(false, ATNQBillingUtil.isInBillingPeriod(subItemStartDate, subItemEndDate, nextBillDate));
       
    }
    
    @isTest
    public static void testNumberOfDaysProrated(){
        
        Date subItemStartDate 	= Date.today();
        Date subItemEndDate 	= subItemStartDate.addDays(17);
            
        System.assertEquals(18, ATNQBillingUtil.numberOfDaysProrated(subItemStartDate,subItemEndDate));
    }
    
    @isTest
    public static void testNumberOfDaysProrated2(){
        
        Date subItemStartDate 	= Date.today();
        Date subItemEndDate 	= subItemStartDate;
            
        System.assertEquals(1, ATNQBillingUtil.numberOfDaysProrated(subItemStartDate,subItemEndDate));
    }

    @isTest
    public static void testNumberOfDaysProrated3(){
        
        Date subItemStartDate 	= Date.today();
        Date subItemEndDate 	= subItemStartDate.addDays(-1);
            
        System.assertEquals(0, ATNQBillingUtil.numberOfDaysProrated(subItemStartDate,subItemEndDate));
    }
    
    @isTest
    public static void testproratedPriceForMonthlySubscription(){
        
        Date startDate;
        integer y = Date.today().year();
        integer m = 1;//January
        startDate = Date.newInstance(y, m, 1);
        integer numDays = 10;
        
        decimal price = 50.00;
        decimal expected= ((50.00 / Date.daysInMonth(y, m)) * numDays).setScale(2,RoundingMode.HALF_UP);
        
        System.assertEquals(expected, ATNQBillingUtil.proratedPriceForMonthlySubscription(price, numDays, startDate));
        
    }
    
    @isTest
    public static void testproratedPriceForMonthlySubscriptionForFeb_2004(){// Leap year
        
        Date startDate;
        integer y = 2004;
        integer m = 2;//February
        startDate = Date.newInstance(y, m, 1);
        integer numDays = date.daysInMonth(y, m);//The whole month
        
        decimal price = 50.00;
        decimal expected= ((50.00 / Date.daysInMonth(y, m)) * numDays).setScale(2,RoundingMode.HALF_UP);
        System.assertEquals(29,numDays);
        System.assertEquals(expected, ATNQBillingUtil.proratedPriceForMonthlySubscription(price, numDays, startDate));
        
    }
    
    @isTest
    public static void testproratedPriceForMonthlySubscriptionForFeb_2005(){//non leap year
        
        Date startDate;
        integer y = 2005;
        integer m = 2;//february
        startDate = Date.newInstance(y, m, 1);
        integer numDays = Date.daysInMonth(y, m);//The whole month
        
        decimal price = 50.00;
        decimal expected= ((50.00 / Date.daysInMonth(y, m)) * numDays).setScale(2,RoundingMode.HALF_UP);
        System.assertEquals(28,numDays);
        System.assertEquals(expected, ATNQBillingUtil.proratedPriceForMonthlySubscription(price, numDays, startDate));
        
    }

    @isTest
    public static void testisInBillingPeriodTrue(){

        Date startDate = Date.today();
        Date endDate = startDate.addDays(15);
        Date nextBillDate = startDate;
        boolean expected = true;
        System.assertEquals(expected, ATNQBillingUtil.isInBillingPeriod(startDate, endDate, nextBillDate));


    }

    @isTest
    public static void testisInBillingPeriodFalse(){

        Date startDate = Date.today();
        Date endDate = startDate.addMonths(1).addDays(-1);
        Date nextBillDate = startDate.addMonths(1);
        boolean expected = false;
        System.assertEquals(expected, ATNQBillingUtil.isInBillingPeriod(startDate, endDate, nextBillDate));


    }

    @isTest
    public static void tetcreateOrderItemsFromSubItems(){

    }

    /*  ASSUMPTIONS
        During an update partial month only applies to cancel date withing that month.
        meaning the customer canceellation occured in previous months.
        Same applies to Annual Term.
    */
    

}