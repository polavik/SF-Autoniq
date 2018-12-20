trigger ProofOfInsurance on Proof_of_Insurance__c (after insert, after update) {
    if(Trigger.isAfter){
        List<Proof_of_Insurance__c> filteredList = ProofOfInsuranceServices.filterPOIForCompleted(Trigger.new);
        if(!filteredList.isEmpty()){
            // Automatically generate POIs when one is completed
            ProofOfInsuranceServices.insertPOIs(ProofOfInsuranceServices.createBufferPOIs(filteredList));
        }
    }
}