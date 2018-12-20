public with sharing class Task_Email_Notifications{
    public  List<Task> Task_Info{get;set;}
    public String UId{get;set;}
    public Integer Nodays{get;set;}

    public String getBaseUrl() {    
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl =' + baseUrl);
        return baseUrl;
    }

    public Task_Email_Notifications() {
    }

    public List<Task> getTask_data() {
        Task_Info = [select id,what.name,subject,createddate,ActivityDate,Status,Who.Name from Task 
                        WHERE (Status != 'Completed' AND Status != 'Completed - Sold' AND Status != 'Completed - Not Interested')
                        AND (RecordType.name =:'AFC ASM Task' OR RecordType.name =:'AFC BDC' 
                        OR RecordType.name =:'AFC Branch Task' OR RecordType.name =:'4n1 Log a Call') 
                        AND ActivityDate =: system.today().addDays(Nodays) AND OwnerId =:UId];
        return Task_Info;
    }
    
    
    public List<Task> getTask_Manager_data() {
        List<User> uinfo = [select id,name from user where ManagerId=:UId];    
        set<Id> ManUserID =new set<Id>();
        for(User u:uinfo){
            ManUserID.add(u.id);
        }

    Task_Info = [select id,owner.name,subject,what.name,createddate,ActivityDate,Status,Who.Name from Task 
                    WHERE (Status != 'Completed' and Status != 'Completed - Sold' and Status != 'Completed - Not Interested')
                    AND(RecordType.name =:'AFC ASM Task' OR RecordType.name =:'AFC BDC' OR RecordType.name =:'AFC Branch Task' 
                    OR RecordType.name =:'4n1 Log a Call') 
                    AND ActivityDate =: system.today().addDays(Nodays) AND OwnerId IN :ManUserID];
        return Task_Info;
    }
    
    public List<Task> getTask_SecondaryManager_data() {
        List<User> uinfo = [select id,name from user where Manager.ManagerId=:UId];
        set<Id> ManUserID =new set<Id>();
        for(User u:uinfo){
            ManUserID.add(u.id);
        }

    Task_Info = [select id,owner.name,subject,manager_name__c,what.name,createddate,ActivityDate,Status,Who.Name from Task 
                    WHERE (Status != 'Completed' and Status != 'Completed - Sold' and Status != 'Completed - Not Interested')
                    AND (RecordType.name =:'AFC ASM Task' OR RecordType.name =:'AFC BDC' OR RecordType.name =:'AFC Branch Task' 
                    OR RecordType.name =:'4n1 Log a Call') AND ActivityDate =: system.today().addDays(Nodays) AND OwnerId IN :ManUserID];
        return Task_Info;
    }
}