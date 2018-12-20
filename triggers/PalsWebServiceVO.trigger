trigger PalsWebServiceVO on Vehicles_Opportunities__c (before insert) {
    String recordTypeId = Utils.getRecordTypeId('Opportunity', 'Pals Prospect');
    
    Set<Id> opps = new Set<Id>();
    
    for(Vehicles_Opportunities__c vo: Trigger.new){
       opps.add(vo.opportunity__c);
    }
    
    List<Opportunity> allClosed = [Select id from Opportunity where id in :opps and recordTypeId = :recordTypeId and stageName in ('Closed Won', 'Closed Lost')];
    
    Set<Id> allClosedOpps = new Set<id>();
    for(Opportunity o: allClosed){
       allClosedOpps.add(o.id);
    }
    
    for(Vehicles_Opportunities__c vo: Trigger.new){
       if(allClosedOpps.contains(vo.opportunity__r.id)){
           vo.addError('Cannot create new pals prospect vehicle_opportunity. Opportunity id ' + vo.opportunity__r.id + ' is already closed');
       }
    }
}