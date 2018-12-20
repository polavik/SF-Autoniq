@isTest
private class IAAILeadTrigger_Test {
    
//===========================================================================================
    static testMethod void testLeadTriggerWithMemberDefault() {
        
        integer z = 10001;
        
        string IAAKAR = DateTime.now().format('yyy-MM-dd');
        Branch__c b = TestData.CreateBranch(1, '10000');
        insert b;
        
        //User u = TestData.CreateUser(1);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jasonnnn.liveston@asdf.com',
                           Username = 'jason123.liveston@asdf12.com' +  IAAKAR ,
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
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
        
        for(integer y = 0; y < 2; y++){
            Lead l = TestData.CreateLead(y, string.valueOf(z)); 
            leads.add(l);
            z += y;
        }
       
       system.debug('TRIGGER TEST Lead:' + leads);
       
       insert leads;
    }
//=============================================================================================
    static testMethod void testLeadTriggerWithoutMember(){
        
         integer z = 10001;
         string IAAKAR = DateTime.now().format('yyy-MM-dd');
        Branch__c b = TestData.CreateBranch(1, '10000');
        insert b;
        
        //User u = TestData.CreateUser(1);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason789.liveston@asdf.com',
                           Username = 'jan.liveston@asdf34.com' + IAAKAR ,
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
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
        
        for(integer y = 0; y < 2; y++){
            Lead ld = TestData.CreateLead(y, string.valueOf(z));    
            leads.add(ld);
            z += y;
        }
       
       system.debug('TRIGGER TEST LEADS:' + leads);
       
       insert leads;
    }
}