/**
  * Apex Class: IntranetContentNewController
  * Description: T-179349 : Develop VF page to enter content
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: September 2nd, 2013.
  */
public with sharing class EdgeForceIntranetContentNewController {
    public Intranet_Content__c intranetContent {get;set;}
    public Intranet_Content_Version__c intranetContentVersion {get;set;}
    public String recordTypeName {get;set;}
    public Boolean isCMSField {get;set;}
    public Boolean isArticleField {get;set;}
    public Boolean isLinkField {get;set;}
    public Boolean isBannerField {get;set;}
    public Boolean isLearningCenter {get;set;}
    public Boolean isDynamicComponent {get;set;}
    public Boolean showSummary {get;set;}
    public List<SelectOption> listOfObjectsName {get;set;}
    public String selectedObject {get;set;}
    public String sortColumn {get;set;}
    public List<SelectOption> listOfObjectsFields {get;set;}
    public List<String> selectedFields {get;set;}
    public Boolean isSearchConfig {get;set;}
    public Boolean showDocManagementLayout {get;set;}
    public Boolean isCollapsibleField {get;set;}
    public Boolean isHomePageSocialFeed {get;set;}
    public Boolean isWhatsNew {get;set;}

    String parentName;
    String parentRT;
    String clonedId;
    Set<String> ListFLSCreate1 = new Set<String>();
	Set<String> ListFLSCreate = new Set<String>();	
	Boolean blnFLSOverride = Utils.GetFLS();
	
    public EdgeForceIntranetContentNewController(ApexPages.StandardController controller){
        intranetContent = new Intranet_Content__c();
        intranetContentVersion = new Intranet_Content_Version__c();

        isCMSField = false;
        isArticleField = false;
        isDynamicComponent = false;
        isSearchConfig = false;
        showSummary = false;
        isHomePageSocialFeed = false;
        isCollapsibleField = false;
        isWhatsNew = false;

        if(String.isNotBlank(Apexpages.currentPage().getParameters().get('id'))){
            clonedId = Apexpages.currentPage().getParameters().get('id');
            // Query for existing Content with all fields available
            String queryString = 'SELECT '+IntranetUtility.getAllFields('Intranet_Content__c');
            queryString += ' FROM Intranet_Content__c WHERE Id = \''+clonedId+'\' LIMIT 1';
            // Clone existing Content
            intranetContent = (Intranet_Content__c) Database.query(queryString)[0].clone(false,true);

            // Query for existing Primary Content Version with all fields available
            queryString = 'SELECT '+IntranetUtility.getAllFields('Intranet_Content_Version__c');
            queryString += ' FROM Intranet_Content_Version__c WHERE Intranet_Content__c = \''+clonedId+ '\'';
            queryString += ' AND Primary_Record__c = true';
            // Clone Primary Version
            intranetContentVersion = (Intranet_Content_Version__c) Database.query(queryString)[0].clone(false,true);

            // Get Content Record Type Name
            recordTypeName = [SELECT Name FROM RecordType WHERE Id = :intranetContent.RecordTypeId LIMIT 1].Name;
        } else {
            recordTypeName = Apexpages.currentPage().getParameters().get('RecordTypeName');
			
			if (Schema.sObjectType.Intranet_Content__c.fields.RecordTypeId.isCreateable() || blnFLSOverride)
			{
				intranetContent.RecordTypeId = Apexpages.currentPage().getParameters().get('RecordTypeId');
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Intranet_Content__c.getName()+'.'+Schema.sObjectType.Intranet_Content__c.fields.RecordTypeId.getName());
			}

			if (Schema.sObjectType.Intranet_Content_Version__c.fields.Language__c.isCreateable() || blnFLSOverride)
			{	
				intranetContentVersion.Language__c = 'English';
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Intranet_Content_Version__c.getName()+'.'+Schema.sObjectType.Intranet_Content_Version__c.fields.Language__c.getName());
			}
			if (Schema.sObjectType.Intranet_Content_Version__c.fields.Primary_Record__c.isCreateable() || blnFLSOverride)
			{	
				intranetContentVersion.Primary_Record__c = true;
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Intranet_Content_Version__c.getName()+'.'+Schema.sObjectType.Intranet_Content_Version__c.fields.Primary_Record__c.getName());
			}
        }
        
        if(String.isNotBlank(Apexpages.currentPage().getParameters().get('contentBucketId'))){
			if (Schema.sObjectType.Intranet_Content__c.fields.Content_Bucket__c.isCreateable() || blnFLSOverride)
			{
				intranetContent.Content_Bucket__c = Apexpages.currentPage().getParameters().get('contentBucketId');
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Intranet_Content__c.getName()+'.'+Schema.sObjectType.Intranet_Content__c.fields.Content_Bucket__c.getName());
			}
        }

        if(String.isNotBlank(Apexpages.currentPage().getParameters().get('parentContentId'))){
			if (Schema.sObjectType.Intranet_Content__c.fields.Parent__c.isCreateable() || blnFLSOverride)
			{
				intranetContent.Parent__c = Apexpages.currentPage().getParameters().get('parentContentId');
			}
			else
			{						
				ListFLSCreate.add(Schema.sObjectType.Intranet_Content__c.getName()+'.'+Schema.sObjectType.Intranet_Content__c.fields.Parent__c.getName());
			}
            for(Intranet_Content__c ic : [SELECT Name, Content_Bucket__c, RecordType.Name FROM Intranet_Content__c WHERE Id = :intranetContent.Parent__c]){
				if (Schema.sObjectType.Intranet_Content__c.fields.Content_Bucket__c.isCreateable() || blnFLSOverride)
				{
					intranetContent.Content_Bucket__c = ic.Content_Bucket__c;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Intranet_Content__c.getName()+'.'+Schema.sObjectType.Intranet_Content__c.fields.Content_Bucket__c.getName());
				}
                parentName = ic.Name;
                parentRT = ic.RecordType.Name;
            }
        }
        
        if(recordTypeName == 'Intranet CMS Pages'){
            isCMSField = true;
        }else if(recordTypeName == 'Intranet Collapsible Content'){
            isCollapsibleField = true;
        }else if(recordTypeName == 'What\'s New Banner'){
            isWhatsNew = true;
        }else if(recordTypeName == 'Intranet Article' || recordTypeName == 'Learning Center'){
            isArticleField = true;
        }else if(recordTypeName == 'Intranet Banner'){
            isBannerField = true;
        }else if(recordTypeName == 'Intranet Link'){
            isLinkField = true;
        //}else if(recordTypeName == 'Dynamic Component'){
        //    listOfObjectsName = new List<selectOption>();
        //    listOfObjectsName.add(new SelectOption('---Select---','---Select---'));
        //    for(Schema.SObjectType SObj : Schema.getGlobalDescribe().Values())
        //    {
        //       listOfObjectsName.add(new SelectOption(SObj.getDescribe().getName(),SObj.getDescribe().getName()));
        //    }
        //    listOfObjectsName.sort();
        //    isDynamicComponent = true;
        }
        if(recordTypeName == 'Learning Center'){
            isLearningCenter = true;
        }
        
        if(recordTypeName == 'Intranet Article'){
            showSummary = true;
        }
        if(recordTypeName == 'Search Component'){
           isSearchConfig  = true;
        }
        if(recordTypeName == 'Document Management'){
           showDocManagementLayout  = true;
        }
        if(recordTypeName == 'Home Page Social Feed'){
           isHomePageSocialFeed  = true;
        }
    }
    
    //return List of all the fields of selected object in dynamic Components
    //public void fetchObjectFields(){
        //listOfObjectsFields = new List<SelectOption>();
        //Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        //if(selectedObject!=null && selectedObject!='' && selectedObject != '---Select---'){
        //    Schema.Describesobjectresult dsr = gdMap.get(selectedObject).getDescribe();
        //    Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
        //    for(String key : fieldMap.keySet()) {
        //        listOfObjectsFields.add(new SelectOption(key,key));
        //    }
        //    listOfObjectsFields.sort();
        //}
    //}

    //Save the Intranet Content and Intranet Content version records
    public Pagereference save(){
     try{
		 
		 
        if(intranetContent.Template__c == 'Team' && 
               !intranetContent.Create_Chatter_Group__c){
            //intranetContent.addError('Create Chatter Group? checkbox must be checked.');
            //return null;
        }
        
        if(intranetContent.Target__c == null){
			//Story B-44003 : FLS CREATE ACCESS CHECK
			if (Schema.sObjectType.Intranet_Content__c.fields.Target__c.isCreateable() || blnFLSOverride)
			{			
				intranetContent.Target__c = '_self';
			}
			else
			{						
				ListFLSCreate1.add(Schema.sObjectType.Intranet_Content__c.getName()+'.'+Schema.sObjectType.Intranet_Content__c.fields.Target__c.getName());
			}
        }
        
        //if(recordTypeName == 'Dynamic Component'){
        //    intranetContent.Object_Name__c = selectedObject;
        //    String fieldsString = '';
        //    for(String s:selectedFields) {
        //       fieldsString += (fieldsString==''?'':',')+s;
        //    }
        //    intranetContent.Fields_to_Display__c = fieldsString;
        //    intranetContent.Sort_Column__c = sortColumn;
        //}
      	if(ListFLSCreate1.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:EdgeForceIntranetContentNewController', ListFLSCreate);		
			 return null;
		}
        insert intranetContent;

			
		 
		if (Schema.sObjectType.Intranet_Content_Version__c.fields.Intranet_Content__c.isCreateable() || blnFLSOverride)
		{
			intranetContentVersion.Intranet_Content__c = intranetContent.Id;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Intranet_Content_Version__c.getName()+'.'+Schema.sObjectType.Intranet_Content_Version__c.fields.Intranet_Content__c.getName());
		}
		if (Schema.sObjectType.Intranet_Content_Version__c.fields.Name.isCreateable() || blnFLSOverride)
		{
			intranetContentVersion.Name = intranetContent.Name;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Intranet_Content_Version__c.getName()+'.'+Schema.sObjectType.Intranet_Content_Version__c.fields.Name.getName());
		}
		if (Schema.sObjectType.Intranet_Content_Version__c.fields.Value__c.isCreateable() || blnFLSOverride)
		{
			intranetContentVersion.Value__c = intranetContent.Value__c;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Intranet_Content_Version__c.getName()+'.'+Schema.sObjectType.Intranet_Content_Version__c.fields.Value__c.getName());
		}
		if (Schema.sObjectType.Intranet_Content_Version__c.fields.Image_Description__c.isCreateable() || blnFLSOverride)
		{
			intranetContentVersion.Image_Description__c = intranetContent.Name;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Intranet_Content_Version__c.getName()+'.'+Schema.sObjectType.Intranet_Content_Version__c.fields.Image_Description__c.getName());
		}
		if (Schema.sObjectType.Intranet_Content_Version__c.fields.isPublished__c.isCreateable() || blnFLSOverride)
		{
			intranetContentVersion.isPublished__c = true;
		}
		else
		{						
			ListFLSCreate.add(Schema.sObjectType.Intranet_Content_Version__c.getName()+'.'+Schema.sObjectType.Intranet_Content_Version__c.fields.isPublished__c.getName());
		}

		if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:EdgeForceIntranetContentNewController', ListFLSCreate);
			return null;
		}
		
        insert intranetContentVersion;      

        if(parentName != null && parentRT == 'Intranet CMS Pages'){
            Intranet_Content_Tags__c icTag;
            for(Tags__c tag : [SELECT Id FROM Tags__c WHERE Tag__c = :parentName]){
                icTag = new Intranet_Content_Tags__c(Intranet_Content__c = intranetContent.Id
                                                   , Tags__c = tag.Id);
            }
            insert icTag;
        }

        if(String.isNotBlank(clonedId)){
            List<Intranet_Content_Tags__c> icTags = new List<Intranet_Content_Tags__c>();
            for(Intranet_Content_Tags__c tag : [SELECT Tags__c
                               FROM Intranet_Content_Tags__c
                               WHERE Intranet_Content__c = :clonedId]){
                icTags.add(new Intranet_Content_Tags__c(Intranet_Content__c = intranetContent.Id
                                                      , Tags__c = tag.Tags__c));
            }
            insert icTags;
        }
        
        return new Pagereference('/' + intranetContent.Id);
     }catch(DmlException e){
        intranetContent.addError(e.getDmlMessage(0));
        return null;
     }
    }
    
    //This function will cancel the action and redirect to Intranet Content list view
    public Pagereference cancel(){
        return new Pagereference('/' + Intranet_Content__c.sObjectType.getDescribe().getKeyPrefix());
    }
}