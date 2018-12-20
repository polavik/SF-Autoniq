@isTest
private class TestMVGController {
	
	
	
	
	
    static testMethod void myUnitTest() {
    	Test.startTest();
        MVG_Price__c mvgRough = new 
		MVG_Price__c(
		Name = '12345678910123', 
		Vehicle_ID__c = '2252251', 
		Whl_Ret_Classification__c = 'rough',  
		Wholesale_Base_Rough__c = 1,
        Wholesale_Base_Clean__c = 2,
        Wholesale_Base_Average__c = 3,
        Wholesale_Base_XClean__c = 4,
        CurrencyIsoCode ='USD'
		);
		insert mvgRough;
        		
		 MVG_Price__c existingmvgRough ;
		     existingmvgRough =	[SELECT 
        	Whl_Ret_Classification__c,
        	CurrencyIsoCode,
        		
        	Wholesale_Base_Rough__c,
        	Wholesale_Base_Clean__c,
        	Wholesale_Base_Average__c,
        	Wholesale_Base_XClean__c,
        	
			Wholesale_Total_Rough__c,
	 		Wholesale_Total_Clean__c,
	 		Wholesale_Total_Average__c,
	 		Wholesale_Total_XClean__c,
			//=======================
			
			Regional_Base_Rough__c,
			Regional_Base_Clean__c,
			Regional_Base_Average__c,
			Regional_Base_XClean__c,

			Regional_Total_Rough__c, 
			Regional_Total_Clean__c,
			Regional_Total_Average__c,  
			Regional_Total_XClean__c,
			//=======================
			
			Retail_Base_Rough__c,  
			Retail_Base_Clean__c, 
			Retail_Base_Average__c,  
			Retail_Base_XClean__c,
			
			Retail_Total_Rough__c,   
			Retail_Total_Clean__c, 
			Retail_Total_Average__c,    
			Retail_Total_XClean__c  			
        	
        	FROM MVG_Price__c	WHERE Whl_Ret_Classification__c = 'rough' and Vehicle_ID__c = '2252251' limit 1];

MVG_Price__c mvgClean = new 
		MVG_Price__c(
		Name = '12345678910123', 
		Vehicle_ID__c = '2252252', 
		Whl_Ret_Classification__c = 'clean',  
		Wholesale_Base_Rough__c = 1,
        Wholesale_Base_Clean__c = 2,
        Wholesale_Base_Average__c = 3,
        Wholesale_Base_XClean__c = 4,
        CurrencyIsoCode ='USD'
        
		);
		insert mvgClean;
		
		 MVG_Price__c existingmvgClean ;
		     existingmvgClean =	[SELECT 
        	Whl_Ret_Classification__c,
        	CurrencyIsoCode,
        	
        	Wholesale_Base_Rough__c,
        	Wholesale_Base_Clean__c,
        	Wholesale_Base_Average__c,
        	Wholesale_Base_XClean__c,
        	
			Wholesale_Total_Rough__c,
	 		Wholesale_Total_Clean__c,
	 		Wholesale_Total_Average__c,
	 		Wholesale_Total_XClean__c,
			//=======================
			
			Regional_Base_Rough__c,
			Regional_Base_Clean__c,
			Regional_Base_Average__c,
			Regional_Base_XClean__c,

			Regional_Total_Rough__c, 
			Regional_Total_Clean__c,
			Regional_Total_Average__c,  
			Regional_Total_XClean__c,
			//=======================
			
			Retail_Base_Rough__c,  
			Retail_Base_Clean__c, 
			Retail_Base_Average__c,  
			Retail_Base_XClean__c,
			
			Retail_Total_Rough__c,   
			Retail_Total_Clean__c, 
			Retail_Total_Average__c,    
			Retail_Total_XClean__c  			
        	
        	FROM MVG_Price__c	WHERE Whl_Ret_Classification__c = 'clean'  and  Vehicle_ID__c = '2252252' limit 1];

MVG_Price__c mvgAverage = new 
		MVG_Price__c(
		Name = '12345678910123', 
		Vehicle_ID__c = '2252253', 
		Whl_Ret_Classification__c = 'average',  
		Wholesale_Base_Rough__c = 1,
        Wholesale_Base_Clean__c = 2,
        Wholesale_Base_Average__c = 3,
        Wholesale_Base_XClean__c = 4,
        CurrencyIsoCode ='CAD'
		);
		insert mvgAverage;		

		 MVG_Price__c existingmvgAverage ;
		     existingmvgAverage =	[SELECT 
        	Whl_Ret_Classification__c,
        	CurrencyIsoCode,
        	
        	Wholesale_Base_Rough__c,
        	Wholesale_Base_Clean__c,
        	Wholesale_Base_Average__c,
        	Wholesale_Base_XClean__c,
        	
			Wholesale_Total_Rough__c,
	 		Wholesale_Total_Clean__c,
	 		Wholesale_Total_Average__c,
	 		Wholesale_Total_XClean__c,
			//=======================
			
			Regional_Base_Rough__c,
			Regional_Base_Clean__c,
			Regional_Base_Average__c,
			Regional_Base_XClean__c,

			Regional_Total_Rough__c, 
			Regional_Total_Clean__c,
			Regional_Total_Average__c,  
			Regional_Total_XClean__c,
			//=======================
			
			Retail_Base_Rough__c,  
			Retail_Base_Clean__c, 
			Retail_Base_Average__c,  
			Retail_Base_XClean__c,
			
			Retail_Total_Rough__c,   
			Retail_Total_Clean__c, 
			Retail_Total_Average__c,    
			Retail_Total_XClean__c  			
        	
        	FROM MVG_Price__c	WHERE Whl_Ret_Classification__c = 'average' and Vehicle_ID__c = '2252253' limit 1];		 
		

MVG_Price__c mvgxclean = new 
		MVG_Price__c(
		Name = '12345678910123', 
		Vehicle_ID__c = '2252254', 
		Whl_Ret_Classification__c = 'extraClean',  
		Wholesale_Base_Rough__c = 1,
        Wholesale_Base_Clean__c = 2,
        Wholesale_Base_Average__c = 3,
        Wholesale_Base_XClean__c = 4,
        CurrencyIsoCode ='CAD'
		);
		insert mvgxclean;		

		 MVG_Price__c existingmvgxclean ;
		     existingmvgxclean =	[SELECT 
        	Whl_Ret_Classification__c,
        	CurrencyIsoCode,
        	Wholesale_Base_Rough__c,
        	Wholesale_Base_Clean__c,
        	Wholesale_Base_Average__c,
        	Wholesale_Base_XClean__c,
        	
			Wholesale_Total_Rough__c,
	 		Wholesale_Total_Clean__c,
	 		Wholesale_Total_Average__c,
	 		Wholesale_Total_XClean__c,
			//=======================
			
			Regional_Base_Rough__c,
			Regional_Base_Clean__c,
			Regional_Base_Average__c,
			Regional_Base_XClean__c,

			Regional_Total_Rough__c, 
			Regional_Total_Clean__c,
			Regional_Total_Average__c,  
			Regional_Total_XClean__c,
			//=======================
			
			Retail_Base_Rough__c,  
			Retail_Base_Clean__c, 
			Retail_Base_Average__c,  
			Retail_Base_XClean__c,
			
			Retail_Total_Rough__c,   
			Retail_Total_Clean__c, 
			Retail_Total_Average__c,    
			Retail_Total_XClean__c  			
        	
        	FROM MVG_Price__c	WHERE Whl_Ret_Classification__c = 'extraClean' and Vehicle_ID__c = '2252254' limit 1];		 


    	PageReference currentPRrough = Page.MVGVFP;
    	PageReference currentPRClean = Page.MVGVFP;
    	
    	currentPRrough.getParameters().put('id', existingmvgRough.Id);
    	currentPRClean.getParameters().put('id', existingmvgClean.Id);

    	Test.setCurrentPageReference(currentPRrough);
    	

    	MVGController mvgctl = new MVGController(new Apexpages.Standardcontroller(existingmvgRough));
    	MVGController mvgctl2 = new MVGController(new Apexpages.Standardcontroller(existingmvgClean));
    	MVGController mvgctl3 = new MVGController(new Apexpages.Standardcontroller(existingmvgAverage));
    	MVGController mvgctl4 = new MVGController(new Apexpages.Standardcontroller(existingmvgxclean));
    	
    	System.assert(mvgctl.strClassification.equalsIgnoreCase('rough'));
    	System.assert(mvgctl2.strClassification.equalsIgnoreCase('clean'));
    	System.assert(mvgctl3.strClassification.equalsIgnoreCase('average'));
    	System.assert(mvgctl4.strClassification.equalsIgnoreCase('extraClean'));
    	
		
		System.assertEquals(mvgctl.BlackBookNational,1);  //Wholesale_Base_Rough__c = 1,
		System.assertEquals(mvgctl2.BlackBookNational,2); //Wholesale_Base_Clean__c = 2,
		System.assertEquals(mvgctl3.BlackBookNational,3); //Wholesale_Base_Average__c = 3,
		System.assertEquals(mvgctl4.BlackBookNational,4); //Wholesale_Base_XClean__c = 4
		
    	 	
    	Test.stopTest();
    	
    	
    }
	
	
	

}