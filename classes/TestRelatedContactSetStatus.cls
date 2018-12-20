public class TestRelatedContactSetStatus {
    static testMethod void testInvalid() {
        ID invalidAcctType = 
            [select Id, Name, SobjectType 
             from RecordType 
             where SobjectType = 'Account' 
             and Name = 'Invalid/OOB'].Id;
    
        ID invalidContactType = 
            [select Id, Name, SobjectType
             from RecordType
             where SobjectType = 'Contact'
             and Name = 'Invalid'].Id; 
                             
        ID invalidRContactType = 
            [select Id, Name, SobjectType
             from RecordType
             where SobjectType = 'Related_Contact__c'
             and Name = 'Invalid'].Id;
        
        Account a = new Account();
        //a.ATC_Organization_ID__c = '123456';
        a.Name = 'Mr Stevebobs Volvo';
        a.RecordTypeId = invalidAcctType;
        insert a;
        
        Contact c = new Contact();
        c.Person_ID__c = '123';
        c.LastName = 'Bob';
        c.RecordTypeId = invalidContactType;
        insert c;
        
        Related_Contact__c rc = new Related_Contact__c();
        rc.Account__c = a.Id;
        rc.Contact__c = c.Id;
        rc.Source_Id__c = '12345678';
        insert rc;
        
        rc = [select RecordTypeId from Related_Contact__c where Id = :rc.Id];
        
        System.assertEquals(rc.RecordTypeId, invalidRContactType);
        
    }
    
    static testMethod void testValid() {
        ID validAcctType = 
            [select Id, Name, SobjectType 
             from RecordType 
             where SobjectType = 'Account' 
             and Name = 'Dealership Account US'].Id;
    
        ID validContactType = 
            [select Id, Name, SobjectType
             from RecordType
             where SobjectType = 'Contact'
             and Name = 'Contact'].Id;
                             
        ID activeRContactType = 
            [select Id, Name, SobjectType
             from RecordType
             where SobjectType = 'Related_Contact__c'
             and Name = 'Active'].Id;
        
        Account a = new Account();
        //a.ATC_Organization_ID__c = '123456';
        a.Name = 'Mr Stevebobs Volvo';
        a.RecordTypeId = validAcctType;
       
        insert a;
        
        Contact c = new Contact();
        c.Person_ID__c = '123';
        c.LastName = 'Bob';
        c.RecordTypeId = validContactType;
        insert c;
        
        Related_Contact__c rc = new Related_Contact__c();
        rc.Account__c = a.Id;
        rc.Contact__c = c.Id;
        rc.Source_Id__c = '912345678';
        insert rc;
        
        rc = [select RecordTypeId from Related_Contact__c where Id = :rc.Id];
        
        System.assertEquals(rc.RecordTypeId, activeRContactType);
        
    }
}