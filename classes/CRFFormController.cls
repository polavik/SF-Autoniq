public class CRFFormController 
{
    public DisplayData myDisplayData {get; set;} 
    
    public CRFFormController()
    {
        String src = ApexPages.currentPage().getParameters().get('src');
        String rootId = ApexPages.currentPage().getParameters().get('id');
        
        // Form will be composed of data from 4 objects
        
        Auction_Credit__c credit;
        Action_Package__c pkg;
        Case kase;
        Purchase__c purchase;
        Account acct;
        Contact cont;
        
        
        ID creditId;
        ID pkgId;
        ID kaseId;
        ID purchaseId;
        ID acctId;
        ID contId;
        String strSellerOrgId;
        
        
        if (src.equalsIgnoreCase('AUCTION_CREDIT__C'))
        {
            creditId = rootId;
        }
        else if (src.equalsIgnoreCase('ACTION_PACKAGE__C'))
        {
            pkgId = rootId;
        }
        if (creditId != null)
        {
            credit = 
            [
                SELECT
                    Account__c,
                    Action_Package__c,
                    Credit_Amount__c,
                    Name,
                    Purchase__c, 
                    Promotional_Credit_Reason__c,
                    Send_Results__c,
                    Response_Messages__c,
                    (
                        SELECT
                            Company_Code__c,
                            Extra_Cost_Id__c,
                            Fiscal_Year__c,
                            Line_Number__c,
                            Module__c,
                            Name,
                            Reverse_Step__c
                        FROM Action_Package_Documents__r
                    )
                FROM Auction_Credit__c
                WHERE Id = :rootId
            ];
            
            purchaseId = credit.Purchase__c;
            pkgId = credit.Action_Package__c;
            acctId = credit.Account__c;
        }
        
        if (pkgId != null)
        {
            pkg =
            [
                SELECT 
                    Case__c,
                    Credit_Amount__c,
                    Credit_Reason__c,
                    Credit_To__c,
                    Directions_for_Accounting__c,
                    Discretionary_Fund_Amount__c,
                    House_Amount__c,
                    OwnerId,
                    House_Transport_Responsible_Party__c,
                    Inspector_Amount__c,
                    Issuing_Department__c,
                    Other_Party_Amount__c,
                    Package_Type__c,
                    Response_Messages__c,
                    Seller_Amount__c,
                    Send_Results__c,
                    Tax__c,
                    Transporter_Amount__c,
                    Void_House_Transport__c,
                    name,
                    (
                        SELECT
                            CreatedDate,
                            Id, 
                            TargetObjectId, 
                            StepStatus, 
                            ActorId
                        FROM ProcessSteps
                        ORDER BY CreatedDate DESC
                    ),
                    (
                        SELECT
                            Company_Code__c,
                            Extra_Cost_Id__c,
                            Fiscal_Year__c,
                            Line_Number__c,
                            Module__c,
                            Name,
                            Reverse_Step__c
                        FROM Action_Package_Documents__r
                    )
                FROM Action_Package__c 
                WHERE Id = :pkgId
            ];
            
            kaseId = pkg.Case__c;
        }
        
        if (kaseId != null)
        {
            kase = 
            [
                SELECT
                    AccountId,
                    Claim_Resolution__c,
                    Claim_Resolution_Comments__c,
                    ContactId,
                    CaseNumber,
                    Owner.Name,
                    Resolution_Subtype__c,
                    Type,
                    VIN__c
                FROM Case
                WHERE Id = :kaseId
            ];
            // Only set these fields from the Case if they couldn't be set from the Auction Credit above
            if (purchaseId == null)
            {
                purchaseId = kase.VIN__c;
            }
            if (acctId == null)
            {
                acctId = kase.AccountId;
            }
            contId = kase.ContactId;
        }
        
        if (purchaseId != null)
        {
            purchase = 
            [
                SELECT
                    Actual_Dropoff__c,
                    Actual_Pickup__c,
                    ATC_Buyer_Contact__c,
                    ATC_Sale_Date__c,
                    ATC_Seller__r.Name,
                    ATC_Transporter__r.Name,
                    Handles_Payment__c,
                    Mileage__c,
                    Name,
                    Payment_Method__c,
                    Payment_Received__c,
                    Payment_Sent_to_Seller__c,
                    Private_Label__c,
                    sale_class__c,                
                    Sale_Price__c,
                    Transport_Fee__c,
                    Transport_Incentive__c,
                    Transport_Payment_Method_Name__c,
                    Transport_Tax__c,
                    Transport_Type__c,
                    Vehicle_ID__c,
                    Vehicle_Tax__c,
                    YMMS__c,
                    ATC_Seller_Adesa_com_Detail__r.ATC_Organization_ID__c,
                	Stock_Number__c,
                	Consignee__r.Name                     
                FROM Purchase__c
                WHERE Id = :PurchaseId
            ];
            
            if (contId == null)
            {
                contId = purchase.ATC_Buyer_Contact__c;
            }
            
            strSellerOrgId = purchase.ATC_Seller_Adesa_com_Detail__r.ATC_Organization_ID__c;
        }
        
        if (acctId != null)
        {
            acct = 
            [
                SELECT
                    Name,
                    Phone
                FROM Account
                WHERE Id = :acctId
            ];
        }
        
        if (contId != null)
        {
            cont = 
            [
                SELECT
                    Name
                FROM Contact
                WHERE Id = :contId
            ];
        }
        
        myDisplayData = new DisplayData(credit, pkg, kase, purchase, acct, cont);
    }
    
    public class DisplayData
    {
        public String typeOfCRF {get; set;}
        public String caseType {get; set;}
        public String caseNo {get; set;}
        public String caseOwner {get; set;}
        public String sapSendResults {get; set;}
        public String directionsForAccounting {get; set;}
        public String vin {get; set;}
        public String accountName {get; set;}
        public String ymms {get; set;}
        public String contactName {get; set;}
        public String mileage {get; set;}
        public String phone {get; set;}
        public String vehicleId {get; set;}
        public String seller {get; set;}
        public String consigneeName {get; set;}
        public String stockNumber {get; set;}
        public String transportType {get; set;}
        public String privateLabel {get; set;}
        public String transportIncentive {get; set;}
        public String salePriceForVehicle {get; set;}
        public String transportFee {get; set;}
        public String vehicleTax {get; set;}
        public String transportTax {get; set;}
        public String vehPaymentMethod {get; set;}
        public String tpPaymentMethod {get; set;}
        public String saleDate {get; set;}
        public String actualPickupDate {get; set;}
        public String paymentRecdDate {get; set;}
        public String actualDropoffDate {get; set;}
        public String transporter {get; set;}
        public String resolution {get; set;}
        public String resolutionSubtype {get; set;}
        public String resolutionComments {get; set;}
        public String dateOfFinalApproval {get; set;}
        public String approvers {get; set;}
        public String creditTo {get; set;}
        public String creditAmount {get; set;}
        public String houseAmount {get; set;}
        public String tax {get; set;}
        public String sellerAmount {get; set;}
        public String issuingDepartment {get; set;}
        public String transporterAmount {get; set;}
        public String creditReason {get; set;}
        public String inspectorAmount {get; set;}
        public String otherPartyAmount {get; set;}
        public String discretionaryFundAmount {get; set;}
        public String auctionCreditId {get; set;}
        public String sapErrorMessages {get; set;}
        public String CaseAuctionPackageNumber {get; set;}
        
        public List<FormattedSapDocument> fiDocuments {get; set;}
        public List<FormattedSapDocument> sdDocuments {get; set;}
        
        public Boolean displayCaseData {get; set;}
        public Boolean displayConcessionSection {get; set;}
        public Boolean displayAdjustmentSection {get; set;}
        public Boolean displayTransportAdjustmentSection {get; set;}
        public Boolean displayAuctionCreditSection {get; set;}
        
        
        public DisplayData(Auction_Credit__c credit, Action_Package__c pkg, Case kase, Purchase__c purchase, Account acct, Contact cont)
        {
            displayCaseData = false;
            displayConcessionSection = false;
            displayAdjustmentSection = false;
            displayTransportAdjustmentSection = false;
            displayAuctionCreditSection = false;
            
            List<Action_Package_Document__c> docs;
            
            // Pull Display Data from Credit
            if (credit != null)
            {
                typeOfCRF = 'Auction Credit';
                creditAmount = Utils.format(credit.Credit_Amount__c, 2);
                creditReason = credit.Promotional_Credit_Reason__c;
                auctionCreditId = credit.Name;
                sapSendResults = credit.Send_Results__c;
                sapErrorMessages = credit.Response_Messages__c;
                docs = credit.Action_Package_Documents__r;
                
                
                displayAuctionCreditSection = true;
            }
            
            if (pkg != null)
            {
                typeOfCRF = pkg.Package_Type__c;
                
                
                if (sapSendResults == null)
                {
                    sapSendResults = pkg.Send_Results__c;
                }
                
        //        if (sapSendResults == null)
        //        {
                    directionsForAccounting = pkg.Directions_For_Accounting__c;
        //        }
                creditTo = pkg.Credit_To__c;
                
                // Credit Amount should be set only if it cannot be pulled off an Auction Credit record
                if (creditAmount == null)
                {
                    creditAmount = Utils.format(pkg.Credit_Amount__c, 2);
                }
                
                houseAmount = Utils.format(pkg.House_Amount__c, 2);
                tax = pkg.Tax__c;
                sellerAmount = Utils.format(pkg.Seller_Amount__c, 2);
                issuingDepartment = pkg.Issuing_Department__c;
                transporterAmount = Utils.format(pkg.Transporter_Amount__c, 2);
                
                // Credit Reason should only be set if it can't be pulled off an Auction Credit record
                if (creditReason == null)
                {
                    creditReason = pkg.Credit_Reason__c;
                }
                discretionaryFundAmount = Utils.format(pkg.Discretionary_Fund_Amount__c, 2);
                inspectorAmount = Utils.format(pkg.Inspector_Amount__c, 2);
                otherPartyAmount = Utils.format(pkg.Other_Party_Amount__c, 2);
                sapErrorMessages = pkg.Response_Messages__c;
                
                
                if ('CONCESSION'.equalsIgnoreCase(typeOfCRF))
                {
                    displayConcessionSection = true;
                }
                else if ('ADJUSTMENT'.equalsIgnoreCase(typeOfCRF))
                {
                    displayAdjustmentSection = true;
                }
                else if ('TRANSPORT ADJUSTMENT'.equalsIgnoreCase(typeOfCRF))
                {
                    displayTransportAdjustmentSection = true;
                }
                
                // GET APPROVER INFO
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
                    dateOfFinalApproval = pkg.ProcessSteps.get(0).CreatedDate.format('dd-MMM-yyyy', 'z-0800');
                } 
                
                if (docs == null)
                {
                    docs = pkg.Action_Package_Documents__r;
                }
            }
            
            if (kase != null)
            {
                caseType = kase.Type;
                caseNo = kase.CaseNumber;
                caseOwner = kase.Owner.Name;
                resolution = kase.Claim_Resolution__c;
                resolutionSubtype = kase.Resolution_Subtype__c;
                resolutionComments = kase.Claim_Resolution_Comments__c;
                CaseAuctionPackageNumber = caseNo ;
                displayCaseData = true;
            }

            if(pkg != null) { CaseAuctionPackageNumber= CaseAuctionPackageNumber +'/' + pkg.name ;}

            if (purchase != null)
            {
                vin = purchase.Name;
                ymms = purchase.YMMS__c;
                mileage = Utils.format(purchase.Mileage__c, 0);
                vehicleId = purchase.Vehicle_ID__c;
                seller = purchase.ATC_Seller__r.Name;
                transportType = Utils.format(purchase.Transport_Type__c, 0);
                privateLabel = purchase.Private_Label__c;
                transportIncentive = Utils.format(purchase.Transport_Incentive__c, 2);
                salePriceForVehicle = Utils.format(purchase.Sale_Price__c, 2);
                transportFee = Utils.format(purchase.Transport_Fee__c, 2);
                vehicleTax = Utils.format(purchase.Vehicle_Tax__c, 2);
                transportTax = Utils.format(purchase.Transport_Tax__c, 2);
                vehPaymentMethod = purchase.Payment_Method__c;
                tpPaymentMethod = purchase.Transport_Payment_Method_Name__c;
                saleDate = Utils.format(purchase.ATC_Sale_Date__c, 'dd-MMM-yyyy', 'z-0800');
                actualPickupDate = Utils.format(Utils.getDateTime(purchase.Actual_Pickup__c), 'dd-MMM-yyyy', 'z-0800');
                paymentRecdDate = Utils.format(Utils.getDateTime(purchase.Payment_Received__c), 'dd-MMM-yyyy', 'z-0800');
                actualDropoffDate = Utils.format(Utils.getDateTime(purchase.Actual_Dropoff__c), 'dd-MMM-yyyy', 'z-0800');
                transporter = purchase.ATC_Transporter__r.Name;
                
        		
        		if (purchase.Consignee__r.Name != null)
        		{ consigneeName = purchase.Consignee__r.Name ;
        		}
        		else 
        		{ consigneeName = purchase.ATC_Seller__r.Name;
        		}
                if (purchase.Stock_Number__c != null)	
                {
                	stockNumber = purchase.Stock_Number__c;	
                }
                else
                {
                	stockNumber = ' ';
                }
            }
            
            if (acct != null)
            {
                accountName = acct.Name;
                phone = acct.Phone;
            }
            
            if (cont != null)
            {
                contactName = cont.Name;
            }
            
            if (docs != null)
            {
                // ADD ACTION PACKAGE DOCUMENT INFO
                fiDocuments = new List<FormattedSapDocument>();
                sdDocuments = new List<FormattedSapDocument>();
                for (Action_Package_Document__c doc : docs) 
                {
                    if ('FI'.equals(doc.Module__c)) 
                    {
                        fiDocuments.add(new FormattedSapDocument(doc));
                    } 
                    else if ('SD'.equals(doc.Module__c)) 
                    {
                        sdDocuments.add(new FormattedSapDocument(doc));
                    }
                }
                
                // ADD A BLANK DOCUMENT IF NONE EXIST
                if(fiDocuments.size()  == 0) 
                {
                    fiDocuments.add(new FormattedSapDocument());
                }
                if(sdDocuments.size()  == 0) 
                {
                    sdDocuments.add(new FormattedSapDocument());
                }
            }
        }
    }
    
    public class FormattedSapDocument {
        public String documentNumber {get; set;}
        public String companyCode {get; set;}
        public String fiscalYear {get; set;}
        public String reverseStep {get; set;}
        public String lineNumber {get; set;}
        public String extraCostId {get; set;}
        
        public FormattedSapDocument(Action_Package_Document__c apd) {
            this.documentNumber = apd.Name;
            this.companyCode = apd.Company_Code__c;
            this.fiscalYear = apd.Fiscal_Year__c;
            this.reverseStep = apd.Reverse_Step__c;
            this.lineNumber = apd.Line_Number__c;
            this.extraCostId = apd.Extra_Cost_Id__c;
        }
        
        public FormattedSapDocument() {
            this.documentNumber = 'None';
            this.companyCode = '-';
            this.fiscalYear = '-';
            this.reverseStep = '-';
            this.lineNumber = '-';
            this.extraCostId = '-';
        }
    }
}