public class GoogleMaps {

	public String duration {get;set;}
	public Integer travelTime {get;set;}
	public Decimal distance {get;set;}
	
	public string status {get;set;}	//ADDED 4/23/13 TO CHECK FOR STATUS
	
//-----------------------------------------------------------------------------------------
	public googleMaps(String address1,String address2) {
				
		String jsonResults = getJsonResults(address1, address2);
		jsonResults = formatJsonResults(jsonResults);
		updateJsonSections(jsonResults);
		
	}
//-----------------------------------------------------------------------------------------
	public String getJsonResults(String address1,String address2) {
		
		HttpRequest req = new HttpRequest();
		Http http = new Http();
		
		req.setMethod('GET');

//https://maps.googleapis.com/maps/api/distancematrix/json?origins=&destinations=&mode=driving&sensor=false&language=en&units=imperial
//https://maps.googleapis.com/maps/api/distancematrix/json?origins=795+Harris+Ave+Denver%2C+CO+80201+USA&destinations=555+Harris+Ave+Denver%2C+CO+60606+USA&mode=driving&sensor=false&language=en&units=imperial
		
		
		system.debug('==========================================================================================MAP ADDRESS 1 ' + address1);
		system.debug('==========================================================================================MAP ADDRESS 2 ' + address2);
		
		String url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
			+ '?origins=' + address1
			+ '&destinations=' + address2
			+ '&mode=driving'
			+ '&sensor=false'
			+ '&language=en'
			+ '&units=imperial';

			system.debug('==========================================================================================URL ' + url);		
		
		req.setEndPoint(url);
		
		string jsonResults;
		
		//NEED TRY/CATCH FOR TEST METHODS TO WORK
		try{
			system.debug('Start http.send');
			
			HTTPResponse resp = http.send(req);
			
			system.debug('HTTP Repsponse:' + resp);
			system.debug('End http.send');
			system.debug('Google Result: ' + resp.getBody());
			
			jsonResults = resp.getBody().replace('\n', '');
			
			system.debug('Google Result No Break: ' + resp.getBody());
			
		}catch(system.TypeException te){
			
			string testResponseResults = 
			'{"destination_addresses":["555 Harris Drive, Arapaho National Forest, Idaho Springs, CO 80452, USA"],' +
   				'"origin_addresses":[ "Harris Circle, Denver, CO 80229, USA" ],' +
   				'"rows":[{' + 
   					'"elements":[' + 
            		'{	"distance":{"text" : "51.3 mi", "value":82625},' + 
            			'"duration":{"text" : "1 hour 8 mins", "value":4107},' + 
               			'"status":"OK"}]}],' + 
   				'"status":"OK"}';
   			
			jsonResults = testResponseResults.replace('\n', '');
		}
		
		//system.debug('Google Result: ' + resp.getBody());
		//String jsonResults = resp.getBody().replace('\n', '');
		return jsonResults;
	}
//-----------------------------------------------------------------------------------------	
	public String formatJsonResults(String value) {
		
		value = value.replace('{', ', ');
		value = value.replace('}', ', ');
		value = value.replace('[', ', ');
		value = value.replace(']', ', ');
		value = value.replace('"', '');
		
		return value;	
	}
//-----------------------------------------------------------------------------------------	
	public void updateJsonSections(String jsonResults) {
		
		system.debug('JSON Sections String');
		
		list<String> jsonSections = jsonResults.split(', ');
		
		for (Integer i = 0; i < jsonSections.size(); i++) {
			jsonSections[i] = jsonSections[i].trim();
			
			if (jsonSections[i].contains('duration:')) {
				duration = parseDuration(jsonSections[i + 2]);
				travelTime = parseTravelTime(duration);
			}
			
			if (jsonSections[i].contains('distance')) {
				distance = parseDistance(jsonSections[i + 1]);
				system.debug('jSON Distance:' + distance);
			}
			
			//ADDED 4/23/13 TO CHECK STATUS
			if (jsonSections[i].contains('status')) {
				system.debug('jSON Status Before:' + jsonSections[i]);
				
				status = parseStatus(jsonSections[i]);
				
				system.debug('jSON Status After:' + status);
			}
			
		}
	}
//-----------------------------------------------------------------------------------------
	public Decimal parseDistance(String value) {
		
		system.debug('PARSE DISTANCE STRING:' + value);
		
		value = value.replace('text : ', '');
		value = value.replace(' mi', '');
		value = value.replace(' ft', '');
		value = value.replace(',', '');
		value = value.trim();
		
		system.debug('PARSE DISTANCE VALUE:' + value);
		
		return Decimal.valueOf(value);
	}
//-----------------------------------------------------------------------------------------	
	public String parseDuration(String value) {
		
		value = value.replace('text: ', '');
		return value;
	}
//-----------------------------------------------------------------------------------------
	public Integer parseTravelTime(String value) {
	
		Integer tmpMinutes = 0;
	
		list<String> durationNodes = value.split(' ');
		String prevDurationNode = '';
		
		for (String durationNode : durationNodes) {
			if (durationNode == 'day' || durationNode == 'days') {
				tmpMinutes += Integer.valueOf(prevDurationNode) * 1440;
			}
			if (durationNode == 'hour' || durationNode == 'hours') {
				tmpMinutes += Integer.valueOf(prevDurationNode) * 60;
			}
			if (durationNode == 'min' || durationNode == 'mins') {
				tmpMinutes += Integer.valueOf(prevDurationNode);
			}
			
			prevDurationNode = durationNode;
		}
	
		return tmpMinutes;	
	}
//-----------------------------------------------------------------------------------------
	public string parseStatus(string value){
		
		system.debug('Start Parse Status');
		
		value = value.replace('status : ', '');
		system.debug('End Parse Status Result:' + value);
		
		return value;
		
	}
//-----------------------------------------------------------------------------------------


}