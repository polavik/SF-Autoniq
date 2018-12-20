/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class TestActionPkgDetailsController {
    static Integer counter=0;
    static Purchase__c p;
    static void setup(){
        p = TestServices.createPurchases(1, true)[0]; 
    }


/*
    static testMethod void auctionVoidApproved() {
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '1234567', Source_ID__c='1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='asdf', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void', Status__c = 'Approved', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        insert pkg;
        
        Extra_Cost__c ec = new Extra_Cost__c(Action_Package__c = pkg.Id, Extra_Cost_Responsible_Party__c = 'Seller', Extra_Cost_Type__c = 'Repair', Net_Amount__c = 100);
        insert ec;
        
        DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
        ctr.redirect();
        
        DispatcherActionPkgDetails2Controller ctr2 = new DispatcherActionPkgDetails2Controller(new ApexPages.StandardController(pkg));
        ctr2.redirect();
        
        VoidFormController ctr3 = new VoidFormController(new ApexPages.StandardController(pkg));
    }
 
    static testMethod void auctionVoidRecApproved() {
        // Due to complexity of all mechanism of purchase/case/AP insert update trigger and all helper classes SOQL call, 
        //it easily exceed the SOQL 101 limit. Thus, SeeAllData is used instead of creating test data
         
   
        //setup();
        //Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        //insert c;
           
        List<Case> cs = new List<Case>();
        for(Case c  : [select Id, VIN__c, REASON,Claim_Resolution__c, Resolution_Subtype__c, Inspection_Company_Responsibility__c, Description 
                       from Case where Type = 'Arbitration' and Claim_Resolution__c = 'Void' and Resolution_Subtype__c = 'Seller' 
                       and Inspection_Company_Responsibility__c = 'Yes' and origin = 'Web']){
            if(c.VIN__c != null){
                cs.add(c);
                break;
            }
        }
        
        //List<Case> cs = [select Id, VIN__c, REASON,Claim_Resolution__c, Resolution_Subtype__c, Inspection_Company_Responsibility__c, Description 
        //          from Case where Type = 'Arbitration' and VIN__c != null and Claim_Resolution__c = 'Void' and Resolution_Subtype__c = 'Seller' 
        //                 and Inspection_Company_Responsibility__c = 'Yes' and origin = 'Web' limit 1];
           
        if(cs.size() > 0){
            List<Action_Package__c> pkgs = [select Id from Action_Package__c limit 1];
            if(pkgs.size() > 0){
                Action_Package__c pkg = pkgs.get(0);
                pkg.Case__c = cs.get(0).Id;
                pkg.Package_Type__c = 'Auction Void - Rec';
                pkg.Status__c = 'Approved';
                pkg.Approved__c = true;
                pkg.House_Transport_Responsible_Party__c = 'Seller';
                pkg.Standard_SAP_Transactions__c = true;
                pkg.Directions_For_Accounting__c = null;
                
                //new Action_Package__c(Case__c = cs.get(0).Id, Package_Type__c = 'Auction Void - Rec', Status__c = 'Approved', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
            update pkg;
            DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
            ctr.redirect();
            }
             
        }                   
        
    }
    
    static testMethod void auctionVoidSwapApproved() {
        // Due to complexity of all mechanism of purchase/case/AP insert update trigger and all helper classes SOQL call, 
        // it easily exceed the SOQL 101 limit. Thus, SeeAllData is used instead of creating test data
         
        
        //setup();        
        //Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        //insert c;
                
        List<Case> cs = new List<Case>();
        for(Case c  : [SELECT Id, VIN__c, Reason, Claim_Resolution__c, Resolution_Subtype__c
                       , Inspection_Company_Responsibility__c, Description 
                       FROM Case
                       WHERE Type = 'Arbitration' AND Claim_Resolution__c = 'Void'
                       AND Resolution_Subtype__c = 'Seller' AND Inspection_Company_Responsibility__c = 'Yes'
                       AND Origin = 'Web' limit 100]){
            if(c.VIN__c != null){
                cs.add(c);
                break;
            }
        }
        
        //List<Case> cs = [SELECT Id, VIN__c, Reason, Claim_Resolution__c, Resolution_Subtype__c
        //                 , Inspection_Company_Responsibility__c, Description 
        //                   FROM Case
        //                 WHERE Type = 'Arbitration' AND VIN__c != null AND Claim_Resolution__c = 'Void'
        //                 AND Resolution_Subtype__c = 'Seller' AND Inspection_Company_Responsibility__c = 'Yes'
        //                 AND Origin = 'Web' Limit 1];
           
        if(cs.size() > 0){
            List<Action_Package__c> pkgs = [select Id from Action_Package__c limit 1];
            if(pkgs.size() > 0){
                Action_Package__c pkg = pkgs.get(0);
                pkg.Case__c = cs.get(0).Id;
                pkg.Package_Type__c = 'Auction Void - Swap';
                pkg.Status__c = 'Approved';
                pkg.Approved__c = true;
                pkg.House_Transport_Responsible_Party__c = 'Seller';
                pkg.Standard_SAP_Transactions__c = true;
                pkg.Directions_For_Accounting__c = null;
                //Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Auction Void - Swap', Status__c = 'Approved', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
                update pkg;
                DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
                ctr.redirect();
            }
        }
    }
  
    static testMethod void houseVoid3rdPartyApproved() {
        // Due to complexity of all mechanism of purchase/case/AP insert update trigger and all helper classes SOQL call, 
         // it easily exceed the SOQL 101 limit. Thus, SeeAllData is used instead of creating test data
         
        
        //setup();        
        //Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        //insert c;
        
        List<Case> cs = new List<Case>();
        for(Case c  : [select Id, VIN__c, REASON,Claim_Resolution__c, Resolution_Subtype__c, Inspection_Company_Responsibility__c, Description 
                       from Case where Type = 'Arbitration' and Claim_Resolution__c = 'Void' and Resolution_Subtype__c = 'Seller' 
                       and Inspection_Company_Responsibility__c = 'Yes' and origin = 'Web']){
            if(c.VIN__c != null){
                cs.add(c);
                break;
            }
        }
        
        //List<Case> cs = [select Id, VIN__c, REASON,Claim_Resolution__c, Resolution_Subtype__c, Inspection_Company_Responsibility__c, Description 
        //          from Case where Type = 'Arbitration' and VIN__c != null and Claim_Resolution__c = 'Void' and Resolution_Subtype__c = 'Seller' 
        //                 and Inspection_Company_Responsibility__c = 'Yes' and origin = 'Web' limit 1];
           
        if(cs.size() > 0){
            List<Action_Package__c> pkgs = [select Id from Action_Package__c limit 1];
            if(pkgs.size() > 0){
                Action_Package__c pkg = pkgs.get(0);
                pkg.Case__c = cs.get(0).Id;
                pkg.Package_Type__c = 'House Void - 3rd Party';
                pkg.Status__c = 'Approved';
                pkg.Approved__c = true;
                pkg.House_Transport_Responsible_Party__c = 'Seller';
                pkg.Standard_SAP_Transactions__c = true;
                pkg.Directions_For_Accounting__c = null;
                //Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'House Void - 3rd Party', Status__c = 'Approved', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
                update pkg; 
                DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
                ctr.redirect();
            }
        }        
    }
    
    
    static testMethod void houseVoid3rdPartyRecApproved() {
        //Due to complexity of all mechanism of purchase/case/AP insert update trigger and all helper classes SOQL call, 
         //it easily exceed the SOQL 101 limit. Thus, SeeAllData is used instead of creating test data
         
               
        //setup();        
        //Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        //insert c;
        
        List<Case> cs = new List<Case>();
        for(Case c  : [select Id, VIN__c, REASON,Claim_Resolution__c, Resolution_Subtype__c, Inspection_Company_Responsibility__c, Description 
                       from Case where Type = 'Arbitration' and Claim_Resolution__c = 'Void' and Resolution_Subtype__c = 'Seller' 
                       and Inspection_Company_Responsibility__c = 'Yes' and origin = 'Web' limit 100]){
            if(c.VIN__c != null){
                cs.add(c);
                break;
            }
        }
        
        //List<Case> cs = [select Id, VIN__c, REASON,Claim_Resolution__c, Resolution_Subtype__c, Inspection_Company_Responsibility__c, Description 
        //          from Case where Type = 'Arbitration' and VIN__c != null and Claim_Resolution__c = 'Void' and Resolution_Subtype__c = 'Seller' 
        //                 and Inspection_Company_Responsibility__c = 'Yes' and origin = 'Web' limit 1];
           
        if(cs.size() > 0){
            List<Action_Package__c> pkgs = [select Id from Action_Package__c limit 1];
            if(pkgs.size() > 0){
                Action_Package__c pkg = pkgs.get(0);
                pkg.Case__c = cs.get(0).Id;
                pkg.Package_Type__c = 'House Void - 3rd Party Rec';
                pkg.Status__c = 'Approved';
                pkg.Approved__c = true;
                pkg.House_Transport_Responsible_Party__c = 'Seller';
                pkg.Standard_SAP_Transactions__c = true;
                pkg.Directions_For_Accounting__c = null;
                //Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'House Void - 3rd Party Rec', Status__c = 'Approved', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
            update pkg; 
                
                DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
            ctr.redirect();
            }
        }        
        
    }
    
    
    static testMethod void houseVoidAIARec() {
        // Due to complexity of all mechanism of purchase/case/AP insert update trigger and all helper classes SOQL call, 
         // it easily exceed the SOQL 101 limit. Thus, SeeAllData is used instead of creating test data
         
        
        //setup();        
        //Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        //insert c;
        
        List<Case> cs = new List<Case>();
        for(Case c  : [select Id, VIN__c, REASON,Claim_Resolution__c, Resolution_Subtype__c, Inspection_Company_Responsibility__c, Description 
                       from Case where Type = 'Arbitration' and Claim_Resolution__c = 'Void' and Resolution_Subtype__c = 'Seller' 
                       and Inspection_Company_Responsibility__c = 'Yes' and origin = 'Web']){
            if(c.VIN__c != null){
                cs.add(c);
                break;
            }
        }
        
        //List<Case> cs = [select Id, VIN__c, REASON,Claim_Resolution__c, Resolution_Subtype__c, Inspection_Company_Responsibility__c, Description 
        //          from Case where Type = 'Arbitration' and VIN__c != null and Claim_Resolution__c = 'Void' and Resolution_Subtype__c = 'Seller' 
        //                 and Inspection_Company_Responsibility__c = 'Yes' and origin = 'Web' limit 1];
           
        if(cs.size() > 0){
            List<Action_Package__c> pkgs = [select Id from Action_Package__c limit 1];
            if(pkgs.size() > 0){
                Action_Package__c pkg = pkgs.get(0);
                pkg.Case__c = cs.get(0).Id;
                pkg.Package_Type__c = 'House Void - AIA Rec';
                pkg.Status__c = 'Approved';
                pkg.Approved__c = true;
                pkg.House_Transport_Responsible_Party__c = 'Seller';
                pkg.Standard_SAP_Transactions__c = true;
                pkg.Directions_For_Accounting__c = null;
                //Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'House Void - AIA Rec', Status__c = 'Approved', Approved__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
            update pkg; 
                
                DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
            ctr.redirect();
            }
        }        
    }
    
    static testMethod void houseVoidRecApproved() {
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '1234567', Source_ID__c='1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='asdf', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'House Void - Rec', Status__c = 'Open', House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        insert pkg;
        
        DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
        ctr.redirect();
    } 
    
   static testMethod void transportVoidApproved() {
    
        Account a = new Account(Name='Test Account And Stuff');
        insert a; 
        
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', ATC_Seller__c=a.Id, Vehicle_ID__c = '1234567', Source_ID__c='1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = null, Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='asdf', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Transport Void', Status__c = 'Open', House_Transport_Responsible_Party__c = null, Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        insert pkg;
        
        DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
        ctr.redirect();
    }
   
    static testMethod void extraCostApproved() {
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', Vehicle_ID__c = '1234567', Source_ID__c='1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = null, Transport_Type__c = 2, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='asdf', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Transport Void', Status__c = 'Approved', Approved__c = true, House_Transport_Responsible_Party__c = null, Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        insert pkg;
        
        DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
        ctr.redirect();
        
        p.Transport_Void_Package__c = pkg.Id;
        update p;
        
        Action_Package__c pkg2 = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Extra Cost', Status__c = 'Approved', Approved__c = true, House_Transport_Responsible_Party__c = null, Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        insert pkg2;
        
        DispatcherActionPkgDetailsController ctr2 = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg2));
        ctr2.redirect();
    }
   
    static testMethod void houseVoidRecSubmitted() {
        Account a = new Account(Name='Test Account And Stuff');
        insert a;
        
        Contact con = new Contact(LastName='Mr. Awesomeson');
        insert con;
        
        Purchase__c p = new Purchase__c(Name = 'JNKCV54E33M212906', ATC_Buyer__c=a.Id, ATC_Buyer_Contact__c = con.Id, Vehicle_ID__c = '1234567', Source_ID__c='1234567', Handles_Payment__c = 'Y', Actual_Pickup__c = Date.today(), Transport_Type__c = 1, Transport_Preference__c = 'OPENLANE Arranged', sale_Class__c = 'Closed - Grounding Dealer');
        insert p;
        
        Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='asdf', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        insert c;
        
        Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'House Void - Rec', Status__c = 'Pending...', Submitted__c = true, House_Transport_Responsible_Party__c = 'Seller', Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
        insert pkg;
        
        DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
        ctr.redirect();
    }
  
    static testMethod void transportVoidRecalled() {
    // Due to complexity of all mechanism of purchase/case/AP insert update trigger and all helper classes SOQL call, 
         // it easily exceed the SOQL 101 limit. Thus, SeeAllData is used instead of creating test data
         
        
        //setup();        
        //Case c = new Case(VIN__c = p.Id, Type = 'Arbitration', Description='PSI FAILED:Description', Reason='Undisclosed Damages', Validation_Outcome_Override__c = true, Claim_Resolution__c = 'Void', Resolution_Subtype__c = 'Seller', Inspection_Company_Responsibility__c='Yes');
        //insert c;
        
        List<Case> cs = new List<Case>();
        for(Case c  : [select Id, VIN__c, REASON,Claim_Resolution__c, Resolution_Subtype__c, Inspection_Company_Responsibility__c, Description 
                       from Case where Type = 'Arbitration' and Claim_Resolution__c = 'Void' and Resolution_Subtype__c = 'Seller' 
                       and Inspection_Company_Responsibility__c = 'Yes' and origin = 'Web']){
            if(c.VIN__c != null){
                cs.add(c);
                break;
            }
        }
        //List<Case> cs = [select Id, VIN__c, REASON,Claim_Resolution__c, Resolution_Subtype__c, Inspection_Company_Responsibility__c, Description 
        //          from Case where Type = 'Arbitration' and VIN__c != null and Claim_Resolution__c = 'Void' and Resolution_Subtype__c = 'Seller' 
        //                and Inspection_Company_Responsibility__c = 'Yes' and origin = 'Web' limit 1];
           
        if(cs.size() > 0){
            List<Action_Package__c> pkgs = [select Id from Action_Package__c limit 1];
            if(pkgs.size() > 0){
                Action_Package__c pkg = pkgs.get(0);
                pkg.Case__c = cs.get(0).Id;
                pkg.Package_Type__c = 'Transport Void';
                pkg.Status__c = 'Recalled';
                pkg.Recalled__c = true;
                pkg.House_Transport_Responsible_Party__c = null;
                pkg.Standard_SAP_Transactions__c = true;
                pkg.Directions_For_Accounting__c = null;
                //Action_Package__c pkg = new Action_Package__c(Case__c = c.Id, Package_Type__c = 'Transport Void', Status__c = 'Recalled', Recalled__c = true, House_Transport_Responsible_Party__c = null, Standard_SAP_Transactions__c = true, Directions_For_Accounting__c = null);
            update pkg; 
                
                DispatcherActionPkgDetailsController ctr = new DispatcherActionPkgDetailsController(new ApexPages.StandardController(pkg));
            ctr.redirect();
            }
        }        
    }
*/
}