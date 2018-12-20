@isTest
public with sharing class TestBatchUpdateContactPromotion {
    static testMethod void myUnitTest() {
        Test.StartTest();
        
        String testlocation ='ADESA Atlanta;ADESA Austin;ADESA Birmingham;ADESA Boston;ADESA Buffalo;' + 
        		'ADESA Calgary;ADESA Charlotte;ADESA Cleveland;ADESA Colorado Springs;ADESA Concord;' + 
        		'ADESA Dallas;ADESA Des Moines;ADESA Edmonton;ADESA Fargo;ADESA Golden Gate;ADESA Halifax;' + 
        		'ADESA Houston;ADESA Indianapolis;ADESA Jacksonville;ADESA Kansas City;ADESA Kitchener;' + 
        		'ADESA Knoxville;ADESA Lansing;ADESA Lexington;ADESA Little Rock;ADESA Long Island;' + 
        		'ADESA Los Angeles;ADESA Memphis;ADESA Minneapolis;ADESA Moncton;ADESA Montreal;' + 
        		'ADESA Nashville;ADESA New Jersey;ADESA Ocala;ADESA Ottawa;ADESA PA;ADESA Phoenix;' + 
        		'ADESA Pittsburgh;ADESA Quebec City;ADESA Raleigh;ADESA Sacramento;ADESA San Antonio;' + 
        		'ADESA San Diego;ADESA Sarasota;ADESA Saskatoon;ADESA Seattle;ADESA Shreveport;' + 
        		'ADESA Sioux Falls;ADESA St. Louis;ADESA Syracuse;ADESA Tampa;ADESA Toronto;ADESA Tulsa;' + 
        		'ADESA Vancouver;ADESA Washington DC;ADESA Winnipeg;ADESA Wisconsin;' + 
        		'ADESA Cincinnati/Dayton;ADESA Mercer;ADESA St. Johns;ADESA Mexico City'; 
        Contact obj = new Contact();
        obj.LastName='Test Contact1';
        obj.Master_Index__c='100';
        obj.Location__c = testlocation;
        obj.Active__c = true;
        obj.sign_me_up__c = true;   
        obj.Consignor__c = 'Ford';
        Insert obj;  
    
	    Promotions__c a = new Promotions__c(Auction_Title_Reference__c = 'ADESA Atlanta', 
	    		Active_Promotion__c = true, Display_Title__c = 'Promotion Title',
	    		Expiry_Date__c =  Date.today().addDays(3)
	    		
	    		);
	    insert a;

	    Promotions__c p1 = new Promotions__c(Auction_Title_Reference__c = 'ADESA Dallas', 
	    		Active_Promotion__c = true, Display_Title__c = 'Promotion Title1',
	    		Expiry_Date__c =  Date.today().addDays(5)
	    		
	    		);
	    insert p1;
	    Promotions__c p2 = new Promotions__c(Auction_Title_Reference__c = 'ADESA Birmingham', 
	    		Active_Promotion__c = true, Display_Title__c = 'Promotion Title2',
	    		Expiry_Date__c =  Date.today().addDays(5)
	    		
	    		);
	    insert p2;
	    Promotions__c p3 = new Promotions__c(Auction_Title_Reference__c = 'ADESA Wisconsin', 
	    		Active_Promotion__c = true, Display_Title__c = 'Promotion Title3',
	    		Expiry_Date__c =  Date.today().addDays(5)
	    		
	    		);
	    insert p3;

	    Promotions__c p = new Promotions__c(Auction_Title_Reference__c = 'ADESA Cincinnati/Dayton', 
	    		Active_Promotion__c = true, Display_Title__c = 'Display Title dayton',
	    		Expiry_Date__c =  Date.today().addDays(5),
	    		Hypertext_Reference_URL__c = 'http://test.com',
	    		Consignor__c ='General Motors',
	    		Date_Range__c= '5/11/15 -5/17/15',
	    		New__c = True,
	    		Promotion_Title__c = 'Promotion Title dayton'
	    		);
	    insert p;
    
        BatchUpdateContactPromotion om = new BatchUpdateContactPromotion();
        //om.query = om.query + ' LIMIT 10 ';
        Database.executeBatch(om);
        Test.StopTest();
         
    }

}