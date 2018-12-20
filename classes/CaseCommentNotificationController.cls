public class CaseCommentNotificationController 
{
    public String commentBody{get; set;}
    public String createdBy {get; set;}
    public String caseNumber {get; set;}
    
    /*  
    *   ActionPackageId will be passed in by the "caseCommentSecondaryOwnerNotice" component.  
    *   The "set" accessor will act as the constructor method for this class
    */
    public String caseId {
        get;
        
        set
        {
            caseId = value;
            Case c = [select Case_Comment_Id__c from case where id =:value];
            String ccId = null;
            if(c != null){
                ccId = c.case_comment_id__c;
                if(ccId != null){
                    CaseComment cc = 
                    [
                        SELECT Id, commentBody, createdBy.name, parent.CaseNumber
                          FROM caseComment 
                         WHERE parentId = :value
                           AND id = :ccId
                    ];
                    try
                    {
                         if(cc!= null){
                            commentBody = cc.commentBody;
                            createdBy = cc.createdBy.name;
                            caseNumber = cc.parent.CaseNumber;
                         }
                    }
                    catch (Exception e)
                    {
                        Logger.error(cc, e.getMessage());
                        throw new CaseCommentsNoticeException(e); 
                    }
                    finally
                    {
                        Logger.flush(); 
                    }
                }
            }
        }
    }
    
    public class CaseCommentsNoticeException extends Exception {}
}