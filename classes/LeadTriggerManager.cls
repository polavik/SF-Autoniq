// Created By: Amit SanWariya (Appirio)
// Created On: 14-Oct-2016
// Purpose: Removes the newly created tasks if the Do_Not_Create_a_Task__c checkbox is checked
global class LeadTriggerManager {
    //Method to delete the newly created Tasks from the parent record Ids received
    //Method called in future as Task are created after After Update
    @future
    public static void DeleteNewlyCreatedTask(Set<Id> whatIdSet) {
        //Query the most recently created Task from the filtered parent Ids
        List<Task> taskToDelete = [SELECT Id 
                                   FROM Task 
                                   WHERE WhatId IN :whatIdSet
                                   Order By CreatedDate DESC Limit 1];
    	delete taskToDelete;
    }
}