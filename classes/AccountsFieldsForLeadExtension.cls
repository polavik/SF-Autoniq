/*
*Appirio Inc. 2016
*Name  : AccountsFieldsForLeadExtension
*Author: Amit SanWariya (Appirio)
*Date  : 7 Oct, 2016
*Description: To show account fields on Lead Detail page
*/
public class AccountsFieldsForLeadExtension {
    public Id ledId { get; set; }
    public Id accId { get; set; }
    public Id territoryId { get; set; }
    public Lead led { get; set; }
    public Account acc { get; set; }
    public Territory__c territory { get; set; }
    public List<Schema.FieldSetMember> accFieldSet { get; set; }
    public List<Schema.FieldSetMember> territoryFieldSet { get; set; }
    
    //Constructor for fetching the Parent Account field values
    public AccountsFieldsForLeadExtension(ApexPages.StandardController controller) {
        ledId = controller.getId();
        for(Lead led : [SELECT Id, Name, Account__c, Territory_Zipcode__c FROM Lead WHERE Id = :ledId]){
        accId = led.Account__c;
        territoryId = led.Territory_Zipcode__c;
        }
        if ( String.IsEmpty(accId) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Account lookup is empty'));
        } else {
        	accFieldSet = SObjectType.Account.FieldSets.Lead_ADESA_DST.getFields();
            String query = 'SELECT ';
            for (Schema.FieldSetMember fld : accFieldSet) {
                query += fld.getFieldPath() + ', ';
            }
            query += 'Id, Name FROM Account WHERE Id = :accId';
            acc = database.query(query);   
        }
        if ( String.IsEmpty(territoryId) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Territory lookup is empty'));
        } else {
        	territoryFieldSet = SObjectType.Territory__c.FieldSets.Territory_Lead_ADESA_DST.getFields();
            String query = 'SELECT ';
            for (Schema.FieldSetMember fld : territoryFieldSet) {
                query += fld.getFieldPath() + ', ';
            }
            query += 'Id, Name FROM Territory__c WHERE Id = :territoryId';
            territory = database.query(query);
        }
    }
}