trigger InspectionAfterInsertUpdate on Inspection__c (after insert, after update) 
{
    // Delete inactive inspections from Salesforce
    List<ID> inspectionsToDelete = new List<ID>();
    for (Inspection__c insp : Trigger.new)
    {
        if (!insp.Active__c)
        {
            inspectionsToDelete.add(insp.Id);
        }
    }
    if (inspectionsToDelete.size() > 0)
    {
        List<Database.Deleteresult> results = Database.delete(inspectionsToDelete);
        Database.emptyRecycleBin(inspectionsToDelete);
    }
}