public class CaseDetailController {
	public Case myCase {get; set;}
	public List<String> validationMessages {get; set;} 
	public boolean renderValidationError {get; set;}
	
    public CaseDetailController(ApexPages.StandardController stdController) {
    	renderValidationError = false;
    	validationMessages = new List<String>();
    	
		myCase = (Case)stdController.getRecord();
		
		myCase = [SELECT Validation_Outcome_Reason__c FROM Case WHERE Id = :myCase.Id];
		
		if (myCase.Validation_Outcome_Reason__c != null && !myCase.Validation_Outcome_Reason__c.equals('')) {
			renderValidationError = true;
			for (String msg : myCase.Validation_Outcome_Reason__c.split('\n')) {
				validationMessages.add(msg);
			}
		}
    }
}