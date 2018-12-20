public with sharing class Opportunity_Email_Notifications{

    public String getBaseUrl() {
    
    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
    System.debug('baseUrl =' + baseUrl);
        return baseUrl;
    }


public  List<Opportunity> Opp_Info{get;set;}
public String UId{get;set;}
public Integer Nodays{get;set;}


    public Opportunity_Email_Notifications() {
        
        system.debug('UId====='+UId);
        system.debug('Nodays====='+Nodays);
        
    }

    public List<Opportunity> getOpp_data() {
    
    system.debug('UId====='+UId);
    system.debug('Nodays====='+Nodays);
   
    Opp_Info =
    [
        select id,name,Account.Name,Stagename,owner.Name,createddate,owner.Manager.Name,Last_Activity_Date__c from Opportunity 
        WHERE 
            (
                RecordType.name =: 'AFC New Business' 
                OR RecordType.name =:'AFC-Increase Utilization'
            ) 
            AND StageName !='Closed Lost' 
            AND StageName !='Closed Won' 
            AND Stage_Duration_List__c =:Nodays
            AND OwnerId =:UId   
    ];
        return Opp_Info;
    }
    
    
    public List<Opportunity> getOpp_Manager_data() {
    
    system.debug('UId====='+UId);
    system.debug('Nodays====='+Nodays);
     
    Opp_Info = 
    [
        select id,name,Account.Name,Stagename,createddate,owner.Name,owner.Manager.Name,Last_Activity_Date__c from Opportunity 
        WHERE 
            (
                RecordType.name =: 'AFC New Business' 
                OR RecordType.name =:'AFC-Increase Utilization'
            ) 
            AND StageName !='Closed Lost' 
            AND StageName !='Closed Won' 
            AND Stage_Duration_List__c =:Nodays
            AND Owner.ManagerId =:UId   
    ];
        return Opp_Info;
    }
    
     public List<Opportunity> getOpp_SecondaryManager_data() {
    
    system.debug('UId====='+UId);
    system.debug('Nodays====='+Nodays);
    
    Opp_Info = 
    [
        select id,name,Account.Name,Stagename,createddate,owner.Name,owner.Manager.Name,Last_Activity_Date__c from Opportunity 
        WHERE 
            (
                RecordType.name =: 'AFC New Business' 
                OR RecordType.name =:'AFC-Increase Utilization'
            ) 
            AND StageName !='Closed Lost' 
            AND StageName !='Closed Won' 
            AND Stage_Duration_List__c =:Nodays
            AND Owner.Manager.ManagerId =:UId   
    ];
        return Opp_Info;
    }
    
    
}