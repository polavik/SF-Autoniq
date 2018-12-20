@isTest
private class TestCreateReportAsAttachmentPlugin {
	static testMethod void describe(){
		Test.startTest();
			Process.PluginDescribeResult descResult = new CreateReportAsAttachmentPlugin().describe();
		Test.stopTest();

		System.assertEquals(4, descResult.inputParameters.size(), 'The plugin should have the correct number of input params');
		System.assertEquals(1, descResult.outputParameters.size(), 'The plugin should have the correct number of output params');		
	}
	
	@isTest(SeeAllData='true')
	static void invoke(){
		final Id DUMMY_REPORT_ID=[SELECT Id from Report Where Format In ('Summary','Matrix') LIMIT 1].Id;
		final String DUMMY_CONTRACT_ID='test';
		final Date DUMMY_UNDONE_DATE = Date.today();
		Application__c testApp = TestUtils.createApplications(2, true)[0];

		Map<String, Object> requestParam = new Map<String, Object>();
		requestParam.put(CreateReportAsAttachmentPlugin.APPLICATION_ID_PARAM, testApp.Id);
		requestParam.put(CreateReportAsAttachmentPlugin.CONTRACT_ID_PARAM, DUMMY_CONTRACT_ID);
		requestParam.put(CreateReportAsAttachmentPlugin.UNDONE_DATE_PARAM, DUMMY_UNDONE_DATE);
		requestParam.put(CreateReportAsAttachmentPlugin.REPORT_ID_PARAM, DUMMY_REPORT_ID);

		Test.setMock(HttpCalloutMock.class, new MockHttpGetExcelReport());

		Test.startTest();
			Process.PluginResult invokeResult = new CreateReportAsAttachmentPlugin().invoke(new Process.PluginRequest(requestParam));
		Test.stopTest();

		List<Attachment> attachments = [SELECT Body from Attachment where ParentId=:testApp.Id];

		System.assertEquals(null, invokeResult.outputParameters.get(CreateReportAsAttachmentPlugin.ERROR_PARAM), 'The invoke method shouldnt return errors');
		System.assertEquals(1, attachments.size(), 'There should only be one attachment created');
		System.assertEquals(MockHttpGetExcelReport.MOCK_BODY.toString(), attachments[0].Body.toString(), 'The attachment should have the correct blob');			
	}

	static testMethod void invokeError(){
		final Id DUMMY_REPORT_ID=TestServices.getDummyId(Report.SObjectType);
		final String DUMMY_CONTRACT_ID='test';
		final Date DUMMY_UNDONE_DATE = Date.today();
		Application__c testApp = TestUtils.createApplications(2, true)[0];

		Map<String, Object> requestParam = new Map<String, Object>();
		requestParam.put(CreateReportAsAttachmentPlugin.APPLICATION_ID_PARAM, testApp.Id);
		requestParam.put(CreateReportAsAttachmentPlugin.CONTRACT_ID_PARAM, DUMMY_CONTRACT_ID);
		requestParam.put(CreateReportAsAttachmentPlugin.UNDONE_DATE_PARAM, DUMMY_UNDONE_DATE);
		requestParam.put(CreateReportAsAttachmentPlugin.REPORT_ID_PARAM, DUMMY_REPORT_ID);

		MockHttpGetExcelReport.statusCode=500;

		Test.setMock(HttpCalloutMock.class, new MockHttpGetExcelReport());

		Test.startTest();
			Process.PluginResult invokeResult = new CreateReportAsAttachmentPlugin().invoke(new Process.PluginRequest(requestParam));
		Test.stopTest();

		List<Attachment> attachments = [SELECT Body, ParentId from Attachment];

		System.assertEquals(CreateReportAsAttachmentPlugin.ERROR_MESSAGE, invokeResult.outputParameters.get(CreateReportAsAttachmentPlugin.ERROR_PARAM), 'The invoke method should return errors');
		System.assert(attachments.isEmpty(), 'There should not be any attachments created');
	}
}