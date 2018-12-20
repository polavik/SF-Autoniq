/**
 * Trigger for Marketing Cloud Connector functionality on the Contact object
*/

trigger Trig_Contact on Contact (after insert, after update) {
    try{
        et4ae5.triggerUtility.automate('Contact');
    }
    Catch (Exception e)
    {
        if(Test.isRunningTest()){
            return;
        }
        else
        {
            throw e;
        }
    }
}