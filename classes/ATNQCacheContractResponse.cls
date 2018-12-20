public class ATNQCacheContractResponse {
    
    public Response resp;

    public ATNQCacheContractResponse(){
        resp = new Response();
    }
    
    public Class Response{
        public String salesforceId;
        public boolean success;
        public List<ResponseError>  errors;
        
        public Response(){
            errors = new List<ResponseError>();
        }
        
    }

        public Class ResponseError{
            public String source;
            public String message;
        }

}