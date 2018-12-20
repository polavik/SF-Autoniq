public class EdgeForceVideoGalleryController {
    
    private static final Integer ITEM_PER_ROW = 3;
    private static final String INTRANET_VIDEO_GALLERY_RECORDTYPE = 'Video Gallery';
    public Intranet_Content__c currentRecord {get; set;}
    public String orderByField {
        get{
            if(orderByField == null){
                orderByField = 'CreatedDate';
            }
            return orderByField;
        } 
        set;
    }
    
    public Integer userVideoCount {
        get{
            if(userVideoCount == null || userVideoCount == 0){
            	userVideoCount = 0;
                List<Intranet_Content__c> iContList = [SELECT Id FROM Intranet_Content__c WHERE RecordType.Name =:INTRANET_VIDEO_GALLERY_RECORDTYPE AND CreatedById =:user.Id];
                if(iContList != null){
                    userVideoCount = iContList.size();
                }
            }
            return userVideoCount;
        }
        set;
    }
    
    public Boolean isFilteredByAuthor {get; set;}
    public User user{get; set;}
    
    public ApexPages.StandardSetController setOfContent {get; set;}
    
    public List<SelectOption> listOfOrderingFields {
        get{
            if(listOfOrderingFields == null){
                listOfOrderingFields = new List<SelectOption>();
                listOfOrderingFields.add(new SelectOption('CreatedDate', 'CreatedDate'));
                listOfOrderingFields.add(new SelectOption('Name', 'Name'));
            }
            return listOfOrderingFields;
        }
        private set;
    }
    
    public String pageSize{
        get{
            if(String.isBlank(pageSize)){
                pageSize = '3';
            }
            return pageSize;
        }
        set{
            setOfContent.setPageSize(Integer.valueOf(value));
            pageSize = value;
        }
    }
    
    public Boolean hasNext{get{ return setOfContent.getHasNext();} set;}
    public Boolean hasPrevious{ get{ return setOfContent.getHasPrevious();} set;}
    
    public List<SelectOption> listOfPageSizes{
        get{
            if(listOfPageSizes == null){
                listOfPageSizes = new List<SelectOption>();
                listOfPageSizes.add(new SelectOption('3', '3'));
                listOfPageSizes.add(new SelectOption('6', '6'));
                listOfPageSizes.add(new SelectOption('10', '10'));
                listOfPageSizes.add(new SelectOption('20', '20'));
            }
            return listOfPageSizes;
        }
        set;
    }
    
    //list of Intranet Content of record type Video Gallery
    public List<List<Intranet_Content__c>> listOfVideoContent {get; set;}
    
    //CONSTRUCTOR
    public EdgeForceVideoGalleryController(){
        String uId = ApexPages.currentPage().getParameters().get('uid');
        if(String.isBlank(uId)){
            uId = UserInfo.getUserId();
            isFilteredByAuthor = false;
        }else{
            isFilteredByAuthor = true;
        }
        for(User u : [Select Id, Name From User WHERE Id = :uId LIMIT 1]){
            user = u;
        }   
        fetchData();
    }
    
    public void fetchData(){
        String queryString = 'SELECT Id, Name, Video__c, Video_Type__c, CreatedDate, Video_Caption__c, CreatedById FROM Intranet_Content__c WHERE RecordType.Name = \''+INTRANET_VIDEO_GALLERY_RECORDTYPE+'\' ';
        if(isFilteredByAuthor){
        	queryString += ' AND CreatedById = \''+user.Id+'\' ';
        }
        queryString += ' ORDER BY '+orderByField+'';
        setOfContent = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
        
        //getting current record
        String recordId = ApexPages.currentPage().getParameters().get('id');
        if(String.isNotBlank(recordId)){
            for(Intranet_Content__c currentCont : [SELECT Id, Name, Video__c, Video_Type__c, CreatedDate, Video_Caption__c, CreatedById FROM Intranet_Content__c WHERE Id=:recordId LIMIT 1]){
            	currentRecord = currentCont; 
            }
        }
        
        setOfContent.setPageSize(Integer.valueOf(pageSize));
        hasNext = setOfContent.getHasNext();
        hasPrevious = setOfContent.getHasPrevious();
        listOfVideoContent = retrieveIntranetContent(setOfContent);
    }
    
    public void goToNextPage(){
        setOfContent.next();
        listOfVideoContent = retrieveIntranetContent(setOfContent);
    }
    
    public void goToPreviousPage(){
        setOfContent.previous();
        listOfVideoContent = retrieveIntranetContent(setOfContent);
    }
    
    /**
    @author Manish
    @purpose get list of all the intranet contrent records
    @param String, String (recordId of Intranet Content ,Order By field)
    @return List<Intranet_Content__c>
    */
    public List<List<Intranet_Content__c>> retrieveIntranetContent(ApexPages.StandardSetController setOfContent){
        String recordId = ApexPages.currentPage().getParameters().get('id');
        Integer rCount=0;
        
        List<List<Intranet_Content__c>> resultList = new List<List<Intranet_Content__c>>();
        List<Intranet_Content__c> localList = new List<Intranet_Content__c>();
        
        for(Intranet_Content__c iContent : (List<Intranet_Content__c>)setOfContent.getRecords()){
            
            if(currentRecord == null){
                currentRecord = iContent;
            }
            
            if(Math.mod(rCount, ITEM_PER_ROW) == 0){
                localList = new List<Intranet_Content__c>();
                resultList.add(localList);
            }
            
            localList.add(iContent);
            rCount++;
        }
        return resultList;
    }
}