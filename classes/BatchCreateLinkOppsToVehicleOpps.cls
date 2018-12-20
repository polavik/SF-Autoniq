global class BatchCreateLinkOppsToVehicleOpps implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    global String saveResults = '';
    global String deleteResults = '';
  global Set<String> ListFLSUpdate  = new Set<String>();
  global Set<String> ListFLSCreate  = new Set<String>();
    private String TransportRecordTypeId =  Utils.getRecordTypeId('Opportunity', 'Transport');
    
    
public String query = ' Select id,RecordType__c, Purchase__c, Opportunity__c, Vehicle_Status__c,Talked_about_this_vehicle__c, Status__c,Name, vehicle__c,CreatedDate, Buyer_Org_Id__c From Vehicles_Opportunities__c '+
                'where '+
                'RecordType__c = \'01260000000DhtaAAC\''+
                'and opportunity__c = \'0066000000JLkKaAAL\'' ;
/***********
 private String query = 'select id, name, vehicle_id__c,' + 
                                  'ATC_Seller__r.atc_organization_id__c,' + 
                                  'ATC_Seller__r.name,' +
                                  'ATC_Seller__r.ownerId,' +
                                  'ATC_Buyer__r.atc_organization_id__c,' +
                                  'ATC_Buyer__r.name,' +
                                  'ATC_Buyer__r.ownerId, ' +
                                  'sale_class__c ' +
                            'from purchase__c ' +
                           'where ATC_Sale_Date__c >= Last_N_days:120'+
                             'and sale_class__c in (\'Open D2D\', \'Open Non-Grounding Dealer\', ' +
                                                   '\'Closed D2D\', \'Closed - Non-Grounding Dealer\', ' +
                                                   '\'Closed - Grounding Dealer\')';

UNMAPPED OPPORTUNITY ID = 006R0000006vyFdIAI
***********/

    global void execute(SchedulableContext sc) 
    {
       BatchCreateLinkOppsToVehicleOpps retention = new BatchCreateLinkOppsToVehicleOpps();
       Database.executeBatch(retention);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
    Boolean blnFLSOverride = Utils.GetFLS();
        System.debug('####### inside execute');
        List<Vehicles_Opportunities__c> VehicleOppsList = (List<Vehicles_Opportunities__c>) scope;
    //List<Purchase__c> purchases = (List<Purchase__c>) scope;
    //System.debug('##### size ' + purchases.size());
        Set<String> buyerOrgs = new Set<String>();
        for(Vehicles_Opportunities__c vops: VehicleOppsList){
           buyerOrgs.add(vops.Buyer_Org_Id__c);
        }
                 
      List<Opportunity> OpenOpps = [select id, name, stageName, retention_type__c, ADESA_com_Detail__r.atc_organization_id__c 
                                        from Opportunity
                                       where recordTypeId = :TransportRecordTypeId 
                                        and stageName in ('Open','Transport Quoted','Contact Attempted', 'In Progress-Discussion')
                                         and ADESA_com_Detail__r.atc_organization_id__c  in  :buyerOrgs ];
      
      List<Opportunity> WonLostLast24HoursOpps = [select id, name, stageName, retention_type__c, ADESA_com_Detail__r.atc_organization_id__c 
                                        from Opportunity
                                       where recordTypeId = :TransportRecordTypeId 
                                         and stageName in ('Closed Won', 'Closed Lost')
                                         and ADESA_com_Detail__r.atc_organization_id__c  in  :buyerOrgs
                                         and createddate > YESTERDAY
                                                           ];                            
    Map<String, Opportunity> allCloseOpportunityMap = new Map<String, Opportunity>();
    Map<String, Opportunity> allOpportunityMap = new Map<String, Opportunity>();
    List<Vehicles_Opportunities__c> VehicleOppsToUpdate = new List<Vehicles_Opportunities__c>();
    List<Vehicles_Opportunities__c> VehicleOppsToDelete = new List<Vehicles_Opportunities__c>();
    for(Opportunity opp: OpenOpps){
            allOpportunityMap.put(opp.ADESA_com_Detail__r.atc_organization_id__c , opp);
        }
    for(Opportunity opp: WonLostLast24HoursOpps){
            allCloseOpportunityMap.put(opp.ADESA_com_Detail__r.atc_organization_id__c , opp);
        }
  for(Vehicles_Opportunities__c vops: VehicleOppsList)
       {
         String buyerOrgId = vops.Buyer_Org_Id__c;
        Opportunity opp = allOpportunityMap.get(buyerOrgId);
        Opportunity oppclose = allCloseOpportunityMap.get(buyerOrgId);
        //Id strOpportunityId =null;
    if(opp == null)      
       {
            //Utils.sendSingleMail('Does not exist in Master Opps.... ');
        if (oppclose == null) 
        { //Utils.sendSingleMail('Doest not exist in Close Opps too... '); 
            }
        
        else
        {   //vops.opportunity__c =  oppclose.Id;
             Vehicles_Opportunities__c NewVops = vops.clone(false,false);
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.opportunity__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.opportunity__c.isCreateable() || blnFLSOverride)
      {
        NewVops.opportunity__c =  oppclose.Id;
        //Utils.sendSingleMail('Found Master Opps in 24Hours Opps.... '+ oppclose.name );
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.opportunity__c.getName());
        ListFLSCreate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.opportunity__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.name.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.name.isCreateable() || blnFLSOverride)
      {
        NewVops.name = vops.name;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.name.getName());
        ListFLSCreate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.name.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.Buyer_Org_Id__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.Buyer_Org_Id__c.isCreateable() || blnFLSOverride)
      {
        NewVops.Buyer_Org_Id__c = vops.Buyer_Org_Id__c;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Buyer_Org_Id__c.getName());
        ListFLSCreate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Buyer_Org_Id__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.Purchase__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.Purchase__c.isCreateable() || blnFLSOverride)
      {
        NewVops.Purchase__c = vops.Purchase__c;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Purchase__c.getName());
        ListFLSCreate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Purchase__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.vehicle__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.vehicle__c.isCreateable() || blnFLSOverride)
      {
        NewVops.vehicle__c = vops.vehicle__c;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.vehicle__c.getName());
        ListFLSCreate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.vehicle__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.RecordType__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.RecordType__c.isCreateable() || blnFLSOverride)
      {
        NewVops.RecordType__c = vops.RecordType__c ;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.RecordType__c.getName());
        ListFLSCreate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.RecordType__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.Status__c.isCreateable() || blnFLSOverride)
      {
        NewVops.Status__c = vops.Status__c ;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Status__c.getName());
        ListFLSCreate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Status__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.Talked_about_this_vehicle__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.Talked_about_this_vehicle__c.isCreateable() || blnFLSOverride)
      {
        NewVops.Talked_about_this_vehicle__c = vops.Talked_about_this_vehicle__c ;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Talked_about_this_vehicle__c.getName());
        ListFLSCreate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Talked_about_this_vehicle__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.Vehicle_Status__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.Vehicle_Status__c.isCreateable() || blnFLSOverride)
      {
        NewVops.Vehicle_Status__c = vops.Vehicle_Status__c ;              
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Vehicle_Status__c.getName());
        ListFLSCreate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Vehicle_Status__c.getName());
      }  

            VehicleOppsToUpdate.add(NewVops);
            VehicleOppsToDelete.add(vops);
              
            }
    }       
        else
        {   

            
            //    vops.opportunity__c =  opp.Id;
            Vehicles_Opportunities__c NewVops = vops.clone(false,false);
           
             
            if (Schema.sObjectType.Vehicles_Opportunities__c.fields.opportunity__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.opportunity__c.isCreateable() || blnFLSOverride)
      {
          NewVops.opportunity__c =  opp.Id;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.opportunity__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.name.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.name.isCreateable() || blnFLSOverride)
      {
        NewVops.name = vops.name;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.name.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.Buyer_Org_Id__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.Buyer_Org_Id__c.isCreateable() || blnFLSOverride)
      {
        NewVops.Buyer_Org_Id__c = vops.Buyer_Org_Id__c;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Buyer_Org_Id__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.Purchase__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.Purchase__c.isCreateable() || blnFLSOverride)
      {
        NewVops.Purchase__c = vops.Purchase__c;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Purchase__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.vehicle__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.vehicle__c.isCreateable() || blnFLSOverride)
      {
        NewVops.vehicle__c = vops.vehicle__c;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.vehicle__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.RecordType__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.RecordType__c.isCreateable() || blnFLSOverride)
      {
        NewVops.RecordType__c = vops.RecordType__c ;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.RecordType__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.Status__c.isCreateable() || blnFLSOverride)
      {
        NewVops.Status__c = vops.Status__c ;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Status__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.Talked_about_this_vehicle__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.Talked_about_this_vehicle__c.isCreateable() || blnFLSOverride)
      {
        NewVops.Talked_about_this_vehicle__c = vops.Talked_about_this_vehicle__c ;
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Talked_about_this_vehicle__c.getName());
      }
      
      if (Schema.sObjectType.Vehicles_Opportunities__c.fields.Vehicle_Status__c.isUpdateable() && Schema.sObjectType.Vehicles_Opportunities__c.fields.Vehicle_Status__c.isCreateable() || blnFLSOverride)
      {
        NewVops.Vehicle_Status__c = vops.Vehicle_Status__c ;              
      }
      else
      {            
        ListFLSUpdate.add(Schema.sObjectType.Vehicles_Opportunities__c.getName()+'.'+Schema.sObjectType.Vehicles_Opportunities__c.fields.Vehicle_Status__c.getName());
      }     
      
             
            //Utils.sendSingleMail('Old Opps _opportunity__c and name '+ vops.opportunity__c + vops.Name );
            //Utils.sendSingleMail('NewVops_opportunity__c and name '+ NewVops.opportunity__c + NewVops.Name );
            VehicleOppsToUpdate.add(NewVops);
            VehicleOppsToDelete.add(vops);
        
        }
         
    
        }
        if (VehicleOppsToUpdate.size() > 0 )
        {
            Utils.sendSingleMail('VehiceOppsto update is greater then zero ' );
            upsert VehicleOppsToUpdate;
            delete VehicleOppsToDelete;   
        }       
  
    }
    
    global void finish(Database.BatchableContext bc) 
    {
    //Story B-44003 : FLS UPDATE ACCESS CHECK
    if(ListFLSUpdate.size()>0)
    {
      Utils.SendEmailforFLS('FLS_UPDATE','CLASS:BatchCreateLinkOppsToVehicleOpps', ListFLSUpdate);
    }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {'sshehzad@openlane.com'}; 
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('salesforceemails@openlane.com');
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('Finished running BatchCreateLinkOppsToVehicleOpps job.'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('');
        if(!Test.isRunningTest())
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }         
    }
    
   
    


    
}