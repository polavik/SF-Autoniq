@RestResource(urlMapping='/autoniq/user/*')
global class ATNQUserService {
    
    @HttpPost
    global static void validateUserIdAvailability() { 
    
        ATNQJsonParserUtil util = new ATNQJsonParserUtil();
        ATNQResponse aResp = new ATNQResponse();
        RestRequest req = RestContext.request;
        string userData = req.requestBody.toString().trim();
        Type resultType = Type.forName('CacheContract.UserDetail');
        CacheContract.UserDetail newUser = (CacheContract.UserDetail)json.deserialize(userData,resultType);
        System.debug('=======> User: ' + newUser);
        System.debug('=======> User Name: ->' + newUser.autoniqUserId + '<-');
    	List<Contact> existingContacts = [select Id,Name, LastName,FirstName,MobilePhone,Autoniq_User_ID__c, Autoniq_Account__c, Autoniq_Account__r.Name  From Contact where Autoniq_User_ID__c=:newUser.autoniqUserId];
        System.debug('=======> existingContacts: ' + existingContacts);
        if(existingContacts.size()>0){		
            CacheContractUtil.setupErrorResponse('Autoniq User Id Already Exists', ATNQConstants.USER_ALREADY_EXISTS_ERROR,  existingContacts[0].Id);
        }else{
            CacheContractUtil.setupSuccessResponse(null);
    	}
    }
    
    @HttpPut
    global static void doPut() { 
    
        ATNQJsonParserUtil util = new ATNQJsonParserUtil();
        ATNQResponse aResp = new ATNQResponse();
        RestRequest req = RestContext.request;
        string userData = req.requestBody.toString().trim();
        Type resultType = Type.forName('CacheContract.UserDetail');
        CacheContract.UserDetail newUser = (CacheContract.UserDetail)json.deserialize(userData,resultType);
        System.debug('=======> User: ' + newUser);
        System.debug('=======> User Name: ->' + newUser.autoniqUserId + '<-');
    	List<Contact> existingContacts = [select Id,Name, LastName,FirstName,MobilePhone,Autoniq_User_ID__c, Autoniq_Account__c, Autoniq_Account__r.Name  From Contact where Autoniq_User_ID__c=:newUser.autoniqUserId limit 1];
        System.debug('=======> existingContacts: ' + existingContacts);
        if(existingContacts.size()>0){
            CacheContractUtil.setupErrorResponse('Autoniq User Id Already Exists', ATNQConstants.USER_ALREADY_EXISTS_ERROR,  existingContacts[0].Id);
        }else{
            Contact c = CacheContractUtil.createContact(newUser);
            insert c;
            CacheContractUtil.setupSuccessResponse(c.Id);
    	}
    }
    
}