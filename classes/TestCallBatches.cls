@isTest private class TestCallBatches    {
      TestMethod static void test_CallBatchCreateLinkOppsToVehicleOpps() {
        String returncoede = callBatches.CallBatchCreateLinkOppsToVehicleOpps();
        System.assert(returncoede != null);
    }
    TestMethod static void test_CallBatchPurgeOldVir() {
        String returncoede = callBatches.CallBatchPurgeOldVir();
        System.assert(returncoede != null);
    }

    TestMethod static void test_CallBatchVEROrphanManager() {
        String returncoede = callBatches.CallBatchVEROrphanManager();
        System.assert(returncoede != null);
    }
    
    TestMethod static void test_CallBatchCreateSellerRetentionOpps() {
        String returncoede = callBatches.CallBatchCreateSellerRetentionOpps();
        System.assert(returncoede != null);
    }

    TestMethod static void test_CallBatchCreateBuyerRetentionOpps() {
        String returncoede = callBatches.CallBatchCreateBuyerRetentionOpps();
        System.assert(returncoede != null);
    }

    TestMethod static void test_CallBatchCleanUpSellerRetentionOpps() {
        String returncoede = callBatches.CallBatchCleanUpSellerRetentionOpps();
        System.assert(returncoede != null);
    }

    TestMethod static void test_CallBatchCleanUpBuyerRetentionOpps() {
        String returncoede = callBatches.CallBatchCleanUpBuyerRetentionOpps();
        System.assert(returncoede != null);
    }

                
}