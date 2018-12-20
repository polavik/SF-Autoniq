public class ATNQCacheContrractDelegate {
    private static final String endpointUrl = 'http://dev-vpc-701863743.us-east-2.elb.amazonaws.com/autoniq-salesforce/api/users/cache';
    
    public String updateCacheContract(CacheContract cache){
        CacheContractResponse result;
        
        HttpRequest req = new HttpRequest();
    	req.setEndpoint(endpointUrl);
    	req.setMethod('POST');
    	req.setTimeout(60000);
        
        String jsonpayload = Json.serialize(cache);
        Http h = new Http();
        HttpResponse res = h.send(req);

    	result = (CacheContractResponse)Json.deserialize(res.getBody(), CacheContractResponse.class);
        return res.getBody();
        
    }
    
    public Class CacheContractResponse{
        boolean success;
        Map<String,String> errorSourceMessageMap;
        String errorMessage;
        
        public CacheContractResponse(){
            errorSourceMessageMap = new Map<String,String>();
            success = false;
        }
    }

}