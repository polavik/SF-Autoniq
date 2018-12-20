public class PartialVinSearchController 
{
    public String queryStr {get; set;}
    public List<Purchase__c> purchases {get; set;}
    public List<Asset__c> vehicles {get; set;}
    
    public PartialVinSearchController()
    {
        purchases = new List<Purchase__c>();
        vehicles = new List<Asset__c>();
        
        if (queryStr == null)
        {
            queryStr = ApexPages.currentPage().getParameters().get('q');
        }
        if (queryStr == null)
        {
            queryStr = '';
        }
        
        assemblePageData();
    }
    
    public ApexPages.PageReference submit()
    {
        
        assemblePageData();
        return null;
    }
    
    public void assemblePageData()
    {
        if (validate())
        {
            System.debug('Partial VIN given: ' + queryStr);
            String reverseQueryStr = Utils.reverse(queryStr) + '%';
            System.debug('Partial VIN reversed: ' + reverseQueryStr);
            populateResults(reverseQueryStr);
        }
        addEmptyResults();
    }
    
    public Boolean validate()
    {
        if (queryStr == null || queryStr.trim().length() < 6)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the last 6 digits (or more) of a VIN in order to perform a partial search.'));
            return false;
        }
        System.debug('queryStr.trim().length(): ' + queryStr.trim().length());
        return true;
    }
    
    public void populateResults(String query)
    {
        purchases = 
        [
            SELECT
                Id,
                Name,
                YMMS__c,
                Segment_Name__c,
                ATC_Sale_Date__c,
                Sale_Price__c,
                Pick_Up_State__c,
                Transport_Type__c,
                ATC_Seller__c
            FROM Purchase__c
            WHERE Indexed_Reversed_VIN__c LIKE :query
            LIMIT 10
        ];

        vehicles = 
        [
            SELECT
                Id,
                Name,
                YMMS__c,
                Auction_Status__c,
                Location__c,
                Buy_Now_Price__c,
                Reserve_Price__c
            FROM Asset__c
            WHERE Indexed_Reversed_VIN__c LIKE :query
            LIMIT 10
        ];
    }
    
    // If any search result list is empty, add an empty record so the list will display correctly in the Visualforce page
    public void addEmptyResults()
    {
        if (purchases.size() == 0)
        {
            purchases.add(new Purchase__c());
        }
        
        if (vehicles.size() == 0)
        {
            vehicles.add(new Asset__c());
        }
    }
    
}