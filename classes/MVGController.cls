public class MVGController {

public MVG_Price__c mvg {get; set;}

    
public Double BlackBookNational {get;set;}
public Double BlackBookRegional {get;set;}
public Double BlackBookRetail {get;set;}

public Double BlackBookNationalAdj {get;set;}
public Double BlackBookRegionalAdj {get;set;}
public Double BlackBookRetailAdj {get;set;}

public String BBClass {get;set;}
public String strClassification {get;set;}
public Boolean bolRendered {get;set;} 
public String Countrycode {get;set;}

public MVGController(ApexPages.StandardController stdController) 
    {
    
         ID mvgid = stdController.getId();
        
         
     mvg =  [SELECT 
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
            
            FROM MVG_Price__c   WHERE Id = :mvgid];
        
     if (mvg.Whl_Ret_Classification__c == null)
     {  strClassification ='';
        }
     else
     { strClassification =mvg.Whl_Ret_Classification__c;
        }
     
if ( strClassification.equalsIgnoreCase('rough')) {
    BlackBookNational = mvg.Wholesale_Base_Rough__c;
    BlackBookNationalAdj = mvg.Wholesale_Total_Rough__c;
    
    BlackBookRegional = mvg.Regional_Base_Rough__c;
    BlackBookRegionalAdj = mvg.Regional_Total_Rough__c;

    BlackBookRetail = mvg.Retail_Base_Rough__c ;
    BlackBookRetailAdj = mvg.Retail_Total_Rough__c; 
    
} 
else if (strClassification.equalsIgnoreCase('clean')) {
    BlackBookNational = mvg.Wholesale_Base_Clean__c;
    BlackBookNationalAdj = mvg.Wholesale_Total_Clean__c;
    
    BlackBookRegional = mvg.Regional_Base_Clean__c;
    BlackBookRegionalAdj = mvg.Regional_Total_Clean__c;

    BlackBookRetail = mvg.Retail_Base_Clean__c ;
    BlackBookRetailAdj = mvg.Retail_Total_Clean__c; 
    
} 
else if (strClassification.equalsIgnoreCase('average')) {
    BlackBookNational = mvg.Wholesale_Base_Average__c;
    BlackBookNationalAdj = mvg.Wholesale_Total_Average__c;
    
    BlackBookRegional = mvg.Regional_Base_Average__c;
    BlackBookRegionalAdj = mvg.Regional_Total_Average__c;

    BlackBookRetail = mvg.Retail_Base_Average__c ;
    BlackBookRetailAdj = mvg.Retail_Total_Average__c;   
    
    
} 
else if (strClassification.equalsIgnoreCase('extraClean')) {
    BlackBookNational = mvg.Wholesale_Base_XClean__c;
    BlackBookNationalAdj = mvg.Wholesale_Total_XClean__c;
    
    BlackBookRegional = mvg.Regional_Base_XClean__c;
    BlackBookRegionalAdj = mvg.Regional_Total_XClean__c;

    BlackBookRetail = mvg.Retail_Base_XClean__c ;
    BlackBookRetailAdj = mvg.Retail_Total_XClean__c;    
    
} 
else {
    BlackBookNational = 0;
    BlackBookNationalAdj = 0;
    
    BlackBookRegional = 0;
    BlackBookRegionalAdj = 0;
    
    BlackBookRetail = 0;
    BlackBookRetailAdj = 0; 
    
}

     if (mvg.Whl_Ret_Classification__c == null)
     {  strClassification ='';
        
        }
     else
     { strClassification =mvg.Whl_Ret_Classification__c;
       strClassification = strClassification.substring(0,1).toUpperCase()+ strClassification.substring(1,strClassification.length());   
        }
   if(mvg.CurrencyIsoCode == null)
    {   bolRendered =false;
    }
   
   else {
    Countrycode = mvg.CurrencyIsoCode;
    
    if(Countrycode.equalsIgnoreCase('USD'))
    {
        bolRendered =false;}    
     else {
        bolRendered = true;}
   }    
    
 }
             
  



}