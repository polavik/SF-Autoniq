/*
* (c) 2016 Appirio, Inc.
* 
* Apex Class Name   : Test_DataFactory
*
* Description       : Class to create test data.
*
* 15 Nov 2016         Ankita Sharma(Appirio)   Original (Task T-548983  ) - Please see the Task description for more details.
*
*/
public class Test_DataFactory {
	
    //Method to create Property record.
    public static Property__c createPropertyRecord(String proId, String proValue, Boolean isInsert){
        Property__c prop = new Property__c(Property_Id__c = proId, Property_Value__c = proValue);
        if(isInsert){ 
            insert prop;
        }
        return prop;
    }
}