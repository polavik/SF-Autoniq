/* ************************************************************
   copyright (c) Appirio Inc. 2017
 
   original author/creation date unknown.
   purpose: to pass Salesforce Content documents to Edgeforce.
 
*************************************************************** */
public with sharing class EdgeforceDocumentDirectoryController{
  public List<ContentVersion> contents {get;set;}
  public List<String> librariesMap {get;set;}
  public String libraryName {get;set;}
  public static final string NAME_PRAM = 'name';
  public User currentUser {get; set;}
  public String selectedLib {get; set;}
  public Map<String,ContentVersion> mapofversionIdandVersion;
  /*
  * the default constructor fetches library contents that will be used in pages which use the resource component.
  */
  public EdgeforceDocumentDirectoryController() {   
    librariesMap = new List<String>();

    //Fetch current user   
    for(User u :[SELECT Id, UserPermissionsSFContentUser, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()]){
      currentUser = u;             
    }
    //Return if current user has no permission for access of contents
    if(currentUser.UserPermissionsSFContentUser == false){return;}   

    // Fetch all ContentWorkspaces except *master and build librariesMap.
    for(ContentWorkspace cWD :[SELECT Id, Name 
                               FROM ContentWorkspace
                               WHERE Name !='*master'
                               ORDER BY Name DESC]){
      librariesMap.add(cWD.Name);
    }
    librariesMap.add(Label.All);
    librariesMap.sort();
    
    // Get the desired library name from the incoming url parameters.
    if(!String.isBlank(ApexPages.currentPage().getParameters().get(NAME_PRAM))) 
       libraryName=ApexPages.currentPage().getParameters().get(NAME_PRAM);
    else libraryName=Label.All;

    fetchContents();
  }

  // This method fetches the documents from a specific library.
  Public void fetchContents(){
    Set<ID> contentIDs = new Set<ID>();

    // Build the query to fetch the document IDs and Names.
    String query = 'SELECT ContentDocumentId, ContentWorkspace.Name FROM ContentWorkspaceDoc ';
    if(libraryName != Label.All) {
    	 query += 'WHERE ContentWorkspace.Name = :libraryName ';
         query += 'ORDER BY ContentWorkspace.Name';
    }
    System.debug('QUERY=' + query);
    // Loop through the documents and put their IDs into a list. 
    for(sObject objectR : Database.query(query)) {
       contentIDs.add(String.valueOf(objectR.get('ContentDocumentId')));
    }
System.debug('ABCDEF');
    // Fetch library contents, using the list of IDs from above. Always get only the latest version.
    contents = [SELECT Owner.Name, ContentUrl, Title ,ContentSize, Id, FileType, LastModifiedDate, 
                       Language_Custom__c, ContentDocument.Id, TagCsv 
                FROM ContentVersion 
                WHERE ContentDocument.Id = :contentIDs
                AND IsLatest = true
                ORDER BY Title ASC LIMIT 1000]; 
  }
}