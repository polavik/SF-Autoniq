// ============================================================================================//
//      THIS CLASS IS USED BY IAA-Remarketing APPLICATION
// ============================================================================================//
public with sharing class TestData {


//----------------------------------------------------------------------------
    public static Account CreateAccount(integer Count, string Zip){
        
        Account acct = new Account();
        acct.Name = 'TestAccount' + Count;
        acct.BillingStreet = 'Test Street';
        acct.BillingCity = 'Test City';
        acct.BillingState = 'NJ';
        acct.BillingPostalCode = zip;
        acct.BillingCountry = 'USA';
        acct.IAA_Type__c='Remarketing';
        //acct.BuyerID__c=buyid;
        acct.SPID__c='12345';
        
        // BEGIN: S-444338, T-566475 : Include Account recordtype Custom field
        acct.IAARecordTypes__c='IAA Remarketing';
        // END: S-444338, T-566475 : Include Account recordtype Custom field
        
        acct.OwnerId = Userinfo.getUserId();
        
        return acct;
    }
//----------------------------------------------------------------------------  
    public static ZipCode__c CreateZips(string ZipCode, id BranchId){
        
        ZipCode__c zip = new ZipCode__c();
        zip.City__c = 'Denver';
        zip.County__c = 'Harris';
        zip.Primary__c = true;
        zip.State__c = 'CO';
        
        if(ZipCode != null && ZipCode != ''){
            zip.Name = ZipCode; 
        }else{
            zip.Name = '99999';
        }
        
        zip.Branch__c = BranchId;
        
        return zip;
    }
//----------------------------------------------------------------------------
    public static Branch__c CreateBranch(integer Count, string zip){
        
        Branch__c b = new Branch__c();
        b.Name = 'TestBranch' + Count;
        b.BranchNumber__c = '123';
        //b.Region__c = 'West';
        
        b.PrimaryStreet__c = '100 Branch Street';
        b.PrimaryCity__c = 'BranchCity';
        b.PrimaryState__c = 'NJ';
        b.PrimaryZipCode__c = zip;
        b.PrimaryCountry__c = 'USA';
        
        return b;
        
    }
//----------------------------------------------------------------------------
    public static BranchTeamMember__c CreateBranchTeamMember(Branch__c branch, User usr, boolean DefaultUser){
        
        BranchTeamMember__c btm = new BranchTeamMember__c();
        btm.Branch__c = branch.Id;
        btm.Default__c = DefaultUser;
        btm.TeamMember__c = usr.Id;
        return btm;
        
    }
//----------------------------------------------------------------------------
    public static User CreateUser(integer Count){

        // This gets the license Id for the system admin. 
        // This is so that the test user is created using a full CRM license and not a limited Chatter Only or Chatter Free license
        
        Id CRMLicenseId = [Select Id, UserType, Name, UserLicenseId From Profile Where Name = 'System Administrator'].UserLicenseId;
        
        list<Profile> listProfiles = [  Select UserType, Name, Id 
                                        From Profile 
                                        Where UserLicenseId =: CRMLicenseId  
                                        //OR UserType = 'Standard'
                                        Order By Name Desc
                                        ];
    
        User u;

            u = new User();
            u.FirstName = 'Test';
            u.LastName = 'User' + Count;
            u.email = u.FirstName + u.LastName + '@testing.iaai.com';
            u.Username = u.email;
            u.IsActive = true;
            u.TimeZoneSidKey = 'America/Chicago';
            u.LocaleSidKey = 'en_US';
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.CommunityNickname = u.Alias;
            u.ProfileId = listProfiles[0].Id;
            u.Alias = u.LastName;
        
        return u;
            
    }
//----------------------------------------------------------------------------
    public static Lead CreateLead(integer Count, string zip){
        
        Lead l = new Lead();
        l.FirstName = 'Test';
        l.LastName = 'Lead' + Count;
        l.Street = 'Test Lead Street';
        l.City = 'TestCity';
        l.State = 'NJ';
        l.PostalCode = zip;
        l.Company = 'Test Company';
        
        //BEGIN: S-444340 T-561817 - Process only IAA Remarketing Recordtype data
        RecordType LeadRecordTypeid = [Select Id From RecordType Where SObjectType='Lead' and Name='IAA Remarketing'];
        l.recordtypeid =LeadRecordTypeid.id;
        //END: S-444340 T-561817 - Process only IAA Remarketing Recordtype data
        
        //For Validation Rules
        l.Lead_Type__c = 'Test Type';
        l.LeadSource = 'Web';
        l.Email = 'test@iaa.vrd.com';
        
        return l; 
        
    }
//----------------------------------------------------------------------------
    public static IAASettings__c CreateSetting(string settingName, string settingValue){
        
        IAASettings__c iaa = new IAASettings__c();
        iaa.Name = settingName;
        iaa.SettingValue__c = settingValue;
        return iaa;
    }
//----------------------------------------------------------------------------
}