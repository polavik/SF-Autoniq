@istest
private class TestMediator
{
	
	static Document setupMediator(){
		
       Id profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;        
       User emp = new User
       (
           Alias='test3',Email='test3@test.com',EmailEncodingKey='UTF-8',LastName='Testing',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
           ProfileId=profileId,TimeZoneSidKey='America/Los_Angeles', UserName='test3@test.com.afctest'
       );
		insert emp;
		
		//SELECT  ATC_Organization_ID__c,id,CDN_Joint_Election_Form_on_File__c FROM account
       Account a = new Account(Name='Test Account And Stuff' ,ATC_Organization_ID__c ='123456',CDN_Joint_Election_Form_on_File__c =true);
        insert a;
        
        Contact con = new Contact(LastName='Mr. Awesomeson');
        insert con;        

        Property__c objProperty1 = new Property__c(Property_Id__c='mediator.cert.pw',Property_Value_Encrypted__c='https://www.test.com',
        			Property_Value__c='testpass');
        insert objProperty1 ;
        
        Property__c objProperty2 = new Property__c(Property_Id__c='mediator.url',Property_Value_Encrypted__c='https://www.test.com',
        			Property_Value__c='https://www.test.com');
        insert objProperty2 ;

        Document ms = new Document();
        ms.Name = 'Mediator Certificate';
        Blob bb = Blob.valueOf('testtesttesttesttesttestetesatetestetestetstestestesterateMIIMSAIBAzCCDA4GC');
        ms.body=bb;
        ms.FolderId = emp.id;
		insert ms;
		
		return ms;
	}
	
     public static testMethod void test1()
     {
     
  		 Document doc = setupMediator();
  		 		        
        Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
        System.debug('-----Mediator.MediatorService ms =  [' + ms + ']');
         
  		 Test.startTest();
		                    
		 Test.setMock(WebServiceMock.class, new WebServiceMockMediator());
         Long orgId= 12345;
         Boolean flag = true;
    	  Mediator.updateOrgTaxFormOnFileFlagResponseType response1 = ms.updateOrgTaxFormOnFileFlag(orgId,flag );
         System.debug('-----WebServiceMockMediator2 has been called response= [' + response1 + ']');
         
    	  Test.stopTest();	    		    		     
     }
     
     public static testMethod void test2()
     {
     
  		 Document doc = setupMediator();
  		 		        
        Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
        System.debug('-----Mediator.MediatorService ms =  [' + ms + ']');
         
  		 Test.startTest();		                    
		 Test.setMock(WebServiceMock.class, new WebServiceMockMediatorForUnitTest());     

         String response1 = ms.holdPSForVoid(12345);
         System.debug('----- ms.holdPSForVoid response= [' + response1 + ']');


         String response2 = ms.releasePSFromHold(12345);
         System.debug('----- ms.releasePSFromHold response= [' + response2 + ']');

        
         String response3 = ms.cancelPsi(Long.valueOf('12')).returnCode;
         System.debug('----- ms.cancelPsi response= [' + response3 + ']');


        
         String response4 = ms.arbitrateVehicle(Long.valueOf('12')).returnCode;
         System.debug('----- ms.arbitrateVehicle response= [' + response4 + ']');

        
         String response5 = ms.restoreVehicleFromArbitration(Long.valueOf('12')).returnCode;
         System.debug('----- ms.restoreVehicleFromArbitration response= [' + response5 + ']');

        List<Mediator.ExtraCost> ex = new List<Mediator.ExtraCost>();
        Mediator.ExtraCost ex1 = new Mediator.ExtraCost();

        ex1.materialNumber= '';
        ex1.netAmount= Double.valueOf('12.1');
        ex1.currency_x= '';
        ex1.taxType= Long.valueOf('12');
        ex1.extraCostResponsibleParty= '';
        ex1.sfExtraCostId= '';
        ex1.extraCostType= '';
        ex1.regionCode= '';        
        ex.add(ex1);
        
         String response6 = ms.auctionVoid('aa',Long.valueOf('12'),'321','22',Datetime.now(),'112',true,	true,'32','fds',Long.valueOf('12'),Long.valueOf('12'), ex).returnCode;
       										
         System.debug('----- ms.auctionVoid response= [' + response6 + ']');

        
        Mediator.recAuctionVoidResponseType ms7 =
          ms.recAuctionVoid('aa',Long.valueOf('12'),'321','22',Datetime.now(),'112',true,	true,'32','fds',Long.valueOf('12'),Long.valueOf('12'), ex);
         
         String response7 = ms7.returnCode;
         System.debug('----- ms.recAuctionVoid response= [' + response7 + ']');


        
         String response8 = ms.swapAuctionVoid('aa',Long.valueOf('12'),'321','22',Datetime.now(),'112',true,	true,'32','fds',Long.valueOf('12'),Long.valueOf('12'), ex).returnCode;
         System.debug('----- ms.swapAuctionVoid response= [' + response8 + ']');

        
         String response9 = ms.addExtraCost(Long.valueOf('12'),'22',Datetime.now(),'112',true,	'32','fds',Long.valueOf('12'),Long.valueOf('12'), ex).returnCode;
         System.debug('----- ms.addExtraCost response= [' + response9 + ']');

        
         String response10 = ms.thirdPartyHouseVoid('aa',Long.valueOf('12'),'321','22',Datetime.now(),'112',true,	true,'32','fds',Long.valueOf('12'),Long.valueOf('12'), ex).returnCode;         
         System.debug('----- ms.thirdPartyHouseVoid response= [' + response10 + ']');

        
         String response11 = ms.thirdPartyHouseRecVoid('aa',Long.valueOf('12'),'321','22',Datetime.now(),'112',true,	true,'32','fds',Long.valueOf('12'),Long.valueOf('12'), ex).returnCode;
         System.debug('----- ms.thirdPartyHouseRecVoid response= [' + response11 + ']');

        
         String response12 = ms.aiaHouseVoid('aa',Long.valueOf('12'),'321','22',Datetime.now(),'112',true,	true,'32','fds',Long.valueOf('12'),Long.valueOf('12'), ex).returnCode;
         
         System.debug('----- ms.aiaHouseVoid response= [' + response12 + ']');

        
         String response13 = ms.recHouseVoid('aa',Long.valueOf('12'),'321','22',Datetime.now(),'112',true,	true,'32','fds',Long.valueOf('12'),Long.valueOf('12'), ex).returnCode;
         System.debug('----- ms.recHouseVoid response= [' + response13 + ']');

        
        Test.stopTest();	   
    		
     
     
     }
     
     
}