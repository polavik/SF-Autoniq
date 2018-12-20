global class Batcher_Task_Emails implements Database.Batchable<SObject> {
global set<Id> EmployeeFirst = new set<Id>();
global set<Id> Employeesecond = new set<Id>();
global set<Id> Employeethird = new set<Id>();
global set<Id> EmployeeFinal = new set<Id>();
global set<Id> ManagerFirst = new set<Id>();
global set<Id> ManagerSecond = new set<Id>();
global set<Id> ManagerFinal = new set<Id>();
global set<Id> SecondmanagerFirst= new set<Id>();
global set<Id> SecondmanagerFinal= new set<Id>();

// "Start" runs when the class in instanciated
/*
global Database.QueryLocator start(Database.BatchableContext bcMain) {

return Database.getQueryLocator([select id,ActivityDate,ownerid,owner.email from task where (Status != 'Completed' or Status != 'Completed - Sold' or Status != 'Completed - Not Interested')
                                         And (ActivityDate =: system.today().addDays(-1)
                                         or ActivityDate =: system.today().addDays(-3) or ActivityDate =: system.today().addDays(-7)
                                         or ActivityDate =: system.today().addDays(-30) or ActivityDate =: system.today().addDays(-45) )]);
}
*/


global Database.QueryLocator start(Database.BatchableContext bcMain) {
    return Database.getQueryLocator([select id,ActivityDate,ownerid,owner.email from task where (Status != 'Completed' and Status != 'Completed - Sold' and Status != 'Completed - Not Interested')
                                         And  (RecordType.name =:'AFC ASM Task' or RecordType.name =:'AFC BDC'  or RecordType.name =:'AFC Branch Task' or RecordType.name =:'4n1 Log a Call')
                                         And (ActivityDate =: system.today().addDays(-1)
                                         or ActivityDate =: system.today().addDays(-3) or ActivityDate =: system.today().addDays(-7)
                                         or ActivityDate =: system.today().addDays(-30) 
                                         or ActivityDate =: system.today().addDays(-45) )]);
}
   
global void execute(Database.BatchableContext bcMain, List<SObject> lstBatchRecords){
    recordsMail(lstBatchRecords);
}

public void recordsMail(List<Task> t){
	Boolean blnFLSOverride = Utils.GetFLS();
    if(t.size()>0){
         Set<String> ListFLSUpdate = new Set<String>();
         List < Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage > ();
         List < Task> toUpdate= new List <Task> ();
        //custom settings to store vf template Ids
        Vf_Templates__c taskTemp = Vf_Templates__c.getorgdefaults();
        Set<Id> Uids = new set<Id>();
        for(task ot:t){
            Uids.add(ot.ownerid);
        }
        
        if(Uids.size()>0){
            Map<id,user> Mapuser = new Map<Id,user>([select id,email,managerid,manager.managerId,manager.manager.name,manager.email,manager.manager.email from user where id In:Uids]);
            if(Mapuser.size()>0){
                for(task o:t){
                    if(o.ActivityDate == system.Today().addDays(-1) && o.ownerId == mapuser.get(o.ownerId).id){
                        EmployeeFirst.add(o.ownerId);
                    }else if(o.ActivityDate == system.Today().addDays(-3) && o.ownerId == mapuser.get(o.ownerId).id){
                        Employeesecond.add(o.ownerId);
                        ManagerFirst.add(o.ownerId);
                    }else if(o.ActivityDate == system.Today().addDays(-7) && o.ownerId == mapuser.get(o.ownerId).id ){
                        Employeethird.add(o.ownerId);
                        ManagerSecond.add(o.ownerId);
                        SecondmanagerFirst.add(o.ownerId);
                    }else if(o.ActivityDate == system.Today().addDays(-30) && o.ownerId == mapuser.get(o.ownerId).id ){
                        EmployeeFinal.add(o.ownerId);
                    }else if(o.ActivityDate == system.Today().addDays(-45) ){
                        Task tu = new Task();
                        
                        //Story B-44003 : FLS UPDATE ACCESS CHECK
                        // showing error in test class for below 
                        /* 
                         if (Schema.sObjectType.Task.fields.Id.isUpdateable() || blnFLSOverride)
                         {                       
                            tu.id = o.id;
                         }
                         else
                         {                      
                            ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Id.getName());
                         }
                         */
                         
                         tu.id = o.id;
                         if (Schema.sObjectType.Task.fields.Status.isUpdateable() || blnFLSOverride)
                         {                       
                             tu.Status ='System Closed';
                         }
                         else
                         {                      
                            ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Status.getName());
                         }       
                         
                        toUpdate.add(tu);
                    
                    }
                }
                if(ListFLSUpdate.size()>0)
                {
                    Utils.SendEmailforFLS('FLS_UPDATE','CLASS:Batcher_Task_Emails', ListFLSUpdate);
                }
                // Employee First Notification Code
                if(EmployeeFirst.size()>0){
                    for(Id i:EmployeeFirst){
                        if(mapuser.get(i).email != null){
                            String[] toAddresses = new String[] {mapuser.get(i).email};
                            Messaging.SingleEmailMessage singleMail = framEmail(i,toAddresses,taskTemp.EmployeeFirst__c);
                            emails.add(singleMail);
                        }
                    }
                }
                // Employee Second Notification Code
                if(Employeesecond.size()>0){
                    for(Id i:Employeesecond ){
                        if(mapuser.get(i).email != null){    
                            String[] toAddresses = new String[] {mapuser.get(i).email};
                            Messaging.SingleEmailMessage singleMail = framEmail(i,toAddresses,taskTemp.Employeesecond__c);
                            emails.add(singleMail);
                        }
                    }
                }
                // Employee Third Notification Code
                if(Employeethird.size()>0){
                    for(Id i:Employeethird ){    
                        if(mapuser.get(i).email != null){
                            String[] toAddresses = new String[] {mapuser.get(i).email};
                            Messaging.SingleEmailMessage singleMail = framEmail(i,toAddresses,taskTemp.Employeethird__c);
                            emails.add(singleMail);
                        }
                    }
                }
                // Employee Final Notification Code
                if(EmployeeFinal.size()>0){
                    for(Id i:EmployeeFinal){
                        if(mapuser.get(i).email != null){
                            String[] toAddresses = new String[] {mapuser.get(i).email};
                            Messaging.SingleEmailMessage singleMail = framEmail(i,toAddresses,taskTemp.EmployeeFinal__c);
                            emails.add(singleMail);
                        }
                    }
                }
                // Manager First Notification  Code
                if(ManagerFirst.size()>0){
                    for(Id i: ManagerFirst ){
                        if(mapuser.get(i).manager.email != null){
                            String[] toAddresses = new String[] {mapuser.get(i).manager.email};
                            Messaging.SingleEmailMessage singleMail = framEmail(mapuser.get(i).manager.Id,toAddresses,taskTemp.ManagerFirst__c);
                            emails.add(singleMail);
                        }
                    }
                }
                // Manager Second Notification Code
                if(ManagerSecond.size()>0){
                    for(Id i:ManagerSecond){
                        if(mapuser.get(i).manager.email != null){
                            String[] toAddresses = new String[] {mapuser.get(i).manager.email};
                            Messaging.SingleEmailMessage singleMail = framEmail(mapuser.get(i).manager.Id,toAddresses,taskTemp.ManagerSecond__c);
                            emails.add(singleMail);
                        }
                    }
                }
                /*
                     // Manager Final Notification Code
                    if(ManagerFinal.size()>0){
                        for(Id i:ManagerFinal){
                            if(mapuser.get(i).manager.email != null){
                                String[] toAddresses = new String[] {mapuser.get(i).manager.email};
                                Messaging.SingleEmailMessage singleMail = framEmail(mapuser.get(i).manager.Id,toAddresses,taskTemp.ManagerFinal__c);
                                emails.add(singleMail);
                            }
                        }
                    }
                */
                // Secondary Manager First Notification Code
                if(SecondmanagerFirst.size()>0){
                    for(Id i:SecondmanagerFirst){
                        if(mapuser.get(i).Manager.Manager.email != null){
                            String[] toAddresses = new String[] {mapuser.get(i).Manager.Manager.email};
                            Messaging.SingleEmailMessage singleMail = framEmail(mapuser.get(i).Manager.ManagerId,toAddresses,taskTemp.SecondmanagerFirst__c);
                            emails.add(singleMail);
                        }
                    }
                }
                /*
                    // Secondary Manager Final Notification Code
                    if(SecondmanagerFinal.size()>0){
                        for(Id i:SecondmanagerFinal){
                            if(mapuser.get(i).Manager.Manager.email != null){
                                String[] toAddresses = new String[] {mapuser.get(i).Manager.Manager.email};
                                Messaging.SingleEmailMessage singleMail = framEmail(mapuser.get(i).Manager.Manager.Id,toAddresses,taskTemp.SecondmanagerFinal__c);
                                emails.add(singleMail);
                            }
                        }
                    }
                */
                
                if(emails.size() > 0){
                    sendmail(emails);
                }
                if(toUpdate.size() > 0){
                    update toUpdate;
                }
            }
        }
    }
}
    
    
public static void sendmail(List <Messaging.SingleEmailMessage> emails){
  // Send the emails in a transaction, then roll it back
            Savepoint sp = Database.setSavepoint();                            
            if (!test.isRunningTest())Messaging.sendEmail(emails);
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
            }
            if (!test.isRunningTest())Messaging.sendEmail(lstMsgsToSend);
}

public Messaging.SingleEmailMessage  framEmail(string id,string[] toAddresses,string templateType){
    
    system.debug('toAddresses==='+toAddresses);
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