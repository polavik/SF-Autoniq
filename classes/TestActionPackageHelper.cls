@isTest
public class TestActionPackageHelper{

   static testMethod void UnitTest1() {

        Account acct = new Account(Name='Account-test');
        Insert acct;
        Contact cntct = new Contact(LastName='Contact-test', AccountId = acct.Id);
        Insert cntct;

        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '-798754645',Source_ID__c = '-798754645', 
                                                Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, 
                                                Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
//        Case c = new Case(AccountId=acct.Id,ContactId=cntct.Id,VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        Case c = new Case(AccountId=acct.Id,ContactId=cntct.Id,VIN__c = p.Id, Type = 'Ownership Inquiry', Description='PSI FAILED:Description', Reason='CAP Title', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void', Status__c = 'Approved', Approved__c = true, 
                                                        House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, 
                                                        Directions_For_Accounting__c = null,
                                                        Void_House_Transport__c =true, Emailed_To__c ='dontcare@sandbox.com');
        insert pkg;

        Attachment attach = new Attachment( Name='test',  ParentId = pkg.Id); 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        insert attach;
        
        p.Transport_Void_Package__c  = pkg.Id;
        p.Vehicle_Void_Package__c = pkg.Id;
        update p;

        Auction_Credit__c auctionCredit = new Auction_Credit__c(Action_Package__c=pkg.Id,
                                                                Credit_Amount__c = 260.0,
                                                                 Expires__c = date.today(),
                                                                 Status__c='Available') ;
        insert auctionCredit;
        system.debug('-------------auctionCredit ' + auctionCredit.Id);
        
        new ActionPackageHelper(pkg).holdPS();
        
        }
            static testMethod void UnitTest2() {
           //static testMethod void transportVoidApproved() 
    
        Account a = new Account(Name='Test Account And Stuff');
        insert a; 
        
        Contact cntct = new Contact(LastName='Contact-test', AccountId = a.Id);
        Insert cntct;        
        
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', ATC_Seller__c=a.Id, Vehicle_ID__c = '1234567', Source_ID__c='1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = null, Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Case c = new Case(AccountId=a.Id,ContactId=cntct.Id,VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description',Reason='Undisclosed Damages', Validation_Outcome_Override__c = true,Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        /*
        AND((RecordType.Name = 'Arbitration - New' || RecordType.Name = 'Arbitration - Open'),
        Void__c =false,Undetermined_Willing_to_negotiate__c = false, 
        Concession__c = false,
        !contains(Description,"PSI FAILED:"),!ispickval(Origin,"Web"))
        
        
        Case c = new Case(AccountId=acct.Id,ContactId=cntct.Id,VIN__c = p.Id, 
        Type = 'Ownership Inquiry', Description='PSI FAILED:Description', 
        Reason='CAP Title', Validation_Outcome_Override__c = true, 
        Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', 
        Inspection_Company_Responsibility__c='Yes');
        **/
        insert c;
        
       // Action_Package__c pkgtrp = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Transport Void', Status__c = 'Open', House_Transport_Responsible_Party__c = null, Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        Action_Package__c pkgavoid = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void', Status__c = 'Open', House_Transport_Responsible_Party__c = null, Standard_SAP_Transactions__c = false, Directions_For_Accounting__c = 'yes');        
        
       // insert pkgtrp;
        insert pkgavoid;
       // new ActionPackageHelper(pkgtrp).sendPackage();
        new ActionPackageHelper(pkgavoid).sendPackage();
        /*
        DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
        ctr.redirect();
        */
    }
    
//    Vehicle_ID__c

     static testMethod void UnitTest3() {
    
    
        Account a = new Account(Name='Test Account And Stuff');
        insert a; 
        
        Contact cntct = new Contact(LastName='Contact-test', AccountId = a.Id);
        Insert cntct;        
        
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', ATC_Seller__c=a.Id, Vehicle_ID__c = '-1234567', Source_ID__c='-1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = null, Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Case c = new Case(  AccountId=a.Id,ContactId=cntct.Id,VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description',Reason='Undisclosed Damages', Validation_Outcome_Override__c = true,Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        /*
        AND((RecordType.Name = 'Arbitration - New' || RecordType.Name = 'Arbitration - Open'),
        Void__c =false,Undetermined_Willing_to_negotiate__c = false, 
        Concession__c = false,
        !contains(Description,"PSI FAILED:"),!ispickval(Origin,"Web"))
        
        
        Case c = new Case(AccountId=acct.Id,ContactId=cntct.Id,VIN__c = p.Id, 
        Type = 'Ownership Inquiry', Description='PSI FAILED:Description', 
        Reason='CAP Title', Validation_Outcome_Override__c = true, 
        Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', 
        Inspection_Company_Responsibility__c='Yes');
        **/
        insert c;
        
       // Action_Package__c pkgtrp = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Transport Void', Status__c = 'Open', House_Transport_Responsible_Party__c = null, Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        Action_Package__c pkgavoid = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void', Status__c = 'Open', House_Transport_Responsible_Party__c = null, Standard_SAP_Transactions__c = false, Directions_For_Accounting__c = 'yes');        
        
       // insert pkgtrp;
        insert pkgavoid;
       // new ActionPackageHelper(pkgtrp).sendPackage();
        new ActionPackageHelper(pkgavoid).sendPackage();
        /*
        DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
        ctr.redirect();
        */
    }

}