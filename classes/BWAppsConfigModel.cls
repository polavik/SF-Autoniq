/*
 * Class        : BWAppsConfigModel
 * Developer/Org: Ramón Muñoz/Bluewolf
 * Created      : November 5, 2013
 * Objective    : Model class for BW_Apps_Config__c custom settings object
 *                Contains additional non DB persistent fields and record specific methods
*/
public with sharing class BWAppsConfigModel
{
    private static BW_Apps_Config__c config
    {
        get
        {
            if(config == null) config = BW_Apps_Config__c.getInstance();
            return config;
        }
        private set;
    }
    public static String endpointURL
    {
        get
        {
            if(config.IHUB_Endpoint_URL__c == null)
                throw new CustomExceptions.ApplicationException(System.Label.Endpoint_URL_is_not_configured);
            else
                return config.IHUB_Endpoint_URL__c;
        }
    }
    public static Integer timeout
    {
        get
        {
            if(config.IHUB_Timeout__c == null)
                throw new CustomExceptions.ApplicationException(System.Label.Timeout_is_not_configured);
            else
                return config.IHUB_Timeout__c.intValue();
        }
    }
    public static Boolean enableStackTrace
    {
        get
        {
            return config == null || config.Enable_Stack_Trace__c == null ? false : config.Enable_Stack_Trace__c;
        }
    }
    public static String propertiesName
    {
        get
        {
            return config == null || config.Properties_Name__c == null ? 'IHUB' : config.Properties_Name__c;
        }
    }
}