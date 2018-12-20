@isTest
private class ActionPackageValidator_Test{
   static testMethod void test_hasAlreadyDone_UseCase1(){
    ActionPackageValidator obj01 = new ActionPackageValidator();
    ActionPackageValidator.hasAlreadyDone();
  }
   static testMethod void test_setAlreadyDone_UseCase1(){
    ActionPackageValidator obj01 = new ActionPackageValidator();
    ActionPackageValidator.setAlreadyDone();
  }
   static testMethod void test_validateGeneral_UseCase1(){
    ActionPackageValidator obj01 = new ActionPackageValidator();
    ActionPackageValidator.validateGeneral(new Action_Package__c());
  }
   static testMethod void test_validateTransportVoid_UseCase1(){
    ActionPackageValidator obj01 = new ActionPackageValidator();
    ActionPackageValidator.validateTransportVoid(new Action_Package__c());
  }
/***
   static testMethod void test_validateVehicleVoid_UseCase1(){
    ActionPackageValidator obj01 = new ActionPackageValidator();
    ActionPackageValidator.validateVehicleVoid(new Action_Package__c());
  }
**/  
   static testMethod void test_validateExtraCostPackage_UseCase1(){
    ActionPackageValidator obj01 = new ActionPackageValidator();
    ActionPackageValidator.validateExtraCostPackage(new Action_Package__c());
  }
   static testMethod void test_getForcedNonstandardReasons_UseCase1(){
    ActionPackageValidator obj01 = new ActionPackageValidator();
    ActionPackageValidator.getForcedNonstandardReasons(new Action_Package__c());
  }
}