@isTest
private class VehicleAfterInsertUpdateTest {
	
	@isTest static void test_VehicleAfterInsertUpdate() {

		test.startTest();
		User user = TestUtility.createUser('1');

		system.runAs(user)
		{


				Property__c prop = TestUtility.createProperty('all.account.creator.profiles','System Administrator');
				Property__c prop2 = [Select Name, Property_Id__c, Property_Value__c From Property__c Limit 1];
				system.debug('-----------Property : ' + prop2.Property_Value__c + ' --- ' + prop2.Property_Id__c   );
				
				Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
				Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
				Id rtId = AccountRecordTypeInfo .get('Credit Account').getRecordTypeId();


				Car_Group_Config__c carGrp = TestUtility.createCarGroup(1, true, 2);
				Account acc = TestUtility.createAccount(1, false);
				acc.Openlane_Org_ID__c = '4654643213';
				acc.recordtypeid= rtId;
				insert acc;

		        Account account = [Select Name From Account where Id =: acc.Id];
		        system.assertEquals(account.Name, 'Account1', 'Account not found');

				List<Asset__c> assetList = new List<Asset__c>();
				assetList.addall(TestUtility.createAssets(false, 1, 'Post-Auction', '4', 'src1', acc.Id, 5, carGrp.Id, system.Today().addDays(-65)));
				assetList.addall(TestUtility.createAssets(false, 5, 'Pre-Auction', '3', 'src2', acc.Id, 50, carGrp.Id, null));
				assetList.addall(TestUtility.createAssets(false, 1, 'Post-Auction', '8', 'src3', acc.Id, 55, null, null ));
				assetList.addall(TestUtility.createAssets(false, 2, 'Pre-Auction', '2', 'src4', acc.Id, 25, carGrp.Id, null));
				insert assetList;

			    List<Asset__c> assetList2 = [Select Id, System_id__c, sales_classification__c, Car_group__c, Basic_Listing_Indicator__c  From Asset__c ];
				List<Asset__c> assetUpdList = new List<Asset__c>();

				system.assert(assetList2.size() > 0, 'Zero Asset__c records found');

				Integer cnt = 1;	
			    for(Asset__c asset : assetList2){
			    	if(asset.System_id__c == '3'){
			    		if(cnt == 1)
			    			asset.sales_classification__c = 'Open D2D';	
			    		else if(cnt == 2)	
			    			asset.sales_classification__c = 'Open Non-Grounding Dealer';	
			    		else if(cnt == 3)	
			    			asset.sales_classification__c = 'Closed D2D';	
			    		else if(cnt == 4)	
			    			asset.sales_classification__c = 'Closed - Non-Grounding Dealer';	
			    		else if(cnt == 5)	
			    			asset.sales_classification__c = 'Closed - Grounding Dealer';	

			    		asset.System_id__c = '4';
			    		cnt = cnt + 1;
			    	}
			    	else {
			    		asset.Basic_Listing_Indicator__c = 'No';		
			    		asset.System_id__c = '3';	
			    	}
			    	assetUpdList.add(asset);
			    }
				
				update assetUpdList;

		}
		 test.stopTest(); 	
	}

	
}