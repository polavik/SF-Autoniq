public class OpenCaseEscalationsController {

	private final ApexPages.StandardSetController controller;  
  	    
	public OpenCaseEscalationsController(ApexPages.StandardSetController controller) 
	{  
		this.controller = controller;  
	}      

	public PageReference redirect()
	{
		return new PageReference(Utils.getProperty('open.case.escalations.listview'));
	}
}