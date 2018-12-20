/*
 * Class        : PropertyServices
 * Developer/Org: Ramón Muñoz/Bluewolf
 * Created      : February 24, 2014
*/
public with sharing class PropertyServices
{
    public static Map<String, String> propertiesMap
    {
    	get
    	{
    		if(propertiesMap == null)
    		{
    			getPropertiesMap();
    		}
    		return propertiesMap;
    	}
    	private set;
    }

    public static Map<String, String> contactUpdatePropertiesMap
    {
        get
        {
            if(contactUpdatePropertiesMap == null)
            {
                contactUpdatePropertiesMap = new Map<String,String>();
                for(Property__c prop : [select Property_Id__c, Property_Value_Encrypted__c from Property__c where Name = :SchemaContactUpdateHelper.propertiesName]){
                    contactUpdatePropertiesMap.put(prop.Property_Id__c, prop.Property_Value_Encrypted__c);
                }
            }
            return contactUpdatePropertiesMap;
        }
        private set;
    }

    private static void getPropertiesMap()
    {
    	propertiesMap = new Map<String, String>();
    	Property__c[] properties = [select Property_Id__c, Property_Value_Encrypted__c from Property__c where Name = :BWAppsConfigModel.propertiesName];
    	for(Property__c prop : properties)
    	{
    		propertiesMap.put(prop.Property_Id__c, prop.Property_Value_Encrypted__c);
    	}
    }
}