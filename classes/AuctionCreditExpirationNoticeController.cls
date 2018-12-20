public class AuctionCreditExpirationNoticeController 
{
    public Integer numCredits {get; set;}
    public Decimal creditAmount {get; set;}
    public Date expirationDate {get; set;}
    public Integer daysRemaining {get; set;}
    public Boolean isCanada {get; set;}
    public Boolean isBuyer {get; set;}
    public String issuedTo {get; set;}
    
    /*  
    *   ActionPackageId will be passed in by the "auctionCreditExpirationNotice" component.  
    *   The "set" accessor will act as the constructor method for this class
    */
    public String actionPackageId {
        get;
        
        set
        {
            actionPackageId = value;
            
            Action_Package__c pkg = 
            [
                SELECT Id, CurrencyIsoCode, package_type__c, case__r.account.name, case__r.seller__r.name,
                    (SELECT Id, Credit_Amount__c, Expires__c FROM Auction_Credits__r WHERE Status__c = 'Available')
                FROM Action_Package__c
                WHERE Id = :value
            ];
            try
            {
                Logger.info(pkg, 'Gathering Data for Auction Credit Expiration Notice');
                Logger.info(pkg, 'pkg.CurrencyIsoCode'+ pkg.CurrencyIsoCode+' pkg.package_type__c'+pkg.package_type__c);
                numCredits = 0;
                isCanada = pkg.CurrencyIsoCode == 'CAD' ? true : false;
                isBuyer = (pkg.package_type__c == 'Seller Auction Credit' ? false: true);
                if(isBuyer){
                   issuedTo = pkg.case__r.account.name;
                }else{
                   issuedTo = pkg.case__r.seller__r.name;
                }
                for (Auction_Credit__c credit : pkg.Auction_Credits__r)
                {
                    Logger.info(pkg, 'Inside loop');
                    // Require all credits on a given package to have the same credit amount.  
                    if (creditAmount != null && credit.Credit_Amount__c != creditAmount)
                    {
                        Logger.error(pkg, 'Credit Amount mismatch detected.  Expected ' + creditAmount + ', found ' + credit.Credit_Amount__c);
                    }
                    
                    // Require all credits on a given package to have the same expiration date.  
                    if (expirationDate != null && !credit.Expires__c.isSameDay(expirationDate))
                    {
                        Logger.error(pkg, 'Credit Expiration Date mismatch detected.  Expected ' + expirationDate + ', found ' + credit.Expires__c);
                    }
                    
                    creditAmount = credit.Credit_Amount__c;
                    expirationDate = credit.Expires__c;
                    numCredits += 1;
                }
                Logger.info(pkg, 'After Loop');
                daysRemaining = Date.today().daysBetween(expirationDate);
                if (daysRemaining <= 0)
                {
                    Logger.error(pkg, 'Days remaining must be positive.  Found daysRemaining= ' + daysRemaining);
                }
            }
            catch (Exception e)
            {
                Logger.error(pkg, e.getMessage());
                throw new ExpirationNoticeException(e); 
            }
            finally
            {
                Logger.flush(); 
            }
        }
    }
    
    public class ExpirationNoticeException extends Exception {}
}