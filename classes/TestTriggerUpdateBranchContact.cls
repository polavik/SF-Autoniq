@isTest
private class TestTriggerUpdateBranchContact{

    @isTest static void testUpdateBranchContactUs(){ 
        
    String city1 = 'LONG ISLAND';
    String city2 = 'NEW YORK MILLS';
    

    List<String> ListCity = new List<String>();
    ListCity.Add(city1);
    ListCity.Add(city2);
    
    List<AFC_Branch__c> ListAFCBranches =[SELECT ID,NAME FROM AFC_Branch__c WHERE NAME IN:ListCity];
    system.debug('>>>>ListAFCBranches :'+ListAFCBranches);

    AFC_Branch__c objAFCBranch1 = new AFC_Branch__c();
    AFC_Branch__c objAFCBranch2 = new AFC_Branch__c();
    

    for( AFC_Branch__c objAFCBranch : ListAFCBranches)
    {
        if(objAFCBranch.Name == city1){objAFCBranch1 = objAFCBranch;}
        else if(objAFCBranch.Name == city2){objAFCBranch2 = objAFCBranch;}
        
    }

    List<AFC_Branch__c> ListAFCBranchesInsert = new List<AFC_Branch__c>();

    if(objAFCBranch1.Name == null && Test.isRunningTest()){
        objAFCBranch1.Name =city1;
        ListAFCBranchesInsert.Add(objAFCBranch1);
    }
    if(objAFCBranch2.Name == null && Test.isRunningTest()){
        objAFCBranch2.Name =city2;
        ListAFCBranchesInsert.Add(objAFCBranch2);
    }
    
    If(Test.isRunningTest() && ListAFCBranchesInsert.Size()>0)
    {
        Insert ListAFCBranchesInsert;
    }

    List<User> ListUser1 = [SELECT ID,USERNAME FROM USER WHERE ISACTIVE=TRUE AND USERTYPE='STANDARD' AND CompanyName='AFC' AND DEPARTMENT=:city1];
     

    User objUser1= new User();
     
    List<User> ListUserInsert = new List<User>();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    if(ListUser1.size()>0)
    {
        objUser1 = ListUser1[0];
    }
    else if(Test.isRunningTest())
    {
        objUser1= new User(Alias = 'abtpuqw1'
                                        , Email='standarduser@testorg.com'
                                        ,EmailEncodingKey='UTF-8'
                                        ,LastName='Testing1'
                                        ,LanguageLocaleKey='en_US'
                                        ,LocaleSidKey='en_US'
                                        ,ProfileId = p.Id
                                        ,TimeZoneSidKey='America/Los_Angeles'
                                        ,UserName='abtpuqw1@testorg.com');
            
        ListUserInsert.Add(objUser1);
    }
    
    If(Test.isRunningTest() && ListUserInsert.Size()>0)
    {
        Insert ListUserInsert;
    }
    
    
        Zip_Territory__c zip = new Zip_Territory__c(AFC_Branch__c = objAFCBranch1.Id, AFCSalesContact__c =objUser1.Id, Zip_Code__c = '12345');
        insert zip;

        Account acct = new Account(Name='Test0',Master_Index__c='Test0',AFC_Dealer_ID__c='12345',Primary_Postalcode__c = '12345',AFC_Assignment_exception__c = false,Primary_country__c = 'USA');
        insert acct;

        zip.AFC_Branch__c = objAFCBranch2.Id;
        upsert zip;
    }
    
    @isTest static void testUpdateBranchContactCan(){
        
     
    String city3 = 'TORONTO';
    String city4 = 'MONTREAL';

    List<String> ListCity = new List<String>();
     
    ListCity.Add(city3);
    ListCity.Add(city4);
    List<AFC_Branch__c> ListAFCBranches =[SELECT ID,NAME FROM AFC_Branch__c WHERE NAME IN:ListCity];
    system.debug('>>>>ListAFCBranches :'+ListAFCBranches);

     
    AFC_Branch__c objAFCBranch3 = new AFC_Branch__c();
    AFC_Branch__c objAFCBranch4 = new AFC_Branch__c();

    for( AFC_Branch__c objAFCBranch : ListAFCBranches)
    {
         if(objAFCBranch.Name == city3){objAFCBranch3 = objAFCBranch;}
        else if(objAFCBranch.Name == city4){objAFCBranch4 = objAFCBranch;}
    }

    List<AFC_Branch__c> ListAFCBranchesInsert = new List<AFC_Branch__c>();

     
    if(objAFCBranch3.Name == null && Test.isRunningTest()){
        objAFCBranch3.Name =city3;
        ListAFCBranchesInsert.Add(objAFCBranch3);
    }
    if(objAFCBranch4.Name == null && Test.isRunningTest()){
        objAFCBranch4.Name =city4;
        ListAFCBranchesInsert.Add(objAFCBranch4);
    } 
    If(Test.isRunningTest() && ListAFCBranchesInsert.Size()>0)
    {
        Insert ListAFCBranchesInsert;
    }

     
    List<User> ListUser2 = [SELECT ID,USERNAME FROM USER WHERE ISACTIVE=TRUE AND USERTYPE='STANDARD' AND CompanyName='AFC' AND DEPARTMENT=:city3];

     
    User objUser2= new User();
    List<User> ListUserInsert = new List<User>();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
     

    if(ListUser2.size()>0)
    {
        objUser2 = ListUser2[0];
    }else if(Test.isRunningTest()){
        objUser2= new User(Alias = 'abtpuqw2'
                                    , Email='standarduser@testorg.com'
                                    ,EmailEncodingKey='UTF-8'
                                    ,LastName='Testing2'
                                    ,LanguageLocaleKey='en_US'
                                    ,LocaleSidKey='en_US'
                                    ,ProfileId = p.Id
                                    ,TimeZoneSidKey='America/Los_Angeles'
                                    ,UserName='abtpuqw2@testorg.com');
        ListUserInsert.Add(objUser2);
    }
        
        If(Test.isRunningTest() && ListUserInsert.Size()>0)
    {
        Insert ListUserInsert;
    }
    
        Zip_Territory__c zip1 = new Zip_Territory__c(AFC_Branch__c =objAFCBranch3.Id, AFCSalesContact__c =objUser2.Id, Zip_Code__c = 'M1M');
        insert zip1;
        
        Account acct1 = new Account(Name='Test1',Master_Index__c='Test1',AFC_Dealer_ID__c='54321',Primary_Postalcode__c = 'M1M1C1',AFC_Assignment_exception__c = false,Primary_country__c = 'Canada');
        insert acct1;
        
        zip1.AFC_Branch__c = objAFCBranch4.Id;
        upsert zip1;
    }
}