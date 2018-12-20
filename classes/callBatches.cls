global class callBatches {

    WebService static String CallBatchCreateLinkOppsToVehicleOpps() {
        BatchCreateLinkOppsToVehicleOpps Blvop = new BatchCreateLinkOppsToVehicleOpps();
        Database.executeBatch(Blvop);
        return 'S';
    }
   
     WebService static String CallBatchPurgeOldVir() {
        PurgeOldVirs  POldVIR = new PurgeOldVirs();
        Database.executeBatch(POldVIR);
        return 'S';
    }
     WebService static String CallBatchVEROrphanManager() {
        VEROrphanManager  VEROPManager = new VEROrphanManager();
        Database.executeBatch(VEROPManager);
        return 'S';
    }
     WebService static String CallBatchCreateSellerRetentionOpps() {
        BatchCreateSellerRetentionOpps  CreatSellerRetentionOps = new BatchCreateSellerRetentionOpps();
        Database.executeBatch(CreatSellerRetentionOps);
        return 'S';
    }    
     WebService static String CallBatchCreateBuyerRetentionOpps() {
        BatchCreateBuyerRetentionOpps  CreatBuyerRetentionOps = new BatchCreateBuyerRetentionOpps();
        Database.executeBatch(CreatBuyerRetentionOps);
        return 'S';
    }
     WebService static String CallBatchCleanUpSellerRetentionOpps() {
        BatchCleanUpSellerRetentionOpps  CleanSellerRetentionOps = new BatchCleanUpSellerRetentionOpps();
        Database.executeBatch(CleanSellerRetentionOps);
        return 'S';
    }
     WebService static String CallBatchCleanUpBuyerRetentionOpps() {
        BatchCleanUpBuyerRetentionOpps  CleanBuyerRetentionOps = new BatchCleanUpBuyerRetentionOpps();
        Database.executeBatch(CleanBuyerRetentionOps);
        return 'S';
    }

   
}