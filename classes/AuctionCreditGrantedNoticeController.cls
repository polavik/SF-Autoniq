public class AuctionCreditGrantedNoticeController 
{
    public Integer numCredits {get; set;}
    public Decimal creditAmount {get; set;}
    public Date expirationDate {get; set;}
    public Integer daysRemaining {get; set;}
    public Boolean isCanada {get; set;}
    public String accountName {get; set;}
    public String orgId {get; set;}
    public String creditType {get; set;}
    
    
    /*  
    *   ActionPackageId will be passed in by the "auctionCreditExpirationNotice" component.  
    *   The "set" accessor will act as the constructor method for this class
    */
    public String actionPackageId {
        get;
        
        set
        {
            actionPackageId = value;
            
            List<Action_Package__c> pkgs = 
            [
                SELECT Id, Account_Name__c, Seller__c, CurrencyIsoCode, 
                // FIXME: Case__r.Account.ATC_Organization_ID__c, 
                Package_Type__c,
                    (SELECT Id, Credit_Amount__c, Expires__c FROM Auction_Credits__r WHERE Status__c = 'Available')
                FROM Action_Package__c
                WHERE Id = :value
            ];
            if(pkgs.size()>0){
                Action_Package__c pkg = pkgs.get(0);
                try
                {
                    Logger.info(pkg, 'Gathering Data for Auction Credit Granted Notice');
                    
                    numCredits = 0;
                    isCanada = 'CAD'.equalsIgnoreCase(pkg.CurrencyIsoCode) ? true : false;
                    orgId = '0'; // FIXME: pkg.Case__r.Account.ATC_Organization_ID__c;
                    
                     if('Seller Auction Credit'.equalsIgnoreCase(pkg.Package_Type__c)){
                         creditType = 'sale';
                         accountName = pkg.Seller__c;
                     }else if('Auction Credit'.equalsIgnoreCase(pkg.Package_Type__c)){
                         creditType = 'purchase';
                         accountName = pkg.Account_Name__c;
                     }
                    
                    for (Auction_Credit__c credit : pkg.Auction_Credits__r)
                    {
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
                    
                    daysRemaining = Date.today().daysBetween(expirationDate);
                    if (daysRemaining <= 0)
                    {
                        Logger.error(pkg, 'Days remaining must be positive.  Found daysRemaining= ' + daysRemaining);
                    }
                }
                catch (Exception e)
                {
                    Logger.error(pkg, e.getMessage());
                    throw new CreditGrantedNoticeException(e);  
                }
                finally
                {
                    Logger.flush(); 
                }
            }
        }
    }
    
    public class CreditGrantedNoticeException extends Exception {}
}