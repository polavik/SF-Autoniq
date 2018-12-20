/* ************************
class:   BrandsLandingController
purpose: provides support code for the BrandsLanding VF page.
author:  Jim Cook
Date:    9-14-2016
Comments:
1. The BrandsLanding page has two sections which display lists 
   of brands in different groupins and styles. The code creates
   these groupings so they can be displayed easily.

*************************** */

public with sharing class BrandsLandingController {

   public String chosenView {get; set;}
   public List<EdgeForceIntranetContentController.ContentVersionWrapper> brands {get; set;}
   public List<EdgeForceIntranetContentController.ContentVersionWrapper> homePageInfo {get; set;}
   public String jcMsg {get; set;}
   // This is a list that "buckets" brands based on alphabetic groupings.
   public List<BrandsWrapper> brandsForList {get; set;}
   // This is a list that "buckets" brands based on remarketing categories.
   public List<BrandsWrapper> brandsForRemarket {get; set;}   
   // This is a special bucket of holding all brands. It's needed for the UI.
   public BrandsWrapper allBrands {get; set;}
   public List<PairedBrands> pbs  {get; set;}
   public Integer bannerFileLoc   {get; set;}
   public Integer visionFileLoc   {get; set;}
   public Integer bListFileLoc    {get; set;}
   public Integer remarketFileLoc {get; set;}
   public List<EdgeForceIntranetContentController.ContentVersionWrapper> visionData {get; set;}
   
   // Buckets for list page
   List<String> buckets = new List<String> {'ABCD', 'EFGH', 'IJKL', 'MNOP', 'QRST', 'UVWXYZ'};

   public BrandsLandingController() {
      try{
        chosenView = ApexPages.currentPage().getParameters().get('view');
        if(null == chosenView || '' == chosenView)chosenView='brandshome';
      }
      catch(Exception e){chosenView='brandshome';}
      homePageInfo = getLandingPageInfo();
      brands = getBrandList();
      brandsForList = getBucketedBrands(brands);
      brandsForRemarket = getCategorizedBrands(brands);
      visionData = getVisionData();
   }

   public List<EdgeForceIntranetContentController.ContentVersionWrapper> getLandingPageInfo() {
        List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        List<EdgeForceIntranetContentController.ContentVersionWrapper> resultList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    
    
      String queryString =  'Select Id, Name, Description__c, Title__c, Team_Mission_Statement__c, Brand_Lifecycle_Category__c, Target__c,Frame_Height__c, ' + 
                                    'Banner_Image_File_Name__c, Brands_List_Image_File_Name__c, Remarketing_Lifecycle_Image_File_Name__c, Vision_and_Strategy_Image_File_Name__c, ' +
                                    '(SELECT Id, Name FROM Attachments order by Name)' +
                                    'From Intranet_Content__c  '  + 
                                    'WHERE Status__c=\'Published\' ' +
                                    'AND RecordType.Name =\'Brand Landing RT\'  order by Name';
      EdgeForceIntranetContentController versionHandler = new EdgeForceIntranetContentController();
      tempList = versionHandler.processContentAndVersionMenu(queryString);
      jcMsg = String.valueOf(tempList.size());
      
        for(Intranet_Content__c bList : [Select Id From Intranet_Content__c 
                                         WHERE Status__c='Published' 
                                         AND RecordType.Name ='Brand Landing RT' 
                                         order by Name])
        {        
           for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempList) {
             if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(bList.Id).substring(0,15)){
                resultList.add(wrapper);
             }
           }
        }
        Integer counter = 0;
       if(resultList.size()>0){
        for( Attachment att : resultList[0].content.Attachments) {
           if( att.Name == resultList[0].content.Banner_Image_File_Name__c               ) bannerFileLoc   = counter;
           if( att.Name == resultList[0].content.Brands_List_Image_File_Name__c          ) bListFileLoc    = counter;
           if( att.Name == resultList[0].content.Remarketing_Lifecycle_Image_File_Name__c) remarketFileLoc = counter;
           if( att.Name == resultList[0].content.Vision_and_Strategy_Image_file_Name__c  ) visionFileLoc   = counter;
           counter++;       
        }
       }

        
      return resultList;    
   }

  
   // Retrieve list of brands to display in dropdown.   
   public List<EdgeForceIntranetContentController.ContentVersionWrapper> getBrandList() {
        List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        List<EdgeForceIntranetContentController.ContentVersionWrapper> resultList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    
    
      String queryString =  'Select Id, Name, Description__c, Team_Mission_Statement__c, Brand_Lifecycle_Category__c, ' + 
                                    'Lifecycle_Flipcard_Image__c,Team_Brand_Image_File_Name__c, Target__c,Frame_Height__c,' + 
                                    '(SELECT Id, Name FROM Attachments order by Name)' +
                                    'From Intranet_Content__c  '  + 
                                    'WHERE Status__c=\'Published\' ' +
                                    'AND RecordType.Name =\'Team Page RT\' AND Page_Type__c=\'Brand\' order by Name';
      EdgeForceIntranetContentController versionHandler = new EdgeForceIntranetContentController();
      tempList = versionHandler.processContentAndVersionMenu(queryString);
      jcMsg = String.valueOf(tempList.size());
      
        for(Intranet_Content__c bList : [Select Id From Intranet_Content__c 
                                         WHERE Status__c='Published' 
                                         AND RecordType.Name ='Team Page RT' 
                                         AND Page_Type__c='Brand' 
                                         order by Name])
        { 
           Integer attachCount = 0;       
           for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempList) {
              attachCount = 0;
                    for( Attachment att : wrapper.content.Attachments) {
                       if( att.Name == wrapper.content.Team_Brand_Image_File_Name__c) wrapper.baseImageLocation = attachCount;                       
                       attachCount++;
                    } 
             if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(bList.Id).substring(0,15)){
                resultList.add(wrapper);
             }
           }
        }
        
      return resultList;
    }
    
    // This method makes a list of brands and sorts them by the categories in the variable buckets.
    List<BrandsWrapper> getCategorizedBrands(List<EdgeForceIntranetContentController.ContentVersionWrapper> startingList) {
       // Get the categories, by reading the picklist values.
       List <String> cats = getCategories();
       
       // This is what the method will return.
       List<BrandsWrapper> resultList = new List<BrandsWrapper>();
       // Set up the categories.
       for(String currentCat : cats) {
          resultList.add(new BrandsWrapper(currentCat));
       }
       
       // Loop through the brands and drop them in the correct categories.
       Integer attachCount = 0;
       // Outermost loop is our list of brands.
       for(EdgeForceIntranetContentController.ContentVersionWrapper cItem : startingList) {
           system.debug('===startingList' +startingList);
          // This loop handles the categories that need brands added to them.
          for(Integer counter=0; counter < resultList.size(); counter++) {
             // [NBRUHN 10/25] Added below 1 line
              if (cItem.content.Brand_Lifecycle_Category__c != null){
                  if(cItem.content.Brand_Lifecycle_Category__c.containsIgnoreCase(resultList[counter].rawLabel)) {
                    System.debug('ZZZZZ0 name=' + cItem.content.Name);
                    if( resultList[counter].pb.size() == 0) {
                        System.debug('ZZZZZA');
                        resultList[counter].pb.add(new PairedBrands());
                        resultList[counter].pb[0].LHS = cItem;
                        attachCount = 0;
                        for( Attachment att : resultList[counter].pb[0].LHS.content.Attachments) {
                           System.debug('XYZ =>1 seeking ' + att.Name + ' comp to ' + cItem.content.Name + ' ' + cItem.content.Team_Brand_Image_File_Name__c);
                           if( att.Name == resultList[counter].pb[0].LHS.content.Lifecycle_Flipcard_Image__c)   resultList[counter].pb[0].lhsFlipCardFrontLoc = attachCount;
                           if( att.Name == resultList[counter].pb[0].LHS.content.Team_Brand_Image_File_Name__c) resultList[counter].pb[0].lhsFlipCardLoc      = attachCount;                       
                           attachCount++;
                        } 
                    }
                    // Check to see if the latest pair in the list has a RHS element or not.
                    else if(resultList[counter].pb[resultList[counter].pb.size()-1].getCount() == 1) {
                        System.debug('ZZZZZB counter=' + counter  + ' -> ' + resultList[counter].pb[resultList[counter].pb.size()-1].getCount());
                        resultList[counter].pb[resultList[counter].pb.size()-1].RHS = cItem;
                        attachCount = 0;
                        for( Attachment att : resultList[counter].pb[resultList[counter].pb.size()-1].RHS.content.Attachments) {
                           System.debug('XYZ =>2 seeking ' + att.Name + ' comp to ' + cItem.content.Team_Brand_Image_File_Name__c);
                           if( att.Name == resultList[counter].pb[resultList[counter].pb.size()-1].RHS.content.Lifecycle_Flipcard_Image__c)   resultList[counter].pb[resultList[counter].pb.size()-1].rhsFlipCardFrontLoc = attachCount;
                           if( att.Name == resultList[counter].pb[resultList[counter].pb.size()-1].RHS.content.Team_Brand_Image_File_Name__c) resultList[counter].pb[resultList[counter].pb.size()-1].rhsFlipCardLoc      = attachCount;                       
                           attachCount++;
                        }      
                    }
                    else {
                        System.debug('ZZZZZC counter=' + counter  + ' -> ' + resultList[counter].pb[resultList[counter].pb.size()-1].getCount());
                        resultList[counter].pb.add(new PairedBrands());
                        resultList[counter].pb[resultList[counter].pb.size()-1].LHS = cItem;
                        attachCount = 0;
                        for( Attachment att : resultList[counter].pb[resultList[counter].pb.size()-1].LHS.content.Attachments) {
                           if( att.Name == resultList[counter].pb[resultList[counter].pb.size()-1].LHS.content.Lifecycle_Flipcard_Image__c)   resultList[counter].pb[resultList[counter].pb.size()-1].lhsFlipCardFrontLoc = attachCount;
                           if( att.Name == resultList[counter].pb[resultList[counter].pb.size()-1].LHS.content.Team_Brand_Image_File_Name__c) resultList[counter].pb[resultList[counter].pb.size()-1].lhsFlipCardLoc      = attachCount;                       
                           attachCount++;
                        }      
                        
                    }
                 }
             // [NBRUHN 10/15] Added below 1 line
             }
          }
       }

       // a little check that things worked out.       
//       for(BrandsWrapper bw : resultList){
//            System.debug('XXXXX ' + bw.getLabel() + ' ' + bw.getCount());
//       }
       
       return resultList;
    } 
    
    // This method makes a list of brands and sorts them by the categories in the variable buckets.
    // It also creates an allBrands list, that holds everything.
    List<BrandsWrapper> getBucketedBrands(List<EdgeForceIntranetContentController.ContentVersionWrapper> startingList) {
       allBrands = new BrandsWrapper('All');
       List<BrandsWrapper> resultList = new List<BrandsWrapper>();
       
       // Set up all the buckets: a default "All" bucket, and  whatever's listed in buckets, above.
       for(String bucketName : buckets) {
          resultList.add(new BrandsWrapper(bucketName));
       }
       
       // Loop through the brands and drop them in the correct buckets.
       for(EdgeForceIntranetContentController.ContentVersionWrapper cItem : startingList) {
          allBrands.brands.add(cItem);
          for(Integer counter=0; counter < resultList.size(); counter++) {
             if(resultList[counter].initials.containsIgnoreCase(cItem.content.Name.substring(0,1))) {
                resultList[counter].brands.add(cItem);
             }
          }
       }

       // a little check that things worked out.       
//       for(BrandsWrapper bw : resultList){
//            System.debug('XXXXX ' + bw.getLabel() + ' ' + bw.getCount());
//       }
       
       return resultList;
    }        
    
   public class BrandsWrapper {
      // Although initials is a String think of it as a character array.
      // The name of each brand listed in any instance of BrandsWrapper should have on
      // of the entries in initials as the first character of it's name.
      public String initials {get; set;}
      public String rawLabel {get; set;}
      public String rawLabelNoSpaces {get; set;}
      
      // List of (wrapped) brands.
      public List<EdgeForceIntranetContentController.ContentVersionWrapper> brands {get; set;}
      // The following item is used only for the Remarketing Lifecycle view.
      public List<PairedBrands> pb {get; set;}

      // default constructor. Not used. 
      public BrandsWrapper(){
         initials='';
         rawLabel='';
         rawLabelNoSpaces = '';
         brands = new List<EdgeForceIntranetContentController.ContentVersionWrapper>(); 
         pb = new List<PairedBrands>(); 
      }
      
      // common constructor. 
      public BrandsWrapper(String inits) {
         initials = inits;
         rawLabel = inits;
         rawLabelNoSpaces =rawLabel.replace(' ', '');
         brands = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
         pb = new List<PairedBrands>();         
      }
    
      // return the number of brands stored.
      public Integer getCount() {
         try{ return brands.size();}catch(Exception e){}
         return 0;
      }
      
      // Return count of items in PairedBrands child object. 
      // Used for Remarketing Lifecycle view.
      public Integer getPairedCount() {
        Integer result = 0;
        for(PairedBrands x : pb) {
            if(null != x.LHS) result++;
            if(null != x.RHS) result++;
        }
        return result;
      }
      
      // Return the first and last letter of initials, separated by a dash. Used in the UI.
      public String getLabel() {
        try{
            if(null != initials) return initials.substring(0,1) + '-'+initials.substring(initials.length()-1,initials.length());
        } catch(Exception e){}
        return 'no label';
      }

      // Return the full label. Used in the UI.
      public String getRawLabel() {
        try{
            if(null != rawLabel) return rawLabel;
        } catch(Exception e){}
        return 'no label';
      }

      
      // returns the name of the first brand in the list.
      public String getFirstName() {
        try{return brands[0].content.name;}catch(Exception e){}
        return 'no name';
      }
      
   }    
    
   public class PairedBrands {
    public Integer lhsFlipCardLoc {get; set;}
    public Integer rhsFlipCardLoc {get; set;}
    public Integer lhsFlipCardFrontLoc {get; set;}
    public Integer rhsFlipCardFrontLoc {get; set;}    
    public EdgeForceIntranetContentController.ContentVersionWrapper LHS {get; set;}
    public EdgeForceIntranetContentController.ContentVersionWrapper RHS {get; set;}
    
    public PairedBrands(){}
    
    public Integer getCount() {
        if(null == LHS && null == RHS) return 0;
        if(null != LHS && null != RHS) return 2;
        return 1;
    }       
   }    
   
    public List<String> getCategories() {
       List<String>results = new List<String>();
        
       Schema.DescribeFieldResult fieldResult = Intranet_Content__c.Brand_Lifecycle_Category__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
       for( Schema.PicklistEntry f : ple) {
          results.add(f.getValue());
          System.debug('PICKLIST VALUE ' + f.getValue());
       }       
   return results;
}    

   public List<EdgeForceIntranetContentController.ContentVersionWrapper> getVisionData() {
	       // Versioning
        List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        String queryString = 'SELECT Name, Id, URL__c, Target__c, Template__c, Team_Brand_Image_File_Name__c,' + 
                                     'Content_Type__c, Language__c, Team_Mission_Statement__c, Title__c,Frame_Height__c, ' +
                                     'Show_Sub_Team__c, Sub_Team_Sequence__c, ' +
                                     'Show_Meet_The_Team__c, Meet_The_Team_Sequence__c, ' +
                                     'Show_About_The_Team__c, About_The_Team_Sequence__c, ' +
                                     'Show_News__c, News_Sequence__c, ' +
                                     'Show_Calendar__c, Calendar_Sequence__c, ' +
                                     'Show_Chatter_Feed__c, Chatter_Feed_Sequence__c, ' +
                                     'Show_Collapsible_Content__c, Collapsible_Content_Sequence__c, ' +
                                     'Show_News_Banner__c, News_Banner_Sequence__c, ' +
                                     'Show_Resource_Library__c, Resource_Library_Sequence__c, ' +
                                     'Content_Bucket__c, Overlay_Color__c, ' + 
                                     '(SELECT Id, Name FROM Attachments order by Name) ' +
                             'FROM Intranet_Content__c ' + 
                             'WHERE Name = \'Vision and Strategy\' AND RecordType.Name = \'Team Page RT\' ORDER BY Sequence__c ASC';
        EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
        tempListofLocalContentVersionWrapper = contentController.processContentAndVersionMenu(queryString);
          
        for(Intranet_Content__C teamContent : [SELECT Id, Page_Type__c
                                               FROM Intranet_Content__c
                                               WHERE Name = 'Vision and Strategy'
                                               AND RecordType.Name = 'Team Page RT' 
                                               ORDER BY Sequence__c ASC
                                              ])
        {        
           for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper) {
             if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(teamContent.Id).substring(0,15)){
                listofLocalContentVersionWrapper.add(wrapper);
             }
           }
		}
      return listofLocalContentVersionWrapper;
   }

}