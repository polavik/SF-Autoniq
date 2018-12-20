/*
 * Class        : TestBWAppsConfigModel
 * Developer/Org: Ramón Muñoz/Bluewolf 
 * Created      : November 5, 2013
 * Objective    : Test class for BWAppsConfigModel 
*/
@isTest
private class TestBWAppsConfigModel
{
    static testMethod void endpointURL_noRecords()
    {
        try
        {
            String endpointURL = BWAppsConfigModel.endpointURL;
        }
        catch(CustomExceptions.ApplicationException ae)
        {
            System.assertEquals(System.Label.Endpoint_URL_is_not_configured, ae.getMessage(), 'We should get this exception if no custom settings have been inserted');
        }
    }
    static testMethod void endpointURL_withOrgRecord()
    {
        TestServices.insert_OrgConfig();
        System.assertEquals('www.org.com', BWAppsConfigModel.endpointURL, 'BWAppsConfigModel.endpointURL should be "www.org.com" after inserting org wide default record');
    }
    static testMethod void endpointURL_withProfileRecord()
    {
        TestServices.insert_ProfileConfig();
        System.assertEquals('www.profile.com', BWAppsConfigModel.endpointURL, 'BWAppsConfigModel.endpointURL should be "www.profile.com" after inserting profile default record');
    }
    static testMethod void timeout_noRecords()
    {
        try
        {
            Integer timeout = BWAppsConfigModel.timeout;
        }
        catch(CustomExceptions.ApplicationException ae)
        {
            System.assertEquals(System.Label.Timeout_is_not_configured, ae.getMessage(), 'We should get this exception if no custom settings have been inserted');
        }
    }
    static testMethod void timeout_withOrgRecord()
    {
        TestServices.insert_OrgConfig();
        System.assertEquals(120000, BWAppsConfigModel.timeout, 'BWAppsConfigModel.timeout should default to 120000 after inserting org wide default record');
    }
    static testMethod void timeout_withProfileRecord()
    {
        TestServices.insert_ProfileConfig();
        System.assertEquals(60000, BWAppsConfigModel.timeout, 'BWAppsConfigModel.timeout should default to 60000 after inserting profile default record');
    }
    static testMethod void enableStackTrace_noRecords()
    {
        System.assertEquals(false, BWAppsConfigModel.enableStackTrace, 'BWAppsConfigModel.enableStackTrace should default to false if no custom settings have been inserted');
    }
    static testMethod void enableStackTrace_withOrgRecord()
    {
        TestServices.insert_OrgConfig();
        System.assertEquals(false, BWAppsConfigModel.enableStackTrace, 'BWAppsConfigModel.enableStackTrace should default to false after inserting org wide default record');
    }
    static testMethod void enableStackTrace_withProfileRecord()
    {
        TestServices.insert_ProfileConfig();
        System.assertEquals(true, BWAppsConfigModel.enableStackTrace, 'BWAppsConfigModel.enableStackTrace should default to true after inserting profile default record');
    }
    static testMethod void propertiesName_noRecords()
    {
        System.assertEquals('IHUB', BWAppsConfigModel.propertiesName, 'BWAppsConfigModel.propertiesName should default to "IHUB" if no custom settings have been inserted');
    }
    static testMethod void propertiesName_withOrgRecord()
    {
        TestServices.insert_OrgConfig();
        System.assertEquals('IHUB', BWAppsConfigModel.propertiesName, 'BWAppsConfigModel.propertiesName should default to "IHUB" after inserting org wide default record');
    }
    static testMethod void propertiesName_withProfileRecord()
    {
        TestServices.insert_ProfileConfig();
        System.assertEquals('IHUB', BWAppsConfigModel.propertiesName, 'BWAppsConfigModel.propertiesName should default to "IHUB" after inserting profile default record');
    }
}