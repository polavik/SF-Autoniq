/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
class TestBatchSandboxFreshHelperFreeze {

@isTest(SeeAllData=true)
    static void deactiveBatch1() {
		String Query= 'Select Id,UserId FROM UserLogin ' + 
								' where UserId in :List_Make_DeActive_User_in_Sandbox ' +  
								' and IsFrozen=false limit 200';
								
        BatchSandboxFreshHelperFreeze bc = new BatchSandboxFreshHelperFreeze(Query);
        
        Profile_to_keep_active__c ptka1 = new Profile_to_keep_active__c(Name = '101' ,UserName_UserId_ProfileName__c =  '005123456789');
        Profile_to_keep_active__c ptka2 = new Profile_to_keep_active__c(Name = '102' ,UserName_UserId_ProfileName__c =  'test20170309@test.com');
		insert ptka1;        
		insert ptka2;        
        								
		Test.startTest();
		Database.executeBatch(bc, 200);
		Test.stopTest();		
    }
    
    
    
}