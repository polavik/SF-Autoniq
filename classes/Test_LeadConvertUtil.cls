/**
 * This class contains unit tests for validating the behavior of LeadConvertUtill
 *
 */
@isTest
public class Test_LeadConvertUtil{ 
    
    static testMethod void leadConvertTrigrTest() {
        
        //Lead VPS Record Type
        // BEGIN:  S-444340, T-567488 - include Lead record type = 'IAA VPS Sales'
        List<RecordType> leadRecordTypes = [select Id, Name from RecordType where SobjectType = 'Lead' and Name='IAA VPS Sales'];
        
        //Insert Test Lead
        Lead ldTst = new Lead();
        ldTst.FirstName = 'Lead1';
        ldTst.LastName = 'Lead';
        ldTst.email = 'user@testOrg.com';
        ldTst.Company = 'TestCorp';
        ldTst.Contract_Type__c = 'CFF';
        
        if(leadRecordTypes!=null && leadRecordTypes.size()>0){          
            ldTst.recordTypeId = leadRecordTypes.get(0).Id;         
        }
        
        ldTst.Lead_Stage__c = 'Account Activated';
        ldTst.Status ='Converted';
        
        insert ldTst;
    }   
    
    
    static testMethod void leadConvertUtilTest() {
        
        //Lead VPS Record Type
        // BEGIN:  S-444340, T-567488 - include Lead record type = 'IAA VPS Sales'
        List<RecordType> leadRecordTypes = [select Id, Name from RecordType where SobjectType = 'Lead' and Name='IAA VPS Sales'];
        
        //Insert Test Lead
        Lead ldTst = new Lead();
        ldTst.FirstName = 'Lead1';
        ldTst.LastName = 'Lead';
        ldTst.email = 'user@testOrg.com';
        ldTst.Company = 'TestCorp';
        ldTst.Contract_Type__c = 'CFF';
        ldTst.Street ='test';
        ldTst.City ='test';
        ldTst.State ='GA';
        ldTst.PostalCode = '56006';
        ldTst.Verified_Create_Account__c=true;
        //integer.valueof(ldTst.Auction_Access_Number__c)=8000000;
        ldTst.TIN__c='test';
        
        if(leadRecordTypes!=null && leadRecordTypes.size()>0){          
            ldTst.recordTypeId = leadRecordTypes.get(0).Id;         
        }
        
        insert ldTst;
        system.debug('ldTst.recordTypeId:'+ldTst.recordTypeId);
        LeadConvertUtil.convertLead(ldTst);
    }   
}