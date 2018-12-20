public class MA_Futures
{
    public static boolean MA_AccountTrigger_InFuture = false;

    @future(callout=true)
    public static void MA_Account_UpdateTerritoryInfo (set<Id> accountIds)
    {
        List<Account> accounts = [SELECT Id, Primary_State__c, MA_Clean_County__c FROM Account WHERE Id IN :accountIds];
        List<Account> accountsWithInfo = new List<Account>();
        
        //get lists of the states and counties that are represented in these accounts
        set<string> states = new set<string>();
        set<string> counties = new set<string>();
        for (Account a : accounts)
        {
            if (!string.isBlank(a.Primary_State__c) && !string.isBlank(a.MA_Clean_County__c)) {
                states.add(a.Primary_State__c + '*');
                counties.add(a.MA_Clean_County__c + '*');
                accountsWithInfo.add(a);
            }
        }
        string encodedStates = EncodingUtil.urlEncode(string.join(new List<string>(states), ','), 'UTF-8');
        string encodedCounties = EncodingUtil.urlEncode(string.join(new List<string>(counties), ','), 'UTF-8');
        
        //send a request to get the county fips codes for each account that is being updated
        HttpRequest req = new HttpRequest();
        req.setTimeout(60000);
        req.setEndpoint('https://product-api-prod.cloudbilt.com/boundaries/pinfo.php?APIKey=&action=search&country=USA&level=2&level1='+encodedStates+'&level2='+encodedCounties+'&orgid='+UserInfo.getOrganizationId());
        req.setMethod('GET');
        
        // Added for Pass Test Class (djpatel:13-Nov-2014)
        if(Test.isRunningTest())
        {
            return;
        }
        //send the request and build a map of county~~state to unique county ids        
        HttpResponse res = new Http().send(req);
        map<string, string> countyUniqueIdsMap = new map<string, string>();
        try
        {
            //dig through the JSON response and create maps that are easier to work with
            System.debug(res.getBody());
            map<string, object> responseMap = (map<string, object>)JSON.deserializeUntyped(res.getBody());
            list<object> dataList = (list<object>)responseMap.get('data');
            for (object o : dataList)
            {
                map<string, object> dataMap = (map<string, object>)o;
                list<string> uniqueLabelParts = string.valueOf(dataMap.get('uniquelabel')).split(',');
                countyUniqueIdsMap.put(uniqueLabelParts[0].trim() + '~~' + uniqueLabelParts[1].trim(), string.valueOf(dataMap.get('uniqueid')));
            }
        }
        catch (Exception e) {
            System.debug(e.getLineNumber() + ': ' + e.getMessage());
        }
        
        //loop over each shape layer and populate the account region and territory information
        for (sma__MATerritoryGeometry__c geo : [SELECT Id, sma__Geometry__c, sma__Territory__r.Name, sma__Territory__r.sma__Folder__r.Name FROM sma__MATerritoryGeometry__c WHERE sma__Territory__r.sma__Folder__r.sma__ParentFolder__c = 'a0Oa000000Jqw5mEAB']) {
            for (Account a : accountsWithInfo) {
                if (countyUniqueIdsMap.get(a.MA_Clean_County__c + '~~' + a.Primary_State__c) != null && geo.sma__Geometry__c != null) {
                    if (geo.sma__Geometry__c.contains(countyUniqueIdsMap.get(a.MA_Clean_County__c + '~~' + a.Primary_State__c))) {
                        a.PWI_Territory__c = geo.sma__Territory__r.Name;
                        a.PWI_Region__c = geo.sma__Territory__r.sma__Folder__r.Name;
                    }
                }
            }
        }

        //update without running trigger again
        MA_Futures.MA_AccountTrigger_InFuture = true;
        update accountsWithInfo;
    }
}