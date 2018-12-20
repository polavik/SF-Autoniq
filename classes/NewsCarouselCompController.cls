/**
  * Apex Class: NewsCarouselCompController
  * Description: This class is used to display news items in a rotating carousel.
  * Created By:Jim Cook
  * Created Date: Sep 18, 2016
*/
public with sharing class NewsCarouselCompController {

    DateTime todayDate = DateTime.now();
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> banners {get;set;}
    public Integer banner_Roating_Speed {get;set;}
    public List<Integer> bannerCounter {get; set;}

    public NewsCarouselCompController() {
      banners = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
      banner_Roating_Speed = 10000;
      //Retrieve Banner rotating speed
      for(Intranet_Content__c qLinks : [Select Name, value__c From Intranet_Content__c where Name = 'Banner_Rotating_Speed' AND recordType.Name = 'Config - Portal' ]) {
      banner_Roating_Speed = Integer.valueOf(qLinks.Value__c);
      }

  	  String pageName;
  	  try{pageName = ApexPages.currentPage().getParameters().get('name');}
  	  catch(Exception e){}
  	  if(null == pageName) pageName = 'Home';

      List<String> resultFields = new List<String>();
      resultFields.add('URL__c');
      resultFields.add('Name');
      resultFields.add('Title__c');
      resultFields.add('Description__c');
      resultFields.add('Target__c');
      resultFields.add('Target_URL__c');
      resultFields.add('Position__c');
      resultFields.add('Button_Location__c');
      resultFields.add('Summary_Color__c');
      resultFields.add('Header_Color__c');
      resultFields.add('Frame_Height__c');

      List<String> tags = new List<String>();
      tags.add(pageName);
      String rtName = EdgeForceIntranetContentController.RECORDTYPE_INTERNET_BANNER;
      banners = TagUtilities.getVersionedContentByTags(resultFields, tags,  rtName);
      system.debug('JCJCJC banners: ' + banners.size() + ' ' + pageName);
      bannerCounter = new List<Integer>();

      // set carouselImageLink for each banner.
      String innerLinkStyle = '';
      String innerLinkHref='';
      String buttonLabel='';
      String dynamicButtonText = '';
      for(Integer i=0; i< banners.size(); i++) {
         	banners[i].carouselImageLinkOpen  = '';
         	banners[i].carouselImageLinkClose = '';
          
         	// Set up inner (Read More) link.
         	// Check for dynamic (button shows on mouseover), or static (button shows all the time).
			dynamicButtonText = '';
         	if(null == banners[i].content.Button_Location__c || '' == banners[i].content.Button_Location__c)
         	   dynamicButtonText = 'class="floating-read-more"  ';

         	// Set Style
         	if(null != banners[i].content .Header_Color__c) {
         		innerLinkStyle = 'style="color:' + banners[i].content.Header_Color__c + ';"';
         	    if(null == banners[i].content.Button_Location__c || '' == banners[i].content.Button_Location__c)
         	       innerLinkStyle = 'style="color:' + banners[i].content.Header_Color__c + ';"';
         	}
         	else {
         	   if(null == banners[i].content.Button_Location__c || '' == banners[i].content.Button_Location__c)
         	      innerLinkStyle = 'class="fixed-read-more"';
         	   else
         	      innerLinkStyle='';
         	}

         	//set target
         	//system.assert(false, banners[3].content.Target__c);
         		if(banners[i].content.Target__c.contains('blank'))
         		innerLinkStyle='target= "_blank" data-target="_blank"';
         		else if(banners[i].content.Target__c.contains('self'))
         		innerLinkStyle='target= "_self" data-target="_self"';

         	// Set href
         	if(banners[i].content.Target__c.contains('Frame'))
         		innerLinkHref='href="/apex/KAR_Frame?url='+ banners[i].contentVersionForDisplay.URL__c  + '&height=' + banners[i].content.Frame_Height__c +'" ';
         	else if(banners[i].contentVersionForDisplay.URL__c.contains('http'))
         	    innerLinkHref='href="'+ banners[i].contentVersionForDisplay.URL__c  +'" ';
         	else
         	    innerLinkHref='href="https://'+ banners[i].contentVersionForDisplay.URL__c  +'" ';

         	// Set the text on the button.
         	if(null == banners[i].contentVersionForDisplay.Button_Label__c) buttonLabel='';
         	else buttonLabel=banners[i].contentVersionForDisplay.Button_Label__c;

         	// Build the complete inner link.
         	banners[i].carouselInnerLink = '<span ' + dynamicButtonText + '>' +
         	   '<a class="read-more dynamic-target" ' +
         	   innerLinkStyle + ' ' +
         	   innerLinkHref +  ' >' +
         	   buttonLabel + '</a></span>';
      }

      try{if(null == banners[0].content.Attachments[0].Id) banners[0].content.Attachments[0].Id = '0';}
      catch(Exception e){}
      for(Integer i=1; i< banners.size(); i++) {
      	try{
      		if(null == banners[i].content.Attachments[0].Id) banners[i].content.Attachments[0].Id = '0';
      	}
      	catch(Exception e){}
      	bannerCounter.add(i);
      }
//      System.debug('JCCOUNT ' + banners.size());
//      for(EdgeForceIntranetContentController.ContentVersionWrapper x : banners) System.debug('JCRESULT ' + x.content.name);
    }
}