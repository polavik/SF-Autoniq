/*
*@purpose : Controller for IntranetChatterFileSearch
*/
public  class EdgeForceIntranetChtFileSearchController {
    public List<contentVersion> listoffiles {get;set;}
    public String searchInputinController {get;set;}
    public Boolean allResults {get;set;}
    
    private Integer resultLimit;
    private Set<String> setoffileId;
    private String searchString;

    public EdgeForceIntranetChtFileSearchController () {
        clear();
        resultLimit  = 10;
        //processfileSearch();
    }
    
    public void clear(){
        listoffiles = new  List<contentVersion>();
        setoffileId = new  Set<String>();
        allResults = true;
    }
    
    public void processfileSearch(){
        clear();
        String urlInput = apexpages.currentPage().getParameters().get('searchInput');
        if((urlInput <> null && urlInput <> '') || (searchInputinController <> null && searchInputinController <> '')){
            searchString = searchInputinController <> null ? searchInputinController : urlInput;
            if(searchString.length()>=2){
                String fileSearchInput = searchString+'%';
                String query = 'SELECT Title, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, FileType, Id FROM ContentVersion WHERE (Title LIKE :fileSearchInput) LIMIT '+resultLimit;
                List<ContentVersion> files = database.query(query);
                // Edit by Joe Castro (Appirio) 27-MAR-2017 to remove unauthorized records from search results
                EF_SearchUtilities.RemoveUnauthorizedFromList(files);
                for(contentVersion chatterfile : files){
                    if(chatterfile <> null){
                        listoffiles.add(chatterfile);
                        setoffileId.add(chatterfile.id);
                    }                 
                }
                allResults = (setoffileId.size() < resultLimit);        
            }else{
                clear();
            }
        }
    }   
    
    public void processfilesSearchMore(){
        if(searchString <> null && searchString <> ''){
            if(searchString.length()>=2){
                String fileSearchInput = searchString+'%';
                String query = 'SELECT Title, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, FileType, Id FROM ContentVersion WHERE (Title LIKE :fileSearchInput) AND Id NOT IN :setoffileId LIMIT '+resultLimit;
                Integer i = 0;
                List<ContentVersion> files = database.query(query);
                // Edit by Joe Castro (Appirio) 27-MAR-2017 to remove unauthorized records from search results
                EF_SearchUtilities.RemoveUnauthorizedFromList(files);
                for(ContentVersion chatterfile : files){
                    if(chatterfile <> null){
                        i++;
                        listoffiles.add(chatterfile);
                        setoffileId.add(chatterfile.id);
                    }         
                }
                allResults = (i < resultLimit);        
            }else{
                clear();
            }
        }
    }  
}