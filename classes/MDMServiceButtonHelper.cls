global class MDMServiceButtonHelper {
	webService static String refreshSalesforceAccount(Id accountId){
		return MDMServiceHelper.refreshSalesforceAccount(new List<Id>{accountId});
	}
}