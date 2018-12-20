public class LeadConvertUtil { 
  
  public static void convertLead(Lead leadRcd){
    
    String leadRecordTypeName = leadRcd.Lead_Record_Type_Name__c;
    Map<Id, Schema.RecordTypeInfo> rt_Map = Lead.sObjectType.getDescribe().getRecordTypeInfosById();
	
   if(rt_Map.get(leadRcd.RecordTypeId).getName().containsIgnoreCase('IAA VPS Sales'))
   {
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadRcd.Id);
        lc.setDoNotCreateOpportunity(true); 
        lc.setConvertedStatus('Converted');
        
        try{
            Database.LeadConvertResult lcr = Database.convertLead(lc);
    		//Account Updates
            Account convertedAccount = new Account(
                Id=lcr.getAccountId(),
                Converted_Lead_ID__c = leadRcd.Id,
                RecordType=new RecordType(Name=leadRcd.Lead_Record_Type_Name__c)               
            );
            //Contact Updates
            Contact ConvertedContact = new Contact(
                Id=lcr.getContactId(),
                RecordType=New recordType(Name=leadRcd.Lead_Record_Type_Name__c)
            );
            update new SObject[]{convertedAccount, convertedContact};
            } catch(DmlException e) {
                System.debug('Exception: '+ e);
            }
      }
    } 
}