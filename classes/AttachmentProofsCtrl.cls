public class AttachmentProofsCtrl
{
    public List<sObject> records { get; private set; }
    public List<Attachment> attachments { get; private set; }
    public String selectedToAttachTo {get; set;}
    public static final Integer MAX_ATTACHMENTS = 10;
    public static final String OBJECT_TYPE = 'objectType';
    public static final String VIEW_REPORTING_FOR_ATTACHMENTS_FIELDS_NAME = 'ViewReportingForAttachments';
    public static final String ADDITIONAL_INPUT_FIELDS = 'UploadingAttachmentFields';
    public static final String AFC_CONTRACT_ID = 'afc_id';

    public AttachmentProofsCtrl()
    {
        setRecordsToAttach();
        attachments = new List<Attachment>();
        
        for( Integer i = 0; i < MAX_ATTACHMENTS; i++ )
        {
            attachments.add( new Attachment() );
        }
    }
    
    public sObject selectedObj
    {
        get
        {
            Map<Id, sObject> allRecords = new Map<Id, sObject>( records );
            return allRecords.get( selectedToAttachTo );
        }
    }
    
    private Id AfcContractId
    {
        get
        {
            return (Id)ApexPages.currentPage().getParameters().get( AFC_CONTRACT_ID );
        }
    }
    
    public Boolean displayFields
    {
        get
        {
            return additionalInput != null && selectedToAttachTo != null && (Boolean)selectedObj.get('Sales_Numbers__c') == true;
        }
    }
    
    public List<Schema.FieldSetMember> fieldMembers
    {
        get
        {
            if( fieldMembers == null )
            {
                Map<String, Schema.FieldSet> fieldSets = selectedObjectType.getDescribe().fieldSets.getMap();
                if( fieldSets.containsKey( VIEW_REPORTING_FOR_ATTACHMENTS_FIELDS_NAME ) )
                {
                    fieldMembers = fieldSets.get( VIEW_REPORTING_FOR_ATTACHMENTS_FIELDS_NAME ).getFields();
                }
                else
                {
                    throw new AttachmentProofsCtrlException('The SObjectType does not contain the field set "' +
                                                             VIEW_REPORTING_FOR_ATTACHMENTS_FIELDS_NAME + '".  Please create it first');
                }
            }
            return fieldMembers;
        }
        private set;
    }

    public List<Schema.FieldSetMember> additionalInput
    {
        get
        {
            if( additionalInput == null )
            {
                Map<String, Schema.FieldSet> fieldSets = selectedObjectType.getDescribe().fieldSets.getMap();
                if( fieldSets.containsKey( ADDITIONAL_INPUT_FIELDS ) )
                {
                    additionalInput = fieldSets.get( ADDITIONAL_INPUT_FIELDS ).getFields();
                }
            }
            return additionalInput;
        }
        private set;
    }

    private Set<String> getFields()
    {
        Set<String> fields = new Set<String>();
		Boolean blnFLSOverride = Utils.GetFLS();
        List<Schema.FieldSetMember> members = new List<Schema.FieldSetMember>(fieldMembers);
        if( additionalInput != null )
            members.addAll( additionalInput );
        for( Schema.FieldSetMember member : members )
        {
            fields.add( member.getFieldPath().toUpperCase() );
        }
        fields.add('NAME');
        if( selectedObjectType.getDescribe().getName().toUpperCase() == 'MONTHLY_REPORTING__C' )
            fields.add('SALES_NUMBERS__C');
        else {
            fields.add('INSURANCE_CERTIFICATE__C');
        }
            
        return fields;
    }
    
    private Schema.sObjectType selectedObjectType
    {
        get
        {
            if( selectedObjectType == null )
            {
                Map<String, Schema.SObjectType> types = Schema.getGlobalDescribe();
                String objectType = ApexPages.currentPage().getParameters().get( OBJECT_TYPE );
                if( types.containsKey( objectType ) )
                    selectedObjectType = types.get( objectType );
                else
                    throw new AttachmentProofsCtrlException( 'The sObjectType "' +  objectType +
                                                             '" does not exist.  Please check your "' + OBJECT_TYPE  + 
                                                             '" parameter and ensure that API name exists ' );
            }
            return selectedObjectType;
        }
        set;
    }
    
    private void setRecordsToAttach()
    {
        String query = 'SELECT ' + String.join( new List<String>( getFields() ), ',' ) +
                       ' FROM ' + selectedObjectType.getDescribe().getName() +
                       ' WHERE Status__c != \'Complete\' ' +
                       '   AND Contract__c = :AfcContractId ';
        records = Database.query( query );
    }
    
    public ApexPages.PageReference uploadAttachments()
    {
		Set<String> ListFLSCreate = new Set<String>();
		Boolean blnFLSOverride ;
		if(Test.isRunningTest())
		{
			blnFLSOverride = true;
		}   
		else
		{
			blnFLSOverride = !(FLS_Enforce_Switch__c.getInstance().Enforce_FLS__c); 
		}
		System.debug('>>>>blnFLSOverride:'+blnFLSOverride);
        List<Attachment> attachmentsToCreate = new List<Attachment>();
        for( Attachment doc : attachments )
        {			
			if (Schema.sObjectType.Attachment.fields.ParentId.isCreateable() || blnFLSOverride)
			{
				doc.ParentId = selectedToAttachTo;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Attachment.getName()+'.'+Schema.sObjectType.Attachment.fields.ParentId.getName());
			}
			
            if( doc.Body != null && doc.Name != null )
                attachmentsToCreate.add( doc );
        }
        //SavePoint sp = Database.setSavePoint();
        //
        //   Error Message	System.CalloutException: You have already created Savepoints. You cannot make callout after creating a Savepoint
        //   Stack Trace	Class.MA_Futures.MA_Account_UpdateTerritoryInfo: line 32, column 1
        //
        
        if( ( !selectedObjectRequiresAttachment() ) || 
            ( selectedObjectRequiresAttachment() && ( !attachmentsToCreate.isEmpty() ) )
        ){
			if(ListFLSCreate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_CREATE','CLASS:AttachmentProofsCtrl', ListFLSCreate);
				ApexPages.Message mess = new ApexPages.Message(ApexPages.Severity.ERROR, 'FLS Permission not allow to upload attachment. Please contact your manager/salesforce administrator');
				ApexPAges.addMessage(mess);
				return null;
			}
            insert attachmentsToCreate;

            Map<Id, sObject> objects = new Map<Id, sObject>( records );
            sObject objToUpdate = objects.get( selectedToAttachTo );

            try
            {
                objToUpdate.put( 'Status__c', 'Ready for Review' );
                update objToUpdate;
            }
            catch(DmlException e)
            {
                //Database.rollback( sp );
                throw e;
            }
            return returnBack();
        } else {
        	ApexPages.Message mess = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please attach a file.');
            ApexPAges.addMessage(mess);
            return null;
        }
        
        
    }
    
    public ApexPages.PageReference returnBack()
    {
        return new ApexPages.PageReference( '/' + afcContractId );
    }
    
    public boolean selectedObjectRequiresAttachment (){
        String selectedObjectTypeName = selectedObjectType.getDescribe().getName().toUpperCase();
        if(selectedObjectTypeName == 'MONTHLY_REPORTING__C') {
            return ( ((boolean)selectedObj.get('Bank_Statements__c')) || ((boolean)selectedObj.get('Financials__c')) || ((boolean)selectedObj.get('Tax_Returns__c')));
        }
        else if (selectedObjectTypeName == 'PROOF_OF_INSURANCE__C'){
            return (boolean)selectedObj.get('Insurance_Certificate__c');
        }
        return false;
    }
    
    public class AttachmentProofsCtrlException extends Exception {}
}