/*
 * Class        : ControllerServices
 * Developer/Org: Ramón Muñoz/Bluewolf 
 * Created      : October 21, 2013
 * Objective    : Helper class for VisualForce controllers
*/
public with sharing class ControllerServices
{
	public static void displayExceptionAsMessage(Exception e)
	{
		displayExceptionAsMessage(e, true);
	}
	public static void displayExceptionAsMessage(Exception e, Boolean enableStackTrace)
	{
		if(e != null)
		{
			if(e.getTypeName() == 'System.DmlException')
			{
				for (Integer i=0; i < e.getNumDml(); i++)
				{
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getDmlMessage(i)));
				}
			}
			else
			{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
			}
			if(enableStackTrace != null && enableStackTrace)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getTypeName() + ': ' + e.getStackTraceString()));
			}
		}
	}
}