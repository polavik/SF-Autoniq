public class HtmlClearHelper {
	public Contact ClearAuction(Contact cont)
	{
		List<String> strLocationSplit   = new List<String>();
		Map<String, Contact> ContactLocationMap =  new Map<String, Contact>();
		
		Contact contactfound = null;
		if (cont.Location__c!=null) strLocationSplit = cont.Location__c.split(';');
		if(strLocationSplit.size() == 0 ) strLocationSplit.add('AllAuctionNeedToclear');
		 
		 
		
			for (integer cnt = 0; cnt < strLocationSplit.size(); cnt++)
			{
				ContactLocationMap.put(strLocationSplit.get(cnt),cont);
				
				
				}
		 contactfound = ContactLocationMap.get('ADESA Atlanta');
		if (contactfound==null) cont.ADESA_Atlanta__c  = '';
		contactfound = null;
		 contactfound = ContactLocationMap.get('ADESA Birmingham');
		if (contactfound==null) cont.ADESA_Birmingham__c  = '';
		contactfound = null;
		 contactfound = ContactLocationMap.get('ADESA Wisconsin');
		if (contactfound==null) cont.ADESA_Wisconsin__c  = '';
		contactfound = null;
		
		

contactfound = ContactLocationMap.get('ADESA Austin');
if (contactfound==null) cont.ADESA_Austin__c='';
contactfound = null;

contactfound = ContactLocationMap.get('ADESA Boston'); if (contactfound==null) cont.ADESA_Boston__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Buffalo'); if (contactfound==null) cont.ADESA_Buffalo__c=''; contactfound = null;

contactfound = ContactLocationMap.get('ADESA Charlotte');
if (contactfound==null) cont.ADESA_Charlotte__c='';
contactfound = null;
contactfound = ContactLocationMap.get('ADESA Cincinnati / Dayton');
if (contactfound==null) cont.ADESA_Cincinnati__c='';
contactfound = null;
contactfound = ContactLocationMap.get('ADESA Cleveland');
if (contactfound==null) cont.ADESA_Cleveland__c='';
contactfound = null;
contactfound = ContactLocationMap.get('ADESA Colorado Springs');
if (contactfound==null) cont.ADESA_Colorado_Springs__c='';
contactfound = null;

contactfound = ContactLocationMap.get('ADESA Concord');
if (contactfound==null) cont.ADESA_Concord__c='';
contactfound = null;
contactfound = ContactLocationMap.get('ADESA Dallas');
if (contactfound==null) cont.ADESA_Dallas__c = '';
contactfound = null;

contactfound = ContactLocationMap.get('ADESA Des Moines');
if (contactfound==null) cont.ADESA_Des_Moines__c='';
contactfound = null;
contactfound = ContactLocationMap.get('ADESA East Tennessee');
if (contactfound==null) cont.ADESA_East_Tennessee__c='';
contactfound = null;
contactfound = ContactLocationMap.get('ADESA Fargo');
if (contactfound==null) cont.ADESA_Fargo__c='';
contactfound = null;
contactfound = ContactLocationMap.get('ADESA Golden Gate');
if (contactfound==null) cont.ADESA_Golden_Gate__c='';
contactfound = null;
contactfound = ContactLocationMap.get('ADESA Great Lakes');
if (contactfound==null) cont.ADESA_Great_Lakes__c='';
contactfound = null;
contactfound = ContactLocationMap.get('ADESA Houston'); if (contactfound==null) cont.ADESA_Houston__c=''; contactfound = null;

contactfound = ContactLocationMap.get('ADESA Indianapolis'); if (contactfound==null) cont.ADESA_Indianapolis__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Jacksonville'); if (contactfound==null) cont.ADESA_Jacksonville__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Kansas City'); if (contactfound==null) cont.ADESA_Kansas_City__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Knoxville'); if (contactfound==null) cont.ADESA_Knoxville__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Lansing'); if (contactfound==null) cont.ADESA_Lansing__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Las Vegas'); if (contactfound==null) cont.ADESA_Las_Vegas__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Lexington'); if (contactfound==null) cont.ADESA_Lexington__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Little Rock'); if (contactfound==null) cont.ADESA_Little_Rock__c=''; contactfound = null;

contactfound = ContactLocationMap.get('ADESA Long Island'); if (contactfound==null) cont.ADESA_Long_Island__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Los Angeles'); if (contactfound==null) cont.ADESA_Los_Angeles__c=''; contactfound = null;

contactfound = ContactLocationMap.get('ADESA Memphis'); if (contactfound==null) cont.ADESA_Memphis__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Miami'); if (contactfound==null) cont.ADESA_Miami__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Minneapolis'); if (contactfound==null) cont.ADESA_Minneapolis__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Nashville'); if (contactfound==null) cont.ADESA_Nashville__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA New Jersey'); if (contactfound==null) cont.ADESA_New_Jersey__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Ocala'); if (contactfound==null) cont.ADESA_Ocala__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA PA'); if (contactfound==null) cont.ADESA_PA__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Phoenix'); if (contactfound==null) cont.ADESA_Phoenix__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Raleigh'); if (contactfound==null) cont.ADESA_Raleigh__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Sacramento'); if (contactfound==null) cont.ADESA_Sacramento__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA San Antonio'); if (contactfound==null) cont.ADESA_San_Antonio__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA San Diego'); if (contactfound==null) cont.ADESA_San_Diego__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Sarasota'); if (contactfound==null) cont.ADESA_Sarasota__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Seattle'); if (contactfound==null) cont.ADESA_Seattle__c=''; contactfound = null;

contactfound = ContactLocationMap.get('ADESA Shreveport'); if (contactfound==null) cont.ADESA_Shreveport__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Sioux Falls'); if (contactfound==null) cont.ADESA_Sioux_Falls__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA St. Louis'); if (contactfound==null) cont.ADESA_St_Louis__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Syracuse'); if (contactfound==null) cont.ADESA_Syracuse__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Tampa'); if (contactfound==null) cont.ADESA_Tampa__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Tulsa'); if (contactfound==null) cont.ADESA_Tulsa__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Washington DC'); if (contactfound==null) cont.ADESA_Washington_DC__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Wisconsin'); if (contactfound==null) cont.ADESA_Wisconsin__c=''; contactfound = null;

contactfound = ContactLocationMap.get('ADESA Central Kentucky'); if (contactfound==null) cont.ADESA_Central_Kentucky__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Northern Ohio'); if (contactfound==null) cont.ADESA_Northern_Ohio__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Springdale'); if (contactfound==null) cont.ADESA_Springdale__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Pittsburgh'); if (contactfound==null) cont.ADESA_Pittsburgh__c=''; contactfound = null;
contactfound = ContactLocationMap.get('ADESA Queen City'); if (contactfound==null) cont.ADESA_Queen_City__c=''; contactfound = null;



	 	return cont;
	}
		
		
		
}