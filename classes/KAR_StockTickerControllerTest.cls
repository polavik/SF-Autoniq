/**
  * Apex Class: KAR_StockTickerControllerTest
  * Description: Test class for KAR_StockTickerController
  * Created By: Matt Salpietro
  * Created Date: 11 Feb, 2016
*/
@isTest
public class KAR_StockTickerControllerTest {
  static testmethod void StockTickerComponentTest(){
    Intranet_Content__c article1 = IntranetTestUtility.createIntranetContent('Config - Stock Ticker', null, 'KAR', false);
    article1.Value__c = 'KAR';
    insert article1;
    
    Test.setMock(HttpCalloutMock.class, new KAR_StockTickerMock());

    Test.startTest();
	    KAR_StockTickerController conObj = new KAR_StockTickerController();
	    system.assertNotEquals(null,conObj.stockPrice);
    Test.stopTest();
  }
}