public without sharing class PricebookUtility {

    public static Pricebook2 StandardPricebook {
        get {
            if (StandardPricebook == null) {
                if (Test.isRunningTest()) {
                    StandardPricebook = new Pricebook2(Id = Test.getStandardPricebookId());
                }
                
                else {
                    StandardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];                    
                }
            }
            return StandardPricebook;
        }
        private set;
    }

    public static Map<string, PricebookEntry> productCode_to_priceBookEntry {
        get {
        	if (productCode_to_priceBookEntry == null) {
	            productCode_to_priceBookEntry = new Map<string, PricebookEntry> ();
    	        for (PricebookEntry pbe : [
                    SELECT Id, UnitPrice, Product2.ProductCode,Product2.Name
                    FROM PricebookEntry 
                    WHERE Pricebook2Id = : StandardPricebook.Id AND IsActive = true  ]) {
        	        productCode_to_priceBookEntry.put(pbe.Product2.ProductCode, pbe);
            	}
            }
            return productCode_to_priceBookEntry;
        }
        private set;
    }
}