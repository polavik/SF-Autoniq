/**
 * This class contains unit tests for validating the behavior of ConatctAccountTrigger
 *
 */
@isTest
private class Test_ConatctAccountTrigger{

    static testMethod void testConatctAccountTrigger() {    
        


        //Insert Account
        List<Account> accList= new List<Account>();
        //S-444339 T-567363
        Account accnt = new Account (name='TestAccount', Buyer_ID__c = '12345', BillingPostalCode ='12345');
        accList.add(accnt);
        //S-444339 T-567363
        Account accnt1 = new Account (name='TestAccount1', ASAP_Tower_ID__c = '123456',BillingPostalCode ='12345' );
        accList.add(accnt1);
        insert accList;
        
        //Contact with Buyer ID
        //S-444339 T-567363
        Contact cntc = new Contact (firstname ='TestFirstName', lastname ='TestLastName', Buyer_ID__c = '12345', AccountId=accnt.Id);
        insert cntc;
        Contact dbCntc = [select accountId from Contact where Id=:cntc.Id];
        //system.assertEquals(accnt.Id, dbCntc.accountId);
        
        //Contact with ASAP Tower ID
        Contact cntc1 = new Contact (firstname ='TestFirstName', lastname ='TestLastName', ASAP_Tower_ID__c = '123456');
        insert cntc1;
        Contact dbCntcASAPId = [select accountId from Contact where Id=:cntc1.Id];
        //system.assertEquals(accnt1.Id, dbCntcASAPId.accountId);
        
        //Contact with no Buyer ID
        Contact cntcNBI = new Contact (firstname ='TestFirstName2', lastname ='TestLastName2');
        insert cntcNBI;
        Contact dbCntcNBI = [select accountId from Contact where Id=:cntcNBI.Id];
        //system.assert(true, dbCntcNBI.accountId==null);
        
        //Contact with wrong Buyer ID
        Contact cntcWBI = new Contact (firstname ='TestFirstName3', lastname ='TestLastName3', Buyer_ID__c = '123456');
        insert cntcWBI;
        Contact dbCntcWBI = [select accountId from Contact where Id=:cntcWBI.Id];
        //system.assert(true, cntcWBI.accountId==null);        
    }
}