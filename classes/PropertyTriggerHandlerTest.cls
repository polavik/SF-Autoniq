/*
* (c) 2016 Appirio, Inc.
* 
* Apex Class Name   : PropertyTriggerHandlerTest
*
* For Apex Class    : PropertyTriggerHandler
*
* Description       : Class to test PropertyTriggerHandler functionality.
*
* 15 Nov 2016         Ankita Sharma(Appirio)   Original (T-548983  ) - Please see the Task description for more details.
*
*/
@isTest
public class PropertyTriggerHandlerTest {
    //================================================================      
   // Name         : myUnitTestOne
   // Description  : Method to test PropertyTriggerHandler functionality.
   // Created Date : 14 November 2016 
   // Created By   : Ankita Sharma (Appirio)
   // Task         : T-548983
  //==================================================================
    
    private testMethod static void myUnitTestOne(){
        test.startTest();
        
        //Insert Property record.
        Property__c prop = Test_DataFactory.createPropertyRecord('KillSwitch', 'true', true);
        
        //Query Killswitch__c Custom setting records.
        List<Killswitch__c> killSwitchRecords = [SELECT Killswitch_Enabled__c 
                                                 FROM Killswitch__c];
        //Test Case 1: Verify that three Custom Setting records inserted 
        //             for all three profiles.
        System.assertEquals(4, killSwitchRecords.size());
        
        //Test Case 2: Verify that Killswitch_Enabled__c field value is 
        //             true for all custom setting records.
        for(Killswitch__c kill : killSwitchRecords){
            System.assertEquals(true, kill.Killswitch_Enabled__c);
        }
        
        test.stopTest();
    } 
    //================================================================      
   // Name         : myUnitTestTwo
   // Description  : Method to test PropertyTriggerHandler functionality.
   // Created Date : 14 November 2016 
   // Created By   : Ankita Sharma (Appirio)
   // Task         : T-548983
  //==================================================================
    
    private testMethod static void myUnitTestTwo(){
        test.startTest();
        //Insert Property record.
        Property__c prop = Test_DataFactory.createPropertyRecord('KillSwitch', 'true', true);
        
        //Update property record.
        Property__c proptoUpdate = new Property__c(Id = prop.Id, Property_Id__c = 'KillSwitch', Property_Value__c = 'false');
        update proptoUpdate;
        
        //Query Killswitch__c Custom setting records.
        List<Killswitch__c> killSwitchRecords = [SELECT Killswitch_Enabled__c 
                                                 FROM Killswitch__c];
        //Test Case 1: Verify that three Custom Setting records inserted 
        //             for all three profiles.
        System.assertEquals(4, killSwitchRecords.size());
        
        //Test Case 2: Verify that Killswitch_Enabled__c field value is 
        //             updated to false for all custom setting records.
        for(Killswitch__c kill : killSwitchRecords){
            System.assertEquals(false, kill.Killswitch_Enabled__c);
        }
        test.stopTest();
    }
    //================================================================      
   // Name         : myUnitTestThree
   // Description  : Method to test PropertyTriggerHandler functionality.
   // Created Date : 14 November 2016 
   // Created By   : Ankita Sharma (Appirio)
   // Task         : T-548983
  //==================================================================
    
    private testMethod static void myUnitTestThree(){
        test.startTest();
        //Insert Property record.
        Property__c prop = Test_DataFactory.createPropertyRecord('KillSwitch', 'true', true);
        
        //Query Killswitch__c Custom setting records.
        List<Killswitch__c> killSwitchRecords = [SELECT Killswitch_Enabled__c 
                                                 FROM Killswitch__c];
        System.assertEquals(4, killSwitchRecords.size());
        
        delete prop;
        test.stopTest();
    }
}