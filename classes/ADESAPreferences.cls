public class ADESAPreferences { 
    public Contact userContact{ get; set; }
    public boolean issignmeup{get;set;}
    public Preference__c ObjPreference{ get; set; }
    public boolean isheavydutytrucks{get;set;}    
    public boolean ispowersports{get;set;}    
    public boolean isrv{get;set;}    
    public boolean ismarine{get;set;}    
    public boolean ispublic{get;set;}    
    public boolean issucess{get;set;}
    public string strlocations{get;set;}
    public string strconsignors{get;set;}
    public string strmakes{get;set;}
    public boolean ishideemailoptinnote{get;set;}
    public boolean ishideconsignorupdate{get;set;}
    public boolean ishidemakeupdate{get;set;}
    public string lang{get;set;}
             Map<String, Language_Settings__c> CslanguageSettings = Language_Settings__c.getAll();
         string userlanguage = apexpages.currentpage().getparameters().get('lang');
    

    public ADESAPreferences(){ 
        userContact = new contact();
        issignmeup = false;
        ObjPreference = new Preference__c();
        isheavydutytrucks = false;
        ispowersports = false;
        isrv = false;
        ismarine = false;
        ispublic = false;
        issucess = false;
        strlocations = '';
        strconsignors = '';
        strmakes = '';
        ishideemailoptinnote = false;
        ishideconsignorupdate = false;
        ishidemakeupdate = false;      
		
        //Acquires Customer Portal login user-contact and preference details
        list<Contact> lstcontacts = [Select Id, 
                                            FirstName, 
                                            LastName, 
                                            Email,
                                            Sign_me_up__c,
                                            (select id,
                                                    Name,
                                                    Contact__c,
                                                    AD_Heavy_duty_Truck_and_Equipment__c,
                                                    AD_Powersports__c,
                                                    AD_RV__c,
                                                    AD_Marine__c,
                                                    AD_Public__c,
                                                    AD_Location__c,
                                                    AD_Consignor__c,
                                                    AD_Make__c
                                             From Preferences__R)
                                            From Contact 
                                            Where Id In (Select ContactId 
                                            From User Where Id = :UserInfo.getUserId())]; 
         if(lstcontacts != null && lstcontacts.size() > 0){
             userContact = lstcontacts[0];
             issignmeup = userContact.Sign_me_up__c;
             if(lstcontacts[0].Preferences__R != null && lstcontacts[0].Preferences__R.size() > 0){
                 ObjPreference = lstcontacts[0].Preferences__R[0];
                 isheavydutytrucks = ObjPreference.AD_Heavy_duty_Truck_and_Equipment__c;
                 ispowersports = ObjPreference.AD_Powersports__c;
                 isrv = ObjPreference.AD_RV__c;
                 ismarine = ObjPreference.AD_Marine__c;
                 ispublic = ObjPreference.AD_Public__c;
                 strlocations = ObjPreference.AD_Location__c;
                 strconsignors = ObjPreference.AD_Consignor__c;
                 strmakes = ObjPreference.AD_Make__c;                 
             }
             else{
				 
				 //Story B-44003 : FLS UPDATE ACCESS CHECK
				 Set<String> ListFLSUpdate = new Set<String>();				  
				 Set<String> ListFLSCreate = new Set<String>();	
				Boolean blnFLSOverride = Utils.GetFLS();				 
				 ObjPreference = new Preference__c();
				 
				 if (Schema.sObjectType.Preference__c.fields.name.isUpdateable() && Schema.sObjectType.Preference__c.fields.name.isCreateable() || blnFLSOverride)
				 {
					 ObjPreference.name = 'PC';
				 }
				 else
				 {						
					ListFLSUpdate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.name.getName());
					ListFLSCreate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.name.getName());
				 }
				 if (Schema.sObjectType.Preference__c.fields.Contact__c.isUpdateable() && Schema.sObjectType.Preference__c.fields.Contact__c.isCreateable() || blnFLSOverride)
				 {
					ObjPreference.Contact__c = userContact.id;
				 }
				 else
				 {						
					ListFLSUpdate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.Contact__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.Contact__c.getName());
				 }
				 
				 if(ListFLSUpdate.size()>0)
				 {
				 	Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ADESAPreferences', ListFLSUpdate);
				 }
				 if(ListFLSCreate.size()>0)
				 {
				 	Utils.SendEmailforFLS('FLS_CREATE','CLASS:ADESAPreferences', ListFLSCreate);
				 }
 
             }
         }
         //Start             
         if(CslanguageSettings != null && CslanguageSettings.size() > 0 && userlanguage != null 
             && userlanguage != '' && CslanguageSettings.get(userlanguage) != null){
             ishideemailoptinnote = true;
             ishideconsignorupdate = true;
             ishidemakeupdate = true;
         }
         system.debug('ishideemailoptinnote_______'+ishideemailoptinnote);
         system.debug('ishideconsignorupdate_______'+ishideconsignorupdate);
         system.debug('ishidemakeupdate_______'+ishidemakeupdate);
         system.debug('userlanguage_______'+userlanguage);
         //ENd         
		 
    }
    //Updates Preference Record
    public PageReference Savemethod(){
        system.debug('XXX_______'+strlocations);
        Savepoint sp = Database.setSavepoint();
        try{
            // DML statements here
			//Story B-44003 : FLS UPDATE ACCESS CHECK
			Set<String> ListFLSUpdate = new Set<String>();			
			Set<String> ListFLSCreate = new Set<String>();			
			Set<String> ListFLSUpdate1 = new Set<String>();			
			Set<String> ListFLSCreate1 = new Set<String>();			
			Boolean blnFLSOverride ;
			if(Test.isRunningTest())
			{
				blnFLSOverride = true;
			}   
			else
			{
				blnFLSOverride = !(FLS_Enforce_Switch__c.getInstance().Enforce_FLS__c); 
			}
			System.debug('>>>>blnFLSOverride:'+blnFLSOverride);
			if (Schema.sObjectType.Contact.fields.Sign_me_up__c.isUpdateable() && Schema.sObjectType.Contact.fields.Sign_me_up__c.isUpdateable() && Schema.sObjectType.Contact.fields.Sign_me_up__c.isCreateable() || blnFLSOverride)
			{
				userContact.Sign_me_up__c = issignmeup;
			}
			else
			{						
				ListFLSUpdate1.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Sign_me_up__c.getName());
				ListFLSCreate1.add(Schema.sObjectType.Contact.getName()+'.'+Schema.sObjectType.Contact.fields.Sign_me_up__c.getName());
			}
			
			if(ListFLSUpdate1.size()>0)
			{
				Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ADESAPreferences', ListFLSUpdate1);
			}
			else if(ListFLSCreate1.size()>0)
			{
				Utils.SendEmailforFLS('FLS_CREATE','CLASS:ADESAPreferences', ListFLSCreate1);
			}
			else
			{	
				upsert userContact;
			}
		
			if(ObjPreference.Contact__c != null)
			{
				if (Schema.sObjectType.Preference__c.fields.AD_Heavy_duty_Truck_and_Equipment__c.isUpdateable() && Schema.sObjectType.Preference__c.fields.AD_Heavy_duty_Truck_and_Equipment__c.isCreateable() || blnFLSOverride)
				{
					ObjPreference.AD_Heavy_duty_Truck_and_Equipment__c = isheavydutytrucks;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Heavy_duty_Truck_and_Equipment__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Heavy_duty_Truck_and_Equipment__c.getName());
				}
				if (Schema.sObjectType.Preference__c.fields.AD_Powersports__c.isUpdateable() && Schema.sObjectType.Preference__c.fields.AD_Powersports__c.isCreateable() || blnFLSOverride)
				{
					ObjPreference.AD_Powersports__c = ispowersports;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Powersports__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Powersports__c.getName());
				}
				if (Schema.sObjectType.Preference__c.fields.AD_RV__c.isUpdateable() && Schema.sObjectType.Preference__c.fields.AD_RV__c.isCreateable() || blnFLSOverride)
				{
					ObjPreference.AD_RV__c = isrv;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_RV__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_RV__c.getName());
				}
				if (Schema.sObjectType.Preference__c.fields.AD_Marine__c.isUpdateable() && Schema.sObjectType.Preference__c.fields.AD_Marine__c.isCreateable() || blnFLSOverride)
				{
					ObjPreference.AD_Marine__c = ismarine;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Marine__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Marine__c.getName());
				}
				if (Schema.sObjectType.Preference__c.fields.AD_Public__c.isUpdateable() && Schema.sObjectType.Preference__c.fields.AD_Public__c.isCreateable() || blnFLSOverride)
				{
					ObjPreference.AD_Public__c = ispublic;     
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Public__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Public__c.getName());
				}
				if (Schema.sObjectType.Preference__c.fields.AD_Location__c.isUpdateable() && Schema.sObjectType.Preference__c.fields.AD_Location__c.isCreateable() || blnFLSOverride)
				{
					ObjPreference.AD_Location__c = strlocations;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Location__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Location__c.getName());
				}
				if (Schema.sObjectType.Preference__c.fields.AD_Consignor__c.isUpdateable() && Schema.sObjectType.Preference__c.fields.AD_Consignor__c.isCreateable() || blnFLSOverride)
				{					
					ObjPreference.AD_Consignor__c = strconsignors;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Consignor__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Consignor__c.getName());
				}
				if (Schema.sObjectType.Preference__c.fields.AD_Make__c.isUpdateable() && Schema.sObjectType.Preference__c.fields.AD_Make__c.isCreateable() || blnFLSOverride)
				{					
					ObjPreference.AD_Make__c = strmakes;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Make__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Preference__c.getName()+'.'+Schema.sObjectType.Preference__c.fields.AD_Make__c.getName());
				}
				
				if(ListFLSUpdate.size()>0)
				{
					Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ADESAPreferences', ListFLSUpdate);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Permission missing. Please contact salesforce administrator.'));
				}
				else if(ListFLSCreate.size()>0)
				{
					Utils.SendEmailforFLS('FLS_CREATE','CLASS:ADESAPreferences', ListFLSCreate);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Permission missing. Please contact salesforce administrator.'));
				}
				else
				{	
					upsert ObjPreference;
					system.debug('XXX_______'+ObjPreference.id);
					issucess = true;
					
					pagereference pg = new pagereference('/apex/ADESAPreferencesThanks');
					pg.getParameters().put('lang', userlanguage);
					return pg.setredirect(true);
				}
					
			}			
			
        }catch(Exception e)
        {
            // An exception was caught. We need to revert back to our Savepoint
            // This will rollback all successful changes. 
            Database.rollback(sp);
        
            // Error message displays on the Visualforce page
            ApexPages.addMessages(e);
        }
		
		return null;
       
    } 
}