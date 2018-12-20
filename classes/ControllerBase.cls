/**
* Copyright 2013 Forseva, LLC. All rights reserved.
*/
public virtual class ControllerBase {
    
    @TestVisible protected void addSuccessMessage(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, msg));  
    }

    @TestVisible protected void addInfoMessage(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, msg));  
    }

    @TestVisible protected void addWarningMessage(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, msg));       
    }
    
    @TestVisible protected void addErrorMessage(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));     
    }

    @TestVisible protected void handleException(Exception e) {
    	String msg = e.getTypeName() + ' ' + e.getMessage() + ' ' + e.getStackTraceString();
    	System.debug(msg);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,msg));        
    }

}

// EOF