@isTest
private class Test_AutoniqMyAccountService {

  
  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    req.requestURI = 'services/apexrest/autoniq/myaccount/user/viewAccount';  
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;

    AutoniqMyAccountViewAccountResponse response = AutoniqMyAccountService.viewAccount();
  }

}