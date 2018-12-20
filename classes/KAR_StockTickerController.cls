/**
  * Apex Class: KAR_StockTickerController
  * Description: Controller for KAR Stock Ticker Component
  * Created By: Appirio
  * Created Date: Feb, 2016
*/
public class KAR_StockTickerController
{
    public String upDownImgURL{get;set;}
    public String stockSymbol{get;set;}
    public Decimal stockPrice{get;set;}
    public Decimal stockChange{get;set;}
    public Decimal stockChangePercent{get;set;}
    public String target{get;set;}
    public Decimal frameHeight{get;set;} 
    
    public static final String stockDownImg = 'arrow-down2 red'; 
    public static final String stockUpImg = 'arrow-up green';
    
    public boolean isMobile {get; set;}
    
    public  KAR_StockTickerController()
    {
        initValues();
        // check for mobile.
        if(null == ApexPages.currentPage().getParameters().get('hideHeaders') || '' == ApexPages.currentPage().getParameters().get('hideHeaders')) isMobile=false;
        else isMobile=true;        
    }        
    
    private void initValues()
    {
        if(String.isEmpty(stockSymbol))
        {
            target = '_parent';
            for(Intranet_Content__c aContent : [select Id, Name, Value__c, Target__c, Frame_Height__c from Intranet_Content__c 
                                                where RecordType.Name = 'Config - Stock Ticker' limit 1])
            {
                stockSymbol = aContent.Value__c;
                target = aContent.Target__c;
                frameHeight = aContent.Frame_Height__c;
                
            }
            
            if(!String.isEmpty(stockSymbol))
            {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('http://finance.yahoo.com/webservice/v1/symbols/'+ stockSymbol +'/quote?format=json&view=detail');
                req.setMethod('GET');
                req.setHeader('User-Agent','Mozilla/5.0');
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                // System.debug('>>>'+res.getBody());
                if(res.getStatusCode() == 200){
                    parseJSONData(res.getBody());
                }
            }
        }
    }
    
    private void parseJSONData(String jsonString)
    {
        JSONParser parser = JSON.createParser(jsonString);
        Double grandTotal = 0.0;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'price')) {
                // Get the value.
                parser.nextToken();
                stockPrice = Decimal.valueOf(parser.getText()).setScale(2);
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'change')) {
                // Get the value.
                parser.nextToken();
                stockChange = Decimal.valueOf(parser.getText()).setScale(2);
                if(stockChange < 0)
                {
                    upDownImgURL = stockDownImg;
                }else {
                    upDownImgURL = stockUpImg;
                }
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'chg_percent')) {
                // Get the value.
                parser.nextToken();
                stockChangePercent = Decimal.valueOf(parser.getText()).setScale(2);
            }
        }

    }
}