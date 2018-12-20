/**
 * This class contains unit tests for CaseBeforeTrigger
 *
 */
@isTest
public class Test_CaseBeforeTrigger
{
    
    static testmethod void testCaseBeforeTrigger()
    {
        //S-444999 and T-567278 Jan.12th-2017 N.B
        Id casRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IAA Buyer Services').getRecordTypeId();
        
        Case cse = new Case();       
        cse.RecordTypeId = casRecordTypeId; //S-444999and T-567278 Jan.12th-2017 N.B
        cse.Subject = 'Test Case';
        cse.Status = 'new';
        cse.Origin = 'web';//S-444999and T-567278 Jan.12th-2017 N.B
        cse.Type = 'Arbitration Inquiry'; //S-444999and T-567278 Jan.12th-2017 N.B
        cse.Description ='test'; //S-444999and T-567278 Jan.12th-2017 N.B, this is a must because validation rule.
        insert cse;   
        
        cse.Status = 'Closed';
        update cse;
    }
}