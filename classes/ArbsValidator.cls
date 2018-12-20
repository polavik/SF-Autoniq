public class ArbsValidator {


    public static ValidationResults validate(Case myCase) {
        
        Purchase__c purchase = myCase.VIN__r;
        ValidationResults results = new ValidationResults();
        
        // Sanity check, make sure case is an Arbitration
        if (!myCase.Type.equals('Arbitration')) {throw new ArbsValidatorException('Not an Arbitration Case');}
        
        // If we can't match the purchase, return undecided
        if (purchase == null) {
            results.undecided = true;
            return results;
        }
        
        // Check Openlane Handles Payment
        if (!'Y'.equalsIgnoreCase(purchase.Handles_Payment__c)) {
            results.undecided = true;
            return results;
        }
        
        // Check Open Sale
        if (purchase.sale_class__c == null || !purchase.sale_class__c.contains('Open')) {
            results.undecided = true;
            return results;
        }
        
        // Check Payment Received
        if (purchase.Payment_Received__c == null) {
            results.paymentError = true;
        }
        
        // Check Grounding Dealer and Non-Title-Issue Reason
        if ('Open - Grounding Dealer'.equals(purchase.sale_class__c) && !'Title Issues'.equals(myCase.Reason)) {
            results.groundingDealerError = true;
        }
        
        // Check Case Reason
        if ('Odometer Discrepancy'.equals(myCase.Reason) || 'Title Issues'.equals(myCase.Reason)) {
            results.undecided = true;
            return results;
        }
        
        
        // Determine if transport is OL Arranged or Buyer/Seller Arranged
        boolean OLTransport = false;
        if (purchase.Transport_Preference__c == null) {
            results.undecided = true;
            return results;
        }
        else if ('OPENLANE Arranged'.equals(purchase.Transport_Preference__c) ||
                 'OPENLANE Canada Arranged'.equals(purchase.Transport_Preference__c)) {
                    
            //  Check transporter for "OPENLANE CANADA TRANSPORT" (i.e. transport handled in OCAS)
            if (purchase.ATC_Transporter__c != null &&
                '27445'.equals(purchase.Adesa_com__r.ATC_Organization_ID__c)) {
                
                results.undecided = true;
                return results;
            }
            // Check transporter for "CANCELLED TRANSPORT" or "CANCELLED TRANSPORT CANADA"
            else if (purchase.ATC_Transporter__c != null && 
                !'23758'.equals(purchase.Adesa_com__r.ATC_Organization_ID__c) &&
                !'227468'.equals(purchase.Adesa_com__r.ATC_Organization_ID__c)) {
                
                OLTransport = true;
                
            }

        }
        
        // for non-OL transport, base decision on sale date
        if (!OLTransport) {
            if (purchase.ATC_Sale_Date__c != null) {
                Date saleDate = Date.newInstance(purchase.ATC_Sale_Date__c.year(), purchase.ATC_Sale_Date__c.month(), purchase.ATC_Sale_Date__c.day());
                Date createdDate = Date.today();
                if (saleDate.daysBetween(createdDate) > 14) {
                    results.undecided = true;//changed from results.salesDateError temporarily for PPM 78230
                }
            } else {
                results.undecided = true;
                return results;
            }
        }
        // for OL transport, base decision on delivery date
        else {
            if (purchase.Actual_Dropoff__c != null) {
                Date createdDate = Date.today();
            
                // Requirement to arbitrate is 2 days past delivery
                Date dropoffPlusTwo = purchase.Actual_Dropoff__c.addDays(2);
                
                // Shift dropoffPlusTwo to weekday if it falls on a weekend
                Date referenceDate = Date.newInstance(1900,1,6); // A Saturday for reference
                Integer daysPastSaturday = Math.mod(referenceDate.daysBetween(dropoffPlusTwo), 7);
                
                if (daysPastSaturday == 0) { // dropoffPlusTwo is a Saturday, add 2 days
                    dropoffPlusTwo = dropoffPlusTwo.addDays(2);
                } else if (daysPastSaturday == 1) { // dropoffPlusTwo is a Sunday, add 1 day
                    dropoffPlusTwo = dropoffPlusTwo.addDays(1);
                }
                
                if (dropoffPlusTwo.daysBetween(createdDate) > 0) {
                    results.undecided = true;//changed from results.deliveryDateError temporarily for PPM 78230
                }
            }
        }
                
        return results;
    }

    public class ValidationResults {
        public boolean undecided {get; set;}
        public boolean paymentError {get; set;}
        public boolean groundingDealerError {get; set;}
        public boolean salesDateError {get; set;}
        public boolean deliveryDateError {get; set;}
        
        public ValidationResults() {
            undecided = false;
            paymentError = false;
            groundingDealerError = false;
            salesDateError = false;
            deliveryDateError = false;
        }
        
    }
    
    public class ArbsValidatorException extends Exception{}

}