@isTest
private class LeadTrigger_Test {
    
//=============================================================================================
    static testMethod void testLeadTriggerWithMemberDefault() {
        
        integer z = 10001;
                
        //BEGIN: S-444338 When we run this test class we are getting Mixed DML Operations error, to avoid this we need modify this TEST Apex class
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        
        Branch__c b = TestData.CreateBranch(1, '10000');
        insert b;
        
        User u = TestData.CreateUser(1);
        insert u;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        BranchTeamMember__c btm = TestData.CreateBranchTeamMember(b, u, true);
        insert btm;
        
        list<ZipCode__c> zips = new list<ZipCode__c>();
        
        for(integer x = 1; x < 200; x++){
            //system.debug('================================ CURRENT ZIP INTEGER: ' + z);
            ZipCode__c zip = TestData.CreateZips(string.valueOf(z), b.id);  
            zips.add(zip);
            //system.debug('================================ CURRENT ZIP: ' + zip);
            z += x;
            
        }
        
        insert zips;
        
        z = 10001;
        
        list<Lead> leads = new list<Lead>();
        
        for(integer y = 0; y < 5; y++){
            Lead l = TestData.CreateLead(y, string.valueOf(z)); 
            leads.add(l);
            z += y;
        }
       
       system.debug('TRIGGER TEST Lead:' + leads);
    
       insert leads;
      }
   }
//=============================================================================================
    static testMethod void testLeadTriggerWithoutMember(){
        
         integer z = 10001;
        
        //BEGIN: S-444338 When we run this test class we are getting Mixed DML Operations error, to avoid this we need modify this TEST Apex class
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){
        
        Branch__c b = TestData.CreateBranch(1, '10000');
        insert b;
        
        User u = TestData.CreateUser(1);
        insert u;
        
        IAASettings__c iaa = TestData.CreateSetting('DefaultOwnerId', u.Id);
        insert iaa;
        
        list<ZipCode__c> zips = new list<ZipCode__c>();
        
        for(integer x = 1; x < 200; x++){
            //system.debug('================================ CURRENT ZIP INTEGER: ' + z);
            ZipCode__c zip = TestData.CreateZips(string.valueOf(z), b.id);  
            zips.add(zip);
            //system.debug('================================ CURRENT ZIP: ' + zip);
            z += x;
            
        }
        
        insert zips;
        
        z = 10001;
        
        list<Lead> leads = new list<Lead>();
        
        for(integer y = 0; y < 5; y++){
            Lead ld = TestData.CreateLead(y, string.valueOf(z));    
            leads.add(ld);
            z += y;
        }
       
       system.debug('TRIGGER TEST LEADS:' + leads);
       
       insert leads;
    }
   } 
}