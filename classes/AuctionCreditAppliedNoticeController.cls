public class AuctionCreditAppliedNoticeController 
{
    
    public Boolean isCanada {get; set;}
    public Boolean isBuyer {get; set;}
    public Decimal creditAmount {get; set;}
    public String buyerOrgName {get; set;}
    public String sellerOrgName {get; set;}
    public Datetime createDate {get; set;}
    public Datetime saleDate {get; set;}
    public Boolean isFastLaneACH {get; set;}
    public Boolean isDirectDebit {get; set;}
    public String vin {get; set;}
    
    
    /*  
    *   ActionPackageId will be passed in by the "auctionCreditExpirationNotice" component.  
    *   The "set" accessor will act as the constructor method for this class
    */
    public String auctionCreditId{
        get;
        
        set
        {
            auctionCreditId = value;
            
            Auction_Credit__c ac = 
            [
                SELECT Id, Credit_Amount__c, CurrencyIsoCode, createdDate,
                       purchase__r.ATC_Buyer__r.name, purchase__r.ATC_Seller__r.name,
                       purchase__r.payment_method__c, 
                       purchase__r.ATC_Sale_Date__c, auction_Credit_type__c,
                       purchase__r.name
                FROM Auction_Credit__c
                WHERE Id = :value
            ];
            try
            {
                Logger.info(ac, 'Gathering Data for Auction Credit Applied Notice');
                
                isCanada = 'CAD'.equalsIgnoreCase(ac.CurrencyIsoCode) ? true : false;
                buyerOrgName = ac.purchase__r.ATC_Buyer__r.name;
                sellerOrgName = ac.purchase__r.ATC_Seller__r.name;
                isFastLaneACH = 'Fastlane ACH'.equalsIgnoreCase(ac.purchase__r.payment_method__c) ? true: false;
                isDirectDebit = 'Direct Debit'.equalsIgnoreCase(ac.purchase__r.payment_method__c) ? true: false;
                createDate = ac.createdDate;
                saleDate = ac.purchase__r.ATC_Sale_Date__c;
                creditAmount = ac.credit_Amount__c;
                vin = ac.purchase__r.name;
                isBuyer = 'Seller Auction Credit'.equalsIgnoreCase(ac.auction_credit_type__c)? false :true;
            }
            catch (Exception e)
            {
                Logger.error(ac, e.getMessage());
                throw new CreditAppliedNoticeException(e);  
            }
            finally
            {
                Logger.flush(); 
            }
        }
    }
    
    public class CreditAppliedNoticeException extends Exception {}
}