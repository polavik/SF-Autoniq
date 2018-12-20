public class ActionPackageHelper 
{
    
    // MEMBER VARIABLES

    // Format: Action_Package__c.Package_Name__c -> ActionPackageSenderImpl
    private static Map<String, ActionPackageSender> senderMap;
    
    public Action_Package__c pkg {get; set;} 
    protected Boolean callSAP {get; set;}
    
    
    // PUBLIC METHODS
    
    public ActionPackageHelper(Action_Package__c pkg)
    {
        this.pkg = pkg;
        
        if (senderMap == null)
        {
            initializeSenderMap();
        }
    }
    
    public void sendPackage() 
    {          
        try 
        {
            // Process reasons for Non-Standard SAP Transactions
            List<String> nonstandardReasons = ActionPackageValidator.getForcedNonstandardReasons(pkg);
            List<String> processedNonstandardReasons = new List<String>();
            for (String reason : nonstandardReasons)
            {
                processedNonstandardReasons.add('Manual SAP processing required: '+reason);
            }
            
            if (Integer.valueOf(pkg.Case__r.Vehicle_ID__c) < 0) 
            {
                Logger.info(pkg, 'OCAS vehicle id: ' + pkg.Case__r.Vehicle_ID__c + '. Skipping...');
                pkg.Send_Results__c = 'MANUAL - Transactions need to be created manually in OCAS and SAP';
                String[] messages = new String[] {'OCAS vehicles are not supported for automated voids transactions.'};
                addResponseMessagesToPackage(messages);
            }
            // Don't even try to call the Mediator for CRFs with non-standard transactions
            else if (!pkg.Standard_SAP_Transactions__c &&
                    (pkg.Package_Type__c.equalsIgnoreCase('ADJUSTMENT') ||
                        pkg.Package_Type__c.equalsIgnoreCase('TRANSPORT ADJUSTMENT') ||
                        pkg.Package_Type__c.equalsIgnoreCase('CONCESSION')))
            {
                
                String strDealerBlock = (pkg.Is_Dealer_Block__c != null) ?  pkg.Is_Dealer_Block__c : 'No' ;
                String strPaymentMethod = pkg.Payment_Method__c;
                
                if ('Yes'.equalsIgnoreCase(strDealerBlock) &&
                    !pkg.Standard_SAP_Transactions__c &&
                    (
                   // Replace PPA with PPAA (ppm 102221 )
                    //'pay processing auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) || 
                    'adesa\'s centralized payment'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'ally financial floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'tfs floorplan'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||                   
                    'toyota fin svcs floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'pay adesa worldwide'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'pay openlane worldwide - wire'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||            
                    'pay using other floorplans'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'pay processing adesa auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c)
                    )) 
                {
                    if ('CONCESSION'.equalsIgnoreCase(pkg.Package_Type__c))
                        {pkg.Send_Results__c = 'AUTOMATIC - NO SAP accounting entries required. Adesa will handle the refund to buyer';}
                    else if ('ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c))
                    {pkg.Send_Results__c = 'MANUAL - Transactions need to be created manually in SAP';}
                }
             else       
              {     
                pkg.Send_Results__c = 'MANUAL - Transactions need to be created manually in SAP';
                if (processedNonstandardReasons.size() > 0)
                {
                    addResponseMessagesToPackage(processedNonstandardReasons);
                }
                else
                {
                    addResponseMessagesToPackage(new String[] {'USER UNCHECKED STANDARD SAP TRANSACTIONS - SEE INSTRUCTIONS FOR ACCOUNTING FOR MANUAL PROCESSING'});
                }
              } //Adesa block  
            }

            else 
            {
                ActionPackageSender sender = senderMap.get(pkg.Package_Type__c);
                Logger.info(pkg, 'Using Sender: ' + sender);
                Logger.info(pkg, 'Sending...');
                
                SendResponse response = sender.send(this);
                pkg.Send_Results__c = response.results;
                // Provide some additional feedback if Non-Standard SAP 
                if (!pkg.Standard_SAP_Transactions__c) 
                {
                    if (processedNonstandardReasons.size() > 0)
                    {
                        addResponseMessagesToPackage(processedNonstandardReasons);
                    }
                    else
                    {
                        addResponseMessagesToPackage(new String[] {'USER UNCHECKED STANDARD SAP TRANSACTIONS - SEE INSTRUCTIONS FOR ACCOUNTING FOR MANUAL PROCESSING'}); 
                    }
                }
                addResponseMessagesToPackage(response.messages);
                insert response.docs;
            }
        }
        catch (Exception e) 
        {
            logger.error(pkg, 'Unhandled Exception encountered while sending');
            logger.error(pkg, e.getMessage());
            addResponseMessagesToPackage(new String[] {e.getMessage()});
            pkg.Send_Results__c = 'An unexpected error occured.  Please contact production support.';
        } 
        finally 
        {
            Logger.flush();
        }
    }
    
    public void holdPS() 
    {
        if (!getFreezePostSales(pkg)) 
        {
            return;
        }
        try 
        {
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            Logger.info(pkg, 'Calling Mediator holdPSForVoid() operation');
            Logger.info(pkg, 'Vehicle Id: ' + Long.valueOf(pkg.Case__r.Vehicle_ID__c));
            String response = ms.holdPSForVoid(Long.valueOf(pkg.Case__r.Vehicle_ID__c));
            Logger.info(pkg, 'Response: ' + response);
            if ('A'.equals(response)) 
            {
                Logger.info(pkg, 'Hold PS successful');
                Logger.info(pkg, 'Sending Hold Transport Notification');
                pkg.Send_Transport_Hold_Notification__c = true;
                pkg.Post_Sales_Frozen__c = true;
            } 
            else if ('B'.equals(response)) 
            {
                Logger.info(pkg, 'Hold PS successful');
                Logger.info(pkg, 'Hold Transport Notification not required');
                pkg.Post_Sales_Frozen__c = true;
            } 
            else if ('C'.equals(response))
            {
                throw new MediatorException('Hold PS Request failed.');
            } 
            else 
            {
                throw new MediatorException('Hold PS Request - Unexpected return code: ' + response);
            }
        } 
        catch (Exception e) 
        {
            Logger.error(pkg, e.getMessage());
            addResponseMessagesToPackage(new String[] {e.getMessage()});
        } 
        finally 
        {
            Logger.flush();
        }
    }
    
    public void releasePSHold() 
    {
        if (!getFreezePostSales(pkg)) 
        {
            return;
        }
        try 
        {
            
            // If Send_Transport_Hold_Notification__c was checked during psHold(),
            //   then send a Show_Transport_Notification during releasePSHold()
            if (pkg.Transport_Hidden__c) 
            {
                pkg.Send_Show_Transport_Notification__c = true;
            }
            
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            Logger.info(pkg, 'Calling Mediator releasePSFromHold() operation');
            Logger.info(pkg, 'Vehicle Id: ' + Long.valueOf(pkg.Case__r.Vehicle_ID__c));
            String response = ms.releasePSFromHold(Long.valueOf(pkg.Case__r.Vehicle_ID__c));
            Logger.info(pkg, 'Response: ' + response);
            if ('B'.equals(response)) 
            {
                Logger.info(pkg, 'Release PS from Hold successful');
                pkg.Post_Sales_Frozen__c = false;
            } 
            else if ('C'.equals(response))
            {
                throw new MediatorException('Hold PS Request failed.');
            } 
            else 
            {
                throw new MediatorException('Hold PS Request - Unexpected return code: ' + response);
            }            
        } 
        catch (Exception e) 
        {
            Logger.error(pkg, e.getMessage());
            addResponseMessagesToPackage(new String[] {e.getMessage()});
        } 
        finally 
        {
            Logger.flush();
        }
    }
    
    @future(callout=true)
    public static void cancelPSIAndArbitrateVehicle(List<ID> caseIds)
    {
        Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
        List<Case> cases = [SELECT VIN__r.Vehicle_ID__c, V1_Status_Change__c, VIN__r.Buyout__c, Purchase_Types__c  FROM Case WHERE Id IN :caseIds];
        for (Case c : cases)
        {
            Long vehicleId = Long.valueOf(c.VIN__r.Vehicle_ID__c);
            
            Logger.info(c, 'Calling Mediator operation: cancelPsi(' + vehicleId +')');
            Mediator.cancelPsiResponseType response1 = ms.cancelPsi(vehicleId);
            String results = response1.returnCode;
            if (response1.errorMsg != null && response1.errorMsg.size() > 0)
            {
                results = results + ': ' + Utils.joinList( response1.errorMsg, ';');
            }
            Logger.info(c, 'RESPONSE: ' + results);
            
            
            //Logger.info(c, 'Calling Mediator operation: arbitrateVehicle(' + vehicleId + ')');
            //Mediator.arbitrateVehicleResponseType response2 = ms.arbitrateVehicle(Long.valueOf(c.VIN__r.Vehicle_ID__c));
            //Logger.info(c, 'arbitrateVehicle return code: ' + response2.returnCode);
            //if (response2.errorMsg != null)
            //{
            //    for (String message : response2.errorMsg)
            //    {
            //        Logger.info(c, 'arbitrateVehicle error message: ' + message);
            //    }
            //}
            
            /* Commented above and added below for 2017.5a release Story B-44638 */
            
            // For Existing (before added Purchase_Types__c field on Purchase object )
            Long PurchaseTypes;
            if(String.isBlank(c.Purchase_Types__c))
            {
                if(c.VIN__r.Buyout__c)
                {
                    PurchaseTypes = 3;
                }
                else
                {
                    PurchaseTypes = 1;
                }
            }
            else
            {
                PurchaseTypes = Long.valueOf(c.Purchase_Types__c);
            }
            System.debug('PurchaseTypes: '+PurchaseTypes);
            Logger.info(c, 'Calling Mediator operation: arbitrateVehicleWithType(' + vehicleId + ','+ PurchaseTypes +')');
            Mediator.arbitrateVehicleResponseType response2 = ms.arbitrateVehicleWithType(Long.valueOf(c.VIN__r.Vehicle_ID__c),PurchaseTypes);
            Logger.info(c, 'arbitrateVehicleWithType return code: ' + response2.returnCode);
            if (response2.errorMsg != null)
            {
                for (String message : response2.errorMsg)
                {
                    Logger.info(c, 'arbitrateVehicleWithType error message: ' + message);
                }
            }
            
            if (response2.returnCode.equalsIgnoreCase('ARBITRATION_SUCCESS'))
            {
                c.V1_Status_Change__c = 'VIN successfully placed in arbitration in Post Sales';
            }
            else
            {
                c.V1_Status_Change__c = 'Error - VIN not placed in arbitration in Post Sales';
            }
        }
        update cases;
        Logger.flush();
    }
    
    @future(callout=true)
    public static void arbitrateVehicle(List<ID> caseIds)
    {
        Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
        List<Case> cases = [SELECT VIN__r.Vehicle_ID__c, V1_Status_Change__c, VIN__r.Buyout__c, Purchase_Types__c FROM Case WHERE Id IN :caseIds];
        for (Case c : cases)
        {
            //Logger.info(c, 'Calling Mediator operation: arbitrateVehicle(' + c.VIN__r.Vehicle_ID__c + ')');           
            //Mediator.arbitrateVehicleResponseType response = ms.arbitrateVehicle(Long.valueOf(c.VIN__r.Vehicle_ID__c));
            //Logger.info(c, 'arbitrateVehicle return code: ' + response.returnCode);
            //if (response.errorMsg != null)
            //{
            //    for (String message : response.errorMsg)
            //    {
            //        Logger.info(c, 'arbitrateVehicle error message: ' + message);
            //    }
            //}
            
            /* Commented above and added below for 2017.5a release Story B-44638 */
            Long PurchaseTypes;
            if(String.isBlank(c.Purchase_Types__c))
            {
                if(c.VIN__r.Buyout__c)
                {
                    PurchaseTypes = 3;
                }
                else
                {
                    PurchaseTypes = 1;
                }
            }
            else
            {
                PurchaseTypes = Long.valueOf(c.Purchase_Types__c);
            }
            System.debug('PurchaseTypes: '+PurchaseTypes);          
            Logger.info(c, 'Calling Mediator operation: arbitrateVehicleWithType(' + c.VIN__r.Vehicle_ID__c + ','+ PurchaseTypes +')');
            Mediator.arbitrateVehicleResponseType response = ms.arbitrateVehicleWithType(Long.valueOf(c.VIN__r.Vehicle_ID__c),PurchaseTypes);
            Logger.info(c, 'arbitrateVehicle return code: ' + response.returnCode);
            if (response.errorMsg != null)
            {
                for (String message : response.errorMsg)
                {
                    Logger.info(c, 'arbitrateVehicle error message: ' + message);
                }
            }
            
            if (response.returnCode.equalsIgnoreCase('ARBITRATION_SUCCESS'))
            {
                c.V1_Status_Change__c = 'VIN successfully placed in arbitration in Post Sales';
            }
            else
            {
                c.V1_Status_Change__c = 'Error - VIN not placed in arbitration in Post Sales';
            }
        }
        update cases;
        Logger.flush();
    }
    
    @future(callout=true)
    public static void restoreVehicleFromArbitration(List<ID> caseIds)
    {
        Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
        List<Case> cases = [SELECT VIN__r.Vehicle_ID__c, V1_Status_Change__c, VIN__r.Buyout__c, Purchase_Types__c FROM Case WHERE Id IN :caseIds];
        for (Case c : cases)
        {
            //Logger.info(c, 'Calling Mediator operation: restoreVehicleFromArbitration(' + c.VIN__r.Vehicle_ID__c + ')');
            //Mediator.restoreVehicleFromArbitrationResponseType response = ms.restoreVehicleFromArbitration(Long.valueOf(c.VIN__r.Vehicle_ID__c));
            //Logger.info(c, 'restoreVehicleFromArbitration return code: ' + response.returnCode);
            //if (response.errorMsg != null)
            //{
            //    for (String message : response.errorMsg)
            //    {
            //        Logger.info(c, 'restoreVehicleFromArbitration error message: ' + message);
            //    }
            //}
            
            /* Commented above and added below for 2017.5a release Story B-44638 */
            Long PurchaseTypes;
            if(String.isBlank(c.Purchase_Types__c))
            {
                if(c.VIN__r.Buyout__c)
                {
                    PurchaseTypes = 3;
                }
                else
                {
                    PurchaseTypes = 1;
                }
            }
            else
            {
                PurchaseTypes = Long.valueOf(c.Purchase_Types__c);
            }
            System.debug('PurchaseTypes: '+PurchaseTypes);  
            
            Logger.info(c, 'Calling Mediator operation: restoreVehicleFromArbitrationWithType(' + c.VIN__r.Vehicle_ID__c + ','+ PurchaseTypes +')');
            Mediator.restoreVehicleFromArbitrationResponseType response = ms.restoreVehicleFromArbitrationWithType(Long.valueOf(c.VIN__r.Vehicle_ID__c),PurchaseTypes);
            Logger.info(c, 'restoreVehicleFromArbitrationWithType return code: ' + response.returnCode);
            if (response.errorMsg != null)
            {
                for (String message : response.errorMsg)
                {
                    Logger.info(c, 'restoreVehicleFromArbitrationWithType error message: ' + message);
                }
            }
            
            if (response.returnCode.equalsIgnoreCase('ARBITRATION_SUCCESS'))
            {
                c.V1_Status_Change__c = 'VIN successfully restored from arbitration in Post Sales';
            }
            else
            {
                c.V1_Status_Change__c = 'Error - VIN not restored from arbitration in Post Sales';
            }
        }
        update cases;
        Logger.flush();
    }
    
    
    // PRIVATE METHODS
    
    private void initializeSenderMap()
    {
        senderMap = new Map<String, ActionPackageSender>();     
        senderMap.put('Auction Void', new AuctionVoidSender());
        senderMap.put('Auction Void - Rec', new AuctionVoidRecSender());
        senderMap.put('Auction Void - SWAP', new AuctionVoidSwapSender());
        senderMap.put('Extra Cost', new ExtraCostSender());
        senderMap.put('House Void - 3rd Party', new HouseVoidThirdPartySender());
        senderMap.put('House Void - 3rd Party Rec', new HouseVoidThirdPartyRecSender());
        senderMap.put('House Void - AIA Rec', new HouseVoidAIARecSender());
        senderMap.put('House Void - Rec', new HouseVoidRecSender());
        senderMap.put('Transport Void', new TransportVoidSender());     
        senderMap.put('Adjustment', new AdjustmentSender());
        senderMap.put('Transport Adjustment', new TransportAdjustmentSender());
        senderMap.put('Concession', new ConcessionSender());
    }    
    
    // NESTED ACTION PACKAGE SENDER IMPLEMENTATIONS
    
    private interface ActionPackageSender 
    {
        SendResponse send(ActionPackageHelper parent);
    }
        
    private class AuctionVoidSender implements ActionPackageSender
    {
        public SendResponse send(ActionPackageHelper parent)
        {           
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            
            ActionPackageStandardFields apStandardFields = new ActionPackageStandardFields(parent.pkg);
            VoidStandardFields voidStandardFields = new VoidStandardFields(parent.pkg);
            
            Mediator.auctionVoidResponseType response;
            
            if(apStandardFields.IsBuyout)
            {
                response = ms.buyoutAuctionVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );
            }
            else
            {
                response = ms.auctionVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );
            }
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            
            return new SendResponse(returnCode, responseMessages, docs);           
            
        }
    }
    
    private class AuctionVoidRecSender implements ActionPackageSender 
    {
        public SendResponse send(ActionPackageHelper parent)
        {           
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            
            ActionPackageStandardFields apStandardFields = new ActionPackageStandardFields(parent.pkg);
            VoidStandardFields voidStandardFields = new VoidStandardFields(parent.pkg);
            
            Mediator.recAuctionVoidResponseType response;
            
            if(apStandardFields.IsBuyout)
            {
                response = ms.buyoutRecAuctionVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );
            }
            else
            {
                response = ms.recAuctionVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );
            }            
                
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            
            return new SendResponse(returnCode, responseMessages, docs);
        }
    }
    
    private class AuctionVoidSwapSender implements ActionPackageSender 
    {
        public SendResponse send(ActionPackageHelper parent)
        {           
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            
            ActionPackageStandardFields apStandardFields = new ActionPackageStandardFields(parent.pkg);
            VoidStandardFields voidStandardFields = new VoidStandardFields(parent.pkg);
            
            Mediator.swapAuctionVoidResponseType response ;
            if(apStandardFields.IsBuyout)
            {
                response = ms.buyoutSwapAuctionVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );
            }
            else
            {
                response = ms.swapAuctionVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );
            }            
            
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            
            return new SendResponse(returnCode, responseMessages, docs);
        }
    }
    
    private class ExtraCostSender implements ActionPackageSender 
    {
        public SendResponse send(ActionPackageHelper parent)
        {           
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            
            ActionPackageStandardFields apStandardFields = new ActionPackageStandardFields(parent.pkg);
            VoidStandardFields voidStandardFields = new VoidStandardFields(parent.pkg);
            
            //Determine Reason Code based off of the most recently completed Vehicle or Transport void
            String parentPackageType;
            if (parent.pkg.Case__r.VIN__r.Vehicle_Void_Package__r != null) 
            {
                parentPackageType = parent.pkg.Case__r.VIN__r.Vehicle_Void_Package__r.Package_Type__c;
            } 
            else if (parent.pkg.Case__r.VIN__r.Transport_Void_Package__r != null) 
            {
                parentPackageType = parent.pkg.Case__r.VIN__r.Transport_Void_Package__r.Package_Type__c;
            } 
            else 
            {
                throw new MediatorException('Unable to resolve Reason Code from previous vehicle or transport void.');
            }  
            
            Logger.info(parent.pkg, 'Overridden Reason Code: ' + getVoidReasonCode(parentPackageType));
            //Utils.sendSingleMail(DateTime.now() + parentPackageType + ' reason code ' + getVoidReasonCode(parentPackageType));
            Mediator.addExtraCostResponseType response = ms.addExtraCost(
                apStandardFields.vehicleId,
                apStandardFields.actionPackageId,
                apStandardFields.approvalDate,
                getVoidReasonCode(parentPackageType), //note that parentPackageType is used for reason code
                apStandardFields.standardSapTransactions,
                apStandardFields.buyerSapCustomerNumber,
                apStandardFields.sellerSapCustomerNumber,
                apStandardFields.vehiclePaymentMethodId,
                apStandardFields.transportPaymentMethodId,
                voidStandardFields.extraCosts);
            
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            return new SendResponse(returnCode, responseMessages, docs);
        }
    }
    
    private class HouseVoidThirdPartySender implements ActionPackageSender 
    {
        public SendResponse send(ActionPackageHelper parent)
        {        
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            
            ActionPackageStandardFields apStandardFields = new ActionPackageStandardFields(parent.pkg);
            VoidStandardFields voidStandardFields = new VoidStandardFields(parent.pkg);
            
            Mediator.thirdPartyHouseVoidResponseType response;
            
            if(apStandardFields.IsBuyout)
            {
                response = ms.buyoutThirdPartyHouseVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts);
            }
            else
            {
                response = ms.thirdPartyHouseVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts);
            }
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            
            return new SendResponse(returnCode, responseMessages, docs);
        }
    }
    
    private class HouseVoidThirdPartyRecSender implements ActionPackageSender 
    {
        public SendResponse send(ActionPackageHelper parent)
        {        
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            
            ActionPackageStandardFields apStandardFields = new ActionPackageStandardFields(parent.pkg);
            VoidStandardFields voidStandardFields = new VoidStandardFields(parent.pkg);
            
            Mediator.thirdPartyHouseRecVoidResponseType response ;
            
            if(apStandardFields.IsBuyout)
            {
                response = ms.buyoutThirdPartyHouseRecVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );
            }
            else
            {
                response = ms.thirdPartyHouseRecVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );

            }
            
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            
            return new SendResponse(returnCode, responseMessages, docs);
        }
    }
    
    private class HouseVoidAIARecSender implements ActionPackageSender 
    {
        public SendResponse send(ActionPackageHelper parent)
        {        
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            
            ActionPackageStandardFields apStandardFields = new ActionPackageStandardFields(parent.pkg);
            VoidStandardFields voidStandardFields = new VoidStandardFields(parent.pkg); 
            
            Mediator.aiaHouseVoidResponseType response;
            
            if(apStandardFields.IsBuyout)
            {
                response = ms.buyoutAiaHouseVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );
            }
            else
            {
                response = ms.aiaHouseVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );
            }           
           
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            
            return new SendResponse(returnCode, responseMessages, docs);
        }
    }
    
    private class HouseVoidRecSender implements ActionPackageSender 
    {
        public SendResponse send(ActionPackageHelper parent)
        {        
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            
            ActionPackageStandardFields apStandardFields = new ActionPackageStandardFields(parent.pkg);
            VoidStandardFields voidStandardFields = new VoidStandardFields(parent.pkg);
            
            Mediator.recHousevoidResponseType response;
            
            if(apStandardFields.IsBuyout)
            {
                response = ms.buyoutRecHouseVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts);
            }
            else
            {
                response = ms.recHouseVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts);

            }
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            
            return new SendResponse(returnCode, responseMessages, docs);
        }
    }
    
    private class TransportVoidSender implements ActionPackageSender 
    {
        public SendResponse send(ActionPackageHelper parent)
        {                    
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            
            ActionPackageStandardFields apStandardFields = new ActionPackageStandardFields(parent.pkg);
            VoidStandardFields voidStandardFields = new VoidStandardFields(parent.pkg);
            
            Mediator.transportVoidResponseType response;
            if(apStandardFields.IsBuyout)
            {
                response = ms.buyoutTransportVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );
            }
            else
            {
                response = ms.transportVoid(
                    voidStandardFields.processOverride,
                    apStandardFields.vehicleId, 
                    apStandardFields.actionPackageId, 
                    voidStandardFields.transportResponsibleParty,
                    apStandardFields.approvalDate, 
                    voidStandardFields.voidReasonCode,
                    voidStandardFields.transportVoided,
                    apStandardFields.standardSapTransactions,
                    apStandardFields.buyerSapCustomerNumber,
                    apStandardFields.sellerSapCustomerNumber,
                    apStandardFields.vehiclePaymentMethodId,
                    apStandardFields.transportPaymentMethodId,
                    voidStandardFields.extraCosts
                );
            }
            
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            
            return new SendResponse(returnCode, responseMessages, docs);
            
        }
    }
    
    private class AdjustmentSender implements ActionPackageSender
    {
        public SendResponse send(ActionPackageHelper parent)
        {        
            ActionPackageStandardFields standardFields = new ActionPackageStandardFields(parent.pkg);
            CRFStandardFields crfStandardFields = new CRFStandardFields(parent.pkg);
            
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();  
            
            Mediator.applyAdjustmentResponseType response = ms.applyAdjustment(
                standardFields.vehicleId,
                standardFields.actionPackageId,
                standardFields.approvalDate,
                crfStandardFields.crfReasonCode,
                standardFields.buyerSapCustomerNumber,
                standardFields.sellerSapCustomerNumber,
                standardFields.vehiclePaymentMethodId,
                standardFields.transportPaymentMethodId,
                crfStandardFields.adjustmentLineItems
            );
            
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            
            return new SendResponse(returnCode, responseMessages, docs);
        }
    }
    
    private class TransportAdjustmentSender implements ActionPackageSender
    {
        public SendResponse send(ActionPackageHelper parent)
        {        
            ActionPackageStandardFields standardFields = new ActionPackageStandardFields(parent.pkg);
            CRFStandardFields crfStandardFields = new CRFStandardFields(parent.pkg);
            
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();  
            
            Mediator.applyTransportAdjustmentResponseType response = ms.applyTransportAdjustment(
                standardFields.vehicleId,
                standardFields.actionPackageId,
                standardFields.approvalDate,
                crfStandardFields.crfReasonCode,
                standardFields.buyerSapCustomerNumber,
                standardFields.sellerSapCustomerNumber,
                standardFields.vehiclePaymentMethodId,
                standardFields.transportPaymentMethodId,
                crfStandardFields.adjustmentLineItems
            );
            
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            
            return new SendResponse(returnCode, responseMessages, docs);
        }
    }
    
    private class ConcessionSender implements ActionPackageSender
    {
        public SendResponse send(ActionPackageHelper parent)
        {        
            ActionPackageStandardFields standardFields = new ActionPackageStandardFields(parent.pkg);
            CRFStandardFields crfStandardFields = new CRFStandardFields(parent.pkg);
            
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();  
            
            Mediator.applyConcessionResponseType response = ms.applyConcession(
                standardFields.vehicleId,
                standardFields.actionPackageId,
                standardFields.approvalDate,
                crfStandardFields.crfReasonCode,
                standardFields.buyerSapCustomerNumber,
                standardFields.sellerSapCustomerNumber,
                standardFields.vehiclePaymentMethodId,
                standardFields.transportPaymentMethodId,
                crfStandardFields.adjustmentLineItems
            );
            
            String returnCode = parent.translateReturnCode(response.returnCode);
            List<String> responseMessages = parent.processResponseMessages(response.returnCode, response.errorMsg, response.msg);    
            List<Action_Package_Document__c> docs = parent.processReturnDocs(response.fiDocument, response.sdDocument);
            
            return new SendResponse(returnCode, responseMessages, docs);
        }
    }
    
    // NESTED UTILITY CLASSES
    
    public class SendResponse 
    {
        String results {get; set;}
        List<String> messages {get; set;}
        List<Action_Package_Document__c> docs {get; set;}
        public SendResponse(String results, List<String> messages, List<Action_Package_Document__c> docs) 
        {
            this.messages = new List<String>();
            this.docs = docs;
            this.results = results;
            this.messages = messages;
            this.docs = docs;
        }
    }
    
    public class ActionPackageStandardFields
    {
        public Long vehicleId {get; set;}
        public String actionPackageId {get; set;}
        public DateTime approvalDate {get; set;}
        
        public Boolean standardSapTransactions {get; set;}
        public String buyerSapCustomerNumber {get; set;}
        public String sellerSapCustomerNumber {get; set;}
        public Long vehiclePaymentMethodId {get; set;}
        public Long transportPaymentMethodId {get; set;}
        public Boolean IsBuyout {get; set;}
        
        public ActionPackageStandardFields(Action_Package__c pkg)
        {
            Logger.info(pkg, 'Computing Action Package StandardFields for pkg ' + pkg.Name);
            this.vehicleId = Long.valueOf(pkg.Case__r.Vehicle_ID__c);
            this.actionPackageId = pkg.Name;
            this.approvalDate = DateTime.now();
            this.buyerSapCustomerNumber = pkg.Case__r.VIN__r.ATC_Buyer__r.SAP_Customer_Number__c;
            this.sellerSapCustomerNumber = pkg.Case__r.VIN__r.ATC_Seller__r.SAP_Customer_Number__c;
            this.vehiclePaymentMethodId = getPaymentMethodId(pkg.Case__r.VIN__r.Vehicle_Payment_Method_Id__c);
            this.transportPaymentMethodId = getPaymentMethodId(pkg.Case__r.VIN__r.Transport_Payment_Method_Id__c);
            
            // Consult getSAPNotApplicableReason() to see if standardSapTransactions needs to be overridden
            if (pkg.Standard_SAP_Transactions__c && getSAPNotApplicableReason(pkg) == null)
            {
                this.standardSapTransactions = true;
            }
            else if (pkg.Standard_SAP_Transactions__c && getSAPNotApplicableReason(pkg) != null)
            {
                Logger.info(pkg, 'Overriding Standard SAP Transactions, reason:' + getSAPNotApplicableReason(pkg));
                this.standardSapTransactions = false;
            }
            else
            {
                this.standardSapTransactions = false;
            }
            
            this.IsBuyout = pkg.Case__r.VIN__r.Buyout__c;           
            
            Logger.info(pkg, 'Vehicle ID: ' + this.vehicleId);
            Logger.info(pkg, 'actionPackageId: ' + this.actionPackageId);
            Logger.info(pkg, 'approvalDate: ' + this.approvalDate);
            Logger.info(pkg, 'Standard SAP Transactions: ' + this.standardSapTransactions);
            Logger.info(pkg, 'Buyer SAP Customer Number: ' + this.buyerSapCustomerNumber);
            Logger.info(pkg, 'Seller SAP Customer Number: ' + this.sellerSapCustomerNumber);
            Logger.info(pkg, 'Vehicle Payment Method Id: ' + this.vehiclePaymentMethodId);
            Logger.info(pkg, 'Transport Payment Method Id: ' + this.transportPaymentMethodId);
            Logger.info(pkg, 'IsBuyout: ' + this.IsBuyout);
        }
    }
    
    public class VoidStandardFields
    {
        public String voidReasonCode {get; set;}
        public String transportResponsibleParty;
        public boolean transportVoided;
        public String processOverride;
        public List<Mediator.ExtraCost> extraCosts;
        
        public VoidStandardFields(Action_Package__c pkg)
        {
            Logger.info(pkg, 'Computing Void Standard Fields for pkg ' + pkg.Name);
            
            this.voidReasonCode = getVoidReasonCode(pkg.Package_Type__c);
            transportResponsibleParty = getResponsiblePartyId(pkg.House_Transport_Responsible_Party__c);
            transportVoided = (pkg.Case__r.VIN__r.Transport_Void_Package__r != null);
            Logger.info(pkg, 'Before getting the ProcessOverride ' + pkg.Name);
            processOverride = getProcessOverride(pkg);
            
            Logger.info(pkg, 'voidReasonCode: ' + this.voidReasonCode);
            Logger.info(pkg, 'transportResponsibleParty: ' + this.transportResponsibleParty);
            Logger.info(pkg, 'transportVoided: ' + this.transportVoided);
            Logger.info(pkg, 'processOverride: ' + this.processOverride);
            
            extraCosts = new List<Mediator.ExtraCost>();
            for (Extra_Cost__c src : pkg.Extra_Costs__r) {
                Mediator.ExtraCost payerEC = new Mediator.ExtraCost();
                Logger.info(pkg, 'Converting Extra Cost: ' + src.Name);
                Logger.info(pkg, 'Payer Side...');
                // All Extra Costs are currently entered into SAP with material number 7.  Could potentially change.
                payerEC.materialNumber = '7';
                payerEC.sfExtraCostId = src.Name;
                payerEC.netAmount = src.Net_Amount__c;
                payerEC.currency_x = src.CurrencyIsoCode;
                payerEC.regionCode = filterRegionCode(src.Region_Code__c);
                payerEC.taxType = getTaxTypeId(src.Tax_Type__c);
                payerEC.extraCostResponsibleParty = getResponsiblePartyId(src.Extra_Cost_Responsible_Party__c);
                payerEC.extraCostType = src.Extra_Cost_Type__c;
                Logger.info(pkg, 'Extra Cost - Material Number:' + payerEC.materialNumber);
                Logger.info(pkg, 'Extra Cost - sfExtraCostId: ' + payerEC.sfExtraCostId);
                Logger.info(pkg, 'Extra Cost - netAmount: ' + payerEC.netAmount);
                Logger.info(pkg, 'Extra Cost - currency: ' + payerEC.currency_x);
                Logger.info(pkg, 'Extra Cost - regionCode' + payerEC.regionCode);
                Logger.info(pkg, 'Extra Cost - taxType: ' + payerEC.taxType);
                Logger.info(pkg, 'Extra Cost - extraCostResponsibleParty: ' + payerEC.extraCostResponsibleParty);
                Logger.info(pkg, 'Extra Cost - extraCostType: ' + payerEC.extraCostType);
                extraCosts.add(payerEC);
                
                Mediator.ExtraCost buyerEC = new Mediator.ExtraCost();
                Logger.info(pkg, 'Buyer Side...');
                buyerEC.materialNumber = '7';
                buyerEC.sfExtraCostId = src.Name;
                buyerEC.netAmount = -1.0 * src.Net_Amount__c;
                buyerEC.currency_x = src.CurrencyIsoCode;
                buyerEc.regionCode = filterRegionCode(src.Region_Code__c);
                buyerEC.taxType = getTaxTypeId(src.Tax_Type__c);
                buyerEC.extraCostResponsibleParty = getResponsiblePartyId('Buyer');
                buyerEC.extraCostType = src.Extra_Cost_Type__c;
                Logger.info(pkg, 'Extra Cost - Material Number:' + buyerEC.materialNumber);
                Logger.info(pkg, 'Extra Cost - sfExtraCostId: ' + buyerEC.sfExtraCostId);
                Logger.info(pkg, 'Extra Cost - netAmount: ' + buyerEC.netAmount);
                Logger.info(pkg, 'Extra Cost - currency: ' + buyerEC.currency_x);
                Logger.info(pkg, 'Extra Cost - regionCode' + buyerEC.regionCode);
                Logger.info(pkg, 'Extra Cost - taxType: ' + buyerEC.taxType);
                Logger.info(pkg, 'Extra Cost - extraCostResponsibleParty: ' + buyerEC.extraCostResponsibleParty);
                Logger.info(pkg, 'Extra Cost - extraCostType: ' + buyerEC.extraCostType);
                extraCosts.add(buyerEC);
            }
            
            // B-15852: Voids SF - iDeal Voids.  Pass in Arbitration Fee as an Extra Cost
            if (pkg.Arbitration_Fee__c != null)
            {
                Mediator.ExtraCost arbFee = new Mediator.ExtraCost();
                arbFee.materialNumber = '7';
                arbFee.sfExtraCostId = 'ARBFEE'+pkg.Name;
                arbFee.netAmount = Double.valueOf(pkg.Arbitration_Fee__c);
                arbFee.currency_x = pkg.CurrencyIsoCode;
                arbFee.regionCode = filterRegionCode('N/A');
                arbFee.taxType = getTaxTypeId('Tax Exempt');
                arbFee.extraCostResponsibleParty = getResponsiblePartyId('Seller');
                arbFee.extraCostType = 'Arbitration Fee';
                Logger.info(pkg, 'Extra Cost - Material Number:' + arbFee.materialNumber);
                Logger.info(pkg, 'Extra Cost - sfExtraCostId: ' + arbFee.sfExtraCostId);
                Logger.info(pkg, 'Extra Cost - netAmount: ' + arbFee.netAmount);
                Logger.info(pkg, 'Extra Cost - currency: ' + arbFee.currency_x);
                Logger.info(pkg, 'Extra Cost - regionCode' + arbFee.regionCode);
                Logger.info(pkg, 'Extra Cost - taxType: ' + arbFee.taxType);
                Logger.info(pkg, 'Extra Cost - extraCostResponsibleParty: ' + arbFee.extraCostResponsibleParty);
                Logger.info(pkg, 'Extra Cost - extraCostType: ' + arbFee.extraCostType);
                extraCosts.add(arbFee);
            }
            
        }
    }
    
    public class CRFStandardFields
    {
        public String crfReasonCode {get; set;}
        public List<Mediator.AdjustmentLineItem> adjustmentLineItems {get; set;}
        
        public CRFStandardFields(Action_Package__c pkg)
        {
            
            crfReasonCode = getCRFReasonCode(pkg.Credit_Reason__c);
            Logger.info(pkg, 'voidReasonCode: ' + this.crfReasonCode);
            
            adjustmentLineItems = new List<Mediator.AdjustmentLineItem>();
            Logger.info(pkg, 'Converting Credit/Responsible Amounts to AdjustmentLineItems');
            Mediator.AdjustmentLineItem primaryLI = new Mediator.AdjustmentLineItem();
            if ('BUYER'.equalsIgnoreCase(pkg.Credit_To__c))
            {
                primaryLI.partnerType = 'B';
            }
            else if ('SELLER'.equalsIgnoreCase(pkg.Credit_To__c))
            {
                primaryLI.partnerType = 'S';
            }
            else
            {
                Logger.info(pkg, 'Unknown Credit To value: ' + pkg.Credit_To__c);
                throw new MediatorException('Unknown Credit To value: ' + pkg.Credit_To__c);
            }

            primaryLI.netAmount = pkg.Credit_Amount__c * -1.0;
            primaryLI.currency_x = pkg.CurrencyIsoCode;
            adjustmentLineItems.add(primaryLI);
            
            if (pkg.Seller_Amount__c != null && pkg.Seller_Amount__c != 0)
            {
                Logger.info(pkg, 'Converting Seller Amount to Seller Adjustment Line Item');
                Mediator.AdjustmentLineItem sellerLI = new Mediator.AdjustmentLineItem();
                sellerLI.netAmount = pkg.Seller_Amount__c;
                sellerLI.currency_x = pkg.CurrencyIsoCode;
                sellerLI.partnerType = 'S';
                adjustmentLineItems.add(sellerLI);
            }
            
            if (pkg.Discretionary_Fund_Amount__c != null && pkg.Discretionary_Fund_Amount__c != 0)
            {
                Logger.info(pkg, 'Converting Discretionary Amount to Discretionary Adjustment Line Item');
                Mediator.AdjustmentLineItem discretionaryLI = new Mediator.AdjustmentLineItem();
                discretionaryLI.netAmount = pkg.Discretionary_Fund_Amount__c;
                discretionaryLI.currency_x = pkg.CurrencyIsoCode;
                discretionaryLI.partnerType = 'D';
                adjustmentLineItems.add(discretionaryLI);
            }
            
            for (Mediator.AdjustmentLineItem li : adjustmentLineItems)
            {
                Logger.info(pkg, 'AdjustmentLineItem - netAmount: ' + li.netAmount);
                Logger.info(pkg, 'AdjustmentLineItem - currency: ' + li.currency_x);
                Logger.info(pkg, 'AdjustmentLineItem - partnerType: ' + li.partnerType);
            }
        }
    }
    
    private static String getVoidReasonCode(String packageType) 
    {
        if (packageType.contains('Auction Void')) 
        {
            System.debug(DateTime.now() + packageType + 'Sending V41');
            return 'V41';
        } 
        else if (packageType.contains('House Void')) 
        {
            System.debug(DateTime.now() + packageType + 'Sending V51');
            return 'V51';
        } 
        else if (packageType.contains('Transport Void')) 
        {
            System.debug(DateTime.now() + packageType + 'Sending V31');
            return 'V31';
        } 
        else if (packageType.contains('Extra Cost'))
        {
            // Do nothing, reason codes for Extra Cost packages depends on the parent case
            //Utils.sendSingleMail(DateTime.now() + packageType + 'Sending V41 from if Block');   
            //return null; EC01 is ActionVoidtype for extra cost
            return 'V41';
        }
        else 
        {
           System.debug(DateTime.now() + packageType + 'Not Falling any of the action package type');
           throw new MediatorException('Unexpected Package Type: ' + packageType);
        }
    }
    
    private static String getCRFReasonCode(String creditReason) 
    {

        List<Picklist_Mapping__c> mappings = [
            SELECT Mapping__c 
            FROM Picklist_Mapping__c 
            WHERE Object_Type__c = 'Action_Package__c' 
            AND Field_Name__c = 'Credit_Reason__c' 
            AND Name = :creditReason
        ];
        
        if (mappings.size() < 1)
        {
            throw new MediatorException('Unable to find mapping for Credit Reason: ' + creditReason);
        }
        
        return mappings.get(0).Mapping__c;
    }
    
    private static Long getTaxTypeId(String taxCode) 
    {
        if ('Tax Exempt'.equals(taxCode)) 
        {
            return 0;
        } 
        else if ('GST'.equals(taxCode)) 
        {
            return 2;
        } 
        else if ('QST + GST'.equals(taxCode)) 
        {
            return 6;
        } 
        else if ('HST'.equals(taxCode)) 
        {
            return 4;
        } 
        else 
        {
            throw new MediatorException('Invalid Tax Type: ' + taxCode);
        }
    }
    
    private static Long getPaymentMethodId(String paymentMethodId) {
        return (paymentMethodId != null) ? Long.valueOf(paymentMethodId) : -1;
    }
    
    private static String filterRegionCode(String regionCode) {
        return ('N/A'.equalsIgnoreCase(regionCode)) ? null : regionCode;
    }
    
    private static String getResponsiblePartyId(String responsibleParty) {
        if (responsibleParty == null) {
            return ''; 
        } else if ('House'.equals(responsibleParty)) {
            return 'O';
        } else if ('Seller'.equals(responsibleParty)) {
            return 'S';
        } else if ('Buyer'.equals(responsibleParty)) {
            return 'B';
        } else if ('Discretionary Fund'.equals(responsibleParty)) {
            return 'D';
        // Transporter, Inspector, and Other are currently unsupported in SAP, default to empty string
        } else if ('Transporter'.equals(responsibleParty)) {
            return '';
        } else if ('Inspector'.equals(responsibleParty)) {
            return '';
        } else if ('Other'.equals(responsibleParty)) {
            return '';
        } else {
            throw new MediatorException('Invalid Responsible Party: ' + responsibleParty);
        }
    }
    
    // Currently just prints reponse messages to log.  
    public List<String> processResponseMessages(List<String> returnMessages) {
        Logger.info(pkg, 'Processing Resonse Messages...');
        if (returnMessages != null) {
            for (String msg : returnMessages) {
                Logger.info(pkg, 'Response Message: ' + msg);
            }
            return returnMessages;
        }
        else
        {
            return new List<String>();
        }
    }
    

    public List<String> processResponseMessages(String resultCode, List<String> returnMessages, List<String> extraMessages) {
        Logger.info(pkg, 'Processing Resonse Messages...');
        List<String> messages = null;
        if (returnMessages == null || 'SAP_VOID_SUCCESS_WITHOUT_DOC'.equals(resultCode)) {
            messages = extraMessages;
        } else {
            messages = returnMessages;
        }
        
        return processResponseMessages(messages);
    }


    // Appends new response messages to the Action_Package__c.Response_Messages__c field
    public void addResponseMessagesToPackage(List<String> newMessages) {
        List<String> messages = new List<String>();
        if (pkg.Response_Messages__c != null) {
            messages = pkg.Response_Messages__c.split('\n');
        }
        messages.addAll(newMessages);
        pkg.Response_Messages__c = Utils.joinList(messages, '\n');
    }
    
    // Converts Mediator.FIDocuments and Mediator SDDocuments into Action_Package_Document__c objects
    public List<Action_Package_Document__c> processReturnDocs(List<Mediator.FIDocument> fiDocs, List<Mediator.SDDocument> sdDocs) {
            
        List<Action_Package_Document__c> docs = new List<Action_Package_Document__c>();
        
        Logger.info(pkg, 'Processing Returned FI Documents');
        if (fiDocs != null) {
            for (Mediator.FIDocument fiDoc : fiDocs) {
                Logger.info(pkg, 'FI Document Number: ' + fiDoc.documentNumber);
                Logger.info(pkg, 'Company Code: ' + fiDoc.companyCode);
                Logger.info(pkg, 'Fiscal Year: ' + fiDoc.fiscalYear);
                Logger.info(pkg, 'Reverse Step: ' + fiDoc.revStep);
                Action_Package_Document__c doc = new Action_Package_Document__c();
                doc.Action_Package__c = pkg.Id;
                doc.RecordTypeId = Utils.getRecordTypeId('Action_Package_Document__c', 'FI Document');
                doc.Name = fiDoc.documentNumber;
                doc.Company_Code__c = fiDoc.companyCode;
                doc.Fiscal_Year__c = fiDoc.fiscalYear;
                doc.Reverse_Step__c = fiDoc.revStep;
                docs.add(doc);
            }
        }
        
        Logger.info(pkg, 'Processing Returned SD Documents');
        if (sdDocs != null) {
            for (Mediator.SDDocument sdDoc : sdDocs) {
                Logger.info(pkg, 'SD Document Number: ' + sdDoc.documentNumber);
                Logger.info(pkg, 'Line Number: ' + sdDoc.lineNumber);
                Logger.info(pkg, 'Extra Cost Id' + sdDoc.extraCostId);
                Logger.info(pkg, 'Reverse Step: ' + sdDoc.revStep);
                Action_Package_Document__c doc = new Action_Package_Document__c();
                doc.Action_Package__c = pkg.Id;
                doc.RecordTypeId = Utils.getRecordTypeId('Action_Package_Document__c', 'SD Document');
                doc.Name = sdDoc.documentNumber;
                doc.Line_Number__c = sdDoc.lineNumber;
                doc.Extra_Cost_Id__c = sdDoc.extraCostId;
                doc.Reverse_Step__c = sdDoc.revStep;
                docs.add(doc);
            }
        }
        return docs;
    }
    
    // Translates return code from Mediator into plain-english result string
    public String translateReturnCode(String returnCode) 
    {
        Logger.info(pkg, 'Translating Return Code: ' + returnCode);
        String translation;
        if ('SAP_VOID_SUCCESS_WITHOUT_DOC'.equals(returnCode)) {
            translation = 'AUTOMATIC - Transactions created successfully in V1. No SAP accounting entries required.';
        } 
        else if (pkg.Standard_SAP_Transactions__c && getSAPNotApplicableReason(pkg) == null) {
            if ('VOID_SUCCESS'.equals(returnCode)) 
            {
                translation = 'AUTOMATIC - Transactions created successfully in V1 and SAP';
            } 
            else if ('SAP_VOID_FAIL'.equals(returnCode)) 
            {
                translation = 'V1 ONLY - Transactions need to be created manually on SAP';
            } 
            else if ('V1_VOID_FAIL'.equals(returnCode) || 'VEHICLE_PICKED_UP'.equals(returnCode))
            {
                translation = 'MANUAL - Transactions need to be created manually in V1 and SAP';
            }
            else if ('ADJUSTMENT_SUCCESS'.equals(returnCode))
            {
                translation = 'AUTOMATIC - Transactions created successfully in SAP';
            }
            else if ('SAP_ADJUSTMENT_FAIL'.equals(returnCode))
            {
               if (pkg.Auto_Approve_Override__c == true){
                   translation = 'AUTOMATIC – NO SAP accounting entries required';
                /*ppm 102221:Salesforce - call made to SAP when PM is Pay Processing ADESA Auction - should not have posted concession
                   cancel psi for PPA  need to have accounting notify process
                */
               }else{
                   translation = 'MANUAL - Transactions need to be created manually in SAP';
                }
            }
            else 
            {
                throw new MediatorException('Invalid Mediator Return Code: ' + returnCode);
            }
        } 
        else if (pkg.Standard_SAP_Transactions__c && getSAPNotApplicableReason(pkg) != null)
        {
            if ('VOID_SUCCESS'.equals(returnCode)) 
            {
                translation = getSAPNotApplicableReason(pkg);
            } 
            else if ('V1_VOID_FAIL'.equals(returnCode) || 'VEHICLE_PICKED_UP'.equals(returnCode))
            {
                translation = 'MANUAL - Transactions need to be created manually in V1 and SAP';
            } 
            else 
            {
                throw new MediatorException('Invalid Mediator Return Code: ' + returnCode);
            }
        }
        else
        {
            if ('VOID_SUCCESS'.equals(returnCode)) 
            {
                translation = 'V1 ONLY - Transactions need to be created manually on SAP';
            } 
            else if ('V1_VOID_FAIL'.equals(returnCode) || 'VEHICLE_PICKED_UP'.equals(returnCode))
            {
                translation = 'MANUAL - Transactions need to be created manually in V1 and SAP';
            } 
            else 
            {
                throw new MediatorException('Invalid Mediator Return Code: ' + returnCode);
            }
        }
        
        Logger.info(pkg, translation);
        return translation;
    }
    
    private static boolean getFreezePostSales(Action_Package__c pkg) 
    {
        try 
        {
            if (Integer.valueOf(pkg.Case__r.Vehicle_ID__c) < 0) 
            {
                return false;
            }
        } 
        catch (Exception e) 
        {
            return false;  // Return false if vehicle id cannot be converted to Integer
        }
        
        return (!'EXTRA COST'.equalsIgnoreCase(pkg.Package_Type__c) &&
                !'ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) &&
                !'AUCTION CREDIT'.equalsIgnoreCase(pkg.Package_Type__c) &&
                !'TRANSPORT ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) &&
                !'CONCESSION'.equalsIgnoreCase(pkg.Package_Type__c));
    }
    
    // Added in B-15237: Voids - Don't call BAPI for some scenarios
    private static String getSAPNotApplicableReason(Action_Package__c pkg)
    {
        
        // Non-voids (i.e. CRFs) are always applicable in SAP
        if (!pkg.Void_Vehicle__c && !pkg.Void_House_Transport__c)
        {
            return null;    
        }
        
        if (
            'AUCTION VOID'.equalsIgnoreCase(pkg.Package_Type__c) &&
            (
                'AUDIDIRECT'.equalsIgnoreCase(pkg.Private_Label__c) || 
                'VOLKSWAGENDIRECT'.equalsIgnoreCase(pkg.Private_Label__c)
            ))
        {
            return 'AUTOMATIC - Transactions created successfully in V1. No SAP accounting entries required.';
        }
        
        if ('TRANSPORT VOID'.equalsIgnoreCase(pkg.Package_Type__c) &&
            pkg.Transport_Type__c == 3 &&
            (
                'HONDA FINANCIAL SERVICES CANADA'.equalsIgnoreCase(pkg.Case__r.VIN__r.ATC_Buyer__r.Name) || 
                'BMW FINANCIAL SERVICES CANADA'.equalsIgnoreCase(pkg.Case__r.VIN__r.ATC_Buyer__r.Name)
            ))
        {
            if (pkg.Case__r.VIN__r.Transport_Sale_Date__c != null && pkg.Case__r.VIN__r.Transport_Sale_Date__c.month() == Date.today().month())
            {
                return 'AUTOMATIC - Transactions created successfully in V1. No SAP accounting entries required.';
            }
            else if (pkg.Case__r.VIN__r.ATC_Sale_Date__c != null && pkg.Case__r.VIN__r.ATC_Sale_Date__c.month() == Date.today().month())
            {
                return 'AUTOMATIC - Transactions created successfully in V1. No SAP accounting entries required.';
            }
            else
            {
                return 'AUTOMATIC - Transactions created successfully in V1. Finance to create the SAP accounting entries manually at month end.';
            }
        }
        //B-20136 Management of voided DealerBlock vehicles - OL does not handle settlement
        //------------------------------------------------------------------------------------------------------------
        String DealerBlock;
        
        if (pkg.Is_Dealer_Block__c != null)
        {   
            DealerBlock = pkg.Is_Dealer_Block__c;
            }else
        {   DealerBlock = 'No';
            }
            
        
        if (DealerBlock.equalsIgnoreCase('Yes') &&
                'AUCTION VOID'.equalsIgnoreCase(pkg.Package_Type__c) &&
                    (
                    // Replace PPA with PPAA (ppm 102221 )
                    //'pay processing auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) || 
                    'adesa\'s centralized payment'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'ally financial floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'tfs floorplan'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'toyota fin svcs floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||                   
                    'pay adesa worldwide'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'pay openlane worldwide - wire'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||            
                    'pay using other floorplans'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'pay processing adesa auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c)
                    ))
        {
            return 'AUTOMATIC - Transactions created successfully in V1. No SAP accounting entries required.';
        }
        //B-20138 Update Concessions for DealerBlock Sales
        //-------------------------------------------------
        if (DealerBlock.equalsIgnoreCase('Yes') &&
                'CONCESSION'.equalsIgnoreCase(pkg.Package_Type__c) &&
                    (
                    // Replace PPA with PPAA (ppm 102221 )
                    //'pay processing auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) || 
                    'adesa\'s centralized payment'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'ally financial floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'tfs floorplan'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'toyota fin svcs floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||                
                    'pay adesa worldwide'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'pay openlane worldwide - wire'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||            
                    'pay using other floorplans'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'pay processing adesa auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c)
                    ))
        {
            return 'AUTOMATIC - Transactions created successfully in V1. No SAP accounting entries required.';
        }
        //B-20315 Update Adjustments for DealerBlock sales in SF for specific payment method
        //----------------------------------------------------------------------------------
        if (DealerBlock.equalsIgnoreCase('Yes') &&
                'ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) &&
                    (
                    
                    //'pay processing auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) || 
                    'adesa\'s centralized payment'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'ally financial floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'tfs floorplan'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'toyota fin svcs floorplan (processed by auction)'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||                                    
                    'pay adesa worldwide'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||
                    'pay openlane worldwide - wire'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) ||            
                    'pay using other floorplans'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c) 
                    //'pay processing adesa auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c)
                    ))
        {
            return 'MANUAL  - Transactions need to be created manually in SAP.';
        }
        
                if (DealerBlock.equalsIgnoreCase('Yes') &&
                'ADJUSTMENT'.equalsIgnoreCase(pkg.Package_Type__c) &&
                    ('pay processing adesa auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Payment_Method__c)
                    ))
        {
            return 'AUTOMATIC – NO SAP accounting entries required.';
        }

        if (('FORD CREDIT SIGNATURE PLAN'.equalsIgnoreCase(pkg.Payment_Method__c) ||
                'BRASS HAT CREDIT LINE'.equalsIgnoreCase(pkg.Payment_Method__c) ||
                'BMW FLOORPLAN'.equalsIgnoreCase(pkg.Payment_Method__c) ||
                'DEFT'.equalsIgnoreCase(pkg.Payment_Method__c)) &&
             pkg.House_Extra_Costs__c == 0 &&
             pkg.Seller_Extra_Costs__c == 0 &&
             pkg.Other_Party_Amount__c == 0 &&
             !pkg.Void_House_Transport__c)
        {
            return 'AUTOMATIC - Transactions created successfully in V1. No SAP accounting entries required.';
        }
        //B-30204: New rules for Sales Rules and Car Groups
        if (
            ('GMF – Open Auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Sales_Rules__c)) || //GM Financial Off Lease
            ('Honda In Transit or At Auction'.equalsIgnoreCase(pkg.Case__r.VIN__r.Sales_Rules__c)) || //Honda/Acura Off Lease
            ('SETF to OA bid only – In transit'.equalsIgnoreCase(pkg.Case__r.VIN__r.Sales_Rules__c))  //SETF EOT In-transit
            
            //B-39003   Reverse the rules implemented in B-30204  AUDI , VW
            )
        {
            return 'AUTOMATIC - Transactions created successfully in V1. No SAP accounting entries required';
        }
                        
        return null;
    }
    
    // Added in B-15852: Voids SF - iDeal Voids.  Instructs SAP to ignore seller-level fees table
    //  and apply the user-entered 'Arbitration Fee' (passed in as an Extra Cost) instead
    private static String getProcessOverride(Action_Package__c pkg)
    {
        
        Set<String> CasesIds = new Set<String>();
        String strSegment_Name;
        CasesIds.add(pkg.Case__r.Id);
        List<Case> cases =  [SELECT VIN__r.Segment_Name__c FROM Case WHERE Id IN :CasesIds];
        for (Case c : cases)
        {
            strSegment_Name = c.VIN__r.Segment_Name__c;
        }
           
        System.debug(' Information...for Pkg inside getProcessOvrride before if statement ' );
        System.debug(' Information...for Pkg inside getProcessOverride Segment: '+ strSegment_Name );
        //Logger.info(pkg, 'Purchase Segment Name___ ' + pkg.Case__r.VIN__r.Segment_Name__c);
        if (pkg.Package_Type__c.toUpperCase().startsWith('AUCTION VOID') && 
        ('OPEN D2D'.equalsIgnoreCase(pkg.Sale_Classification__c) || 'ADC OPEN'.equalsIgnoreCase(pkg.Sale_Classification__c)) && 
        !'CANADA'.equalsIgnoreCase(pkg.Country__c)) 
        {
            System.debug(' Return I for D2D Dealers: '+ strSegment_Name + 'Country : ' + pkg.Country__c );
            return 'I';
        }
        else if (pkg.Package_Type__c.toUpperCase().startsWith('AUCTION VOID') &&
            'United States'.equalsIgnoreCase(pkg.Country__c) &&
            pkg.Arbitration_Fee__c != null && (
            'CAP Dealers'.equalsIgnoreCase(strSegment_Name) || 
            'CAP Inst Repo'.equalsIgnoreCase(strSegment_Name) ||
            'CAP iDEAL Repo'.equalsIgnoreCase(strSegment_Name) 
            ))           
        {
            System.debug(' Return I for CAP Dealers: '+ strSegment_Name + 'Country : ' + pkg.Country__c );
            return 'I';
        }
                    
        return null;
    }
    
    public class MediatorException extends Exception {}

}