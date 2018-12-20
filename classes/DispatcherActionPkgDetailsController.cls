/**
* This controller will run every time a user views an Action Package detail page.  
* It is used to perform actions (Webservice Callouts, Visualforce Email generation)
* that cannot be performed in the context of a trigger fire due to Apex limitations.  
*/
public class DispatcherActionPkgDetailsController 
{
    
    Action_Package__c pkg;
    List<String> errors;
    boolean purchaseChanged = false;
    boolean caseChanged = false;
    boolean gotoPageTwo = false;
    Set<String> ListFLSUpdate = new Set<String>();
    
    private final ApexPages.StandardController controller;  
        
    public DispatcherActionPkgDetailsController(ApexPages.StandardController controller) 
    {  
        this.controller = controller;
    }
    
    public PageReference redirect() {   
        
        Boolean blnFLSOverride = Utils.GetFLS();

        ID pkgId = controller.getId();
        errors = new List<String>();
        
        pkg = 
            [SELECT
                Accounting_Notified__c,
                Accounting_Notified_Date__c,
                Approved__c,
                Arbitration_Fee__c,
                Case__c,
                Case__r.AccountId,
                Case__r.Contact.Email,
                Case__r.Status,
                Case__r.Type,
                Case__r.Vehicle_ID__c,
                Case__r.Seller__c,
                Case__r.Seller__r.Organization_type__c,
                Case__r.VIN__r.ATC_Sale_Date__c,
                Case__r.VIN__r.ATC_Buyer__r.Name,
                Case__r.VIN__r.ATC_Buyer__r.SAP_Customer_Number__c,
                Case__r.VIN__r.ATC_Seller__r.SAP_Customer_Number__c,
                Case__r.VIN__r.ATC_Seller__r.ATC_Organization_ID__c,
                Case__r.VIN__r.Car_Group_Config_Id__c, 
                Case__r.VIN__r.Country__c,
                Case__r.VIN__r.Payment_Method__c, 
                Case__r.VIN__r.Private_Label__c,
                Case__r.VIN__r.PS_Hold_Package__c,
                Case__r.VIN__r.Transport_Incentive__c,
                Case__r.VIN__r.Transport_Payment_Method_Id__c,
                Case__r.VIN__r.Transport_Sale_Date__c,
                Case__r.VIN__r.Transport_Type__c,
                Case__r.VIN__r.Transport_Void_Package__c,
                Case__r.VIN__r.Vehicle_Payment_Method_Id__c,
                Case__r.VIN__r.Vehicle_Void_Package__c,
                Case__r.VIN__r.Transport_Void_Package__r.Package_Type__c,
                Case__r.VIN__r.Vehicle_Void_Package__r.Package_Type__c,
                Case__r.VIN__r.Sales_Rules__c,
                Case__r.VIN__r.Purchase_Types__c,
                Case__r.VIN__r.Buyout__c,
                Seller_Contact__r.Email,
                Country__c,
                Credit_Amount__c,
                Credit_Reason__c,
                Credit_To__c,
                CurrencyIsoCode,
                Discretionary_Fund_Amount__c,
                Emailed_To__c,
                House_Extra_Costs__c,
                House_Transport_Responsible_Party__c,
                Inspector_Amount__c,
                Invalid_HST_Count__c,
                Invalid_GST_Count__c,
                Invalid_QST_Count__c,
                Name,
                Number_Of_Credits__c,
                Other_Party_Amount__c,
                Package_Type__c,
                Payment_Method__c,
                Private_Label__c,
                Recalled__c,
                Rejected__c,
                Response_Messages__c,
                Sale_Classification__c,
                Seller__c,
                Seller_Amount__c,
                Seller_Extra_Costs__c,
                Send_Results__c,
                Standard_SAP_Transactions__c,
                Submitted__c,
                Tax__c,
                Third_Party_Extra_Costs__c,
                Transport_Hidden__c,
                Transport_Type__c,
                Transporter_Amount__c,
                Send_Show_Transport_Notification__c,
                Void_Vehicle__c,
                Void_House_Transport__c,
                Is_Dealer_Block__c,
                Auto_Approve_Override__c,
                (SELECT CurrencyIsoCode, Extra_Cost_Responsible_Party__c, Extra_Cost_Type__c, Name, Net_Amount__c, Region_Code__c, Tax_Type__c FROM Extra_Costs__r)
            FROM Action_Package__c WHERE Id = :pkgId
            FOR UPDATE];
        
        
        if (pkg.Submitted__c) { 
            try 
            {
                new ActionPackageHelper(pkg).holdPS();
                markPSHold();
            } 
            catch (Exception e) 
            {
                throw e;
            } 
            finally 
            {
                if (purchaseChanged) {
                    update pkg.Case__r.VIN__r;
                }
                if (Schema.sObjectType.Action_Package__c.fields.Submitted__c.isUpdateable() || blnFLSOverride)
                {   
                    pkg.Submitted__c = false;
                }
                else
                {                       
                    ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Submitted__c.getName());
                }
                update pkg;
            }
        }
        
        if (pkg.Recalled__c || pkg.Rejected__c) {
            try 
            {
                new ActionPackageHelper(pkg).releasePSHold();
                unmarkPSHold();
            } 
            catch (Exception e) 
            {
                throw e;
            } 
            finally 
            {
                if (purchaseChanged) 
                {
                    update pkg.Case__r.VIN__r;
                }
                if (Schema.sObjectType.Action_Package__c.fields.Recalled__c.isUpdateable() || blnFLSOverride)
                {   
                    pkg.Recalled__c = false;
                }
                else
                {                       
                    ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Recalled__c.getName());
                }
                if (Schema.sObjectType.Action_Package__c.fields.Rejected__c.isUpdateable() || blnFLSOverride)
                {   
                    pkg.Rejected__c = false;
                }
                else
                {                       
                    ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Rejected__c.getName());
                }
                update pkg;
            }
        }
        
        if (pkg.Approved__c) {
            try 
            {
                if ('AUCTION CREDIT'.equalsIgnoreCase(pkg.Package_Type__c)){
                    AuctionCreditHelper.createCreditsFromActionPackage(pkg);
                    if (Schema.sObjectType.Action_Package__c.fields.Notification_Step__c.isUpdateable() || blnFLSOverride)
                    {   
                        pkg.Notification_Step__c = 'AUCTION_CREDIT_GRANTED';
                    }
                    else
                    {                       
                        ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Notification_Step__c.getName());
                    }
                    if (Schema.sObjectType.Action_Package__c.fields.Notification_Recipient__c.isUpdateable() || blnFLSOverride)
                    {   
                        pkg.Notification_Recipient__c = pkg.Case__r.Contact.Email;
                    }
                    else
                    {                       
                        ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Notification_Recipient__c.getName());
                    }
                }else if('SELLER AUCTION CREDIT'.equalsIgnoreCase(pkg.Package_Type__c)){
                    AuctionCreditHelper.createCreditsFromActionPackage(pkg);
                    if (Schema.sObjectType.Action_Package__c.fields.Notification_Step__c.isUpdateable() || blnFLSOverride)
                    {   
                        pkg.Notification_Step__c = 'AUCTION_CREDIT_GRANTED';
                    }
                    else
                    {                       
                        ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Notification_Step__c.getName());
                    }
                    if (Schema.sObjectType.Action_Package__c.fields.Notification_Recipient__c.isUpdateable() || blnFLSOverride)
                    {   
                        pkg.Notification_Recipient__c = pkg.Seller_Contact__r.Email;
                    }
                    else
                    {                       
                        ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Notification_Recipient__c.getName());
                    }
                }else if(pkg.Auto_Approve_Override__c == true && (
                /*ppm 102221:Salesforce - call made to SAP when PM is Pay Processing ADESA Auction - should not have posted concession
                   cancel psi for PPA  need to have accounting notify process
                */
                    //pkg.Payment_Method__c.toLowerCase() == 'pay processing adesa auction' ||
                    pkg.Payment_Method__c.toLowerCase() == 'pay using other floorplans' ||
                    pkg.Payment_Method__c.toLowerCase() == 'pay adesa worldwide' ||
                    pkg.Payment_Method__c.toLowerCase() == 'adesa\'s centralized payment' ||
                    pkg.Payment_Method__c.toLowerCase() == 'ford credit floorplan - dealerblock' ||
                    pkg.Payment_Method__c.toLowerCase() == 'pay adesa worldwide canada' ||
                    pkg.Payment_Method__c.toLowerCase() == 'toyota financial services floorplan (processed by auction)' ||
                    pkg.Payment_Method__c.toLowerCase() == 'ally floorplan (processed by auction)' ||
                    pkg.Payment_Method__c.toLowerCase() == 'ford credit floorplan - dealerblock' ||
                    pkg.Payment_Method__c.toLowerCase() == 'toyota fin svcs floorplan (processed by auction)' ||
                    pkg.Payment_Method__c.toLowerCase() == 'ally financial floorplan (processed by auction)' ||
                    pkg.Payment_Method__c.toLowerCase() == 'bmw floorplan - dealerblock') 
                ){
                //Do Nothing, we don't want to send this       
                }else{
                    new ActionPackageHelper(pkg).sendPackage();
                    gotoPageTwo = true;
                }
                markVehicleVoid();
                markTransportVoid();
                unmarkPSHold();
                closeParentCase();
            } 
            catch (Exception e) 
            { 
                if (Schema.sObjectType.Action_Package__c.fields.Response_Messages__c.isUpdateable() || blnFLSOverride)
                {   
                    pkg.Response_Messages__c = e.getMessage();
                }
                else
                {                       
                    ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Response_Messages__c.getName());
                }
                throw e;
            } 
            finally 
            {
                if (purchaseChanged) 
                {
                    update pkg.Case__r.VIN__r;
                }
                
                if (caseChanged)
                {
                    update pkg.Case__r;
                }
                
                if (Schema.sObjectType.Action_Package__c.fields.Approved__c.isUpdateable() || blnFLSOverride)
                {   
                    pkg.Approved__c = false;
                }
                else
                {                       
                    ListFLSUpdate.add(Schema.sObjectType.Action_Package__c.getName()+'.'+Schema.sObjectType.Action_Package__c.fields.Approved__c.getName());
                }
                
                update pkg;
                
                if(ListFLSUpdate.size()>0)
                {
                    Utils.SendEmailforFLS('FLS_UPDATE','DispatcherActionPkgDetailsController', ListFLSUpdate);
                }
            }
        }
        
        /* To create the void form, we must first commit the results from the web service callout.    
        * However, Salesforce only commits updates after a page has been processed.  
        * Therefore, before sending out the void form, we will redirect the user to a second visualforce
        * page in order to force a save.  
        */
        
        
        if (gotoPageTwo) 
        {
            PageReference pr = Page.dispatcher_action_pkg_details2;
            pr.getParameters().put('id', pkg.Id);
            return pr;
        } 
        else 
        {
            PageReference ref = controller.view();
            Map<String, String> params = ref.getParameters();
            params.put('nooverride','1');
            return ref;
        }
    }
    
    public void markPSHold() 
    {
        if (pkg.Case__r == null || pkg.Case__r.VIN__r == null || pkg.Case__r.VIN__r.PS_Hold_Package__c == null)
            return;
            
        pkg.Case__r.VIN__r.PS_Hold_Package__c = pkg.Id;
        purchaseChanged = true;
    }
    
    public void unmarkPSHold() 
    {
        if (pkg.Case__r == null || pkg.Case__r.VIN__r == null || pkg.Case__r.VIN__r.PS_Hold_Package__c == null)
            return;
        
        if (pkg.Case__r.VIN__r.PS_Hold_Package__c == pkg.Id) 
        {
            pkg.Case__r.VIN__r.PS_Hold_Package__c = null;
            purchaseChanged = true;
        }
    }
    
    public void markTransportVoid() 
    {
        if (pkg.Void_House_Transport__c) 
        {
            pkg.Case__r.VIN__r.Transport_Void_Package__c = pkg.Id;
            purchaseChanged = true;
        }
    }
    
    public void markVehicleVoid() 
    {
        if (pkg.Void_Vehicle__c) 
        {
            pkg.Case__r.VIN__r.Vehicle_Void_Package__c = pkg.Id;
            purchaseChanged = true;
        }
    }
    
    public void closeParentCase()
    {
        Integer openPackageCount = 
            [SELECT count()
             FROM Action_Package__c
             WHERE Case__c = :pkg.Case__r.Id
             AND Status__c NOT IN ('APPROVED', 'DEACTIVATED', 'CANCELED')];
             
        if (openPackageCount == 0)
        {
            pkg.Case__r.Status = 'Closed';
            caseChanged = true;
        }
        
    }

}