global class UpdateContactHTMLBlock 
{
    public void FetchContacts(List<Contact> ListOfContcts)
    //public void FetchContacts()
{   
     
     List<String> strLocationlist   = new List<String>();
     
     //List<Promotions__c> ListOfPromotionsToUpdate = new List<Promotions__c>() ;
     //List<Promotions__c> LocationPromoObjectList = new List<Promotions__c>() ;
     //List<Promotions__c> MasterLocationPromoObjectList = new List<Promotions__c>() ;
     
     List<Contact> ListOfContactToUpdate = new List<Contact>() ;
     
     Map<String, List <Promotions__c>> PromotionsListMap =  new Map<String, List<Promotions__c>>();
     Map<Id, List <Promotions__c>> ContactWithPromotionsListMap =  new Map<Id, List<Promotions__c>>();
     
     Map<ID, Promotions__c> ContctPromoListMap =  new Map<ID, Promotions__c>();
     
     Map<ID, List<String>> ContactListMap =  new Map<ID, List<String>>();
     Map<ID, List<String>> MasterContactListMap =  new Map<ID, List<String>>();
    
    
    //List<AggregateResult> groupedResults = [select Auction_Title_Reference__c ATR, count(Id) from Promotions__c where   Auction_Title_Reference__c != '' GROUP BY Auction_Title_Reference__c ] ;
      
    for (AggregateResult ar : [select Auction_Title_Reference__c ATR, count(Id) from Promotions__c where   Auction_Title_Reference__c != '' GROUP BY Auction_Title_Reference__c ])
    {
        //String ConstantTitle = LocationPromoObjectList.get(cnt).Auction_Title_Reference__c;
        //System.debug('Campaign ID' + ar.get('ATR'));
        //String locname = '' ;
        
        String locname = (String) ar.get('ATR');
        //System.debug('Location Name ' + locname);
        strLocationlist.add((String) ar.get('ATR'));
        
        //List<Promotions__c> ListOfPromotions = [ select id,Auction_Name__c,Auction_Title_Reference__c,Consignor__c,Expiry_Date__c,Display_Title__c,Date_Range__c,Hypertext_Reference_URL__c,Promotion_ID__c,Promotion_Title__c, Publish_Date__c,Start_Date__c,State_Reference__c from Promotions__c where Auction_Title_Reference__c =: locname ];
        //PromotionsListMap.put(locname,ListOfPromotions);
        
        
    }
        //System.debug('strLocationlist'+strLocationlist);

    for (integer cnt = 0; cnt < strLocationlist.size(); cnt++)
    {
        List<Promotions__c> ListOfPromotions = [ select id,Auction_Name__c,Auction_Title_Reference__c,Consignor__c,Expiry_Date__c,Display_Title__c,Date_Range__c,Hypertext_Reference_URL__c,Promotion_ID__c,Promotion_Title__c, Publish_Date__c,Start_Date__c,State_Reference__c,New__c from Promotions__c where Auction_Title_Reference__c =: strLocationlist.get(cnt) and Expiry_Date__c >= today order by Expiry_Date__c ];
        PromotionsListMap.put(strLocationlist.get(cnt),ListOfPromotions);
        //System.debug('strLocationlist.get(cnt) '+strLocationlist.get(cnt)+ ListOfPromotions ); 
    }
    //System.debug('PromotionsListMap '+PromotionsListMap);

    Contact rcvContact = new Contact();
    
    
    Map<String, Contact> ContactWithLocationMap =  new Map<String, Contact>();
     
    for(Contact cot : ListOfContcts)
    //for(Contact cot : [ select id,Name,Location__c,Consignor__c,ADESA_Dallas__c,ADESA_Atlanta__c,ADESA_Birmingham__c,ADESA_Wisconsin__c from Contact  where Location__c != ''  and Active__c = True and Recordtypeid = '01230000000DEXY' ])
    {
        List<String> strLocationSplit   = new List<String>();
      if(cot.Location__c!=null)
      { 
        strLocationSplit = cot.Location__c.split(';');
        //System.debug('strLocationSplit '+strLocationSplit);   
        List<Promotions__c> ListOfPromotionsPerContact = new List<Promotions__c>() ;
        
        for (integer cnt = 0; cnt < strLocationSplit.size(); cnt++)
        {
        
            
            List<Promotions__c> PromoListOnly = PromotionsListMap.get(strLocationSplit.get(cnt));
            
            //System.debug(cot.Name+' '+strLocationSplit.get(cnt));
            /*
            if (strLocationSplit.get(cnt).equalsIgnorecase('ADESA Cincinnati / Dayton'))
                { System.debug('Found in before calling UpdateHTML Block ADESA Cincinnati / Dayton');}
                */
            if(PromoListOnly != null && PromoListOnly.size() > 0 )
            {
                rcvContact = UpdateHTMLBlock(PromoListOnly,strLocationSplit.get(cnt),cot);
            } else
            {
                /*
                    if (strLocationSplit.get(cnt).equalsIgnorecase('ADESA Cincinnati / Dayton'))
                { System.debug('Promotion are null for ADESA Cincinnati / Dayton');}
                */
             }
            
            
            
        }
        
        ListOfContactToUpdate.add(cot);
      }
        
    }
        //System.debug('PromotionsListMap'+PromotionsListMap.size()+'Size of ListOfContactToUpdate '+ ListOfContactToUpdate.size());
    
    /*
    for(integer ctr = 0; ctr < ListOfContactToUpdate.size(); ctr++)
    {
        
        System.debug('Contact number '+ ctr + ListOfContactToUpdate.get(ctr).ADESA_Dallas__c+ListOfContactToUpdate.get(ctr).ADESA_Atlanta__c+ListOfContactToUpdate.get(ctr).ADESA_Birmingham__c+ListOfContactToUpdate.get(ctr).ADESA_Wisconsin__c); 
    }
    */
        if (ListOfContactToUpdate.size() > 0 && ListOfContactToUpdate.get(0) !=null) {
        UpdateContactCollection(ListOfContactToUpdate);
        }
}   
    public static Contact UpdateHTMLBlock(List<Promotions__c> promoObjList, string LocationName,Contact rcvObjContact)
{   
            //String strLocationlink = ((LocationName.remove('.')).remove(' ')).substringAfter('ADESA') ;
            String strLocationlink =  ((((LocationName.remove('.')).remove(' '))).remove('\'')).substringAfter('ADESA') ;
            String HTMLBlock2 = '';
            String strImageName = LocationName;
            if (LocationName.equalsIgnorecase('ADESA St. Louis')) strImageName='ADESA StLouis';
            if (LocationName.equalsIgnorecase('ADESA Cincinnati / Dayton')) strImageName='ADESA Cincinnati Dayton';
            
          //HTMLBlock2 = '<h2 style="font-family:Trebuchet MS, Arial, Helvetica, sans-serif; font-size:18px; margin-bottom:0;"'+'>'+strLocationlink+' Promotions</h2>'+'<p style='+'"margin-top:0;"'+'><a style='+'"color:#008C99;"'+'href="' + 'http://www.adesa.com/'+strLocationlink+'"'+'>View Auction Info/Schedule</a></p>';
            HTMLBlock2 = '<table width="100%" border="0" cellspacing="0" cellpadding="0" style="font-family: Calibri, Helvetica, Arial, sans-serif;"'+'>';
HTMLBlock2 = HTMLBlock2+ '<tr><td align="left"><h2 style="font-size:20px; margin-bottom:0;color:#333333"'+'>'+LocationName+' Promotions</h2>'+'<p style="margin-top:0;"><a style="color:#008C99; font-size:14px"href="http://www.adesa.com/'+strLocationlink+'"'+'>View Auction Info/Schedule</a></p></td>' + '<td align="right"><img alt="Adesa "'+strLocationlink+' src="http://go.openlane.com/rs/openlane/images/'+strImageName+'.png"'+'/></td>'   + '</tr><tr style="line-height:10px;"> <td>&nbsp;</td>  <td>&nbsp;</td>  </tr> </table>' ;          
//HTMLBlock2 = HTMLBlock2+ '<td align="right"><img alt="Adesa "'+strLocationlink+' src="http://go.openlane.com/rs/openlane/images/'+strImageName+'.png"'+'/></td>'   + '</tr><tr style="line-height:10px;"> <td>&nbsp;</td>  <td>&nbsp;</td>  </tr> </table>';

 
            
            //HTMLBlock2 = '<h2 style="font-family:Trebuchet MS, Arial, Helvetica, sans-serif; font-size:18px; margin-bottom:0;"'+'>'+strLocationlink+' Promotions</h2>'+'<p style='+'"margin-top:0;"'+'><a style='+'"color:#008C99;"'+'href="' + 'http://www.adesa.com/'+strLocationlink+'"'+'>View Auction Info/Schedule</a></p>';            
            
            //'<table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="white">'                      
            HTMLBlock2 = HTMLBlock2 + '<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse; border:1px solid #948671;">  <tr> <td>' + '<table width="100%" border="1" cellpadding="2" cellspacing="0" bordercolor="#FFFFFF" style="font-family: Calibri, Helvetica, Arial, sans-serif; font-size:14px; width:100%; border-collapse:collapse;border:1px solid #FFF;">' +'<tr style="color:#FFF; background:#89806F">'+'<th width="25%">CONSIGNOR</th>'+'<th width="50%">PROMOTION</th>'+'<th width="25%">DATE</th>'+'</tr>';
            //Outer Border            '<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse; border:1px solid #948671;">  <tr> <td>'+              
            
/*          
            HTMLBlock2 = HTMLBlock2 +'<table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="white">';
            HTMLBlock2 = HTMLBlock2 +'<tr>';
            HTMLBlock2 = HTMLBlock2 +'<td width="25%">CONSIGNOR</td>';
            HTMLBlock2 = HTMLBlock2 +'<td width="50%">PROMOTION</td>';
            HTMLBlock2 = HTMLBlock2 +'<td width="25%">DATE</td>';
            HTMLBlock2 = HTMLBlock2 +'</tr>';
*/
            String strConsignor,strPromotionTitle,strExpiryDate,strDisplayTitle,strDateRange,strLink,strSpan ='       ';
            

//String s1 = 'ADESA St. Louis';
//String s2 = 'ADESA Las Vegas';
//String s3 = 'ADESA San Antonio';
//String s5 =    s2.remove('.');
//String s6 =    s5.remove(' ');
//System.debug(s6.substringAfter('ADESA'));

/*      
            String strConsignor ='       ';
            String strPromotionTitle ='       ';
            String strExpiryDate ='       ';
            String strDisplayTitle ='       ';
            String strDateRange = ' ';
            */
if (LocationName.equalsIgnorecase('ADESA Cincinnati/Dayton'))
{ System.debug('Found in Update html code before promotion loop ADESA Cincinnati/Dayton');}
            
         String bkgColour = '#DDD4C5';  
    for (Promotions__c PromoObj : promoObjList)
    {
        if (PromoObj != null) 
        {
            //strConsignor,strPromotionTitle,strExpiryDate,strDisplayTitle,strDateRange ='       ';

            
            strConsignor ='       ';
            strPromotionTitle ='       ';
            strExpiryDate ='       ';
            strDisplayTitle ='       ';
            strDateRange = ' ';
            strLink = ' ';
            strSpan = ' ';

if (LocationName.equalsIgnorecase('ADESA Cincinnati/Dayton'))
{ System.debug('Found in Update html code inside promotion loop ADESA Cincinnati/Dayton');}
            
            if((PromoObj.Hypertext_Reference_URL__c!='') && (PromoObj.Hypertext_Reference_URL__c!=null))
                strLink = PromoObj.Hypertext_Reference_URL__c;
            if((PromoObj.Consignor__c!='') && (PromoObj.Consignor__c!=null))
                strConsignor = PromoObj.Consignor__c;
            if((PromoObj.Promotion_Title__c!='') && (PromoObj.Promotion_Title__c!=null)) 
                strPromotionTitle = PromoObj.Promotion_Title__c;
            if(PromoObj.Expiry_Date__c!=null)
                strExpiryDate = String.valueOf(PromoObj.Expiry_Date__c);
            if(PromoObj.Display_Title__c!=null)
                strDisplayTitle = PromoObj.Display_Title__c;
            if(PromoObj.Date_Range__c!=null)
                strDateRange = PromoObj.Date_Range__c ; 
                //"&nbsp;". 
            if(PromoObj.New__c==True) 
            {   bkgColour = '#FED47C';
                strSpan = '<span style="color:#008C99; font-weight:bold;">*NEW</span>' ;  
                } else { strSpan = '&nbsp;'; } 
                                
            
             //HTMLBlock2 = HTMLBlock2 +'<tr><td width="25%">'+strConsignor+'&nbsp;'+'</td>'+'<td width="50%">'+'<a style="text-decoration:none;color:#008C99;" href="'+strLink+'">'+strDisplayTitle +'&nbsp;' + '</a>'+'</td>'+'<td width="25%">'+strDateRange +'&nbsp;'+'</td>'+'</tr>';
             //HTMLBlock2 = HTMLBlock2 +'<tr style="background-color:'+'#F2EADD'+';"><td width="25%" align="left">'+strConsignor+'&nbsp;'+'</td>'+'<td width="50%" align="left">'+'<a style="color:#413724;" href="'+strLink+'">'+strDisplayTitle +'&nbsp;' + '</a>'+'</td>'+'<td width="25%" align="center">'+strDateRange +'&nbsp;'+'</td>'+'</tr>';
               HTMLBlock2 = HTMLBlock2 +'<tr style="background-color:'+bkgColour+';"><td width="25%" align="left">'+strConsignor+'&nbsp;'+'</td>'+'<td width="50%" align="left">'+'<a style="color:#413724;" href="'+strLink+'">'+strDisplayTitle +'&nbsp;' + '</a>'+strSpan+'</td>'+'<td width="25%" align="center">'+strDateRange +'&nbsp;'+'</td>'+'</tr>';
               //<tr class="alt" style="background-color:#DDD4C5;">
               if(bkgColour == '#DDD4C5') {bkgColour = '#F2EADD';} else {bkgColour = '#DDD4C5';}
                


            
            /*      
            HTMLBlock2 = HTMLBlock2 +'<tr>';
            HTMLBlock2 = HTMLBlock2 +'<td width="25%">';
            HTMLBlock2 = HTMLBlock2 +strConsignor +'</td>';
            HTMLBlock2 = HTMLBlock2 +'<td width="50%">';
            HTMLBlock2 = HTMLBlock2 +strDisplayTitle +'</td>';
            HTMLBlock2 = HTMLBlock2 +'<td width="25%">';
            HTMLBlock2 = HTMLBlock2 +strDateRange +'</td>';
            HTMLBlock2 = HTMLBlock2 +'</tr>';
            */

            
            
            //System.debug('Auction Title Reference_consignor,title,exprity..'+strConsignor+strPromotionTitle+strExpiryDate);
            
        }
     } 
    
    //HTMLBlock2 = HTMLBlock2 +'</table>';
    HTMLBlock2 = HTMLBlock2 +' </table> </td> </tr> ' + '</table>'+'<p>'+'&nbsp;'+'</p>';       

    //Sobject ContactToReturn=new Contact();
    //String filedName='Id';
    //ContactToReturn.put(filedName,ContactId);
    //ContactToReturn.Id = ContactId;
    if (LocationName.equalsIgnorecase('ADESA Dallas'))
                    rcvObjContact.ADESA_Dallas__c = HTMLBlock2;
    
    if (LocationName.equalsIgnorecase('ADESA Atlanta'))
            rcvObjContact.ADESA_Atlanta__c = HTMLBlock2;

    if (LocationName.equalsIgnorecase('ADESA Birmingham'))
            rcvObjContact.ADESA_Birmingham__c = HTMLBlock2;
    
    if (LocationName.equalsIgnorecase('ADESA Wisconsin'))
            rcvObjContact.ADESA_Wisconsin__c = HTMLBlock2;
                
//if (LocationName.equalsIgnorecase('ADESA Atlanta'))  rcvObjContact.ADESA_Atlanta__c=HTMLBlock2;
System.debug('Location Name'+LocationName);

if (LocationName.equalsIgnorecase('ADESA Calgary'))  rcvObjContact.ADESA_Calgary__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Edmonton'))  rcvObjContact.ADESA_Edmonton__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Halifax'))  rcvObjContact.ADESA_Halifax__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Kitchener'))  rcvObjContact.ADESA_Kitchener__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Moncton'))  rcvObjContact.ADESA_Moncton__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Montreal'))  rcvObjContact.ADESA_Montreal__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Ottawa'))  rcvObjContact.ADESA_Ottawa__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Quebec City'))  rcvObjContact.ADESA_Quebec_City__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Richmond'))  rcvObjContact.ADESA_Richmond__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Saskatoon'))  rcvObjContact.ADESA_Saskatoon__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Mercer'))  rcvObjContact.ADESA_Mercer__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA St. John\'s'))  rcvObjContact.ADESA_St_John_s__c=HTMLBlock2;

if (LocationName.equalsIgnorecase('ADESA Toronto'))  rcvObjContact.ADESA_Toronto__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Vancouver'))  rcvObjContact.ADESA_Vancouver__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Winnipeg'))  rcvObjContact.ADESA_Winnipeg__c=HTMLBlock2;


if (LocationName.equalsIgnorecase('ADESA Austin'))  rcvObjContact.ADESA_Austin__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Buffalo'))  rcvObjContact.ADESA_Buffalo__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Boston'))  rcvObjContact.ADESA_Boston__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Charlotte'))  rcvObjContact.ADESA_Charlotte__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Cincinnati / Dayton'))  rcvObjContact.ADESA_Cincinnati__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Cleveland'))  rcvObjContact.ADESA_Cleveland__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Colorado Springs'))  rcvObjContact.ADESA_Colorado_Springs__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Concord'))  rcvObjContact.ADESA_Concord__c=HTMLBlock2;


if (LocationName.equalsIgnorecase('ADESA Des Moines'))  rcvObjContact.ADESA_Des_Moines__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA East Tennessee'))  rcvObjContact.ADESA_East_Tennessee__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Fargo'))  rcvObjContact.ADESA_Fargo__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Golden Gate'))  rcvObjContact.ADESA_Golden_Gate__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Great Lakes'))  rcvObjContact.ADESA_Great_Lakes__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Houston'))  rcvObjContact.ADESA_Houston__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Indianapolis'))  rcvObjContact.ADESA_Indianapolis__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Jacksonville'))  rcvObjContact.ADESA_Jacksonville__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Kansas City'))  rcvObjContact.ADESA_Kansas_City__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Knoxville'))  rcvObjContact.ADESA_Knoxville__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Lansing'))  rcvObjContact.ADESA_Lansing__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Las Vegas'))  rcvObjContact.ADESA_Las_Vegas__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Lexington'))  rcvObjContact.ADESA_Lexington__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Little Rock'))  rcvObjContact.ADESA_Little_Rock__c=HTMLBlock2;

if (LocationName.equalsIgnorecase('ADESA Long Island'))  rcvObjContact.ADESA_Long_Island__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Los Angeles'))  rcvObjContact.ADESA_Los_Angeles__c=HTMLBlock2;

if (LocationName.equalsIgnorecase('ADESA Memphis'))  rcvObjContact.ADESA_Memphis__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Miami'))  rcvObjContact.ADESA_Miami__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Minneapolis'))  rcvObjContact.ADESA_Minneapolis__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Nashville'))  rcvObjContact.ADESA_Nashville__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA New Jersey'))  rcvObjContact.ADESA_New_Jersey__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Ocala'))  rcvObjContact.ADESA_Ocala__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA PA'))  rcvObjContact.ADESA_PA__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Phoenix'))  rcvObjContact.ADESA_Phoenix__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Raleigh'))  rcvObjContact.ADESA_Raleigh__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Sacramento'))  rcvObjContact.ADESA_Sacramento__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA San Antonio'))  rcvObjContact.ADESA_San_Antonio__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA San Diego'))  rcvObjContact.ADESA_San_Diego__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Sarasota'))  rcvObjContact.ADESA_Sarasota__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Seattle'))  rcvObjContact.ADESA_Seattle__c=HTMLBlock2;

if (LocationName.equalsIgnorecase('ADESA Shreveport'))  rcvObjContact.ADESA_Shreveport__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Sioux Falls'))  rcvObjContact.ADESA_Sioux_Falls__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA St. Louis'))  rcvObjContact.ADESA_St_Louis__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Syracuse'))  rcvObjContact.ADESA_Syracuse__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Tampa'))  rcvObjContact.ADESA_Tampa__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Tulsa'))  rcvObjContact.ADESA_Tulsa__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Washington DC'))  rcvObjContact.ADESA_Washington_DC__c=HTMLBlock2;

if (LocationName.equalsIgnorecase('ADESA Central Kentucky'))  rcvObjContact.ADESA_Central_Kentucky__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Northern Ohio'))  rcvObjContact.ADESA_Northern_Ohio__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Springdale'))  rcvObjContact.ADESA_Springdale__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Pittsburgh'))  rcvObjContact.ADESA_Pittsburgh__c=HTMLBlock2;
if (LocationName.equalsIgnorecase('ADESA Queen City'))  rcvObjContact.ADESA_Queen_City__c=HTMLBlock2;

    
    
    //Contact mycontact = new Contact();
    //mycontact = (Contact)ContactToReturn ;
    return rcvObjContact ;
 }
 
public void UpdateContactCollection(List<Contact> ContactListToUpdate)
 {
     integer Flag = 1;
     integer blockcount = 1;
    List<Contact> ContactListToUpsert = new List<Contact>();
    
 for(integer i = 0; i < ContactListToUpdate.size(); i++)
    {   
        if(Flag== 1)
        {ContactListToUpsert = new List<Contact>();}
        
        if (i < blockcount*100)
        {
            
            ContactListToUpsert.add(ContactListToUpdate.get(i) );
             Flag = 0;
        }   
        else
        {
             Flag = 1;
        }
        
          if (ContactListToUpsert.size() > 99 )
          {
            
            upsert ContactListToUpsert ID ; 
             Flag = 1;
            //System.debug('Size of ContactListToUpsert ' + ContactListToUpsert.size()+'I  ' + i +' Block Count ' +blockcount+' Flag ' +Flag);
            //System.debug('I  ' + i);
            //System.debug(' Block Count ' +blockcount);
            //System.debug(' Flag ' +Flag);
            
            blockcount =blockcount+1;
            ContactListToUpsert = null;
            
            }
    }

if (ContactListToUpsert != null)
{
    if (ContactListToUpsert.size() >0 )
    {   
        //System.debug('Size of ContactListToUpsert ' + ContactListToUpsert.size() );
        upsert ContactListToUpsert ID ; 
    }
 }  
    
 } 
 
 
}

/*
I did try the set(fieldName,value), but this method doesnot exist on sObjects.
I found another method put(fieldName,fieldValue), and it works fine.
For eg.:
Sobject flight=new Flight__c();  //Flight__c is a custom object
String filedName='mile__c';     //miles__c is a custom field on Flight__c 
flight.put( fieldName,12);
insert flight; 
*/