global class KDM_BatchDedupeRecordByWebService implements Database.Batchable<SObject>, Database.AllowsCallouts,Database.Stateful {
       
    global final String query;
    global string Summary;
    global boolean SendBatchCompleteNotification;
    global string ToEmail;
    global String strWhere;
    global Integer LoadNo;
    global Integer RecurExeCount;
    global Integer MaxRecurExeAllow;
    global Set<String> SetDupeKeysForFutureRun ;
    global Integer CounterProcessRecords;
    global Integer CounterSuccessUpdateRecords;
    
    // Constructor  
    public KDM_BatchDedupeRecordByWebService(Integer intRecurExeCount,Integer intMaxRecurExeAllow,Integer intLoadNo,String strSOQLWhereClause1, String strSOQLWhereClause2,boolean blnSendBatchCompleteNotification, string strToEmail)  
    {
      //query = 'SELECT Id,CRMfusion_dupeKey__c,CRMfusion_Icon__c,CRMfusion_Score__c,CRMfusion_Winner__c,FactType__c,Is_Failed__c,Is_Merged__c,Load__c,Master_Index__c,Mdm_ID__c,Record_Name__c,Record_SF_Id__c FROM DuplicateRecordMerge__c '+strSOQLWhereClause +' Order by ';  
      query = 'SELECT Id,CRMfusion_dupeKey__c FROM DuplicateRecordMerge__c where load__c='+intLoadNo+' '+strSOQLWhereClause1+' '+strSOQLWhereClause2; //' and CRMfusion_Winner__c=true and FactType__c=\'ACCOUNT\' 
      
      Summary='';
      ToEmail = strToEmail;
      LoadNo = intLoadNo;
      MaxRecurExeAllow = intMaxRecurExeAllow;
      RecurExeCount = intRecurExeCount;
      RecurExeCount+=1;
      strWhere = strSOQLWhereClause1;
      SetDupeKeysForFutureRun = new Set<String>();
      CounterProcessRecords=0;
      CounterSuccessUpdateRecords=0;
      SendBatchCompleteNotification = blnSendBatchCompleteNotification;
      System.debug('>>> query: '+query);
      Summary+='SOQL: '+query+'<br/><br/>';
      
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        List<DuplicateRecordMerge__c> List_SuccessMergedDuplicateRecord = new List<DuplicateRecordMerge__c>();
        List<DuplicateRecordMerge__c> List_FailMergedDuplicateRecord = new List<DuplicateRecordMerge__c>();
        
        try{
            if(RecurExeCount>MaxRecurExeAllow)
            {
                Summary+='Too many Recursive Batch...(Exiting)<br/><br/>';
                return;
            }
           //1. Get List of 200 Records
           List<DuplicateRecordMerge__c> List_DuplicateRecordMergeToProcess = (List<DuplicateRecordMerge__c>) scope;           
           System.debug('>>> List_DuplicateRecordMergeToProcess.size(): '+List_DuplicateRecordMergeToProcess.size());           
           if(List_DuplicateRecordMergeToProcess.size() == 0)
           {
               Summary+='No Record to Process..(Exiting)<br/><br/>';
                return;
           }           
           //2. Make Set
           Set<String> SetDupeKeys = new Set<String>();
           List<String> ListDupeKeys = new List<String>();        
           for(DuplicateRecordMerge__c obj: List_DuplicateRecordMergeToProcess)
           {
               if(obj.CRMfusion_dupeKey__c!='' && SetDupeKeys.add(obj.CRMfusion_dupeKey__c))
               {
                    ListDupeKeys.Add(obj.CRMfusion_dupeKey__c);
               }
           }
           System.debug('>>> ListDupeKeys : '+ListDupeKeys);
           Summary+='Winner DupeKeys Count in Execute :'+ListDupeKeys.size()+'<br/>';
           // Retrive Records By DupeKeys
           List<DuplicateRecordMerge__c> List_AllRecord = [SELECT Id, Is_Merged__c, CRMfusion_dupeKey__c, CRMfusion_Winner__c, FactType__c, Master_Index__c, Mdm_ID__c FROM DuplicateRecordMerge__c WHERE Is_Merged__c=false and CRMfusion_dupeKey__c IN :ListDupeKeys and Load__c=:LoadNo order by CRMfusion_dupeKey__c];
           
           // Make Winer ad Duplicate Seperate 
           //List<DuplicateRecordMerge__c> List_WinnerRecord = new List<DuplicateRecordMerge__c>();
           Map<String,DuplicateRecordMerge__c> Map_WinnerDupeKey_To_WinnerRecord = new Map<String,DuplicateRecordMerge__c>();
           List<DuplicateRecordMerge__c> List_DuplicateRecord = new List<DuplicateRecordMerge__c>();
           Integer intCountDuplicate = 0;           
           
           for(DuplicateRecordMerge__c obj: List_AllRecord)
           {
               if(obj.CRMfusion_Winner__c)
               {
                    //List_WinnerRecord.Add(obj);
                    Map_WinnerDupeKey_To_WinnerRecord.put(obj.CRMfusion_dupeKey__c,obj);
               }
               else if(obj.Is_Merged__c==false)
               {
                   intCountDuplicate+=1;
                   if(intCountDuplicate<11)
                   {
                        List_DuplicateRecord.Add(obj);
                   }
                   else
                   {
                       SetDupeKeysForFutureRun.Add(obj.CRMfusion_dupeKey__c);
                   }
               }
           }
           
           Summary+='DuplicateRecord Count :'+List_DuplicateRecord.size()+'<br/>';
           Summary+='SetDupeKeysForFutureRun Count:'+SetDupeKeysForFutureRun.size()+'<br/><br/>';
           
           //Loop on Duplicate records and Merge  with Winner
           
            string token = GetToken();
            System.Debug('>>> token :'+token );    
            if(token==null || token=='')
            {
                Summary+='Token is Empty or Null<br/><br/>';
                return;
            }           
            for(DuplicateRecordMerge__c objDuplicate: List_DuplicateRecord)
            {
                CounterProcessRecords+=1;
                
                DuplicateRecordMerge__c WinerRecord = Map_WinnerDupeKey_To_WinnerRecord.get(objDuplicate.CRMfusion_dupeKey__c);
                if(WinerRecord!=null)
                {
                    if(WinerRecord.FactType__c == objDuplicate.FactType__c)
                    {
                        String masterIndex = objDuplicate.Master_Index__c;
                        String masterIndexChangeTo = WinerRecord.Master_Index__c;
                        String miFactType = objDuplicate.FactType__c; 
                        
                        boolean blnStatus = false;
                        Integer intResponseCode;
                        String ResponseMessage;
                        
                        //if(!Test.isRunningTest())
                        //{                           
                            MIServicePhase2.MiService objMiService = new MIServicePhase2.MiService();
                            objMiService.endpoint_x = Utils.getMiServiceEndpointUrl('mi.service.url');
                            
                            MIServicePhase2.MiUpdateResponse  objMiUpdateResponse = objMiService.updateMasterIndex(token,masterIndex,masterIndexChangeTo,miFactType,null,null);
                            //MIServicePhase2.MiUpdateResponse objMiUpdateResponse;
                            
                            if(objMiUpdateResponse == null)
                            {
                                System.Debug('>>> Error occur on Server while Updating Master Index ' );
                                Summary+='>>>Server Error while Updating Duplicate Master Index:'+masterIndex+' to Winner Master Index:'+masterIndexChangeTo+' <br/>';
                                objDuplicate.Status_Detail__c += 'Error: Webservicee Error while Updating Duplicate Master Index:'+masterIndex+' to Winner Master Index:'+masterIndexChangeTo;
                                objDuplicate.Is_Failed__c = true;
                                continue;
                            }
                             System.Debug('>>> objMiUpdateResponse '+objMiUpdateResponse);
                            blnStatus = objMiUpdateResponse.success;
                            System.Debug('>>> blnStatus :'+blnStatus ); 
                            if(!blnStatus)
                            {
                                Summary+='Error: Webservice return false Status while Updating Duplicate Master Index:'+masterIndex+' to Winner Master Index:'+masterIndexChangeTo+' <br/>';
                                objDuplicate.Status_Detail__c = 'Error: Server Status is false while Updating Duplicate Master Index:'+masterIndex+' to Winner Master Index:'+masterIndexChangeTo;
                                objDuplicate.Is_Failed__c = true;
                                MIServicePhase2.Result myServiceResult = objMiUpdateResponse.result;
                                if(myServiceResult!=null)
                                {
                                    intResponseCode = myServiceResult.resultCode;
                                    System.Debug('>>> intResponseCode :'+intResponseCode );    
                                    ResponseMessage = myServiceResult.message ;
                                    System.Debug('>>> ResponseMessage :'+ResponseMessage );  
                                    Summary+='>>>intResponseCode:'+intResponseCode+'<br/>';
                                    Summary+='>>>ResponseMessage:'+ResponseMessage+'<br/>';
                                    
                                    objDuplicate.Status_Detail__c += ' >>>ResponseCode:'+intResponseCode +' >>>ResponseMessage:'+ResponseMessage;
                                    
                                }
                                List_FailMergedDuplicateRecord.Add(objDuplicate);
                            }
                            else
                            {
                                objDuplicate.Is_Merged__c=true;
                                objDuplicate.Is_Failed__c = false;
                                objDuplicate.Status_Detail__c = 'Success: Updated Duplicate Master Index:'+masterIndex+' With Winner Master Index:'+masterIndexChangeTo;
                                CounterSuccessUpdateRecords+=1;
                                List_SuccessMergedDuplicateRecord.Add(objDuplicate);
                            }
                        //}
                    }
                }
            }          
           
            
        
                      
            //Update Records
            Update List_DuplicateRecord;
                        
        }
        catch (Exception e)
        {
            System.debug('>>>> Error:'+e);
            Summary+='>>>> Catch Error Detail : '+e.getmessage()+'<br/><br/>';      
            if(List_SuccessMergedDuplicateRecord.size()>0)
            {   
                //Update Only Success Merged Records
                Update List_SuccessMergedDuplicateRecord;
                
            }
            if(List_FailMergedDuplicateRecord.size()>0)
            {   
                //Update failed Merged Records
                Update List_FailMergedDuplicateRecord;
            }
        }        
    }
   
    global void finish(Database.BatchableContext bc) 
    {
        if(SendBatchCompleteNotification)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            String[] toAddresses = new String[] {ToEmail}; 
            mail.setToAddresses(toAddresses);           
            mail.setSenderDisplayName('Salesforce Support - Batch Complete Notification');
            mail.setSubject('Finished process of KDM_BatchDedupeRecordByWebService.'); 
            mail.setBccSender(false);
            mail.setUseSignature(false);
            Summary+='<br/><br/> Organization Id: ' + Userinfo.getOrganizationId();
            Summary+='<br/><br/> Organization Name: ' + Userinfo.getOrganizationName() +' ('+ URL.getSalesforceBaseUrl().getHost().substring(0,URL.getSalesforceBaseUrl().getHost().indexOf('.',0)).toUpperCase() +')';         
            Summary+='<br/><br/> Processed Records: ' + String.valueOf(CounterProcessRecords);
            Summary+='<br/><br/> ---------------------------- ';            
            Summary+='<br/> Success Updated Records: ' + String.valueOf(CounterSuccessUpdateRecords);
            Summary+='<br/>>> Fail to Update Records: ' + String.valueOf(CounterProcessRecords - CounterSuccessUpdateRecords);
            Summary+='<br/> ---------------------------- ';
            Summary+='<br/><br/> Batch Recursion Count: ' + String.valueOf(RecurExeCount);
            //Check if pending records exist to process 
            if(!SetDupeKeysForFutureRun.isEmpty())
            {
                Summary+='<br/> Pending DupeKeys: ' + SetDupeKeysForFutureRun.size();
                //List<String> List_DupeKey = new List<String>();
                //List_DupeKey.addAll(SetDupeKeysForFutureRun);
                
                
                String strWhere2 ='';
                strWhere2+=' and CRMfusion_dupeKey__c IN (';
                for(String strDupekey: SetDupeKeysForFutureRun)
                {
                    strWhere2+='\''+strDupekey+'\',';
                }
                
                if(strWhere2.lastIndexOf(',')==strWhere2.length()-1)
                {
                    strWhere2 = strWhere2.substring(0,strWhere2.length()-1);
                }
                strWhere2+=')';
                
                System.Debug('>>> strWhere2:'+strWhere2);
                if(!Test.isRunningTest())
                { 
                    KDM_BatchDedupeRecordByWebService objKDM_BatchDedupeRecordByWebService = new KDM_BatchDedupeRecordByWebService(RecurExeCount,MaxRecurExeAllow,LoadNo,strWhere,strWhere2,SendBatchCompleteNotification,ToEmail);
                    Database.executeBatch(objKDM_BatchDedupeRecordByWebService,1);
                }
            }
            
            mail.sethtmlBody(Summary);
            if(!Test.isRunningTest() && !Sandbox.isSandbox())
            { 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        
    }
    
    public string GetToken()
            {    
       
                String OrgType = Utils.getOrganizationType('org.type');                        
				String token;                        
				
				String ProdNode = Utils.getProductionNode('prod.instance.node')  ;
				
				
				/*
				if( ProdNode !=null)
				{
					ProdNode = ProdNode.toUppercase();
				}                        
				
				String CurrentUrlNode ;
				String HostURL = URL.getSalesforceBaseUrl().getHost();
				System.Debug('>>> HostURL :'+HostURL );                        
				Integer parts = HostURL.countMatches('.');                        
				System.Debug('>>> countMatches:'+parts);
				// changed for check URL node dynamically e.g. na19, c.na19 
				if(parts== 2)
				{                        
					CurrentUrlNode = HostURL.substring(0,HostURL .indexOf('.',0)).toUpperCase();
				}else{        
					
					CurrentUrlNode = HostURL.substring(HostURL.indexOf('.',0)+1,HostURL.indexOf('.',2)).toUpperCase();
				}
				System.Debug('>>> CurrentUrlNode :'+CurrentUrlNode ); 
				if(OrgType == 'prod' && CurrentUrlNode != ProdNode)
				*/
				
				//djpatel on 18-Nov-2016 (B-43977) remove URL dependency
				if(OrgType == 'prod' && Sandbox.isSandbox())
				{        
					System.Debug('>>> Please Contact Administrator to Chage Organization Type in Property Settings...' );                   
					return null;        
				}                     
				 
				 List<String> strPropertyId = new List<String>();
				 strPropertyId.Add('mi.service.token.stg');
				 strPropertyId.Add('mi.service.token.stg2');
				 strPropertyId.Add('mi.service.token.prod');
				 strPropertyId.Add('mi.service.token.test');
				 
				 // work from here 
				 List<Property__c> propTokenList = [select Property_Id__c, Property_Value__c,Property_Value_Encrypted__c from Property__c where Property_Id__c IN :strPropertyId];
				 
				 if( !Sandbox.isSandbox() )
				 {
					 for(Property__c objProp : propTokenList )
					 {
						 if(objProp.Property_Id__c == 'mi.service.token.prod')
						 {
							 token = objProp.Property_Value_Encrypted__c;
						 }
					 }
				 }else{
				 
					 for(Property__c objProp : propTokenList )
					 {
						 if(objProp.Property_Id__c == 'mi.service.token.'+OrgType)
						 {
							 token = objProp.Property_Value_Encrypted__c;
						 }
					 }                        
				 }
			return token;
            }
   
}


//KDM_BatchDedupeRecordByWebService objKDM_BatchDedupeRecordByWebService = new KDM_BatchDedupeRecordByWebService(0,4,3,'and CRMfusion_Winner__c=true and Master_Index__c!=\'\' and FactType__c=\'ACCOUNT\' ',' ',true,'djpatel@openlane.com');
//Database.executeBatch(objKDM_BatchDedupeRecordByWebService,1);