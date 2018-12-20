public class ActionPackageValidator { 

    private static boolean blnAlreadyDone = false; 
    
    public static boolean hasAlreadyDone(){ 
       return blnAlreadyDone; 
    }
    
    public static void setAlreadyDone() {

       blnAlreadyDone = true;
    } 

    /* General Validation for all Action Packages */
    public static boolean validateGeneral(Action_Package__c pkg) 
    {
        if (pkg.Case__c == null) 
        {
            pkg.addError('Required field missing: Case');
            return false;
        }
/*
6.       CRF - Seller Auction Credit
*/                                                   
        if ('Yes'.equalsIgnoreCase(pkg.Case__r.VIN__r.Is_Dealer_Block__c) &&
            
        ( pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'Auction Void - Rec') ||
        pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Adjustment') ||
        pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Arbitration Auction Credit') ||
        pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Arbitration Seller Auction Credit') ||
        pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Auction Credit - Goodwill') ||
        pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'Extra Cost') ||
        pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'House Void - 3rd Party') ||
        pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'House Void - 3rd Party Rec') ||
        pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'House Void - AIA Rec') ||
        pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'House Void - Rec') ||
        pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Seller Auction Credit - Goodwill')
            )
        && (pkg.Auto_Approve_Override__c = false) //Allows APs to be approved when automatically created by a canceled PSI
             )
        {
            /*
            pkg.addError('For Dealer Block Vehicles Following Auction Package Rec.Types are not Valid...'+
'Auction Void - Rec'+' '+
'CRF - Adjustment'+' '+
'CRF - Arbitration Auction Credit'+' '+
'CRF - Arbitration Seller Auction Credit'+' '+
'CRF - Auction Credit - Goodwill'+' '+
'CRF - Seller Auction Credit'+' '+
'Extra Cost'+' '+
'House Void - 3rd Party'+' '+
'House Void - 3rd Party Rec'+' '+
'House Void - AIA Rec'+' '+
'House Void - Rec'
            );
            */
            pkg.addError('Only Auction Void and Concession Action Packages are authorized to be processed on ADESA consigned units');
            return false;           
        }        
        if (pkg.Case__r.AccountId == null)
        {
            pkg.addError('Parent Case must have an Account set in order to create an Action Package');
            return false;
        }
        
        if (pkg.Case__r.ContactId == null)
        {
            pkg.addError('Parent Case must have a Contact set in order to create an Action Package');
            return false;
        }
        
        if ((pkg.Void_Vehicle__c || pkg.Void_House_Transport__c) &&
            !'VOID'.equalsIgnoreCase(pkg.Case__r.Claim_Resolution__c)) 
        {
            pkg.addError('Parent Case must have a Resolution of "Void" to create a Void or Transport Void Action Package');
            return false;
        }
        
        if ('CONCESSION'.equalsIgnoreCase(pkg.Package_Type__c))
        {
            if(!'ARBITRATION'.equalsIgnoreCase(pkg.Case__r.Type))
            {
                pkg.AddError('Concessions can only created as the result of an Arbitration Case Type');
                return false;
            }
            else if (!'VOID'.equalsIgnoreCase(pkg.Case__r.Claim_Resolution__c) &&
                !'CONCESSIONS'.equalsIgnoreCase(pkg.Case__r.Claim_Resolution__c))
            {
                pkg.AddError('Parent Case must have a Resolution of "Void" or "Concessions" to create a Concession Action Package');
                return false;
            }
        }
        //* B-20138-- Update Concessions for DealerBlock sales in SF for specific payment method
        //* PPM: 72386 - Remove validation
        //* ------------------------------------------------------------------------------------
        if ('CONCESSION'.equalsIgnoreCase(pkg.Package_Type__c) &&
            'Yes'.equalsIgnoreCase(pkg.Case__r.VIN__r.Is_Dealer_Block__c) &&
            pkg.Standard_SAP_Transactions__c &&
             (
            // Replace PPA with PPAA (ppm 102221 )
            //'pay processing auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) || 
            'pay processing adesa auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) || 
            'adesa\'s centralized payment'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
            'ally financial floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
            'tfs floorplan'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||           
            'toyota fin svcs floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
            'pay adesa worldwide'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
            'pay openlane worldwide - wire'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||            
            'pay using other floorplans'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) 
            )) 
        {
            //pkg.addError('Please unCheck the Standard Sap Transaction, since it is a DealerBlock Vehicle and OL Does not handle the settlement..');
           pkg.Standard_SAP_Transactions__c = false;
        }
        //--------------------------------------------------
        if ('ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) &&
                !'VOID'.equalsIgnoreCase(pkg.Case__r.Claim_Resolution__c) &&
                !'CREDIT'.equalsIgnoreCase(pkg.Case__r.Claim_Resolution__c))
        {
            pkg.addError('Parent Case must have a Resolution of "Void" or "Credit" to create an Adjustment Action Package');
            return false;
        }
        //* B-20315 Update Adjustments for DealerBlock sales in SF for specific payment method
        //* ------------------------------------------------------------------------------------
        if ('ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) &&
                'Yes'.equalsIgnoreCase(pkg.Case__r.VIN__r.Is_Dealer_Block__c) &&
               pkg.Standard_SAP_Transactions__c &&
               !(pkg.Auto_Approve_Override__c = true) &&
             (
            // Replace PPA with PPAA (ppm 102221 )
            //'pay processing auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
            'pay processing adesa auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) || 
            'adesa\'s centralized payment'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
            'ally financial floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
            'tfs floorplan'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||           
            'toyota fin svcs floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
            'pay adesa worldwide'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
            'pay openlane worldwide - wire'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||            
            'pay using other floorplans'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) 
            )) 
        {
            pkg.addError('Please unCheck the Standard Sap Transaction, since it is a DealerBlock Vehicle and OL Does not handle the settlement..');
            return false;
        }
        //--------------------------------------------------

        //* B-21184  BMWFS - No Sale Transport - Do not call SAP when Transport buyer is BMWFS 
        //* ------------------------------------------------------------------------------------
        
        if ( 
            (
                pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Transport Adjustment') ||
                pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'Transport Void')
            ) &&
            (   'Transport Void'.equalsIgnoreCase(pkg.Package_Type__c) ||
                'Transport Adjustment'.equalsIgnoreCase(pkg.Package_Type__c)
            ) &&
                pkg.Standard_SAP_Transactions__c &&              
                pkg.Case__r.VIN__r.Buyer_Org_Name__c.contains('BMW') 
            )
        {
            pkg.addError('Please unCheck the Standard Sap Transaction, Since this is a Transport Sell and BMW is the buyer, SAP Posting should be done manually by Accounting Team..');
            return false;
        }
        //--------------------------------------------------        
        if ('AUCTION CREDIT'.equalsIgnoreCase(pkg.Package_Type__c) &&
                !'VOID'.equalsIgnoreCase(pkg.Case__r.Claim_Resolution__c))
        {
            if ('ARBITRATION'.equalsIgnoreCase(pkg.Case__r.Type) &&
                !'CONCESSIONS'.equalsIgnoreCase(pkg.Case__r.Claim_Resolution__c) &&
                !'VOID'.equalsIgnoreCase(pkg.Case__r.Claim_Resolution__c))
            {
                pkg.addError('Parent Case must have Resolution of "Void" or "Concessions" to create an Auction Credit Action Package');
                return false;
            }
            else if (!'ARBITRATION'.equalsIgnoreCase(pkg.Case__r.Type) &&
                !'VOID'.equalsIgnoreCase(pkg.Case__r.Claim_Resolution__c) &&
                !'CREDIT'.equalsIgnoreCase(pkg.Case__r.Claim_Resolution__c))
            {
                pkg.addError('Parent Case must have a Resolution of "Void" or "Credit" to create an Auction Credit Action Package');    
                return false;
            }
        }
        
        if (pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Arbitration Auction Credit') &&
            !'ARBITRATION'.equalsIgnoreCase(pkg.Case__r.Type))
        {
            pkg.addError('"CRF - Arbitration Auction Credit" Action Packages can only be created as a result of Arbitration cases');
            return false;
        }
        else if (pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Auction Credit - Goodwill') &&
            'ARBITRATION'.equalsIgnoreCase(pkg.Case__r.Type))
        {
            pkg.addError('Please use the "CRF - Arbitration Auction Credit" Action Packages record type to create an Auction Credit on an Arbitration.');
            return false;
        }
        
        if (pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Arbitration Seller Auction Credit') &&
            !'ARBITRATION'.equalsIgnoreCase(pkg.Case__r.Type))
        {
            pkg.addError('"CRF - Arbitration Seller Auction Credit" Action Packages can only be created as a result of Arbitration cases');
            return false;
        }
        else if (pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Seller Auction Credit - Goodwill') &&
            'ARBITRATION'.equalsIgnoreCase(pkg.Case__r.Type))
        {
            pkg.addError('Please use the "CRF – Arbitration Seller Auction Credit" Action Package record type to create a Seller Auction Credit on an Arbitration');
            return false;
        }
        
       
        if (pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Arbitration Seller Auction Credit') &&
            !'DEALERSHIP'.equalsIgnoreCase(pkg.case__r.seller__r.Organization_Type__c))
        {
            pkg.addError('Please use the "CRF - Arbitration Seller Auction Credit" Action Packages record type to create an Auction Credit on a Dealership Organization Type.');
            return false;
        }else if (pkg.RecordTypeId == Utils.getRecordTypeId('Action_Package__c', 'CRF - Seller Auction Credit - Goodwill') &&
            !'DEALERSHIP'.equalsIgnoreCase(pkg.case__r.seller__r.Organization_Type__c))
        {
            pkg.addError('Please use the "CRF - Seller Auction Credit - Goodwill" Action Packages record type to create an Auction Credit on a Dealership Organization Type.');
            return false;
        }
        
        
        if ('AUCTION CREDIT'.equalsIgnoreCase(pkg.Credit_To__c) &&
            'SELLER INQUIRY'.equalsIgnoreCase(pkg.Case__r.Type))
        {
            pkg.addError('Auction Credits not allowed on Seller Inquiry cases');
            return false;
        }
        
        if ('SELLER INVOICING ERROR'.equalsIgnoreCase(pkg.Credit_Reason__c) &&
            'BUYER'.equalsIgnoreCase(pkg.Credit_To__c))
        {
            pkg.addError('Credit Reason "Seller Invoicing Error" can only be issued on credits to the Seller');
            return false;
        }
        
        if ('TRANSPORT ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) && !'TRANSPORTATION INQUIRY'.equalsIgnoreCase(pkg.Case__r.Type))
        {
            pkg.addError('Transportation Adjustments can only be created on Transportation Inquiry Cases.');
            return false;
        }
        
        if ('TRANSPORT ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) && pkg.Case__r.VIN__r.Transport_Type__c == 0)
        {
            pkg.addError('Transportation Adjustments can only be created on Purchases with OPENLANE Arranged Transport');
            return false;
        }
        
        if ('TRANSPORT ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) && 
            !'ADJUSTMENT'.equalsIgnoreCase(pkg.Case__r.Claim_Resolution__c))
        {
            pkg.addError('Case Resolution must be set to Adjustment before you can create a transport adjustment action package');
            return false;
        }
        
        if ('Arbitration'.equals(pkg.Case__r.Type) && pkg.Case__r.Resolution_Subtype__c == null) 
        {
            pkg.addError('Parent Case must specify a Resolution Subtype to create an Action Package');
            return false;
        } 
        
        if (pkg.Case__r.VIN__c == null && !pkg.Package_Type__c.equalsIgnoreCase('AUCTION CREDIT')) 
        {
            pkg.addError('Parent Case must be assigned to a Purchase');
            return false;
        } 

        List<String> nonstandardReasons = getForcedNonstandardReasons(pkg);
        if (nonstandardReasons.size() > 0 && pkg.Standard_SAP_Transactions__c)
        {
            
            pkg.addError('Please uncheck "Standard SAP Transactions" to continue.  Reason(s): '+Utils.joinList(nonStandardReasons, '; ')+'.');
        }
        
        if (!pkg.Standard_SAP_Transactions__c && pkg.Directions_for_Accounting__c == null) 
        {
            pkg.addError('Directions for Accounting are required on all Non-Standard SAP Transactions');
            return false;
        } 
        
        if (('Pending...'.equals(pkg.Status__c) || 'Approved'.equals(pkg.Status__c)) &&
                    pkg.Case__r.VIN__r.PS_Hold_Package__c != null &&
                    pkg.Case__r.VIN__r.PS_Hold_Package__c != pkg.Id) 
        {
            pkg.addError('This vehicle already has an Action Package awaiting approval.  Please wait until that package is Approved/Rejected before submitting a new package.');
            return false;
        } 
        
        if (pkg.Void_House_Transport__c && 
                    pkg.Case__r.VIN__r.Transport_Void_Package__c != null &&
                    pkg.Case__r.VIN__r.Transport_Void_Package__c != pkg.Id) 
        {
            pkg.addError('Transport has already been voided on this vehicle.');
            return false;
        } 
        
        if (pkg.Void_Vehicle__c && 
                    pkg.Case__r.VIN__r.Vehicle_Void_Package__c != null &&
                    pkg.Case__r.VIN__r.Vehicle_Void_Package__c != pkg.Id) 
        {
            pkg.addError('This vehicle sale has already been voided.');
            return false;
        } 
        
        if (!pkg.Void_House_Transport__c && pkg.House_Transport_Responsible_Party__c != null && !'Buyer'.equals(pkg.House_Transport_Responsible_Party__c)) 
        {
            pkg.addError('Cannot void transport on this vehicle.  Please set House Transport Responsible Party to "None"');
            return false;
        } 
        
        if (pkg.Void_House_Transport__c && pkg.Transport_Type__c == 0) 
        {
            pkg.addError('Cannot void transport on a type 0 (vehicle only) purchase.');
            return false;
        } 
        
        if (pkg.Void_Vehicle__c && pkg.Transport_Type__c == 3) 
        {
            pkg.addError('Cannot void vehicle sale on a type 3 (transport only) purchase.');
            return false;
        }

        return true;
    }
    
    public static boolean validateTransportVoid(Action_Package__c pkg) 
    {
        // Check to make sure vehicle has not been picked up.  
        // Org id 27445, OPENLANE TRANSPORT CANADA, makes pickup dates unreliable,
        //  so those cases must be allowed.  
        if (pkg.Case__r.VIN__r.Actual_Pickup__c != null && 
            !'27445'.equals(pkg.Case__r.VIN__r.ATC_Transporter__c)) 
        {
            pkg.addError('Cannot create a Transport Void if vehicle has already been picked up.  Please issue a credit instead.');
            return false;
        }
        
        return true;
    }
    
    public static boolean validateVehicleVoid(Action_Package__c pkg) 
    {
        System.debug(' information...for pkg '+ pkg.Case__r.VIN__r.ATC_Transporter__c + ' '+ pkg.House_Transport_Responsible_Party__c + ' '+ pkg.Void_House_Transport__c + ' '+pkg.Case__r.VIN__r.Actual_Pickup__c +' ' + pkg.Case__r.VIN__r.Segment_Name__c+' '+ pkg.Country__c +' '+pkg.CurrencyIsoCode+' '+pkg.Package_Type__c);
        // Require House Transport Responsible Party if the vehicle has already been picked up
        // Don't require for OPENLANE TRANSPORT CANADA cases
        if (pkg.Void_House_Transport__c &&
            pkg.Case__r.VIN__r.Actual_Pickup__c != null &&
            pkg.House_Transport_Responsible_Party__c == null &&
            !'27445'.equals(pkg.Case__r.VIN__r.ATC_Transporter__c)) 
        {
            pkg.addError('Vehicle has already been picked up. Please select a House Transport Responsible Party');
            return false;
        }
        
        // Require House Transport Responsible Party to be null if the vehicle has not been picked up. 
        // For OPENLANE TRANSPORT CANADA cases, trust the user input
        if (pkg.Void_House_Transport__c &&
            pkg.Case__r.VIN__r.Actual_Pickup__c == null &&
            pkg.House_Transport_Responsible_Party__c != null &&
            !'27445'.equals(pkg.Case__r.VIN__r.ATC_Transporter__c)) 
        {
            pkg.addError('This vehicle has not been picked up yet.  Please set House Transport Responsible Party to "None."');
            return false;
        }
       
       // B-20773 Allow ARB user to enter an ARB Fee for Dealer Block Vehicles
       //* --------------------------------------------------------------------
        System.debug(' information...for pkg is delaer block ' +  pkg.Case__r.VIN__r.Is_Dealer_Block__c+' '+ pkg.Arbitration_Fee__c +' '+pkg.CurrencyIsoCode+' '+pkg.Package_Type__c);       
        if ( pkg.Package_Type__c.toUpperCase().startsWith('AUCTION VOID') &&
            'Yes'.equalsIgnoreCase(pkg.Case__r.VIN__r.Is_Dealer_Block__c) &&
            pkg.Arbitration_Fee__c != null 
            )
        {
        //    // ('Dealer Block Vehicles Allowed for Arbitration Fee...');
        //    if (Double.valueOf(pkg.Arbitration_Fee__c) > 999)
        //    {
        //        pkg.addError('Maximum Arb Fee should be 999 ');
        //        return false;
        //    }
        //PPM: 72536 - DO NOT Allow Arb fee for dealerblock vehicle
            if  (Double.valueOf(pkg.Arbitration_Fee__c) > 0)
            {
                pkg.addError('Arbitration Fee is not allowed on DealerBlock vehicles ');
                return false;
            }            
            else
            {
                return true;
            }
        }
            
       // B-19709: Voids Automation Arbitration fee
        System.debug(' information...for pkg ' +  pkg.Case__r.VIN__r.Segment_Name__c+' '+ pkg.Country__c +' '+pkg.CurrencyIsoCode+' '+pkg.Package_Type__c);       
        if (pkg.Package_Type__c.toUpperCase().startsWith('AUCTION VOID') &&
            'United States'.equalsIgnoreCase(pkg.Country__c) &&
            pkg.Arbitration_Fee__c != null && (
            'CAP Dealers'.equalsIgnoreCase(pkg.Case__r.VIN__r.Segment_Name__c) || 
            'CAP Inst Repo'.equalsIgnoreCase(pkg.Case__r.VIN__r.Segment_Name__c) ||
            'CAP iDEAL Repo'.equalsIgnoreCase(pkg.Case__r.VIN__r.Segment_Name__c) 
            )
            
            )
        {
            if (Double.valueOf(pkg.Arbitration_Fee__c) > 999)
            {
                pkg.addError('Maximum Arb Fee should be 999 ');
                return false;
            }
            else
            {
                return true;
            }

        } else if (pkg.Package_Type__c.toUpperCase().startsWith('AUCTION VOID') &&
            'United States'.equalsIgnoreCase(pkg.Country__c) &&
            pkg.Arbitration_Fee__c == null && (
            'CAP Dealers'.equalsIgnoreCase(pkg.Case__r.VIN__r.Segment_Name__c) || 
            'CAP Inst Repo'.equalsIgnoreCase(pkg.Case__r.VIN__r.Segment_Name__c) ||
            'CAP iDEAL Repo'.equalsIgnoreCase(pkg.Case__r.VIN__r.Segment_Name__c) 
            ))
        {
                        
            pkg.addError('Please select an Arbitration Fee for USA  CAP Dealer/ Inst Repo/ Ideal Repo ....');
            return false;
        }  
        
        // B-15852: Voids SF - iDeal Voids
        if (pkg.Package_Type__c.toUpperCase().startsWith('AUCTION VOID') &&
            'OPEN D2D'.equalsIgnoreCase(pkg.Sale_Classification__c) &&
            !'CANADA'.equalsIgnoreCase(pkg.Country__c) &&
            pkg.Arbitration_Fee__c == null)
        {
            pkg.addError('Please select an Arbitration Fee for US D2D Auction Voids.');
            return false;
        }
        
        // B-15852: Voids SF - iDeal Voids
        if ((!pkg.Package_Type__c.toUpperCase().startsWith('AUCTION VOID') ||
            !'OPEN D2D'.equalsIgnoreCase(pkg.Sale_Classification__c) ||
            'CANADA'.equalsIgnoreCase(pkg.Country__c)) &&
            pkg.Arbitration_Fee__c != null)
        {   //new change for 90944 
            if ( pkg.Arbitration_Fee__c != null
                && (!'CANADA'.equalsIgnoreCase(pkg.Country__c)) 
                && (pkg.Package_Type__c.toUpperCase().startsWith('AUCTION VOID'))
                && ('ADC Open'.equalsIgnoreCase(pkg.Sale_Classification__c) ||
                    'ADC CTN Revenue'.equalsIgnoreCase(pkg.Sale_Classification__c) ||
                    'ADC CTN Non Revenue'.equalsIgnoreCase(pkg.Sale_Classification__c) )
                    )           
            { }
            else {      
                    pkg.addError('Arbitration Fees are only applicable to US D2D,ADC CTN Auction Voids - please leave this field blank.');
                    return false;
                }
        }
        
        // B-15852: Voids SF - iDeal Voids
        if (pkg.Arbitration_Fee__c != null &&
            pkg.Directions_for_Accounting__c == null)
        {
            pkg.addError('Please enter notes about selected Arbitration Fee in the Directions for Accounting field.');
            return false;
        }

        return true;
    }
    
    public static boolean validateExtraCostPackage(Action_Package__c pkg) 
    {
        // Require Extra Cost packages to have at least 1 extra cost.  
        if ((pkg.Submitted__c || pkg.Approved__c) && pkg.Extra_Cost_Count__c == 0) 
        {
            pkg.addError('Please add an Extra Cost before submitting for approval.');
            return false;
        }
        
        return true;
    }
    
    public static List<String> getForcedNonstandardReasons(Action_Package__c pkg)
    {
        List<String> reasonList = new List<String>();
        
        if (pkg.Case__r.VIN__r != null && 
            pkg.Case__r.VIN__r.ATC_Sale_Date__c != null && 
            DateTime.newInstance(2010, 7, 1).getTime() > pkg.Case__r.VIN__r.ATC_Sale_Date__c.getTime() &&
            'CANADA'.equalsIgnoreCase(pkg.Country__c) &&
            !'AUCTION CREDIT'.equalsIgnoreCase(pkg.Package_Type__c))
        {
            reasonList.add('Canadian Sale occurred prior to July 1st, 2010');
        }
        
        if ('NON-STANDARD'.equalsIgnoreCase(pkg.Tax__c))
        {
            reasonList.add('Taxes have been marked Non-Standard');
        }
        
        if (('Buyer'.equals(pkg.House_Transport_Responsible_Party__c) ||
                   'Transporter'.equals(pkg.House_Transport_Responsible_Party__c) ||
                   'Inspector'.equals(pkg.House_Transport_Responsible_Party__c) ||
                   'Other'.equals(pkg.House_Transport_Responsible_Party__c))) 
        {
            reasonList.add('"'+pkg.House_Transport_Responsible_Party__c+'" has been selected for "House Transport Responsible Party"');
        }
        
        if (pkg.Third_Party_Extra_Costs__c != null && pkg.Third_Party_Extra_Costs__c > 0) 
        {
            reasonList.add('Third party other than Seller has been selected for an Extra Cost Responsible Party');
        } 
        
        if (pkg.Invalid_HST_Count__c != null && pkg.Invalid_HST_Count__c > 0)
        {
            reasonList.add('Non-Standard Extra Cost Tax Type detected.  Expected "HST"');
        }
        
        if (pkg.Invalid_QST_Count__c != null && pkg.Invalid_QST_Count__c > 0)
        {
            reasonList.add('Non-Standard Extra Cost Tax Type detected.  Expected "QST + GST"');
        }
        
        if (pkg.Invalid_GST_Count__c != null && pkg.Invalid_GST_Count__c > 0)
        {
            reasonList.add('Non-Standard Extra Cost Tax Type detected.  Expected "GST"');
        }
        
        if ('CANADA'.equalsIgnoreCase(pkg.Country__c) && 
            pkg.Void_House_Transport__c && 
            pkg.Case__r.VIN__r.Transport_Incentive__c != null && 
            pkg.Case__r.VIN__r.Transport_Incentive__c > 0)
        {
            reasonList.add('Canadian Sale with Transport Incentive');
        }
        /*
        if ('SELLER'.equalsIgnoreCase(pkg.Credit_To__c))
        {
            reasonList.add('Credit To set to "Seller"');
        }
        */
        if (pkg.Transporter_Amount__c > 0)
        {
            reasonList.add('"Transporter Amount" entered for Responsible Party');
        }
        
        if (pkg.Inspector_Amount__c > 0)
        {
            reasonList.add('"Inspector Amount" entered for Responsible Party');
        }
            
        if (pkg.Other_Party_Amount__c > 0)
        {
            reasonList.add('"Other Party Amount" entered for Responsible Party');
        }
        
        return reasonList;
    }
}