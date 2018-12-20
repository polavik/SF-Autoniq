public with sharing Class TaskExtController
{
    //public Integer count = 0;
    // public Integer getCount() {
    //    return count;
    //}
    
    public Task ObjTask{get;set;}
    public Activity_Detail__c Activity_Detail{get;set;}
    public Set<String> ListFLSUpdate ;
    public Set<String> ListFLSCreate ;
	 
    public TaskExtController(ApexPages.StandardController controller) {
    
    try{
		
		if(ListFLSUpdate == null)
		{
			ListFLSUpdate = new Set<String>();
		}
		
		if(ListFLSCreate == null)
		{
			ListFLSCreate = new Set<String>();
		}
		Boolean blnFLSOverride = Utils.GetFLS();
        ObjTask = (Task)controller.getRecord();
        
         string strWhatId = apexpages.currentpage().getparameters().get('whatid');
         string strOwnerId = apexpages.currentpage().getparameters().get('OwnerId');
         string strSubject = apexpages.currentpage().getparameters().get('subject');
         string strStatus = apexpages.currentpage().getparameters().get('status');
         string strwhoid = apexpages.currentpage().getparameters().get('whoid');
         system.debug('>>>> strwhoid:'+strwhoid);
         //string strDueDate = apexpages.currentpage().getparameters().get('DueDate');
         //Date TaskDueDate = Date.valueOf(EncodingUtil.urlDecode(strDueDate,'UTF-8') );
		if(ObjTask!=null && ObjTask.Id!=null)
        {  
		
         if(strwhoid!=null && strwhoid!='')
         {
			if (Schema.sObjectType.Task.fields.whoid.isUpdateable() || blnFLSOverride)
			{
				ObjTask.whoid = strwhoid ;
			}
			else
			{						
				ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.whoid.getName());
			}
         }
         system.debug('>>>> ObjTask.whoid:'+ObjTask.whoid);
		 
		 if (Schema.sObjectType.Task.fields.WhatId.isUpdateable() || blnFLSOverride)
		 {
			 ObjTask.WhatId = strWhatId ;
		 }
		 else
		 {						
		 	ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.WhatId.getName());
		 }
		 
		 if (Schema.sObjectType.Task.fields.OwnerId.isUpdateable() || blnFLSOverride)
		 {
			 ObjTask.OwnerId = strOwnerId ;
		 }
		 else
		 {						
		 	ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.OwnerId.getName());
		 }
		 
		 if (Schema.sObjectType.Task.fields.Subject.isUpdateable() || blnFLSOverride)
		 {
			 ObjTask.Subject= strSubject ;
		 }
		 else
		 {						
		 	ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Subject.getName());
		 }
		 
		 if (Schema.sObjectType.Task.fields.Status.isUpdateable() || blnFLSOverride)
		 {
			 ObjTask.Status = strStatus ;
		 }
		 else
		 {						
		 	ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Status.getName());
		 }
		 
		 if (Schema.sObjectType.Task.fields.ActivityDate.isUpdateable() || blnFLSOverride)
		 {
			 ObjTask.ActivityDate = Date.today();
		 }
		 else
		 {						
		 	ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.ActivityDate.getName());
		 }
         
         
            System.debug('>>> Inside If loop');
                  
            Task tempTask = [SELECT Activity_Detail__c FROM Task WHERE Id=:ObjTask.Id ];
            if(tempTask.Activity_Detail__c != null)
            {
                System.debug('>>> Inside If->IF loop');
                List<Activity_Detail__c > ListActivityDetails = [SELECT Activity_Type1__c,Activity_Type2__c,Auction_Access_Number__c,Activity_Volume__c ,ADESA_Sale_Type_2__c ,ADESA_Sale_Type_3__c ,ADESA_Sale_Type_4__c ,Auction_3__c ,Auction_4__c ,sharedresourceauction__c ,Consignors_Pitched_2__c ,Consignors_Pitched_3__c ,Consignors_Pitched_4__c ,Buy_Commitments_2__c ,Buy_Commitments_3__c ,Buy_Commitments_4__c ,Buy_No_Commitment_Reasons_2__c ,Buy_No_Commitment_Reasons_3__c ,Buy_No_Commitment_Reasons_4__c ,Call_Action__c ,Call_Disposition__c ,Call_Outcome_Log_1_Link__c ,Call_Outcome_Log_2_Link__c ,Call_Outcome_Log_3_Link__c ,Call_Outcome_Log_4_Link__c ,Flexible__c ,Number_Reserved_Units_2__c ,One__c ,PhoneNumber__c ,Sale_Event_Date_2__c ,Sale_Event_Date_3__c ,Sale_Event_Date_4__c ,Sell_Commitments_2__c ,Sell_No_Commitment_Reasons2__c ,Sell_Commitments_3__c ,Sell_Commitments_4__c ,Topics__c  FROM Activity_Detail__c WHERE Id=:tempTask.Activity_Detail__c ];
                if(ListActivityDetails.size()>0)
                {
                    Activity_Detail = ListActivityDetails[0];
                }
    
            }
            else
            {
                System.debug('>>> Inside If->else loop');
                Activity_Detail = new Activity_Detail__c();                
                
            }
        }
        else
        {
			if(strwhoid!=null && strwhoid!='')
			 {
				if (Schema.sObjectType.Task.fields.whoid.isCreateable() || blnFLSOverride)
				{
					ObjTask.whoid = strwhoid ;
				}
				else
				{						
					ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.whoid.getName());
				}
			 }
			 system.debug('>>>> ObjTask.whoid:'+ObjTask.whoid);
			 
			 if (Schema.sObjectType.Task.fields.WhatId.isCreateable() || blnFLSOverride)
			 {
				 ObjTask.WhatId = strWhatId ;
			 }
			 else
			 {						
				ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.WhatId.getName());
			 }
			 
			 if (Schema.sObjectType.Task.fields.OwnerId.isCreateable() || blnFLSOverride)
			 {
				 ObjTask.OwnerId = strOwnerId ;
			 }
			 else
			 {						
				ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.OwnerId.getName());
			 }
			 
			 if (Schema.sObjectType.Task.fields.Subject.isCreateable() || blnFLSOverride)
			 {
				 ObjTask.Subject= strSubject ;
			 }
			 else
			 {						
				ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Subject.getName());
			 }
			 
			 if (Schema.sObjectType.Task.fields.Status.isCreateable() || blnFLSOverride)
			 {
				 ObjTask.Status = strStatus ;
			 }
			 else
			 {						
				ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Status.getName());
			 }
			 
			 if (Schema.sObjectType.Task.fields.ActivityDate.isCreateable() || blnFLSOverride)
			 {
				 ObjTask.ActivityDate = Date.today();
			 }
			 else
			 {						
				ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.ActivityDate.getName());
			 }
		 
            System.debug('>>> Inside else loop');
            Activity_Detail = new Activity_Detail__c();
            String stringWhatId = ObjTask.WhatId;
            
            if(stringWhatId!=null)
            {
                if(stringWhatId.startsWith('001'))
                {
                    
                    List<Account> ListAcct = [Select Id,Auction_Access_Number__c FROM Account WHERE id=:ObjTask.WhatId];     
                    if(ListAcct.size() == 1)
                    {
						 if (Schema.sObjectType.Activity_Detail__c.fields.Auction_Access_Number__c.isUpdateable() || blnFLSOverride)
						 {
							  Activity_Detail.Auction_Access_Number__c = ListAcct[0].Auction_Access_Number__c;
							  System.debug('>>> ListAcct[0].Auction_Access_Number__c: '+ListAcct[0].Auction_Access_Number__c);
						 }
						 else
						 {						
							ListFLSUpdate.add(Schema.sObjectType.Activity_Detail__c.getName()+'.'+Schema.sObjectType.Activity_Detail__c.fields.Auction_Access_Number__c.getName());
						 }                       
                    }
                }
            }
        }
		
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:TaskExtController', ListFLSUpdate);
		}
		
		if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:TaskExtController', ListFLSCreate);
		}
		
        }
        catch(Exception ex)
        {
            System.debug('>>> Error Catch '+ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Invalid URL.'));
        }
        
    }
         
    public PageReference save() {
        try{
				System.debug('>>> ObjTask:'+ObjTask);
				System.debug('>>> Activity_Detail:'+Activity_Detail);
				if(ListFLSUpdate == null)
				{
					ListFLSUpdate = new Set<String>();
				}
				
				if(ListFLSCreate == null)
				{
					ListFLSCreate = new Set<String>();
				}
				Boolean blnFLSOverride = Utils.GetFLS();
				Upsert Activity_Detail;
				
				if(ObjTask!= null && ObjTask.Id != null)
				{
					if (Schema.sObjectType.Task.fields.Activity_Detail__c.isUpdateable() || blnFLSOverride)
					{
						ObjTask.Activity_Detail__c = Activity_Detail.Id;				
					}
					else
					{						
						ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Activity_Detail__c.getName());
					}
				}
				else
				{
					
					if (Schema.sObjectType.Task.fields.Activity_Detail__c.isCreateable() || blnFLSOverride)
					{
						ObjTask.Activity_Detail__c = Activity_Detail.Id;				
					}
					else
					{						
						ListFLSCreate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Activity_Detail__c.getName());
					}
				}
				
				if(ListFLSUpdate.size()>0)
				{
					Utils.SendEmailforFLS('FLS_UPDATE','CLASS:TaskExtController', ListFLSUpdate);
					return null;
				}
				else if(ListFLSCreate.size()>0)
				{
					Utils.SendEmailforFLS('FLS_CREATE','CLASS:TaskExtController', ListFLSCreate);
					return null;
				}
				else
				{			
					Upsert ObjTask;
					
					System.debug('>>> ObjTask:'+ObjTask);
					System.debug('>>> Activity_Detail Id:'+Activity_Detail.id);
					
					PageReference newPage = New PageReference('/');            
					String retUrl = apexpages.currentpage().getparameters().get('retURL');
					newPage.getParameters().put('retURL',retUrl);
					return newPage;  
				}			
          } catch (Exception e){
                return null;
          }
    }
    
    public PageReference SaveNewTask() {
       //Add Save Logic Here   
       Upsert Activity_Detail;           
		Boolean blnFLSOverride = Utils.GetFLS();
		if (Schema.sObjectType.Task.fields.Activity_Detail__c.isUpdateable() || blnFLSOverride)
		{
		   ObjTask.Activity_Detail__c = Activity_Detail.Id;       						
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Activity_Detail__c.getName());
		}
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:TaskExtController', ListFLSUpdate);
			return null;
		}
			
		   Upsert ObjTask;
		   
		   
		   PageReference newPage= new PageReference('/apex/TaskVisualForcePage?');
			
		   //String retUrl = apexpages.currentpage().getparameters().get('retURL');
		   //newPage.getParameters().put('retURL',retUrl);
		   String strWhoId= apexpages.currentpage().getparameters().get('whoid');
		   newPage.getParameters().put('whoid',strWhoId);
		   
		   String strWhatId = apexpages.currentpage().getparameters().get('whatid');
		   newPage.getParameters().put('whatid',strWhatId);
		   
		   newPage.getParameters().put('retURL',strWhatId);
		   
		   String strOwnerId = apexpages.currentpage().getparameters().get('OwnerId');
		   newPage.getParameters().put('OwnerId',strOwnerId);
		   
		   String strSubject = apexpages.currentpage().getparameters().get('subject');
		   newPage.getParameters().put('subject',strSubject);
		   
		   String strStatus = apexpages.currentpage().getparameters().get('status');
		   newPage.getParameters().put('status',strStatus);
			
		   newPage.setRedirect(true);
		   return newPage;
        
       // redirect to a Visualforce page containing a url parm
       //PageReference MyNewPage = new PageReference('/apex/TaskVisualForcePage?whatid=' + strWhatId );    
       //MyNewPage.setRedirect(true);      
       //return MyNewPage;             
          
      
    }
    
    public PageReference SaveNewEvent()
    {
       //Add Save Logic Here      
       Upsert Activity_Detail;            
       Boolean blnFLSOverride = Utils.GetFLS();
		if (Schema.sObjectType.Task.fields.Activity_Detail__c.isUpdateable() || blnFLSOverride)
		{
		   ObjTask.Activity_Detail__c = Activity_Detail.Id;       						
		}
		else
		{						
			ListFLSUpdate.add(Schema.sObjectType.Task.getName()+'.'+Schema.sObjectType.Task.fields.Activity_Detail__c.getName());
		}
		
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:TaskExtController', ListFLSUpdate);
			return null;
		}
       Upsert ObjTask;
       
       
       PageReference newPage = New PageReference('/00U/e?');           
       
       String retUrl = apexpages.currentpage().getparameters().get('retURL');
       newPage.getParameters().put('retURL',retUrl);
       
       String strWhatId = apexpages.currentpage().getparameters().get('WhatId');
       newPage.getParameters().put('what_id',strWhatId);
       
       String strOwnerId = apexpages.currentpage().getparameters().get('OwnerId');
       newPage.getParameters().put('ownerid',strOwnerId);
       
       newPage.getParameters().put('who_id',ObjTask.whoid);
       
       newPage.getParameters().put('evt5',ObjTask.Subject);
       
       
       return newPage;
      
    }

    /*
     public PageReference  WhatIdChangedAction() {
     system.debug('>>> WhatId:'+ObjTask.whatid);
     //count++;
     return null;
     }
    */
    
}