public without sharing class UserLoginHistory{
  public class loginHistoryWrapper {
    public DateTime LoginTime {get;set;}
    public String Status {get;set;}
    public String LoginURL {get;set;}
    public String LoginType {get;set;}
    public String Application {get;set;}
    public String Browser {get;set;}
    public ID UserId {get;set;}
          
    public loginHistoryWrapper(DateTime lt, String statuss, String LR, String ltype, String app, String brow, ID uid){
      LoginTime = lt;
      Status = statuss;
      LoginURL = LR;
      LoginType = ltype;
      Application = app;
      Browser = brow;
      UserId = uid;
    }
  }
  private Map<String, String> UrlParameterMap;
  private User pU {get; set;}
  public User u {
    get{
      if(pU == null){
        pU = [SELECT name FROM User WHERE ID = :UrlParameterMap.get('u')];
      } 
      return pU;
    }
  }
  public List<LoginHistoryWrapper> Records {get; set;}
    public UserLoginHistory(){
    UrlParameterMap = ApexPages.currentPage().getParameters();

    // default to 20 if not set in the custom settings.
    Decimal maxRecords = 20;
    List <LoginHistory__c> lhc = LoginHistory__c.getall().values();

    if (!lhc.isEmpty() ) {
        maxRecords = lhc[0].MaxDisplayHistory__c;
    }

    List<LoginHistory> lRecords = [
      SELECT LoginTime, Status, LoginURL, LoginType, Application, Browser, UserId
      FROM LoginHistory 
      WHERE UserId= :UrlParameterMap.get('u')
      ORDER BY LoginTime DESC LIMIT :maxRecords.intValue() ];
    Records = new List<LoginHistoryWrapper>();
    For(LoginHistory lh : lRecords){
      Records.add(new LoginHistoryWrapper(lh.loginTime, lh.status, lh.loginURL, lh.LoginType, lh.Application, lh.Browser, lh.UserId));
    }
  }
}