public class VoidFormController {
    
    public Action_Package__c pkg {get; set;}
    
    public String accountName {get; set;}
    public String actualPickup {get; set;}
    public String actualDropoff {get; set;}
    public String approvers {get; set;}
    public Contact ctc {get; set;}
    public String dateTitleReceivedBackFromBuyer {get; set;}
    public String dateTitleSentToBuyer {get; set;}
    public String finalApprovalDate {get; set;}
    public String handlesTitle {get; set;}
    public String mileage {get; set;}
    public String ownerName {get; set;}
    public String paymentReceivedDate {get; set;}
    public String paymentSentDate {get; set;}
    public String responseMessages {get; set;}
    public String saleDate {get; set;}
    public String salePriceForVehicle {get; set;}
    public String salePriceForVehicleTax {get; set;}
    public String SAPTransactions {get; set;}
    public String transportFee {get; set;}
    public String transportFeeTax {get; set;}
    public String transportIncentive {get; set;}
    public String transportType {get; set;}
    public String voidHouseTransport {get; set;}
    public String consigneeName {get; set;}
    public String stockNumber {get; set;}
    public String CaseAuctionPackageNumber {get; set;}
    
    
    public Boolean renderTitleSection {get; set;}
    
    public List<FormattedExtraCost> extraCosts {get; set;}
    public List<FormattedActionPackageDocument> fiDocs {get; set;}
    public List<FormattedActionPackageDocument> sdDocs {get; set;}

    
    ApexPages.StandardController stdController;
    
    public VoidFormController(ApexPages.StandardController stdController) {      
        this.stdController = stdController;
        ID pkgId = stdController.getId();   
        String strSellerOrgId;
        Consignor_Mapper__c objConsignee ;
        pkg = 
            [SELECT 
                Case__r.Account.Name,
                Case__r.Actual_Pickup__c,
                Case__r.Actual_Dropoff__c,
                Case__r.Claim_Resolution_Comments__c,
                Case__r.Contact.Name,
                Case__r.Contact.Phone,
                Case__r.CaseNumber,
                Case__r.Payment_Method__c,
                Case__r.Payment_Recd__c,
                Case__r.Private_Label__c,
                Case__r.Sale_Date__c,
                Case__r.Sale_Price__c,
                Case__r.Seller__r.Name,
                Case__r.Transport_Fee__c,
                Case__r.Type,
                Case__r.VIN__r.ATC_Transporter__r.Name,
                Case__r.VIN__r.ATC_Seller_Adesa_com_Detail__r.ATC_Organization_ID__c,
                Case__r.VIN__r.Country__c,
                Case__r.VIN__r.Handles_Payment__c,
                Case__r.VIN__r.Handles_Title__c,
                Case__r.VIN__r.Mileage__c,
                Case__r.VIN__r.Name,
                Case__r.VIN__r.Payment_Received__c,
                Case__r.VIN__r.Payment_Sent_to_Seller__c,
                Case__r.VIN__r.Title_Received_From_Buyer__c,
                Case__r.VIN__r.sale_class__c,
                Case__r.VIN__r.Title_Sent__c,
                Case__r.VIN__r.Transport_Incentive__c,
                Case__r.VIN__r.Transport_Tax__c,
                Case__r.VIN__r.Transport_Type__c,
                Case__r.VIN__r.Vehicle_ID__c,
                Case__r.VIN__r.Vehicle_Tax__c,
                Case__r.VIN__r.Transport_Payment_Method_Name__c,
                Case__r.VIN__r.YMMS__c,
                Case__r.VIN__r.Stock_Number__c,
                Case__r.VIN__r.Consignee__r.Name, 
                
                Directions_for_Accounting__c,
                OwnerId,
                House_Transport_Responsible_Party__c,
                Package_Type__c,
                Response_Messages__c,
                Send_Results__c,
                Void_House_Transport__c,
                Name,
                (SELECT 
                    Extra_Cost_Responsible_Party__c, 
                    Extra_Cost_Type__c,
                    Net_Amount__c,
                    Region_Code__c,
                    Tax_Type__c
                 FROM Extra_Costs__r),
                 (SELECT
                    CreatedDate,
                    Id, 
                    TargetObjectId, 
                    StepStatus, 
                    ActorId
                 FROM ProcessSteps
                 ORDER BY CreatedDate DESC),
                 (SELECT
                    Company_Code__c,
                    Extra_Cost_Id__c,
                    Fiscal_Year__c,
                    Line_Number__c,
                    Module__c,
                    Name,
                    Reverse_Step__c
                  FROM Action_Package_Documents__r)
             FROM Action_Package__c 
             WHERE Id = :pkgId];
             
        ownerName = [SELECT Name FROM User WHERE Id = :pkg.OwnerId].Name;
		//----------------------------------------------
				System.debug('pkg.Case__r.VIN__r.Consignee__r.Name != null '+ (pkg.Case__r.VIN__r.Consignee__r.Name != null));
				System.debug('pkg.Case__r.VIN__r.Stock_Number__c != null'+(pkg.Case__r.VIN__r.Stock_Number__c != null));
				System.debug('pkg.Case__r.VIN__r.Consignee__r!=null' + (pkg.Case__r.VIN__r.Consignee__r!=null));

				CaseAuctionPackageNumber = pkg.Case__r.CaseNumber +'/' + pkg.Name ; 
				 
		        if (pkg.Case__r.VIN__r.Consignee__r.Name != null)
        		{ consigneeName = pkg.Case__r.VIN__r.Consignee__r.Name ;
        		}
        		else 
        		{ consigneeName = pkg.Case__r.Seller__r.Name;
        			              
        		}
                if (pkg.Case__r.VIN__r.Stock_Number__c != null)	
                {
                	stockNumber = pkg.Case__r.VIN__r.Stock_Number__c;	
                }
                else
                {
                	stockNumber = ' ';
                }
                System.debug('stockNumber'+stockNumber);
                System.debug('consigneeName'+consigneeName);
 		 //stockNumber = pkg.Case__r.VIN__r.Stock_Number__c ;
         //consigneeName = pkg.Case__r.VIN__r.Consignee__r.Name; 	
		
        //----------------------------------------------        
        
        // Perform Date and Number formatting
		
        actualPickup = Utils.format(Utils.getDateTime(pkg.Case__r.Actual_Pickup__c),'dd-MMM-yyyy', 'z-0800');
        actualDropoff = Utils.format(Utils.getDateTime(pkg.Case__r.Actual_Dropoff__c), 'dd-MMM-yyyy', 'z-0800');
        dateTitleReceivedBackFromBuyer = Utils.format(pkg.Case__r.VIN__r.Title_Received_From_Buyer__c, 'dd-MMM-yyyy', 'z-0800');
        dateTitleSentToBuyer = Utils.format(Utils.getDateTime(pkg.Case__r.VIN__r.Title_Sent__c), 'dd-MMM-yyyy', 'z-0800');
        handlesTitle = pkg.Case__r.VIN__r.Handles_Title__c;
        mileage = Utils.format(pkg.Case__r.VIN__r.Mileage__c, 0);
        paymentReceivedDate = Utils.format(Utils.getDateTime(pkg.Case__r.Payment_Recd__c), 'dd-MMM-yyyy', 'z-0800');
        if ('N'.equalsIgnoreCase(pkg.Case__r.VIN__r.Handles_Payment__c))
        {
        	paymentSentDate = 'NA';
        }
        else
        {
        	paymentSentDate = Utils.format(pkg.Case__r.VIN__r.Payment_Sent_to_Seller__c, 'dd-MMM-yyyy', 'z-0800');
        }
        saleDate = Utils.format(pkg.Case__r.Sale_Date__c, 'dd-MMM-yyyy', 'z-0800');
        salePriceForVehicle = Utils.format(pkg.Case__r.Sale_Price__c, 2);
        salePriceForVehicleTax = Utils.format(pkg.Case__r.VIN__r.Vehicle_Tax__c, 2);
        if (pkg.Response_Messages__c != null) {
            responseMessages = pkg.Response_Messages__c.replaceAll('\n', '<BR>');
        }
        transportFee = Utils.format(pkg.Case__r.Transport_Fee__c, 2);
        transportFeeTax = Utils.format(pkg.Case__r.VIN__r.Transport_Tax__c, 2);
        transportIncentive = Utils.format(pkg.Case__r.VIN__r.Transport_Incentive__c, 2);
        transportType = Utils.format(pkg.Case__r.VIN__r.Transport_Type__c, 0);
        
        if ('CANADA'.equalsIgnoreCase(pkg.Case__r.VIN__r.Country__c) || 'TRANSPORT VOID'.equalsIgnoreCase(pkg.Package_Type__c))
        {
        	renderTitleSection = false;
        }
        else
        {
        	renderTitleSection = true;
        }

        extraCosts = new List<FormattedExtraCost>();
        for (Extra_Cost__c ec : pkg.Extra_Costs__r) {
            extraCosts.add(new FormattedExtraCost(ec));
        }
        if (extraCosts.size() == 0) {
            extraCosts.add(new FormattedExtraCost());
        }
        
        fiDocs = new List<FormattedActionPackageDocument>();
        sdDocs = new List<FormattedActionPackageDocument>();
        for (Action_Package_Document__c doc : pkg.Action_Package_Documents__r) {
            if ('FI'.equals(doc.Module__c)) {
                fiDocs.add(new FormattedActionPackageDocument(doc));
            } else if ('SD'.equals(doc.Module__c)) {
                sdDocs.add(new FormattedActionPackageDocument(doc));
            }
        }
        if(fiDocs.size()  == 0) {
            fiDocs.add(new FormattedActionPackageDocument());
        }
        if(sdDocs.size()  == 0) {
            sdDocs.add(new FormattedActionPackageDocument());
        }

        if (pkg.Void_House_Transport__c) {
            voidHouseTransport = 'Yes';
        } else {
            voidHouseTransport = 'No';
        }
                
        List<ID> approverIds = new List<ID>();
        Set<ID> uniqueApproverIds = new Set<ID>();  
        for (ProcessInstanceHistory pih : pkg.ProcessSteps) {
            if (pih.StepStatus.equals('Approved') && !uniqueApproverIds.contains(pih.ActorId)) {
                approverIds.add(pih.ActorId);
                uniqueApproverIds.add(pih.ActorId);
            } else if (pih.StepStatus.equals('Started')) {
                if (!uniqueApproverIds.contains(pih.ActorId)) {
                	approverIds.add(pih.ActorId);
                	uniqueApproverIds.add(pih.ActorId);
                }
                break;
            }
        }
        
        Map<ID, User> approverList = new Map<ID, User>(
            [SELECT Name FROM User WHERE Id IN :approverIds]
        );
        
        List<String> userNames = new List<String>();
        for (Integer i = approverIds.size() - 1; i >= 0; i--) {
            userNames.add(approverList.get(approverIds.get(i)).Name);
        }
        
        approvers = Utils.joinList(usernames, ', ');
        
        if (pkg.ProcessSteps.size() != 0) {
            finalApprovalDate = pkg.ProcessSteps.get(0).CreatedDate.format('dd-MMM-yyyy', 'z-0800');
        }  
    
    }
    
    public class FormattedActionPackageDocument {
    	public String documentNumber {get; set;}
    	public String companyCode {get; set;}
    	public String fiscalYear {get; set;}
    	public String reverseStep {get; set;}
    	public String lineNumber {get; set;}
    	public String extraCostId {get; set;}
    	
    	public FormattedActionPackageDocument(Action_Package_Document__c apd) {
    		this.documentNumber = apd.Name;
    		this.companyCode = apd.Company_Code__c;
    		this.fiscalYear = apd.Fiscal_Year__c;
    		this.reverseStep = apd.Reverse_Step__c;
    		this.lineNumber = apd.Line_Number__c;
    		this.extraCostId = apd.Extra_Cost_Id__c;
    	}
    	
    	public FormattedActionPackageDocument() {
    		this.documentNumber = 'None';
    		this.companyCode = '-';
    		this.fiscalYear = '-';
    		this.reverseStep = '-';
    		this.lineNumber = '-';
    		this.extraCostId = '-';
    	}
    }
    
    public class FormattedExtraCost {
        public String extraCostType {get; set;}
        public String netAmount {get; set;}
        public String regionCode {get; set;}
        public String taxType {get; set;}
        public String extraCostResponsibleParty {get; set;}
        
        public FormattedExtraCost(Extra_Cost__c ec) {
            this.extraCostType = ec.Extra_Cost_Type__c;
            this.netAmount = Utils.format(ec.Net_Amount__c, 2);
            this.taxType = ec.Tax_Type__c;
            this.extraCostResponsibleParty = ec.Extra_Cost_Responsible_Party__c;
            this.regionCode = ec.Region_Code__c;
        }
        
        public FormattedExtraCost() {
            this.extraCostType = 'None';
            this.netAmount = '-';
            this.taxType = '-';
            this.extraCostResponsibleParty = '-';
        }
    }
}