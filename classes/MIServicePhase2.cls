//Generated by wsdl2apex

public class MIServicePhase2 {
    public class Result {
        public Integer resultCode;
        public String message;
        private String[] resultCode_type_info = new String[]{'resultCode','urn:MIService',null,'1','1','true'};
        private String[] message_type_info = new String[]{'message','urn:MIService',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:MIService','false','false'};
        private String[] field_order_type_info = new String[]{'resultCode','message'};
    }
    public class miSearchRequest {
        public String miFactType;
        public String miDomain;
        public String miDomainUniqueId;
        public Boolean exactMatch;
         public String token;
         private String[] token_type_info = new String[]{'token','urn:MIService',null,'1','1','false'};
        private String[] miFactType_type_info = new String[]{'miFactType','urn:MIService',null,'1','1','false'};
        private String[] miDomain_type_info = new String[]{'miDomain','urn:MIService',null,'1','1','false'};
        private String[] miDomainUniqueId_type_info = new String[]{'miDomainUniqueId','urn:MIService',null,'1','1','false'};
        private String[] exactMatch_type_info = new String[]{'exactMatch','urn:MIService',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:MIService','false','false'};
        private String[] field_order_type_info = new String[]{'token','miFactType','miDomain','miDomainUniqueId','exactMatch'};
    }
    public class MiUpdateResponse {
        public Boolean success;
        public MIServicePhase2.Result result;
        private String[] success_type_info = new String[]{'success','urn:MIService',null,'1','1','true'};
        private String[] result_type_info = new String[]{'result','urn:MIService',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:MIService','false','false'};
        private String[] field_order_type_info = new String[]{'success','result'};
    }
    public class miSearchResponse {
        public MIServicePhase2.MiFact[] miFacts;
        public MIServicePhase2.Result result;
        private String[] miFacts_type_info = new String[]{'miFacts','urn:MIService',null,'0','-1','true'};
        private String[] result_type_info = new String[]{'result','urn:MIService',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:MIService','false','false'};
        private String[] field_order_type_info = new String[]{'miFacts','result'};
    }
    public class MiRequestBase {
        public String token;
        private String[] token_type_info = new String[]{'token','urn:MIService',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:MIService','false','false'};
        private String[] field_order_type_info = new String[]{'token'};
    }
    public class MiUpdateRequest {
        public String masterIndex;
        public String masterIndexChangeTo;
        public String miFactType;
        public String miDomain;
        public String miDomainUniqueId;
         public String token;
         private String[] token_type_info = new String[]{'token','urn:MIService',null,'1','1','false'};
        private String[] masterIndex_type_info = new String[]{'masterIndex','urn:MIService',null,'1','1','false'};
        private String[] masterIndexChangeTo_type_info = new String[]{'masterIndexChangeTo','urn:MIService',null,'1','1','false'};
        private String[] miFactType_type_info = new String[]{'miFactType','urn:MIService',null,'1','1','false'};
        private String[] miDomain_type_info = new String[]{'miDomain','urn:MIService',null,'1','1','true'}; // false-->true
        private String[] miDomainUniqueId_type_info = new String[]{'miDomainUniqueId','urn:MIService',null,'1','1','true'}; // false-->true
        private String[] apex_schema_type_info = new String[]{'urn:MIService','false','false'};
        private String[] field_order_type_info = new String[]{'token','masterIndex','masterIndexChangeTo','miFactType','miDomain','miDomainUniqueId'};
    }
    public class MiResponse {
        public MIServicePhase2.MiFact[] miFacts;
        public MIServicePhase2.Result result;
        private String[] miFacts_type_info = new String[]{'miFacts','urn:MIService',null,'0','-1','true'};
        private String[] result_type_info = new String[]{'result','urn:MIService',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:MIService','false','false'};
        private String[] field_order_type_info = new String[]{'miFacts','result'};
    }
    public class MiFact {
        public String masterIndex;
        public String miFactType;
        public String miFactId;
        public String miDomain;
        public String domainUniqueId;
        public String name;
        public String tin;
        public String auctionAccessId;
        public String city;
        public String state;
        public String country;
        public String zip;
        public Boolean isDuplicate;
        public Date lastUpdateDate;
        private String[] masterIndex_type_info = new String[]{'masterIndex','urn:MIService',null,'1','1','false'};
        private String[] miFactType_type_info = new String[]{'miFactType','urn:MIService',null,'1','1','false'};
        private String[] miFactId_type_info = new String[]{'miFactId','urn:MIService',null,'1','1','false'};
        private String[] miDomain_type_info = new String[]{'miDomain','urn:MIService',null,'1','1','false'};
        private String[] domainUniqueId_type_info = new String[]{'domainUniqueId','urn:MIService',null,'1','1','false'};
        private String[] name_type_info = new String[]{'name','urn:MIService',null,'1','1','false'};
        private String[] tin_type_info = new String[]{'tin','urn:MIService',null,'1','1','true'};
        private String[] auctionAccessId_type_info = new String[]{'auctionAccessId','urn:MIService',null,'1','1','true'};
        private String[] city_type_info = new String[]{'city','urn:MIService',null,'1','1','true'};
        private String[] state_type_info = new String[]{'state','urn:MIService',null,'1','1','true'};
        private String[] country_type_info = new String[]{'country','urn:MIService',null,'1','1','true'};
        private String[] zip_type_info = new String[]{'zip','urn:MIService',null,'1','1','true'};
        private String[] isDuplicate_type_info = new String[]{'isDuplicate','urn:MIService',null,'1','1','false'};
        private String[] lastUpdateDate_type_info = new String[]{'lastUpdateDate','urn:MIService',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'urn:MIService','false','false'};
        private String[] field_order_type_info = new String[]{'masterIndex','miFactType','miFactId','miDomain','domainUniqueId','name','tin','auctionAccessId','city','state','country','zip','isDuplicate','lastUpdateDate'};
    }
    public class MiRequest {
        public String masterIndex;
        public String miFactType;
        public String[] miFactId;
         public String token;
         private String[] token_type_info = new String[]{'token','urn:MIService',null,'1','1','false'};
        private String[] masterIndex_type_info = new String[]{'masterIndex','urn:MIService',null,'1','1','false'};
        private String[] miFactType_type_info = new String[]{'miFactType','urn:MIService',null,'1','1','false'};
        private String[] miFactId_type_info = new String[]{'miFactId','urn:MIService',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:MIService','false','false'};
        private String[] field_order_type_info = new String[]{'token','masterIndex','miFactType','miFactId'};
    }
    public class MIService {
        public String endpoint_x ;//= 'https://ds2gateway.stg.autc.com/apis/services/MIService';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:MIService', 'MIServicePhase2'};
        public MIServicePhase2.MiUpdateResponse updateMasterIndex(String strToken,String masterIndex,String masterIndexChangeTo,String miFactType,String miDomain,String miDomainUniqueId) {
            MIServicePhase2.MiUpdateRequest request_x = new MIServicePhase2.MiUpdateRequest();
            request_x.masterIndex = masterIndex;
            request_x.masterIndexChangeTo = masterIndexChangeTo;
            request_x.miFactType = miFactType;
            request_x.miDomain = miDomain;
            request_x.miDomainUniqueId = miDomainUniqueId;
            request_x.token = strToken;
            MIServicePhase2.MiUpdateResponse response_x;
            Map<String, MIServicePhase2.MiUpdateResponse> response_map_x = new Map<String, MIServicePhase2.MiUpdateResponse>();
            response_map_x.put('response_x', response_x);
            
            
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:MIService/updateMasterIndex',
              'urn:MIService',
              'miUpdateRequest',
              'urn:MIService',
              'miUpdateResponse',
              'MIServicePhase2.MiUpdateResponse'}
            );
            
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public MIServicePhase2.miSearchResponse searchMi(String strToken,String miFactType,String miDomain,String miDomainUniqueId,Boolean exactMatch) {
            MIServicePhase2.miSearchRequest request_x = new MIServicePhase2.miSearchRequest();
            request_x.miFactType = miFactType;
            request_x.miDomain = miDomain;
            request_x.miDomainUniqueId = miDomainUniqueId;
            request_x.exactMatch = exactMatch;
            request_x.token = strToken;
            MIServicePhase2.miSearchResponse response_x;
            Map<String, MIServicePhase2.miSearchResponse> response_map_x = new Map<String, MIServicePhase2.miSearchResponse>();
            response_map_x.put('response_x', response_x);
            
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:MIService/searchMi',
              'urn:MIService',
              'miSearchRequest',
              'urn:MIService',
              'miSearchResponse',
              'MIServicePhase2.miSearchResponse'}
            );
           
            response_x = response_map_x.get('response_x');
            return response_x;
        }
        public MIServicePhase2.MiResponse getMiFact(String strToken,String masterIndex,String miFactType,String[] miFactId) {
            MIServicePhase2.MiRequest request_x = new MIServicePhase2.MiRequest();
            request_x.masterIndex = masterIndex;
            request_x.miFactType = miFactType;
            request_x.miFactId = miFactId;
            request_x.token = strToken;
            MIServicePhase2.MiResponse response_x;
            Map<String, MIServicePhase2.MiResponse> response_map_x = new Map<String, MIServicePhase2.MiResponse>();
            response_map_x.put('response_x', response_x);
             
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'urn:MIService/getMiFact',
              'urn:MIService',
              'miRequest',
              'urn:MIService',
              'miResponse',
              'MIServicePhase2.MiResponse'}
            );
            
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}