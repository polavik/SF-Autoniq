global class BatchContactUpdate implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts,Database.Stateful {

    private static final String DEFAULT_ERROR_MESSAGE='Error syncing contacts with COSMOS';
    private List<String> errors;

    String query='SELECT    Party_Id__c,'+ 
                            'FirstName,'+
                            'Middle_Name__c,'+
                            'LastName,'+
                            'Bankruptcy_Indicator__c,' +
                            'Suffix__c,'+
                            'Phone,'+
                            'MobilePhone,'+
                            'Email,'+
                            'BirthDate,'+
                            'SSN__c,'+
                            'AFC_Primary_Street__c,'+
                            'AFC_Primary_Street2__c,'+
                            'AFC_Primary_City__c,'+
                            'AFC_Primary_State__c,'+
                            'AFC_Primary_Country__c,'+
                            'AFC_Primary_County__c,'+
                            'AFC_Primary_Postalcode__c,'+
                            'Type_of_Home_Ownership__c,'+
                            'Years_There__c,'+
                            'Citizen__c'+
                    ' FROM  Contact'+
                    ' WHERE Cosmos_Sync_Pending__c=TRUE and Party_Id__c!=null';
    
    global BatchContactUpdate(){
        errors = new List<String>();
    }

    global void execute(SchedulableContext sc) 
    {
       BatchContactUpdate batchObject = new BatchContactUpdate();
       Database.executeBatch(batchObject);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        SchemaContactUpdate.ContactUpdateTypes contacts = new SchemaContactUpdate.ContactUpdateTypes();
        contacts.ContactUpdate = new List<SchemaContactUpdate.ContactUpdateType>();
        
        for(Contact c : (List<Contact>) scope){
            contacts.ContactUpdate.add(SchemaContactUpdateHelper.setContactParams(c));
            c.Cosmos_Sync_Pending__c=false;
        }

        try{
            SchemaContactUpdate.ContactUpdateSOAP_HTTP_Port req = new SchemaContactUpdate.ContactUpdateSOAP_HTTP_Port();
            req.endpoint_x = SchemaContactUpdateHelper.endpointURL;
            req.timeout_x = SchemaContactUpdateHelper.timeout;
            req.inputHttpHeaders_x = new Map<String, String>();
            for(String propName : PropertyServices.contactUpdatePropertiesMap.keySet())
            {
                req.inputHttpHeaders_x.put(propName, PropertyServices.contactUpdatePropertiesMap.get(propName));
            }
            SchemaContactUpdate.ServiceResponse response = req.ContactUpdate(contacts);
            if(response.ResponseStatus == SchemaContactUpdateHelper.SUCCESS_STRING){
                update scope;
            }else{
                String message = response.Error != null ? '' : 'Status Code: ' + response.Error.ErrorCode + ', Message: ' + response.Error.ErrorMessage;
                throw new SchemaContactUpdateHelper.ContactUpdateException(message);
            } 
        } catch(Exception e){
            errors.add(e.getMessage());
        }

    }
    
    global void finish(Database.BatchableContext BC) {
        if(!errors.isEmpty()){
            sendErrorEmail(errors);
        }    
    }

    private static void sendErrorEmail(List<String> messages){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(SchemaContactUpdateHelper.errorEmailUserId);
        mail.setSubject(DEFAULT_ERROR_MESSAGE);
        mail.setPlainTextBody(String.join(messages, '\n'));
        mail.saveAsActivity=false;
        if(!Sandbox.isSandbox())
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}