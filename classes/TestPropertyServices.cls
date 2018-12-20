@isTest
public with sharing class TestPropertyServices
{
    static testMethod void propertiesMap_noRecords()
    {
    	System.assertEquals(0, PropertyServices.propertiesMap.size());
    }
    static testMethod void propertiesMap_validRecords()
    {
    	Property__c[] properties = TestServices.getProperties();
    	for(Property__c prop : properties)
    	{
    		System.assertEquals(prop.Property_Value_Encrypted__c, PropertyServices.propertiesMap.get(prop.Property_Id__c));
    	}
    }
}