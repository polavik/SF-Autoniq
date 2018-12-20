/**
  * Apex Class: KAR_BusinessUnitComponentController
  * Description: Navigation component for KAR Business Unit Pages
  * Created By: Matt Salpietro
  * Created Date: 11 Jan, 2016
*/
public class KAR_BusinessUnitComponentController{
  public String pageId {get;set;}{pageId='Home';}
  public transient List<EdgeForceIntranetContentController.ContentVersionWrapper> intranetList {get;set;}
  public static final String RECORDTYPE_BUSINESS_UNIT = 'Business Unit Pages';

  public KAR_BusinessUnitComponentController() {
    intranetList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    for(EdgeForceIntranetContentController.ContentVersionWrapper temp : getAllLinksDetails()){
      if(temp.content.URL__c == null){
        if(temp.content.Template__c == 'Team'){
          temp.content.URL__c = '/apex/KAR_Team?name=' + EncodingUtil.urlEncode(temp.content.Name, 'UTF-8');
        }else if(temp.content.Template__c == 'Content'){
          temp.content.URL__c = '/apex/KAR_Content?id=' + temp.content.Id + '&category=Content';
        }else if(temp.content.Template__c == 'Content No Sidebar'){
          temp.content.URL__c = '/apex/KAR_ContentNoSidebar?id=' + temp.content.Id + '&category=Content';
        }else if(temp.content.Template__c == 'Content Full'){
          temp.content.URL__c = '/apex/KAR_Content_Full?id=' + temp.content.Id + '&name=' + EncodingUtil.urlEncode(temp.content.Name, 'UTF-8') + '&category=Content';
        }
      }
      intranetList.add(temp);
    }
  }

  public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllLinksDetails(){
    List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    String queryString = 'SELECT Name, Id, URL__c, Target__c, Template__c FROM Intranet_Content__c WHERE RecordType.Name = \''+RECORDTYPE_BUSINESS_UNIT+'\' ORDER BY Sequence__c ASC';
    EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
    tempListofLocalContentVersionWrapper = contentController.processContentAndVersionMenu(queryString);
    for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                       WHERE RecordType.Name = :RECORDTYPE_BUSINESS_UNIT
                                       ORDER BY Sequence__c ASC]){
      for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)   {
        if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
          listofLocalContentVersionWrapper.add(wrapper);
        }
      }
    }
    return listofLocalContentVersionWrapper;
  }

}