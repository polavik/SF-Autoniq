public without sharing class EdgeForceChatterTopicController {
	public String topicId {get;set;}
	public String topicName {get;set;}

	public EdgeForceChatterTopicController() {
		try{
			topicName = ApexPages.currentPage().getParameters().get('t');
			topicId = [SELECT Id FROM Topic WHERE Name = :topicName LIMIT 1].Id;
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Topic Not Found'));
		}
	}
}