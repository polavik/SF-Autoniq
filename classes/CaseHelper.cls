public class CaseHelper 
{ 
        @future(callout=true)
    public static void openLienCase(List<ID> caseIds)
    {
        Map<Id, String> caseIdDesc = new Map<Id, String>();
        List<Case> cases = new List<Case>();
        Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();

        List<RecordType> rts = [SELECT id,Name FROM RecordType WHERE SobjectType ='Case'];
        
        for (RecordType rt  : rts ) {
               caseIdDesc.put(rt.id,rt.Name);     
         }
     if (caseIds.size()>0){
            cases = [SELECT VIN__r.Vehicle_ID__c, status,reason, type,id,RecordTypeId FROM Case WHERE Id IN :caseIds];
           for (Case c : cases)
            {
                Long vehicleId = Long.valueOf(c.VIN__r.Vehicle_ID__c);
                String recordTypeName = '';
                if (caseIdDesc.get(c.RecordTypeId)!=null){
                   recordTypeName = caseIdDesc.get(c.RecordTypeId);
                   Logger.info(c, 'Calling Mediator operation: recordTypeName =' + recordTypeName  );
    
                }
                Logger.info(c, 'Calling Mediator operation: updateOpenLienCaseStatus(' + c.VIN__r.Vehicle_ID__c+','+recordTypeName +','+c.reason+',' + c.status+')');
                String response ='';                
                
try{
                response = ms.updateOpenLienCaseStatus(vehicleId ,recordTypeName ,c.reason,c.status);
                Logger.info(c, 'updateOpenLienCaseStatusreturn code: ' + response);
     
} catch (Exception e) {
     //Generic exception handling code here
} finally {
     //optional finally block
     //code to run whether there is an exception or not
                
                if (response != null)
                {
                   
                        Logger.info(c, 'updateOpenLienCaseStatus return message: ' + response );
                   
                }   
}  //Finally                       
            }
        }  

       
        Logger.flush();
    }
    
    }