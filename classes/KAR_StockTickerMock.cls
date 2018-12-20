/**
  * Apex Class: KAR_StockTickerMock
  * Description: Mock Http response for KAR_StockTickerController
  * Created By: Matt Salpietro
  * Created Date: 11 Feb, 2016
*/
@isTest
global class KAR_StockTickerMock implements HttpCalloutMock{
  // Implement this interface method
  global HTTPResponse respond(HTTPRequest req) {
    // Create a fake response
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody('{"list" : {"meta" : {"type" : "resource-list","start" : 0,"count" : 1},"resources" : [ '+
    						'{"resource" : { "classname" : "Quote","fields" : { "change" : "-0.349998","chg_percent" : "-1.075264",'+
    						'"day_high" : "32.369999","day_low" : "31.610001","issuer_name" : "KAR Auction Services, Inc.",'+
								'"issuer_name_lang" : "KAR Auction Services, Inc.","name" : "KAR Auction Services, Inc Commo",'+
								'"price" : "32.200001","symbol" : "KAR","ts" : "1455224511","type" : "equity","utctime" : '+
								'"2016-02-11T21:01:51+0000","volume" : "746228","year_high" : "39.870000","year_low" : "31.540000"}}}]}}');
    res.setStatusCode(200);
    return res;
  }
}