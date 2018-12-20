public class AccountHelper 
{ 

    public static void OrgTaxFormOnFileFlag(List<ID> accountIds){
        if(System.isFuture() || System.isBatch()){
            OrgTaxFormOnFileFlagSync(accountIds);
        } else {
            if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
                OrgTaxFormOnFileFlagAsync(accountIds);
            } else {
                System.debug('*** Future Call Limits exceeded for OrgTaxFormOnFile');
            }
        }
    }
    @future(callout=true)
    public static void OrgTaxFormOnFileFlagAsync(List<ID> accountIds)
    {
        OrgTaxFormOnFileFlagSync(accountIds);
    }

    public static void OrgTaxFormOnFileFlagSync(List<ID> accountIds)
    {
       try 
        {
    
        Map<Id, String> caseIdDesc = new Map<Id, String>();
        List<Account> accounts= new List<Account>();
        Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
        if (accountIds.size()>0){           
            accounts= [SELECT  ATC_Organization_ID__c,id,CDN_Joint_Election_Form_on_File__c FROM account where  Id IN :accountIds];
             for (Account a: accounts)
            {
               if (a.ATC_Organization_ID__c!=null ){
                    Long orgId= Long.valueOf(a.ATC_Organization_ID__c);
                    Boolean flag = a.CDN_Joint_Election_Form_on_File__c;
                    Logger.info(a, 'Calling Mediator operation: updateOrgTaxFormOnFileFlag(' + orgId +','+ flag  +')');
                   // String response = ms.updateOrgTaxFormOnFileFlag(orgId,flag );
                    if (orgId!=null && flag!=null && ms!=null){
                        Mediator.updateOrgTaxFormOnFileFlagResponseType response1 = ms.updateOrgTaxFormOnFileFlag(orgId,flag );
                        String results = response1.responseCode;
                        if (response1.responseMessage!= null)
                        {
                            results = results + ': ' + response1.responseMessage  ;
                        }
                        
                        Logger.info(a, 'updateOrgTaxFormOnFileFlag RESPONSE: ' + results);
                    }
                    
                }
             
            }
         }  
      }catch (Exception e) 
        {
           system.debug( e.getMessage());
            
        } 
        finally 
        {
            Logger.flush();
        }
    }

    }