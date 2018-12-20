/*
Author: Pike Pullen
Date: 10/30/2013
Description: Unit Test Coverage for assorted Classes
*/

@isTest
private class TestControllerServices 
{
    static testMethod void displayExceptionAsMessage_nullParams_returnsNothing()
    {
        ControllerServices.displayExceptionAsMessage(null, null);
        System.assertEquals(0, ApexPages.getMessages().size(), 'We should have no Apex Messages if null params passed');
    }
    static testMethod void displayExceptionAsMessage_nullParam_returnsNothing()
    {
        ControllerServices.displayExceptionAsMessage(null);
        System.assertEquals(0, ApexPages.getMessages().size(), 'We should have no Apex Messages if null params passed');
    }
    static testMethod void displayExceptionAsMessage_validParams_customException_returnsNothing()
    {
        CustomExceptions.ApplicationException ae = new CustomExceptions.ApplicationException('Test app exception');
        ControllerServices.displayExceptionAsMessage(ae, null);
        System.assertEquals(1, ApexPages.getMessages().size(), 'We should have 1 Apex Message if valid exception and null Boolean passed');
        System.assertEquals(ae.getMessage(), ApexPages.getMessages()[0].getDetail());
        ControllerServices.displayExceptionAsMessage(ae, false);
        System.assertEquals(1, ApexPages.getMessages().size(), 'We should have 1 Apex Message if valid exception and null Boolean passed');
        System.assertEquals(ae.getMessage(), ApexPages.getMessages()[0].getDetail());
        ControllerServices.displayExceptionAsMessage(ae, true);
        System.assertEquals(2, ApexPages.getMessages().size(), 'We should have 2 Apex Messages if valid exception and null Boolean passed');
        System.assertEquals(ae.getMessage(), ApexPages.getMessages()[0].getDetail());
//        System.assertEquals('CustomExceptions.ApplicationException: Class.TestControllerServices.displayExceptionAsMessage_validParams_customException_returnsNothing: line 22, column 1', ApexPages.getMessages()[1].getDetail());
//        System.assert(ApexPages.getMessages()[1].getDetail().contains('Stack Trace: Class.TestControllerServices.displayExceptionAsMessage_validParam_customException_returnsNothing: line 33, column 1'));
    }
    static testMethod void displayExceptionAsMessage_validParam_customException_returnsNothing()
    {
        CustomExceptions.ApplicationException ae = new CustomExceptions.ApplicationException('Test app exception');
        ControllerServices.displayExceptionAsMessage(ae);
        System.assertEquals(2, ApexPages.getMessages().size(), 'We should have 2 Apex Messages if valid exception and null Boolean passed');
        System.assertEquals(ae.getMessage(), ApexPages.getMessages()[0].getDetail());
//        System.assertEquals('CustomExceptions.ApplicationException: Class.TestControllerServices.displayExceptionAsMessage_validParam_customException_returnsNothing: line 36, column 1', ApexPages.getMessages()[1].getDetail());
//        System.assert(ApexPages.getMessages()[1].getDetail().contains('Stack Trace: Class.TestControllerServices.displayExceptionAsMessage_validParam_customException_returnsNothing: line 42, column 1'));
    }
    static testMethod void displayExceptionAsMessage_validParams_DmlException_returnsNothing()
    {
        try
        {
            insert new Account();
        }
        catch(DmlException dmle)
        {
            ControllerServices.displayExceptionAsMessage(dmle, null);
            System.assertEquals(dmle.getNumDml(), ApexPages.getMessages().size(), 'We should have '+dmle.getNumDml()+' Apex Message(s) if valid exception and null Boolean passed');
            for (Integer i=0; i < dmle.getNumDml(); i++)
            {
                System.assertEquals(dmle.getDmlMessage(i), ApexPages.getMessages()[i].getDetail());
            }
        }
    }
	/*
    static testMethod void runControllerServices() 
    {
        try
		{
			Account myRecord = new Account(id = '000');
			update myRecord;
			
			 System.assertEquals(null, myRecord); 
		}
		catch(Exception e)
		{
        	ControllerServices.displayExceptionAsMessage(e); 
        	ControllerServices.displayExceptionAsMessage(e, true); 
		} 
    } 
    */   
}