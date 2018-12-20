/*
*Appirio Inc. 2016
*Name  : AccountFieldsForOpportunityExtension
*Author: Amit SanWariya (Appirio)
*Date  : 29 Sept, 2016
*Description: To show account fields on Opportunity Detail page
*/
public class AccountFieldsForOpportunityExtension {
    public Account acc { get; set; }
    public Id oppId { get; set; }
    public Id accId { get; set; }
    public Opportunity opp { get; set; }
    public List<Schema.FieldSetMember> accFieldSet { get; set; }
    
    //Constructor for fetching the Parent Account field values
    public AccountFieldsForOpportunityExtension(ApexPages.StandardController controller) {
        oppId = controller.getId();
        for(Opportunity opp : [SELECT Id, Name, AccountId FROM Opportunity WHERE Id = :oppId]){
        accId = opp.AccountId;
        }
        if ( String.IsEmpty(accId) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Account lookup is empty'));
        } else {
            accFieldSet = SObjectType.Account.FieldSets.Opportunity_ADESA_DST_CLOSE_Sell.getFields();
            String query = 'SELECT ';
            for (Schema.FieldSetMember fld : accFieldSet) {
                query += fld.getFieldPath() + ', ';
            }
            query += 'Id, Name FROM Account WHERE Id = :accId';
            acc = database.query(query);
        }
    }
}