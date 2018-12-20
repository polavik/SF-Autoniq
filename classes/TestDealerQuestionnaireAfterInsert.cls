@isTest
private class TestDealerQuestionnaireAfterInsert {

    static testMethod void myUnitTest() {
    
        Lead l = new Lead(company = 'dq tes lead', lastname='test', AFC_Branch__c = 'Boise',
            Opportunity_Method__c = 'BDC', Status= 'Qyalified');
        insert l;
        Dealer_Questionnaire__c dq = new Dealer_Questionnaire__c(Lead__c = l.id);
        insert dq;         
        }
}