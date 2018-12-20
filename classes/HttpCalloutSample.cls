public class HttpCalloutSample {
	// Pass in the endpoint to be used using the string url 
  public String getContent(String url) {
 
// Instantiate a new http object 
    Http h = new Http();
 	
 // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('GET');
    req.setTimeout(60000);
 
// Send the request, and return a response
    HttpResponse res = h.send(req);
    return res.getBody();
  }
  
  public String testContent()
  {
      return 'Testing ... 1... 2... 3...';
  }

}