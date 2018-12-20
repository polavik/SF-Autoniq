public class TestTriggerLeadtoAccountValidate {

    static testMethod void testRecordType(){
        Lead l = new Lead(LastName='test',Company='testcom',AFC_Branch__c='Boston',Status='C-Recognize Lead' );
        insert l;
        Lead la = new Lead(id=l.Id,IsConverted =true,LastName='Test0',Company = 'TestCom',AFC_Branch__c='Boston',Status='C-Recognize Lead');
        update la;
        
        Lead lb = new Lead(id=l.Id,IsConverted =true,City = 'test city',LastName='Test0',Company = 'TestCom',AFC_Branch__c='Boston',Status='C-Recognize Lead');
        update lb;
        
        Lead lc = new Lead(id=l.Id,IsConverted =true,Verified_Create_Account__c = true,LastName='Test0',Company = 'TestCom',AFC_Branch__c='Boston',Status='C-Recognize Lead');
        update lc;
        
        Lead ld = new Lead(id=l.Id,IsConverted =true,Auction_Access_Number__c = '1234567890',Verified_Create_Account__c =true,LastName='Test0',Company = 'TestCom',AFC_Branch__c='Boston',Status='C-Recognize Lead');
        update ld;
        
        Lead le = new Lead(id=l.Id,IsConverted =true,Auction_Access_Number__c = '1000000062',Verified_Create_Account__c = true,LastName='Test0',Company = 'TestCom',AFC_Branch__c='Boston',Status='C-Recognize Lead');
        update le; 
        
    /*    la.LastName ='test1';
        lb.LastName ='test1';
        lc.LastName ='test1';
        ld.LastName ='test1';
        le.LastName ='test1';
        
        la.IsConverted =true;
        lb.IsConverted =true;
        lc.IsConverted =true;
        ld.IsConverted =true;
        le.IsConverted =true;
        
        
        update la;
        update lb;
        update lc;
        update ld;
        update le;
      */  
    }

}