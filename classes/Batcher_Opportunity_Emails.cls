global class Batcher_Opportunity_Emails implements Database.Batchable<SObject> {

global set<Id> EmployeeFirst = new set<Id>();
global set<Id> Employeesecond = new set<Id>();
global set<Id> Employeethird = new set<Id>();
global set<Id> ManagerFirst = new set<Id>();
global set<Id> ManagerSecond = new set<Id>();
global set<Id> SecondmanagerFirst= new set<Id>();
global set<Id> QueryId= new set<Id>();

// "Start" runs when the class in instanciated
global Database.QueryLocator start(Database.BatchableContext bcMain) {

system.debug('system.Today().addDays(-45)==='+system.Today().addDays(-45));
system.debug('system.Today().addDays(-28)==='+system.Today().addDays(-28));
system.debug('system.Today().addDays(-14)==='+system.Today().addDays(-14));
/*
return Database.getQueryLocator([select id,name,owner.email,owner.manager.email,owner.Manager.Manager.Email,Last_Activity_Date__c from opportunity where
                                        StageName=:'Open' and  (RecordType.name =: 'AFC New Business' or RecordType.name =:'AFC-Increase Utilization')
                                        and (Stage_Duration_List__c =14 or Stage_Duration_List__c =28 or Stage_Duration_List__c =45)
                                        and (Next_Contact_Date__c =: null or Next_Contact_Date__c < today) and
                                        (Last_Activity_Date__c=:  system.Today().addDays(-14) or Last_Activity_Date__c=:  system.Today().addDays(-28) or
                                        Last_Activity_Date__c=:  system.Today().addDays(-45))]);
                                        */
                                        
return Database.getQueryLocator([select id,name,owner.email,owner.manager.email,owner.Manager.Manager.Email,Last_Activity_Date__c,Stage_Duration_List__c  from opportunity where
                                        (RecordType.name =: 'AFC New Business' or RecordType.name =:'AFC-Increase Utilization') and
                                        StageName !='Closed Lost' and StageName !='Closed Won' and 
                                        (Stage_Duration_List__c =14 or Stage_Duration_List__c =28 or Stage_Duration_List__c =45)]);
}

 
   
global void execute(Database.BatchableContext bcMain, List<SObject> lstBatchRecords){

    recordsMail(lstBatchRecords);

}

public void recordsMail(List<opportunity> opp){
    
    if(opp.size()>0){
         List < Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage > ();
          Map<id,user> Mapuser = new Map<id,user>();
          
    //custom settings to store vf template Ids
    Vf_Templates__c ctemp = Vf_Templates__c.getorgdefaults();
    
    for(opportunity o:opp){
    if(o.Stage_Duration_List__c == 14){
    
    
    EmployeeFirst.add(o.ownerId);
    QueryId.add(o.ownerId);
    
     /*String[] toAddresses = new String[] {o.owner.email};
     Messaging.SingleEmailMessage singleMail = framEmail(o.id,toAddresses,Opptemp.Opportunity_Template__c);
     emails.add(singleMail);*/
     
     
    }else if(o.Stage_Duration_List__c  ==  28){
    
    
    Employeesecond.add(o.ownerId);
    ManagerFirst.add(o.ownerId);
    QueryId.add(o.ownerId);
    
    /*String[] toAddresses = new String[] {o.owner.email,o.owner.manager.email};
     Messaging.SingleEmailMessage singleMail = framEmail(o.id,toAddresses,Opptemp.Opportunity_Template__c);
     emails.add(singleMail);*/
     
     
    }else if(o.Stage_Duration_List__c ==  45){
    
       Employeethird.add(o.ownerId);
       ManagerSecond.add(o.ownerId);
       SecondmanagerFirst.add(o.ownerId);
       QueryId.add(o.ownerId);
   
    /*String[] toAddresses = new String[] {o.owner.email,o.owner.manager.email,o.owner.Manager.Manager.Email};
     Messaging.SingleEmailMessage singleMail = framemail(o.id,toAddresses,Opptemp.Opportunity_Template__c);
     emails.add(singleMail);*/
     
    }
    
    }
    
     if(QueryId.size()>0){
     Mapuser = new Map<Id,user>([select id,email,managerid,Manager.ManagerId,manager.email,Manager.Manager.Email from user where id In:QueryId]);
     }
     
    
     // Employee First Notification Code
    
    if(EmployeeFirst.size()>0){
    
     
    
    for(Id i:EmployeeFirst){
    
     if(mapuser.get(i).email != null){
     
     String[] toAddresses = new String[] {mapuser.get(i).email};
     system.debug('toAddresses ====='+toAddresses);
     Messaging.SingleEmailMessage singleMail = framEmail(i,toAddresses,ctemp.OP_Employee_First__c);
     emails.add(singleMail);
     
     }
    }
      
    }
    
    // Employee Second Notification Code
    
     if(Employeesecond.size()>0){
     
      
    
    for(Id i:Employeesecond ){
    
     if(mapuser.get(i).email != null){
     
     String[] toAddresses = new String[] {mapuser.get(i).email};
     system.debug('toAddresses ====='+toAddresses);
     Messaging.SingleEmailMessage singleMail = framEmail(i,toAddresses,ctemp.OP_Employee_Second__c);
     emails.add(singleMail);
     }
    }
      
    }
    
    // Employee Third Notification Code
    
    
     if(Employeethird.size()>0){
     
      
    
    for(Id i:Employeethird ){
    
    if(mapuser.get(i).email != null){
    
     String[] toAddresses = new String[] {mapuser.get(i).email};
     system.debug('toAddresses ====='+toAddresses);
     Messaging.SingleEmailMessage singleMail = framEmail(i,toAddresses,ctemp.OP_Employee_Third__c);
     emails.add(singleMail);
     
        }
        }
       
    }
    
       
     // Manager First Notification  Code
    
    
    if(ManagerFirst.size()>0){
    
     
    
    for(Id i: ManagerFirst ){
    
    if(mapuser.get(i).manager.email != null){
    
     String[] toAddresses = new String[] {mapuser.get(i).manager.email};
     system.debug('toAddresses ====='+toAddresses);
     Messaging.SingleEmailMessage singleMail = framEmail(mapuser.get(i).managerId,toAddresses,ctemp.OP_Manager_First__c);
     emails.add(singleMail);
     
        }
        }
        
    }
    
     // Manager Second Notification Code
    
    
    if(ManagerSecond.size()>0){
    
     
    
    for(Id i:ManagerSecond){
    
    if(mapuser.get(i).manager.email != null){
    
     String[] toAddresses = new String[] {mapuser.get(i).manager.email};
     system.debug('toAddresses ====='+toAddresses);
     Messaging.SingleEmailMessage singleMail = framEmail(mapuser.get(i).managerId,toAddresses,ctemp.OP_Manager_Second__c);
     emails.add(singleMail);
     
        }
        }
        
    }
    
    
    
     // Secondary Manager First Notification Code
    
    
    if(SecondmanagerFirst.size()>0){
    
     
    
    for(Id i:SecondmanagerFirst){
    
    if(mapuser.get(i).Manager.Manager.Email != null){
     String[] toAddresses = new String[] {mapuser.get(i).Manager.Manager.Email};
     system.debug('toAddresses ====='+toAddresses);
     Messaging.SingleEmailMessage singleMail = framEmail(mapuser.get(i).Manager.ManagerId,toAddresses,ctemp.OP_SManager_First__c);
     emails.add(singleMail);
     
        }
        }
        
             
    }
    
    if(emails.size()>0){
           sendmail(emails);
        }
       }
    }
    
    
     public static void sendmail(List <Messaging.SingleEmailMessage> emails){
    
     // Send the emails in a transaction, then roll it back
                Savepoint sp = Database.setSavepoint();                            
                if (!test.isRunningTest() && !Sandbox.isSandbox())Messaging.sendEmail(emails);
                Database.rollback(sp);

                // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
                // contents to a new SingleEmailMessage. Then send those new messages.
                List < Messaging.SingleEmailMessage > lstMsgsToSend = new List < Messaging.SingleEmailMessage > ();
                for (Messaging.SingleEmailMessage email: emails) {
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(email.getToAddresses());
                    emailToSend.setPlainTextBody(email.getPlainTextBody());
                    emailToSend.setHTMLBody(email.getHTMLBody());
                    emailToSend.setSubject(email.getSubject());
                    lstMsgsToSend.add(emailToSend);
                    system.debug('emailToSend====='+emailToSend);
                }
                if (!test.isRunningTest() && !Sandbox.isSandbox())Messaging.sendEmail(lstMsgsToSend);
    
    }
    
     public Messaging.SingleEmailMessage  framEmail(string id,string[] toAddresses,string templateType){
    
     Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                    //set object Id
                    singleMail.setTargetObjectId(Id);
                    singleMail.setWhatId(Id);
                    //set template Id
                    singleMail.setTemplateId(templateType);
                    // for testing
                    //String[] tAddresses = new String[] {'hanisha.sfdc@gmail.com'};
                    //singleMail.setToAddresses(tAddresses);
                    singleMail.setToAddresses(toAddresses);
                    //flag to false to stop inserting activity history
                    singleMail.setSaveAsActivity(false);
                    return singleMail;
    }

// Finish the Batch Job
    global void finish(Database.BatchableContext BC) {
 
    }
}