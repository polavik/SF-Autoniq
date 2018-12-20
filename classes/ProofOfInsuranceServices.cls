public with sharing class ProofOfInsuranceServices
{
    public final static String COMPLETED_STRING = 'Complete';
    public final static String NOT_STARTED_STRING = 'Not Started';
    @testVisible final static Integer NUMBER_OF_NEW_MONTHLY_RECORDS=3;
    @testVisible final static String MONTHLY_FREQUENCY='Monthly';
    public static final Map<String, Integer> FREQUENCY_TO_NUMBER = new Map<String, Integer>{
        'Monthly'=>1, 'Quarterly'=>3, 'Semi-Annual'=>6, 'Annual'=>12
    };

    @TestVisible
    private static Set<String> POIFields{
        get{
            if(POIFields==null){
                POIFields = new Set<String>();
                for(FieldSetMember fsm : SObjectType.Proof_of_Insurance__c.FieldSets.Generate_POI_Fields.getFields()){
                    POIFields.add(fsm.getFieldPath());
                }
            }
            return POIFields;
        } set;
    }

    public static List<Proof_of_Insurance__c> allNewPOI{
        get {
            if(allNewPOI == null){
                allNewPOI = new List<Proof_of_Insurance__c>();
            }
            return allNewPOI;
        } set;
    }   

    public static Map<Id, List<Proof_of_Insurance__c>> getContractToPOIs(Set<Id> contractIds){
        String query = 'SELECT Id, Due_Date__c, Frequency_of_Schedule__c, Contract__c, Status__c';
        for(String field : POIFields){
            query += ', ' + String.escapeSingleQuotes(field);
        }
        query += ' FROM Proof_of_Insurance__c WHERE Contract__c IN :contractIds AND Due_Date__c > TODAY AND Status__c != \'' + COMPLETED_STRING + '\'';
        List<Proof_of_Insurance__c> poiList = Database.query(query);
        Map<Id, List<Proof_of_Insurance__c>> contractToPOIs = new Map<Id, List<Proof_of_Insurance__c>>();
        for(Proof_of_Insurance__c poi : poiList){
            if(contractToPOIs.get(poi.Contract__c) != null){
                contractToPOIs.get(poi.Contract__c).add(poi);
            } else {
                contractToPOIs.put(poi.Contract__c, new List<Proof_of_Insurance__c>{poi});
            }
        }
        return contractToPOIs;
    }

    public static List<Proof_of_Insurance__c> filterPOIForCompleted(List<Proof_of_Insurance__c> poiList){
        List<Proof_of_Insurance__c> filteredList = new List<Proof_of_Insurance__c>();
        for(Proof_of_Insurance__c poi : poiList){
            if(poi.Status__c == COMPLETED_STRING){
                filteredList.add(poi);
            }
        }
        return filteredList;
    }

    public static Proof_of_Insurance__c clonePOI(Proof_of_Insurance__c origPOI, Date newDate){
        Proof_of_Insurance__c newPOI = new Proof_of_Insurance__c();
        for(String field : POIFields){
            newPOI.put(field, origPOI.get(field));
        }
        newPOI.Contract__c = origPOI.Contract__c;
        newPOI.Frequency_of_Schedule__c = origPOI.Frequency_of_Schedule__c;
        newPOI.Due_Date__c = newDate;
        newPOI.Status__c = NOT_STARTED_STRING;
        return newPOI;
    }

    public static List<POIWrapper> createBufferPOIs(List<Proof_of_Insurance__c> poiList){
        List<POIWrapper> poiForInsert = new List<POIWrapper>();
        Map<Id, List<Proof_of_Insurance__c>> contractToPOIs = getContractToPOIs(Pluck.ids('Contract__c', poiList));
        for(Proof_of_Insurance__c poi : poiList){
            String freq = poi.Frequency_of_Schedule__c;
            if(FREQUENCY_TO_NUMBER.get(freq) == null) {
                poi.addError('Frequency of Schedule must not be null');
            }
            if(freq == MONTHLY_FREQUENCY){
                for(Integer i=1; i<=NUMBER_OF_NEW_MONTHLY_RECORDS; i++){
                    Date newDate = poi.Due_Date__c.addMonths(i*FREQUENCY_TO_NUMBER.get(freq));
                    if(!checkForMatch(contractToPOIs.get(poi.Contract__c), poi, newDate)){
                        poiForInsert.add(new POIWrapper(clonePOI(poi, newDate), poi));
                    }
                }
            }else{
                Date newDate = poi.Due_Date__c.addMonths(FREQUENCY_TO_NUMBER.get(freq));
                if(!checkForMatch(contractToPOIs.get(poi.Contract__c), poi, newDate)){
                    poiForInsert.add(new POIWrapper(clonePOI(poi, newDate), poi));
                }
            }
        }
        return poiForInsert;
    }

    @testVisible static Boolean checkForMatch(List<Proof_of_Insurance__c> pois, Proof_of_Insurance__c currentPOI, Date newDate){
        if(pois == null) return false;
        Boolean hasMatch;
        for(Proof_of_Insurance__c poi : pois){
            hasMatch = poi.Frequency_of_Schedule__c == currentPOI.Frequency_of_Schedule__c;
            hasMatch &= poi.Due_Date__c == newDate;
            for(String field : POIFields){
                hasMatch &= poi.get(field) == currentPOI.get(field);
            }
            if(hasMatch) break;
        }
        return hasMatch;
    }

    public static void insertPOIs(List<POIWrapper> poiList){
        if(poiList.isEmpty()) return;
        try{
            insert allNewPOI;
        } catch (DmlException e){
            Map<string, Proof_of_Insurance__c> identifierMap = new Map<String, Proof_of_Insurance__c>();
            for(POIWrapper wrapper : poiList){
                identifierMap.put(wrapper.newPOI.Contract__c + '-' + wrapper.newPOI.Due_Date__c.format(), wrapper.oldPOI);
            }
            for (Integer i = 0; i < e.getNumDml(); i++){
                String identifier = allNewPOI[e.getDmlIndex(i)].Contract__c + '-' + allNewPOI[e.getDmlIndex(i)].Due_Date__c.format();
                identifierMap.get(identifier).addError(e.getMessage());
            }
        }
    }

    public class POIWrapper{
        public Proof_of_Insurance__c newPOI;
        public Proof_of_Insurance__c oldPOI;

        public POIWrapper(Proof_of_Insurance__c newProof, Proof_of_Insurance__c oldProof){
            newPOI = newProof;
            oldPOI = oldProof;

            allNewPOI.add(newProof);
        }
    }
}