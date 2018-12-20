public class ATNQResponse {
    
    public Response resp;

    public ATNQResponse(){
        resp = new Response();
    }
    
    public Class Response{
        public String salesforceId;//Change to autoniqUserId
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