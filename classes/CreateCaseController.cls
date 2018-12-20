public class CreateCaseController {
	public String caseType {get; set;}
	public Map<String, String> params;
	

    public CreateCaseController(ApexPages.StandardController stdController) {

		params = new Map<String, String>();
    	params.putAll(apexPages.currentPage().getParameters());
    	
    }
    
    public PageReference submit() {

		if ('null'.equals(caseType)) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,
				'Please select a Case Type.'));
			return null;
		}
		
		params.put('type', caseType);

		PageReference pr = Page.create_case2;		
		pr.getParameters().putAll(params);
    	return pr;
    }
}