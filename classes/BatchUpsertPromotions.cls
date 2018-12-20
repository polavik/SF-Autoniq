global class BatchUpsertPromotions implements Database.Batchable<SObject>, Database.AllowsCallouts,Database.Stateful, Schedulable  {
    //make your Batchable class implement Database.AllowsCallout
    global String saveResults = '';
    global String deleteResults = '';
    //private String TransportRecordTypeId =  Utils.getRecordTypeId('Opportunity', 'Transport');
     global Set<String> ListFLSUpdate = new Set<String>();
     global Set<String> ListFLSCreate = new Set<String>();
    private String query = 'SELECT Id, Promotion_ID__c,Auction_Title_Reference__c FROM Promotions__c LIMIT 1 ';

 
 global void execute(SchedulableContext sc) 
    {
       BatchUpsertPromotions PromotionProcess = new BatchUpsertPromotions();
       Database.executeBatch(PromotionProcess);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
	Boolean blnFLSOverride = Utils.GetFLS();

    System.debug('####### inside execute');
    HttpCalloutSample loCS = new HttpCalloutSample();
    String lsReturnValue = loCS.testContent();
    System.debug (lsReturnValue);
    lsReturnValue = loCS.getContent('https://wcm.adesa.com/wps/wcm/connect/eBiz-en_US/adesa/?srv=cmpnt&source=library&cmpntid=2ea8a8d7-aa14-4ff0-a17f-5ef313bd858c&WCM_Page.ResetAll=TRUE&CACHE=NONE&CONTENTCACHE=NONE&CONNECTORCACHE=NONE');
    String test;
    test = lsReturnValue ;
    test = test.replaceAll('<Br>','<br>');
    test = test.replaceAll('<BR>','<br>');
    List<List<String>> splitTest = new List<List<String>>(); 
    List<String> rows = test.split('<br>',0);

    List<String> rowValues = new List<String>();
    String outputstring ;

    for(integer i = 0; i < rows.size(); i++){
    string row = rows.get(i).substring(1,rows.get(i).length()-1);//remove the first and last double quote
    rowValues = row.split('",',0);

    List<String> rowValues1= new List<String>();
    for(integer j = 0; j < rowValues.size(); j++)
        {
            outputstring = rowValues.get(j).replaceAll('"','');
            outputstring = outputstring.replaceAll('<BR/>','');
            outputstring = outputstring.replaceAll('<br/>','');
            outputstring = outputstring.replaceAll('\n','');
            outputstring = outputstring.replaceAll('\N','');
            //System.debug('row ' + i + ' entry ' + j + ' = ' +outputstring);
            rowValues1.add(outputstring);
        }
        splitTest.add(rowValues1);
    }
    // new loop from output file
    //-----------------------
    List<String> rowValuesOut = new List<String>();
    String outputstring2 ;
    //List<Promotions__c> PromotionToUpsert = new List<Promotions__c>();
    List<Promotions__c> PromotionToUpdate = new List<Promotions__c>();
    for(integer i = 0; i < splitTest.size(); i++)
    {

        rowValuesOut = splitTest.get(i);
        Promotions__c NewPromo = new Promotions__c();

        for(integer j = 0; j < rowValuesOut.size(); j++)
        { outputstring2 = rowValuesOut.get(j).replaceAll('<BR/>','');

            if (j==0 && outputstring2 !='') 
			{
				//Story B-44003 : FLS UPDATE ACCESS CHECK
				if (Schema.sObjectType.Promotions__c.fields.Promotion_ID__c.isUpdateable()  && Schema.sObjectType.Promotions__c.fields.Promotion_ID__c.isCreateable() || blnFLSOverride)
				{
					NewPromo.Promotion_ID__c = outputstring2 ;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Promotion_ID__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Promotion_ID__c.getName());
				}
			}
            if (j==1 && outputstring2 !='') 
			{
				if (Schema.sObjectType.Promotions__c.fields.State_Reference__c.isUpdateable() && Schema.sObjectType.Promotions__c.fields.State_Reference__c.isCreateable() || blnFLSOverride)
				{
					NewPromo.State_Reference__c = outputstring2 ;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.State_Reference__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.State_Reference__c.getName());
				}
			}
            if (j==2 && outputstring2 !='') 
			{
				if (Schema.sObjectType.Promotions__c.fields.Auction_Title_Reference__c.isUpdateable() && Schema.sObjectType.Promotions__c.fields.Auction_Title_Reference__c.isCreateable() || blnFLSOverride)
				{
					NewPromo.Auction_Title_Reference__c = outputstring2 ;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Auction_Title_Reference__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Auction_Title_Reference__c.getName());
				}
			}
            if (j==3 && outputstring2 !='') 
			{
				if (Schema.sObjectType.Promotions__c.fields.Promotion_Title__c.isUpdateable() && Schema.sObjectType.Promotions__c.fields.Promotion_Title__c.isCreateable() || blnFLSOverride)
				{
					NewPromo.Promotion_Title__c = outputstring2 ;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Promotion_Title__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Promotion_Title__c.getName());
				}
			}
            if (j==4 && outputstring2 !='') 
			{
				if (Schema.sObjectType.Promotions__c.fields.Consignor__c.isUpdateable() && Schema.sObjectType.Promotions__c.fields.Consignor__c.isCreateable() || blnFLSOverride)
				{
					NewPromo.Consignor__c = outputstring2 ;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Consignor__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Consignor__c.getName());
				}
			}
            
            if (j==5 && outputstring2 !='') 
            {
				if (Schema.sObjectType.Promotions__c.fields.Date_Range__c.isUpdateable() && Schema.sObjectType.Promotions__c.fields.Date_Range__c.isCreateable() || blnFLSOverride)
				{
					NewPromo.Date_Range__c = outputstring2 ;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Date_Range__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Date_Range__c.getName());
				}
			}
            
            if (j==6 && i >0 && outputstring2 !='' ) {
                Date dtPub;
                String[] tempStr = outputstring2.split('/');
                //System.debug(' m ' +tempStr[0]);
                Integer m = Integer.valueOf(tempStr[0]);
                Integer d = Integer.valueOf(tempStr[1]);
                Integer y = Integer.valueOf(tempStr[2]);
                y = y + 2000 ;
                dtPub = Date.newInstance(y,m,d);  // Date dtPub = Date.parse(outputstring2) ;  
				
				if (Schema.sObjectType.Promotions__c.fields.Publish_Date__c.isUpdateable() && Schema.sObjectType.Promotions__c.fields.Publish_Date__c.isCreateable() || blnFLSOverride)
				{
					NewPromo.Publish_Date__c = dtPub ; 
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Publish_Date__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Publish_Date__c.getName());
				}
				
				}
            if (j==7 && i >0 && outputstring2 !='') {
                Date dtExp;
                String[] tempStr = outputstring2.split('/');
                //System.debug(' m ' +tempStr[0]);
                Integer m = Integer.valueOf(tempStr[0]);
                Integer d = Integer.valueOf(tempStr[1]);
                Integer y = Integer.valueOf(tempStr[2]);
                y = y + 2000 ;
                dtExp = Date.newInstance(y,m,d);        // Date dtExp = Date.parse(outputstring2) ; 
				
				if (Schema.sObjectType.Promotions__c.fields.Expiry_Date__c.isUpdateable() && Schema.sObjectType.Promotions__c.fields.Expiry_Date__c.isCreateable() || blnFLSOverride)
				{
					NewPromo.Expiry_Date__c = dtExp ; 
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Expiry_Date__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Expiry_Date__c.getName());
				}
				
				}
            if (j==8 && outputstring2 !='') 
            {
				if (Schema.sObjectType.Promotions__c.fields.Hypertext_Reference_URL__c.isUpdateable() && Schema.sObjectType.Promotions__c.fields.Hypertext_Reference_URL__c.isCreateable() || blnFLSOverride)
				{
					NewPromo.Hypertext_Reference_URL__c = outputstring2 ;
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Hypertext_Reference_URL__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Hypertext_Reference_URL__c.getName());
				}
			}
            if (j==9 && outputstring2 !='') 
            {
				if (Schema.sObjectType.Promotions__c.fields.Display_Title__c.isUpdateable() && Schema.sObjectType.Promotions__c.fields.Display_Title__c.isCreateable() || blnFLSOverride)
				{
					NewPromo.Display_Title__c = outputstring2 ; 
				}
				else
				{						
					ListFLSUpdate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Display_Title__c.getName());
					ListFLSCreate.add(Schema.sObjectType.Promotions__c.getName()+'.'+Schema.sObjectType.Promotions__c.fields.Display_Title__c.getName());
				}				
				
			}

            
            //System.debug('row ' + i + ' entry ' + j + ' = ' +rowValuesOut.get(j));
            System.debug('row ' + i + ' entry ' + j + ' =' +outputstring2);
                
        }
            if( i > 0 && i <1000)   {PromotionToUpdate.add(NewPromo);}
            System.debug('Size of PromotionToUpdate ' + PromotionToUpdate.size() );
    }
	
    integer Flag = 1;
    integer blockcount = 1;
    List<Promotions__c> PromotionToUpsert = new List<Promotions__c>();
    //Promotions__c NewPro = new Promotions__c();
	for(integer i = 0; i < PromotionToUpdate.size(); i++)
    {   
        if(Flag== 1)
        {PromotionToUpsert = new List<Promotions__c>();}
        
        if (i < blockcount*100)
        {            
            PromotionToUpsert.add(PromotionToUpdate.get(i) );
             Flag = 0;
        }   
        else
        {
             Flag = 1;
        }
        
          if (PromotionToUpsert.size() > 99 )
          {
            
            upsert PromotionToUpsert Promotion_ID__c ; 
            Flag = 1;
            System.debug('Size of PromotionToUpsert ' + PromotionToUpsert.size() );
            System.debug('I  ' + i);
            System.debug(' Block Count ' +blockcount);
            System.debug(' Flag ' +Flag);
            
            blockcount =blockcount+1;
            PromotionToUpsert = null;
            
            }
    }
	
	if(ListFLSUpdate.size() == 0 && ListFLSCreate.size() ==0)
	{
		
		if (PromotionToUpsert!=null )
		{
		if (PromotionToUpsert.size() !=null )   
		{
			if (PromotionToUpsert.size() >0 )
			{   
				System.debug('Size of PromotionToUpsert ' + PromotionToUpsert.size() );
				upsert PromotionToUpsert Promotion_ID__c ; 
			}
			
		}
		}
	}
 /*
        if (PromotionToUpdate.size() > 0 )
        {
        try 
            { 
            upsert PromotionToUpdate Promotion_ID__c ; 
            //upsert VehicleOppsToUpdate;
            //delete VehicleOppsToDelete;   
            
            }
            catch (DMLException e) 
            { System.debug('retry!');  
            }
        }
        else
        {
            System.debug('Can not Upsert' + PromotionToUpdate.size() ); 
        }
*/        
}
        
  
    
 global void finish(Database.BatchableContext bc) 
    {
		//Story B-44003 : FLS UPDATE ACCESS CHECK
		if(ListFLSUpdate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_UPDATE','CLASS:BatchUpsertPromotions', ListFLSUpdate);
		}
		if(ListFLSCreate.size()>0)
		{
			Utils.SendEmailforFLS('FLS_CREATE','CLASS:BatchUpsertPromotions', ListFLSCreate);
		}
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
    
       Map<String, SF_Tech_Admin_Email__c> emails= SF_Tech_Admin_Email__c.getAll();
        List<String> emailList= new List<String>();
        emailList.addAll(emails.keySet());
        String[] toAddresses = new String[] {};
        
        for (String emailName : emailList) {
         SF_Tech_Admin_Email__c email= emails.get(emailName);
         
         toAddresses.add(email.email__c); 
        }
        
        //String[] toAddresses = new String[] {'SFTechAdminTeam@openlane.com'}; 
        mail.setToAddresses(toAddresses);
        //mail.setReplyTo('lwu@openlane.com');
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('Finished running Promotion Data Download job.'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static testMethod void testBatch() {
       // Test.StartTest();
       // BatchUpsertPromotions om = new BatchUpsertPromotions();
        //om.query = om.query + ' LIMIT 10 ';
       // Database.executeBatch(om);
       // Test.StopTest(); 
    }
    


    
}