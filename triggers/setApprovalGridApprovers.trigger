trigger setApprovalGridApprovers on Action_Package__c(after insert, after update) {

    // get all the users
    // get all the fields
    try {
        if (!ActionPackageValidator.hasAlreadyDone()) {
            // Your trigger code here
            System.debug(' Trigger fired.... ');
            List < Action_Package__c > toUpdate = new List < Action_Package__c > ();
            // --------------------- B-44323 - removing approvers hardcoded usernames -----------------
            ApprovalGridHelper.initVar();
            Map < String, User > apprs = ApprovalGridHelper.approvers;
            MAP < String, Action_Package_Approvers__c > mapApprs = ApprovalGridHelper.mapApprovers;
            // ---------------------      


            List < Action_Package__c > allPackages = [select Case__r.Type, Case__r.VIN__r.Sale_Class__c,
                Case__r.VIN__r.Country__c, Case__r.VIN__r.Sale_Price__c, Package_Type__c,
                Standard_SAP_Transactions__c, House_Extra_Costs__c,
                Require_Approval__c, Require_C_Level_Approval__c,
                Manager_Approver__c, Director_Approver__c,
                VP_Approver__c, Case_Reason__c, Segment_Name__c, Case__r.VIN__r.RecordType.Name
                from action_package__c
                where id in: Trigger.new
            ];


            for (Action_Package__c pkg: allPackages) {
                System.debug('Case Type: ' + pkg.Case__r.Type);
                System.debug('Sales Classification: ' + pkg.Case__r.VIN__r.Sale_Class__c);
                System.debug('Country: ' + pkg.Case__r.VIN__r.Country__c);
                System.debug('Package Type: ' + pkg.Package_Type__c);
                System.debug('Standard Sap Transaction: ' + pkg.Standard_SAP_Transactions__c);
                System.debug('House Extra Cost: ' + pkg.House_Extra_Costs__c);
                System.debug('Sale Price: ' + pkg.Case__r.VIN__r.Sale_Price__c);
                System.debug('Case Reason: ' + pkg.Case_Reason__c);
                System.debug('Segment Name: ' + pkg.Segment_Name__c);

               if(pkg.Case__r.VIN__r.RecordType.Name != null && pkg.Case__r.VIN__r.RecordType.Name.equalsIgnoreCase('Buyout') && (pkg.Case__r.VIN__r.Country__c.equalsIgnoreCase('usa') || pkg.Case__r.VIN__r.Country__c.equalsIgnoreCase('united states') || pkg.Case__r.VIN__r.Country__c.equalsIgnoreCase('us') ) ) {
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Buyout-1').Manager__c).id;
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Buyout-1';
                                toUpdate.add(pkg);
               }
               else if (pkg.Case_Reason__c != null && pkg.Case_Reason__c.equalsIgnoreCase('Double Sale') && (pkg.Case__r.VIN__r.Country__c.equalsIgnoreCase('usa') || pkg.Case__r.VIN__r.Country__c.equalsIgnoreCase('united states') || pkg.Case__r.VIN__r.Country__c.equalsIgnoreCase('us') )) { //// B-44323 - criteria for Case Reason
                    // *** Condition Key : Case Reason-US-1
                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Case Reason-US-1').Manager__c).id;
                    pkg.Require_Approval__c = true;
                    pkg.ApprovalConditionKey__c = 'Case Reason-US-1';
                    toUpdate.add(pkg);
                    System.debug('Case Reason-Canada-1');
                } else if (pkg.Case__r.Type.equalsIgnoreCase('Arbitration')) {
                    System.debug(' Arbitration ');
                    
                    /* Commenting out TredRev logic as they no longer want it. Keeping code for future in case they change their mind.
                     * if (pkg.Segment_Name__c != null && pkg.Segment_Name__c.equalsIgnoreCase('TradeRev')) { // B-44323 - criteria for TradeRev
                        // *** Condition Key : Segment Name-1
                        pkg.Manager_Approver__c = apprs.get(mapApprs.get('Segment Name-1').Manager__c).id;
                        pkg.Require_Approval__c = true;
                        pkg.ApprovalConditionKey__c = 'Segment Name-1';
                        toUpdate.add(pkg);
                        System.debug('Segment Name-1');
                    } else */
                    
                    if (pkg.Case__r.VIN__r.Sale_Class__c.contains('D2D') || pkg.Case__r.VIN__r.Sale_Class__c.contains('ADC'))
                    // D2D = IDeal  D2D Canada   IDeal
                    {
                        System.debug(' D2D ');
                        if (pkg.Case__r.VIN__r.Country__c.equalsIgnoreCase('Canada')) { // Arbitration D2D Canada   IDeal
                            // Col 6, row 5  Non Standard  
                            if (!pkg.Standard_SAP_Transactions__c &&
                                (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Extra Cost'))) {
                                // *** Condition Key : Arbitration-Ideal-Canada-1 
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-Canada-1').Manager__c).id;
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-Canada-1';
                                toUpdate.add(pkg);
                                System.debug('92 Col 6, row 5  Non Standard , Arbitration-Ideal-Canada-1');
                            }
                            // Col  5, row 6, 7,8,9
                            else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec')) {
                                // *** Condition Key : Arbitration-Ideal-Canada-2
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-Canada-2').Manager__c).id;
                                pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-Canada-2').Director__c).id;
                                //pkg.VP_Approver__c = approvers.get(nagiPalle).id;
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-Canada-2';
                                toUpdate.add(pkg);
                                System.debug('95 Col  5, row 6, 7,8,9, Arbitration-Ideal-Canada-2');
                            }
                            // Col 6  CA Ideal D2D
                            else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Extra Cost')) {
                                // Col 6, row 6
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Arbitration-Ideal-Canada-3 
                                    pkg.Require_Approval__c = false;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-Canada-3';
                                    toUpdate.add(pkg); // No approval required. Null out all approval fields.
                                }
                                // Col 6, row 7
                                else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Arbitration-Ideal-Canada-4
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-Canada-4').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-Canada-4';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Ideal-Canada-4');
                                }
                                // Col 6, row 8
                                else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Arbitration-Ideal-Canada-5
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-Canada-5').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-Canada-5';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Ideal-Canada-5');
                                }
                                // Col 6, row 9
                                else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : Arbitration-Ideal-Canada-6 
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-Canada-6').Director__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-Canada-6';
                                    toUpdate.add(pkg);
                                     System.debug('Arbitration-Ideal-Canada-6');
                                }
                            }
                        }

                        //From Left Column 3 and 4
                        //---------------------------------
                        else { // Arbitration D2D US  IDeal   
                            //From Left Column 3 ,5
                            if (!pkg.Standard_SAP_Transactions__c && //  NON STANDARD TRANSACTION
                                (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec'))) {
                                // *** Condition Key : Arbitration-Ideal-US-1 
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-1').Manager__c).id;
                                pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-1').Director__c).id;
                                if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                    pkg.VP_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-1').VP__c).id;
                                }
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-US-1';
                                toUpdate.add(pkg);
                                System.debug('Arbitration-Ideal-US-1');
                            } else if (!pkg.Standard_SAP_Transactions__c && //  NON STANDARD TRANSACTION
                                (pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Extra Cost'))) {
                                // *** Condition Key : Arbitration-Ideal-US-2
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-2').Manager__c).id;
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-US-2';
                                toUpdate.add(pkg);
                                System.debug('Arbitration-Ideal-US-2');
                            }

                            // From left Column 3, R 6,7,8,9
                            else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec')) {
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Arbitration-Ideal-US-3
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-3').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-3').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-3').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-US-3';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Ideal-US-3');
                                } else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Arbitration-Ideal-US-4
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-4').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-4').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-4').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-US-4';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Ideal-US-4');
                                } else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Arbitration-Ideal-US-5
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-5').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-5').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-5').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-US-5';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Ideal-US-5');
                                } else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : Arbitration-Ideal-US-6
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-6').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-6').Director__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-US-6';
                                    toUpdate.add(pkg);
                                }
                            }
                            // From Left Column 4,6
                            else if (pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Extra Cost')) {
                                // From Left Column 4,6     
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Arbitration-Ideal-US-7
                                    pkg.Require_Approval__c = false;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-US-7';
                                    toUpdate.add(pkg); // No approval required. Null out all approval fields.
                                    System.debug('Arbitration-Ideal-US-7');
                                }
                                //4,7
                                else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Arbitration-Ideal-US-8
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-8').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-US-8';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Ideal-US-8');
                                }
                                //4,8
                                else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Arbitration-Ideal-US-9
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-9').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-US-9';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Ideal-US-9');
                                }
                                //4,9
                                else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : Arbitration-Ideal-US-10
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Ideal-US-10').Manager__c).id;
                                    pkg.Require_Approval__c = true;   
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Ideal-US-10';                                 
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Ideal-US-10');
                                }
                            }
                        }
                    }

                    //Left 2 Column of Excel Sheet ( Approval Grid )  
                    //US and CA Institutional
                    else {
                        System.debug(' Institutional ');
                        // CA Institutional Arbitration
                        if (pkg.Case__r.VIN__r.Country__c.equalsIgnoreCase('Canada')) {
                            System.debug(' Institutional Canada ');
                            // Non Standard VOID  = Standard SAP box is not Checked 
                            // Col A and  B row 5 
                            if (!pkg.Standard_SAP_Transactions__c &&
                                (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Extra Cost'))) {
                                // *** Condition Key : Arbitration-Institutional-Canada-1
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-Canada-1').Manager__c).id;
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-Canada-1';
                                toUpdate.add(pkg);
                                System.debug('Arbitration-Institutional-Canada-1');
                            }

                            //  Col A 
                            else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec')) {

                                //  Col A , Row 6,7,8,9
                                if (pkg.House_Extra_Costs__c >= 0) 
                                {
                                    // *** Condition Key : Arbitration-Institutional-Canada-2
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-Canada-2').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-Canada-2').Director__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-Canada-2';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Institutional-Canada-2');
                                }
                            }

                            // Col B
                            else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Extra Cost')) {
                                //Col B , Row 6
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Arbitration-Institutional-Canada-3
                                    pkg.Require_Approval__c = false;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-Canada-3';
                                    toUpdate.add(pkg); // No approval required. Null out all approval fields.
                                }
                                //Col B , Row 7
                                else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Arbitration-Institutional-Canada-4
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-Canada-4').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-Canada-4';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Institutional-Canada-4');
                                }
                                //Col B , Row 8
                                else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Arbitration-Institutional-Canada-5
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-Canada-5').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-Canada-5';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Institutional-Canada-5');
                                }
                                //Col B , Row 9
                                else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : Arbitration-Institutional-Canada-6
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-Canada-6').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-Canada-6';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Institutional-Canada-6');
                                }
                            }

                        }
                        // US Institutional Arbitration
                        else {
                            if (!pkg.Standard_SAP_Transactions__c && //  NON STANDARD TRANSACTION
                                (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec'))) {
                                // *** Condition Key : Arbitration-Institutional-US-1
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-1').Manager__c).id;
                                pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-1').Director__c).id;
                                if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                    pkg.VP_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-1').VP__c).id;
                                }                                
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-US-1';
                                toUpdate.add(pkg);
                                System.debug('Arbitration-Institutional-US-1');
                            } else if (!pkg.Standard_SAP_Transactions__c && //  NON STANDARD TRANSACTION
                                (pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Extra Cost'))) {
                                // *** Condition Key : Arbitration-Institutional-US-2
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-2').Manager__c).id;
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-US-2';
                                toUpdate.add(pkg);
                                System.debug('Arbitration-Institutional-US-2');
                            } else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec')) {
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Arbitration-Institutional-US-3                                    
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-3').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-3').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-3').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-US-3';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Institutional-US-3');
                                } else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Arbitration-Institutional-US-4                                    
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-4').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-4').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-4').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-US-4';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Institutional-US-4');
                                } else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Arbitration-Institutional-US-5  
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-5').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-5').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-5').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-US-5';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Institutional-US-5');
                                } else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : Arbitration-Institutional-US-6
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-6').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-6').Director__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-US-6';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Institutional-US-6');
                                }
                            } else if (pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Extra Cost')) {
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Arbitration-Institutional-US-7
                                    pkg.Require_Approval__c = false;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-US-7';
                                    toUpdate.add(pkg); // No approval required. Null out all approval fields.
                                    System.debug('Arbitration-Institutional-US-7');
                                } else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Arbitration-Institutional-US-8
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-8').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-US-8';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Institutional-US-8');
                                } else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Arbitration-Institutional-US-9
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-9').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-US-9';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Institutional-US-9');
                                } else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : Arbitration-Institutional-US-10
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Arbitration-Institutional-US-10').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Arbitration-Institutional-US-10';
                                    toUpdate.add(pkg);
                                    System.debug('Arbitration-Institutional-US-10');
                                }
                            }
                        }

                    }
                    //  End of Block

                }
                //Internal Void Approval Matrix
                else if (pkg.Case__r.Type.equalsIgnoreCase('Internal Issue')) { // Internal Void
                    // Internal Void D2D Canada
                    if (pkg.Case__r.VIN__r.Sale_Class__c.contains('D2D') || pkg.Case__r.VIN__r.Sale_Class__c.contains('ADC')) {
                        if (pkg.Case__r.VIN__r.Country__c.equalsIgnoreCase('Canada')) { // Internal Void D2D Canada
                            // Col 8 and 7 ,  row 16    Non Standard Void    CA - Ideal = > D2D  Canada
                            if (!pkg.Standard_SAP_Transactions__c &&
                                (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Extra Cost'))) {
                                // *** Condition Key : Internal Issue-Ideal-Canada-1
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-Canada-1').Manager__c).id;
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-Canada-1';
                                toUpdate.add(pkg);
                                System.debug('Internal Issue-Ideal-Canada-1');
                            }
                            // Col 7, row 17,18,19,20  Non Standard Void    CA - Ideal  == > D2D Canada
                            else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec')) {
                                // *** Condition Key : Internal Issue-Ideal-Canada-2
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-Canada-2').Manager__c).id;
                                pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-Canada-2').Director__c).id;
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-Canada-2';
                                toUpdate.add(pkg);
                                System.debug('Internal Issue-Ideal-Canada-2');
                            }
                            // Col 8 
                            else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Extra Cost')) {
                                // Col 8, 17  
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Internal Issue-Ideal-Canada-3
                                    pkg.Require_Approval__c = false;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-Canada-3';
                                    toUpdate.add(pkg); // No approval required. Null out all approval fields.
                                    System.debug('Internal Issue-Ideal-Canada-3');
                                }
                                // Col 8, 18
                                else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Internal Issue-Ideal-Canada-4
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-Canada-4').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-Canada-4';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Ideal-Canada-4');
                                }
                                // Col 8, 19
                                else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Internal Issue-Ideal-Canada-5
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-Canada-5').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-Canada-5';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Ideal-Canada-5');
                                }
                                // Col 8, 20
                                else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : Internal Issue-Ideal-Canada-6
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-Canada-6';
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-Canada-6').Director__c).id;
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Ideal-Canada-6');
                                }
                            }
                        }
                        // Internal US Ideal  D2D USA 
                        else {
                            if (!pkg.Standard_SAP_Transactions__c && //  NON STANDARD TRANSACTION
                                (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec'))) {
                                // *** Condition Key : Internal Issue-Ideal-US-1
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-1').Manager__c).id;
                                pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-1').Director__c).id;
                                if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                    pkg.VP_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-1').VP__c).id;
                                }
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-US-1';
                                toUpdate.add(pkg);
                                System.debug('Internal Issue-Ideal-US-1');
                            } else if (!pkg.Standard_SAP_Transactions__c && //  NON STANDARD TRANSACTION
                                (pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Extra Cost'))) {
                                // *** Condition Key : Internal Issue-Ideal-US-2
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-2').Manager__c).id;
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-US-2';
                                toUpdate.add(pkg);
                                System.debug('Internal Issue-Ideal-US-2');
                            } else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec')) {
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Internal Issue-Ideal-US-3
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-3').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-3').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-3').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-US-3';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Ideal-US-3');
                                } else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Internal Issue-Ideal-US-4
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-4').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-4').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-4').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-US-4';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Ideal-US-4');
                                } else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Internal Issue-Ideal-US-5
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-5').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-5').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-5').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-US-5';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Ideal-US-5');
                                } else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : Internal Issue-Ideal-US-6
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-6').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-6').Director__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-US-6';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Ideal-US-6');
                                }
                            } else if (pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Extra Cost')) {
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Internal Issue-Ideal-US-7
                                    pkg.Require_Approval__c = false;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-US-7';
                                    toUpdate.add(pkg); // No approval required. Null out all approval fields.
                                    System.debug('Internal Issue-Ideal-US-7');
                                } else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Internal Issue-Ideal-US-8
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-8').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-US-8';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Ideal-US-8');
                                } else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Internal Issue-Ideal-US-9
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-9').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-US-9';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Ideal-US-9');
                                } else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : Internal Issue-Ideal-US-10
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Ideal-US-10').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Ideal-US-10';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Ideal-US-10');
                                }
                            }
                        }
                    }

                    // CA Institutional 
                    else { // Internal Void Institutional
                        // Internal Void Institutional Canada
                        if (pkg.Case__r.VIN__r.Country__c.equalsIgnoreCase('Canada')) {
                            // Col 3 and 4, row 16 Non Standard Void 
                            if (!pkg.Standard_SAP_Transactions__c &&
                                (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Extra Cost'))) {
                                // *** Condition Key : Internal Issue-Institutional-Canada-1
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-Canada-1').Manager__c).id;
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-Canada-1';
                                toUpdate.add(pkg);
                                System.debug('Internal Issue-Institutional-Canada-1');
                            }
                            // Col 3
                            else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec')) {
                                // Col 3, row 17,18, 19             
                                if (pkg.House_Extra_Costs__c >= 0 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Internal Issue-Institutional-Canada-2
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-Canada-2').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-Canada-2').Director__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-Canada-2';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-Canada-2');
                                }
                                //Cold 3, 20
                                else {
                                    // *** Condition Key : Internal Issue-Institutional-Canada-3
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-Canada-3').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-Canada-3').Director__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-Canada-3';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-Canada-3');
                                }
                            }
                            // Col 4 
                            else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Extra Cost')) {
                                // Col 4, 17
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Internal Issue-Institutional-Canada-4
                                    pkg.Require_Approval__c = false;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-Canada-4';
                                    toUpdate.add(pkg); // No approval required. Null out all approval fields.
                                    System.debug('Internal Issue-Institutional-Canada-4');
                                }
                                // Col 4, 18
                                else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Internal Issue-Institutional-Canada-5
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-Canada-5').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-Canada-5';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-Canada-5');
                                }
                                // Col 4, 19
                                else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Internal Issue-Institutional-Canada-6
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-Canada-6').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-Canada-6';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-Canada-6');
                                }
                                // Col 4, 20
                                else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : Internal Issue-Institutional-Canada-7                                    
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-Canada-7').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-Canada-7';    
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-Canada-7');
                                }
                            }
                        }
                        // USA Institutional     Internal Void
                        // Internal Void Institutional US 
                        else {
                            if (!pkg.Standard_SAP_Transactions__c && //  NON STANDARD TRANSACTION
                                (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec'))) {
                                // *** Condition Key : Internal Issue-Institutional-US-1
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-1').Manager__c).id;
                                pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-1').Director__c).id;
                                if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                    pkg.VP_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-1').VP__c).id;
                                }
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-US-1';
                                toUpdate.add(pkg);
                                System.debug('Internal Issue-Institutional-US-1');
                            } else if (!pkg.Standard_SAP_Transactions__c && //  NON STANDARD TRANSACTION
                                (pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                    pkg.Package_Type__c.equalsIgnoreCase('Extra Cost'))) {
                                // *** Condition Key : Internal Issue-Institutional-US-2
                                pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-2').Manager__c).id;
                                pkg.Require_Approval__c = true;
                                pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-US-2';
                                toUpdate.add(pkg);
                                System.debug('Internal Issue-Institutional-US-2');
                            } else if (pkg.Package_Type__c.equalsIgnoreCase('House Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - AIA Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party') ||
                                pkg.Package_Type__c.equalsIgnoreCase('House Void - 3rd Party Rec')) {
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Internal Issue-Institutional-US-3
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-3').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-3').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-3').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-US-3';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-US-3');
                                } else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Internal Issue-Institutional-US-4
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-4').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-4').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-4').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-US-4';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-US-4');
                                } else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Internal Issue-Institutional-US-5
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-5').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-5').Director__c).id;
                                    if (pkg.Case__r.VIN__r.Sale_Price__c > 50000) {
                                        pkg.VP_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-5').VP__c).id;
                                    }
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-US-5';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-US-5');
                                } else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : IInternal Issue-Institutional-US-6
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-6').Manager__c).id;
                                    pkg.Director_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-6').Director__c).id;
                                    pkg.Require_Approval__c = true;
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-US-6');
                                }
                            } else if (pkg.Package_Type__c.equalsIgnoreCase('Auction Void') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - Rec') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Auction Void - SWAP') ||
                                pkg.Package_Type__c.equalsIgnoreCase('Extra Cost')) {
                                if (pkg.House_Extra_Costs__c == 0) {
                                    // *** Condition Key : Internal Issue-Institutional-US-7
                                    pkg.Require_Approval__c = false;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-US-7';
                                    toUpdate.add(pkg); // No approval required. Null out all approval fields.
                                    System.debug('Internal Issue-Institutional-US-7');
                                } else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 500) {
                                    // *** Condition Key : Internal Issue-Institutional-US-8
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-8').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-US-8';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-US-8');
                                } else if (pkg.House_Extra_Costs__c >= 500 && pkg.House_Extra_Costs__c <= 5000) {
                                    // *** Condition Key : Internal Issue-Institutional-US-9
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-9').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-US-9';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-US-9');
                                } else if (pkg.House_Extra_Costs__c > 5000) {
                                    // *** Condition Key : Internal Issue-Institutional-US-10
                                    pkg.Manager_Approver__c = apprs.get(mapApprs.get('Internal Issue-Institutional-US-10').Manager__c).id;
                                    pkg.Require_Approval__c = true;
                                    pkg.ApprovalConditionKey__c = 'Internal Issue-Institutional-US-10';
                                    toUpdate.add(pkg);
                                    System.debug('Internal Issue-Institutional-US-10');
                                }
                            }
                        }
                    }
                }
                // Transport Void Approval Matrix
                else if (pkg.Case__r.Type.equalsIgnoreCase('Transportation Inquiry')) { // Transport 
                    // Transport Canada
                    if (pkg.Case__r.VIN__r.Country__c.equalsIgnoreCase('Canada')) {
                        if (pkg.House_Extra_Costs__c == 0) {
                            // *** Condition Key : Transportation Inquiry-Canada-1
                            pkg.Require_Approval__c = false;
                            pkg.ApprovalConditionKey__c = 'Transportation Inquiry-Canada-1';
                            toUpdate.add(pkg);
                            System.debug('Transportation Inquiry-Canada-1');
                        } else if (pkg.House_Extra_Costs__c > 0 && pkg.House_Extra_Costs__c < 1000) {
                            // *** Condition Key : Transportation Inquiry-Canada-2
                            pkg.Manager_Approver__c = apprs.get(mapApprs.get('Transportation Inquiry-Canada-2').Manager__c).id;
                            pkg.Require_Approval__c = true;
                            pkg.ApprovalConditionKey__c = 'Transportation Inquiry-Canada-2';
                            toUpdate.add(pkg);
                            System.debug('Transportation Inquiry-Canada-2');
                        } else if (pkg.House_Extra_Costs__c >= 1000 && pkg.House_Extra_Costs__c <= 2500) {
                            // *** Condition Key : Transportation Inquiry-Canada-3
                            pkg.Manager_Approver__c = apprs.get(mapApprs.get('Transportation Inquiry-Canada-3').Manager__c).id;
                            pkg.Require_Approval__c = true;
                            pkg.ApprovalConditionKey__c = 'Transportation Inquiry-Canada-3';
                            toUpdate.add(pkg);
                            System.debug('Transportation Inquiry-Canada-3');
                        } else if (pkg.House_Extra_Costs__c > 2500) {
                            // *** Condition Key : Transportation Inquiry-Canada-4
                            pkg.Require_Approval__c = true;
                            pkg.ApprovalConditionKey__c = 'Transportation Inquiry-Canada-4';
                            pkg.Manager_Approver__c = apprs.get(mapApprs.get('Transportation Inquiry-Canada-4').Manager__c).id;
                            pkg.Director_Approver__c = apprs.get(mapApprs.get('Transportation Inquiry-Canada-4').Director__c).id;
                            toUpdate.add(pkg);
                            System.debug('Transportation Inquiry-Canada-4');
                        }
                    }
                    // Transport USA
                    else {
                        if (pkg.House_Extra_Costs__c == 0) {
                            // *** Condition Key : Transportation Inquiry-US-1
                            pkg.Require_Approval__c = false;
                            pkg.ApprovalConditionKey__c = 'Transportation Inquiry-US-1';
                            toUpdate.add(pkg);
                            System.debug('Transportation Inquiry-US-1');
                        } else if (pkg.House_Extra_Costs__c < 1000) {
                            // *** Condition Key : Transportation Inquiry-US-2
                            pkg.Manager_Approver__c = apprs.get(mapApprs.get('Transportation Inquiry-US-2').Manager__c).id;
                            pkg.Require_Approval__c = true;
                            pkg.ApprovalConditionKey__c = 'Transportation Inquiry-US-2';
                            toUpdate.add(pkg);
                            System.debug('Transportation Inquiry-US-2');
                        } else if (pkg.House_Extra_Costs__c >= 1000 && pkg.House_Extra_Costs__c <= 2500) {
                            // *** Condition Key : Transportation Inquiry-US-3
                            pkg.Manager_Approver__c = apprs.get(mapApprs.get('Transportation Inquiry-US-3').Manager__c).id;
                            pkg.Require_Approval__c = true;
                            pkg.ApprovalConditionKey__c = 'Transportation Inquiry-US-3';
                            toUpdate.add(pkg);
                            System.debug('Transportation Inquiry-US-3');
                        } else if (pkg.House_Extra_Costs__c > 2500) {
                            // *** Condition Key : Transportation Inquiry-US-4
                            pkg.Require_Approval__c = true;
                            pkg.ApprovalConditionKey__c = 'Transportation Inquiry-US-4';
                            pkg.Manager_Approver__c = apprs.get(mapApprs.get('Transportation Inquiry-US-4').Manager__c).id;
                            pkg.Director_Approver__c = apprs.get(mapApprs.get('Transportation Inquiry-US-4').Director__c).id;
                            toUpdate.add(pkg);
                            System.debug('Transportation Inquiry-US-4');
                        }
                    }
                }

                //----------------------below section has been pasted  
                System.debug('----------------- Manager_Approver__c' + pkg.Manager_Approver__c); 
                System.debug('----------------- Director_Approver__c' + pkg.Director_Approver__c); 
                System.debug('----------------- VP_Approver__c ' + pkg.VP_Approver__c); 

            } // end of for loop

            ActionPackageValidator.setAlreadyDone();
            if (toUpdate.size() > 0)
                update toUpdate;
        } // end of if *
    } catch (System.Exception e) {
        System.debug('-----##DEBUGGING##' + e.getMessage());
        System.debug('-----##DEBUGGING## getCause : ' + e.getCause());
        System.debug('-----##DEBUGGING## getLineNumber: ' + e.getLineNumber());
        System.debug('-----##DEBUGGING## getStackTraceString' + e.getStackTraceString());
        System.debug('-----##DEBUGGING## getTypeName ' + e.getTypeName());         
    }

}