/**
  * Apex Class: TopicAssignmentTriggerHandler
  * Description: Handler Class for TopicAssignment Trigger
  * Created By: Matt Salpietro
  * Created Date: February 5th 2016
*/
public class TopicAssignmentTriggerHandler {
    public static String CONFIG_RECOGNITION_REC_NAME = 'Config - Recognition';             
    public static boolean IS_TOPIC_ASSIGNMENT_TRIGGER_EXECUTED = false;        
        
    private static List<String> recognitionText = new List<String>();
    private static Set<Id> feedIds = new Set<Id>();
    private static String recognitionTopicId;
    private static String recognitionTopicName;
                
    public static void onAfterInsert(List<TopicAssignment> TopicAssignmentList){
        getRecognitionText();
        initRecognitionIds();
        insertRecognitionRecords(TopicAssignmentList);
    }
    
    private static void insertRecognitionRecords(List<TopicAssignment> TopicAssignmentList){
        List<TopicAssignment> topicAssignmentListToBeInserted = new List<TopicAssignment>();
        for(TopicAssignment aTopicAssignment : TopicAssignmentList){
            if(feedIds.contains(aTopicAssignment.TopicId) && !String.isEmpty(recognitionTopicId)){
               TopicAssignment newTopicAssignment  = new TopicAssignment (); 
               newTopicAssignment.TopicId = recognitionTopicId;
               newTopicAssignment.EntityId = aTopicAssignment.EntityId;
              if(!String.valueOf(aTopicAssignment.EntityId).startsWith('069') && !String.valueOf(aTopicAssignment.EntityId).startsWith('068'))
                  topicAssignmentListToBeInserted.add(newTopicAssignment);
               system.debug('TOPIC ASSGN TRUE  - TopicID=' + recognitionTopicId + ' ' + aTopicAssignment.EntityId);
            }
            else
               system.debug('TOPIC ASSGN FALSE - TopicID=' + recognitionTopicId + ' ' + aTopicAssignment.EntityId);
        }
        insert topicAssignmentListToBeInserted;
    }
    
    private static void getRecognitionText(){
        for(Intranet_Content__c aIntranetContent : [SELECT Id, Recognition_Text__c, Value__c, Name
                                                    FROM Intranet_Content__c 
                                                    WHERE Name = :CONFIG_RECOGNITION_REC_NAME]){
            if(aIntranetContent.Recognition_Text__c != null && aIntranetContent.Recognition_Text__c != ''
                && String.isNotBlank(aIntranetContent.Value__c)){
                recognitionTopicName = aIntranetContent.Value__c;
                for(String textRec : aIntranetContent.Recognition_Text__c.split(',')){
                    if(!String.isEmpty(textRec)){
                        recognitionText.add(textRec);
                    }
                }
            }
        }
    }
    
    private static void initRecognitionIds(){
        for(Topic aTopic : [SELECT Id, Name FROM Topic WHERE Name IN :recognitionText OR Name = :recognitionTopicName]){
            if(aTopic.Name == recognitionTopicName){
                recognitionTopicId = aTopic.Id;
            }else{
                feedIds.add(aTopic.Id);
            }
        }
    }
}