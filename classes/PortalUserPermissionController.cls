public class PortalUserPermissionController {
    
       public String strSearch1{get;set;}
       public String strSearch2{get;set;}
       public String strSearch3{get;set;}
       
        
     
     public void PortalUserPermissionController()
     {
        
     }
     
      public PageReference EnableSellerPortal() {
     
        try{
          
          Long lngLoginId2;
          
          // Validation Start 
          if(strSearch1==null ||strSearch1=='')
          {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Enter Login Name'));
            return null;
          }
          else
          {
              strSearch1 = strSearch1.trim();
          }
          
           if(strSearch2==null ||strSearch2=='')
          {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Enter Login Id'));
            return null;
          } 
         else {
             try{
                strSearch2 = strSearch2.trim();
                lngLoginId2  = Long.valueOf(strSearch2);
             }
             catch(exception ex1)
             {
                 Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Enter Valid Login Id'));
                return null;
             }
             
         }          
         
         // Validation End 
          boolean blnStatus1 = PortalUtils.enableSellerPortal(strSearch1,lngLoginId2);  
          if(blnStatus1)
            {   
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,''+'Successfully Enabled Seller Portal'));
                
            }else
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error Occur in Enabled Seller Portal : Error in \'PortalUtils.enableSellerPortal('+strSearch1+','+lngLoginId2+')\''));
            }
        }
        Catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error occur while Enabling Seller Portal : '+ex.getMessage()));
            return null;
        }
          return null;
      }
      
      public PageReference GrantSellerPermission() {
     
        try{
          
          
          Long lngOrgId3;
          // Validation Start 
          if(strSearch1==null ||strSearch1=='')
          {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Enter Login Name'));
            return null;
          }
        else
        {
            strSearch1=strSearch1.trim();
        }         
           
           if(strSearch3==null ||strSearch3=='')
          {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Enter ATC Org. Id'));
            return null;
          }
          else {
             try{
                 strSearch3 = strSearch3.trim();
                lngOrgId3  = Long.valueOf(strSearch3);
             }
             catch(exception ex1)
             {
                 Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,''+'Enter Valid Org. Id'));
                return null;
             }
             
         }
         
         // Validation End           
            
            boolean blnStatus2 = PortalUtils.grantSellerPermission(strSearch1,lngOrgId3); 
            if(blnStatus2)
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,''+'Successfully Granted Seller Permission'));
            }
            else 
            {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error Occur in Granting Seller Permission: Error in \'PortalUtils.grantSellerPermission('+strSearch1+','+lngOrgId3+')\''));
            }
        
        }
        Catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+'Error occur while Granting Seller Permission : '+ex.getMessage()));
            return null;
        }
          return null;
      }
    
}