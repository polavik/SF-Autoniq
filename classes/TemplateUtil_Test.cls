//
// (c) 2012 Appirio, Inc.
//
// Utility class to process EmailTemplate and merge record field values
//
// 7 December 2016        Amit Sanwariya (Appirio)      Test Class for TemplateUtil
// 22 February 2017       Adesa Salesforce Team         Refactoring Test Class.
//                                                      (Due to lack of best practice followed by Appirio, test class was occasional failing. 
//                                                      Reason was calling org data on top of it calling Select statment without any order,
//                                                      resulting returning different email template on each run.)
//                                                          
@isTest
public class TemplateUtil_Test {
    private static testMethod void testTemplateUtilController() {
        
        //EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate LIMIT 1]; //Note: bad practice calling org data, it should only be used if its limitation from salesforce
        Account acc = TestUtility.createAccount(0, true);
        Account acc2 = [Select id, Name From Account Limit 1];
        EmailTemplate emailTemplate = testMergeEmailHtml();
        Id emailId = emailTemplate.Id;
        EmailTemplate emailTemplateHTML = [SELECT Id, developerName FROM EmailTemplate WHERE Id =:emailId ];
        emailTemplate = testMergeEmailText();
        emailId = emailTemplate.Id;
        EmailTemplate emailTemplateText = [SELECT Id, developerName FROM EmailTemplate WHERE Id =:emailId ];
        Test.startTest();
            TemplateUtil controller= new TemplateUtil();         
            if(emailTemplateHTML.Id != null)
                TemplateUtil.GetMail(emailTemplateHTML.Id, acc.Id);
            
            if(emailTemplateText.Id != null)        
                TemplateUtil.GetMail(emailTemplateText.Id, acc.Id);
        Test.stopTest();
    }
    

    public static EmailTemplate testMergeEmailHtml() {
        // Salesforce does not allow to create BrandTemplate in the the test class, hence we have to use Org BrandTemplate record.
        BrandTemplate brandTemp = [SELECT Id FROM BrandTemplate WHERE Name = 'ADESA']; 
        
        EmailTemplate emailTemplate = new EmailTemplate (developerName = 'testHTML' + UserInfo.getUserId(), Subject='{!Account.Name}', FolderId = UserInfo.getUserId(), TemplateType= 'html',TemplateStyle='freeForm', Name = 'test'); // plus any other fields that you want to set
        emailTemplate.Body = '<html>email: {!Account.Name}   {!User.LastName}, {!User.Title} {!User.Email}, Cell: {!User.MobilePhone} Office: {!User.Phone}</html>';
        emailTemplate.HtmlValue = '<p>email: {!Account.Name}  {!User.LastName}, {!User.Title} {!User.Email}, Cell: {!User.MobilePhone} Office: {!User.Phone} </p>';
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            
            emailTemplate.BrandTemplateId = brandTemp.Id;            
            insert emailTemplate;
        }
        return emailTemplate;
    }
 

     public static EmailTemplate testMergeEmailText() {
        BrandTemplate brandTemp = [SELECT Id FROM BrandTemplate WHERE Name = 'ADESA'];
        EmailTemplate emailTemplate = new EmailTemplate (developerName = 'testText' + UserInfo.getUserId(), Subject='{!Account.Name}', FolderId = UserInfo.getUserId(), TemplateType= 'text',TemplateStyle='none', Name = 'test'); // plus any other fields that you want to set
        emailTemplate.Body = 'email: {!Account.Name}   {!User.LastName}, {!User.Title} {!User.Email}, Cell: {!User.MobilePhone} Office: {!User.Phone}';
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {           
            insert emailTemplate;
        }
        return emailTemplate;
    }
  
  
    

}