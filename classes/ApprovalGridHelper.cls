public  class ApprovalGridHelper {

	public static Map < String, User > approvers {get; set;}
	public static MAP<String, Action_Package_Approvers__c > mapApprovers {set;get;}

	public static void initVar()
	{
		List<Property__c> props = [select property_value__c From Property__c where property_id__c = 'sandbox.suffix'];
		String suffix = props.get(0).property_value__c;  
        if(suffix == null )
            suffix = '';
        system.debug('------------- suffix ' + suffix );        
        
		List<Action_Package_Approvers__c> ApproversList = [select CriteriaKey__c, Name, Manager__c, Director__c, VP__c  From Action_Package_Approvers__c];
		                                                
		MAP<String, Action_Package_Approvers__c > mapApprovers= new Map<String, Action_Package_Approvers__c>();
		SET<String> setApprovers = new SET<String>();
		                                                
		for(Action_Package_Approvers__c approvers: ApproversList){
		    String manager = (!String.isEmpty(approvers.Manager__c))? approvers.Manager__c + suffix : '' ;
		    String director = (!String.isEmpty(approvers.Director__c))? approvers.Director__c + suffix : '' ;
		    String vp = (!String.isEmpty(approvers.VP__c))? approvers.VP__c + suffix : '' ;

		    if(!String.isEmpty(manager)) setApprovers.add(manager);
		    if(!String.isEmpty(director)) setApprovers.add(director);
		    if(!String.isEmpty(vp)) setApprovers.add(vp);

		    Action_Package_Approvers__c temp = new Action_Package_Approvers__c( CriteriaKey__c=approvers.CriteriaKey__c, Manager__c=manager, Director__c=director, VP__c=vp );
		    mapApprovers.put(approvers.CriteriaKey__c, temp);
		}

		ApprovalGridHelper.mapApprovers = mapApprovers;

		system.debug('--------->' + setApprovers);
		system.debug('--------->' + setApprovers.size());
		system.debug('--------->' + mapApprovers);
		system.debug('--------->' + mapApprovers.size());


		List < User > allApprovers = [select id, alias, username from user where username in :setApprovers];
		Map < String, User > approvers = new Map < String, User > ();

		for (User u: allApprovers) {
		    approvers.put(u.username, u);
		    
		}

		system.debug('---------> approvers' + approvers.size());
		system.debug('---------> approvers' + approvers);	

		ApprovalGridHelper.approvers	 = approvers;
	}
}