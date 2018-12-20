@isTest
private class TestCustomExceptions
{
	static testMethod void testExceptions() {
		 CustomExceptions.WebServiceException w = new CustomExceptions.WebServiceException('Test Exception');
		 CustomExceptions.ApplicationException e = new CustomExceptions.ApplicationException('Test Exception');
	}
}