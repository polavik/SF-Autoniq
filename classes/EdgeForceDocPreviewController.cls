public with sharing class EdgeForceDocPreviewController {
	public ContentVersion versionDataforUI {get;set;}
	public Id resourceIdInController {get;set;}
	public String allowedPreviewFormats {get;set;}
    // Mobile stuff
	public Boolean isMobile   {get;set;}
    public String buttonLabel {get; set;}
    public String descOne     {get; set;}
    public String baseURL     {get; set;}

	public EdgeForceDocPreviewController() {
        // Set base URL.
        baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        // check for mobile.
        if(null == ApexPages.currentPage().getParameters().get('hideHeaders') || '' == ApexPages.currentPage().getParameters().get('hideHeaders')) {
        	// NOT Mobile!
        	isMobile    = false;
            buttonLabel = 'Download';
            descOne     = 'Please download to view full size.'; 
        }
        else{
        	// Mobile!
        	 isMobile    = true;
        	 buttonLabel = 'Open';
        	 descOne     = 'Open in external window to see full document.';
        	 baseURL = 'openexternal://' + baseURL;
        }

        
		allowedPreviewFormats = '';
		versionDataforUI = new ContentVersion();
    for(Intranet_content__c config : [SELECT Name, Value__c 
                                      FROM Intranet_Content__c 
                                      WHERE RecordType.Name = 'Config - Portal'
                                      AND Name LIKE 'Allowed Preview Formats']) {
      if(allowedPreviewFormats == ''){
        allowedPreviewFormats = config.Value__c;
      } else {
        allowedPreviewFormats += ',' + config.Value__c;
      }
    }
	}

// 12-6-16 lines 32-27 of EF_DocPreview.component are commented out.
// As far as I can see, that was the only place this code was called, so this code is dead.
// This means, though, that VersionDataForUI will always be blank, but that field is used in 16 places inside EF_DocPreview.component.
  public void processContent(){
  	String queryString = 'Select OwnerId, ContentUrl, Title ,IsLatest, ContentDocument.ParentId, TagCsv '+
  												',ContentDocumentId, Id, Team_Category__c,FileType FROM ContentVersion WHERE ';
  	if(resourceIdInController.getSObjectType().getDescribe().getName() == 'ContentDocument'){
  		queryString += 'ContentDocument.';
  	}
  	queryString += 'Id = :resourceIdInController LIMIT 1';
  	System.debug('###queryString='+queryString);
    versionDataforUI = database.query(queryString);
	}
}