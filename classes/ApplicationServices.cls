public with sharing class ApplicationServices
{
	
    @TestVisible static final List<String> INCOMPLETE_STATUS = new List<String> { 'Not Started', 'Returned to Credit', 'Returned to Branch', 'Returned to CT Processing', 'Submitted'};

    @TestVisible public static void detectAndApplyAppAccountChanges(List<Application_Account_Role__c> appAccounts, Map<Id, Application_Account_Role__c> oldAppAccountsMap, boolean isInsert)
    {
        List<Application__c> applicationsToBeUpdated                = new List<Application__c>();
        Map<Id, Id>          applicationIdToPrimaryAppAccountIdMap      = new Map<Id, Id>();
        Map<Id, Id>          applicationIdToNonprimaryAppAccountIdMap   = new Map<Id, Id>();
        for(Application_Account_Role__c appAcc : appAccounts){
            if((isInsert && appAcc.primary__c) || (!isInsert && oldAppAccountsMap.get(appAcc.Id).primary__c != appAcc.primary__c ))
            {
                if(appAcc.primary__c)
                    applicationIdToPrimaryAppAccountIdMap.put(appAcc.Application__c , appAcc.Account__c);
                else
                    applicationIdToNonprimaryAppAccountIdMap.put(appAcc.Application__c, appAcc.Account__c);
            }
        }
        for(Application__c app : [select Id, Applications_Accounts__c
                from Application__c
                where Id IN :applicationIdToPrimaryAppAccountIdMap.keyset()
                OR Id IN :applicationIdToNonprimaryAppAccountIdMap.keyset()])
        {
            if(applicationIdToPrimaryAppAccountIdMap.keyset().contains(app.Id) && app.Applications_Accounts__c != applicationIdToPrimaryAppAccountIdMap.get(app.Id))
                applicationsToBeUpdated.add(new Application__c(Id = app.Id, Applications_Accounts__c = applicationIdToPrimaryAppAccountIdMap.get(app.Id)));
            else if(applicationIdToNonprimaryAppAccountIdMap.keyset().contains(app.Id) && app.Applications_Accounts__c == applicationIdToNonprimaryAppAccountIdMap.get(app.Id))
                applicationsToBeUpdated.add(new Application__c(Id = app.Id, Applications_Accounts__c = null));
        }
        update applicationsToBeUpdated;

        Database.SaveResult[] srList  = Database.update(applicationsToBeUpdated,false); // allow for partial successes
        for (Integer i = 0; i < srList.size(); i++)
        {
            if (!srList[i].isSuccess())
            {
                String err  = srList[i].getErrors()[0].getMessage();
                Id ErroredappAccId = applicationIdToPrimaryAppAccountIdMap.keyset().contains(applicationsToBeUpdated[i].id) ? applicationIdToPrimaryAppAccountIdMap.get(applicationstobeUpdated[i].id) : applicationIdToPrimaryAppAccountIdMap.get(applicationsToBeUpdated[i].id);
                oldAppAccountsMap.get(ErroredappAccId).addError(err);
            }
        }
    }

    //Called from Application after convert Update
    public static void updateBranchNumber(list<Application__c> applications)
    {
        map<string, Application__c> appMap = new map<string, Application__c>();
        List<String> branchNames = new List<String>();
        for(Application__c a : applications)
        {
            appMap.put(a.Id, a);
            branchNames.add(a.AFC_Branch__c);
        }

        map<string, decimal> csMap = new map<string,decimal>();
        for(BranchNumber__c bn : BranchNumber__c.getall().values())
        {
            csMap.put(bn.Name.toUpperCase(), bn.Branch_Number__c);
        }

        // Added by Eric Whipple of Galvin Technologies to support "Viewer is..." fields on Application object.
        Map<String, List<AFC_Branch__c>> nameToBranch = new Map<String, List<AFC_Branch__c>>();
        for(AFC_Branch__c branch : [select id, name from AFC_Branch__c where name IN :branchNames]){
            if(nameToBranch.get(branch.name) == null){
                nameToBranch.put(branch.name, new List<AFC_Branch__c>{branch});
            } else {
                nameToBranch.get(branch.name).add(branch);
            }
        }

        for(Application__c app : appMap.Values())
        {
            if(app.AFC_Branch__c != null)
            {
                List<AFC_Branch__c> branch = nameToBranch.get(app.AFC_Branch__c);
                if(branch != null && branch.size() > 0){
                    app.AFC_Branch2__c = branch[0].id;
                }
                if(csMap.get(app.AFC_Branch__c.toUpperCase()) != null)
                {
                    app.AFC_Branch_Number__c = csMap.get(app.AFC_Branch__c.toUpperCase());
                }
            }
        }
    }
    public static void updateAppStatusFromContractReceivedDate(AFC_Contract_Shell__c[] updatedContractShells, Map<Id, AFC_Contract_Shell__c> oldContractShellsMap)
    {
        Application__c[] appsToUpdate = new Application__c[]{};
        for(AFC_Contract_Shell__c contractShell : updatedContractShells)
        {
            if(contractShell.Received_from_Dealer__c != null && oldContractShellsMap.get(contractShell.Id).Received_from_Dealer__c == null)
            {
                appsToUpdate.add(new Application__c(Id = contractShell.Application__c, Application_Stage__c = 'Contract Active'));
            }
        }
        update appsToUpdate;
    }

    public static void clearprimaryApplicationAccountsfield(List<Application_Account_Role__c> OldappAccs, map<Id, Application_Account_Role__c> mapNewappAccs, boolean isDelete)   {
        List<Application__c> ApplicationstobeUpdated        = new List<Application__c>();
        Map<Id, Id> ApplicationIdtononprimaryappAccountId   = new Map<Id, Id>();

        for(Application_Account_Role__c appAcc : OldappAccs)
        {
            if(isDelete && appAcc.primary__c)
            {
                ApplicationIdtononprimaryappAccountId.put(appAcc.Application__c, appAcc.Account__c);
            }
        }

        for(Application__c App : [select Id, Applications_Accounts__c from Application__c where Id IN :ApplicationIdtononprimaryappAccountId.keyset()])
        {
            if(ApplicationIdtononprimaryappAccountId.keyset().contains(App.Id) && App.Applications_Accounts__c == ApplicationIdtononprimaryappAccountId.get(App.Id))
            {
                ApplicationstobeUpdated.add(new Application__c(Id = App.Id, Applications_Accounts__c = null));
            }
        }

        Database.SaveResult[] srList  = Database.update(ApplicationstobeUpdated,false); // allow for partial successes

        for (Integer i = 0; i < srList.size(); i++)
        {
            if (!srList[i].isSuccess())
            {
                String err  = srList[i].getErrors()[0].getMessage();
                Id ErroredappAccId = ApplicationIdtononprimaryappAccountId.get(ApplicationstobeUpdated[i].id);
                mapNewappAccs.get(ErroredappAccId).addError(err);
            }
        }
    }

    public static void deleteInProgressApplications(Application__c[] apps)
    {
        //Delete all apps owned by current user where app flow has not been completed (i.e. Application_Flow_In_Progress__c is set to true)
        for(Application__c[] appsToDelete : [select Id from Application__c where Application_Flow_In_Progress__c = true and OwnerId = :UserInfo.getUserId() and Id not in :apps])
        {
            delete appsToDelete;
        }
    }

    public static void updateCreditAndCTUserLookups(Application__c insertedApp)
    {
        try
        {
            System.debug('THIS IS THE INSERTEDAPP: ' + insertedApp);
            Application__c insertedAppToBeUpdated = new Application__c(Id = insertedApp.Id);
			
			//Story B-44003 : FLS UPDATE ACCESS CHECK
			 Set<String> ListFLSUpdate = new Set<String>();
			 Boolean blnFLSOverride = Utils.GetFLS();
			 if (Schema.sObjectType.Application__c.fields.Credit_User__c.isUpdateable() || blnFLSOverride)
			 {	
				insertedAppToBeUpdated.Credit_User__c = getCreditOrCTUserID(insertedApp.AFC_Region__c, insertedApp.AFC_Branch__c, 'Credit', insertedApp.Application_Level__c);
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Application__c.getName()+'.'+Schema.sObjectType.Application__c.fields.Credit_User__c.getName());
			 }
			 
			 if (Schema.sObjectType.Application__c.fields.CT_Processing_User__c.isUpdateable() || blnFLSOverride)
			 {
				insertedAppToBeUpdated.CT_Processing_User__c = getCreditOrCTUserID(insertedApp.AFC_Region__c, insertedApp.AFC_Branch__c, 'CT Processing', null);
			 }
			 else
			 {						
				ListFLSUpdate.add(Schema.sObjectType.Application__c.getName()+'.'+Schema.sObjectType.Application__c.fields.CT_Processing_User__c.getName());
			 }
			 
            update insertedAppToBeUpdated;
			
			if(ListFLSUpdate.size()>0)
			{
				Utils.SendEmailforFLS('FLS_UPDATE','CLASS:ApplicationServices', ListFLSUpdate);
			}
        }
        catch(CustomExceptions.ApplicationException ae)
        {
            insertedApp.addError(ae.getMessage());
        }
    }
    private static Id getCreditOrCTUserID(String region, String branch, String dept, String creditType)
    {
        if(String.isNotBlank(region) && String.isNotBlank(branch) && String.isNotBlank(dept))
        {
            User[] users;
            if(dept == 'Credit')
            {
                users = [select Id
                      from User
                      where AFC_Region_Responsible__c includes (:region)
                      and AFC_Branch_Responsible__c includes (:branch)
                      and Credit_or_Contract__c = :dept
                      and Credit_Type__c = :creditType];
            }
            else
            {
                users = [select Id
                      from User
                      where AFC_Region_Responsible__c includes (:region)
                      and AFC_Branch_Responsible__c includes (:branch)
                      and Credit_or_Contract__c = :dept];
            }
            if(users.size() == 0)
            {
                throw new CustomExceptions.ApplicationException('No user found for AFC Region Responsible: ' + region + ', AFC Branch Responsible: ' + branch + ', Credit or CT Processing?: ' + dept + ', Credit Type : ' + creditType);
            }
            if(users.size() > 1)
            {
                throw new CustomExceptions.ApplicationException('More than one user found for AFC Region Responsible: ' + region + ', AFC Branch Responsible: ' + branch + ', Credit or CT Processing?: ' + dept + ', Credit Type : ' + creditType);
            }
            return users[0].Id;
        }
        else
        {
            if(String.isBlank(region))
            {
                throw new CustomExceptions.ApplicationException('AFC Region cannot be blank!');
            }
            else
            {
                throw new CustomExceptions.ApplicationException('AFC Branch cannot be blank!');
            }
        }
    }

    public static Map<Id, List<String>> filterApplicationsThatHaveChangedUsers( List<Application__c> incomingApplications, Map<Id, Application__c> oldMap, set<String> userLookupfields )
    {
        Map<Id, List<String>> filteredApplicationsIdsToChangedFields;
        if(userLookupFields.isEmpty()){
            return filteredApplicationsIdsToChangedFields;
        }else{
            filteredApplicationsIdsToChangedFields = new Map<Id, List<String>>();
            for(Application__c app : incomingApplications){
                Application__c oldApp = oldMap.get(app.Id);
                for(String field : userLookupFields){
                    if(app.get(field) != oldApp.get(field)){
                        if( !filteredApplicationsIdsToChangedFields.containsKey( app.id ) )
                            filteredApplicationsIdsToChangedFields.put( app.id, new List<String>{field});
                        else
                            filteredApplicationsIdsToChangedFields.get( app.id ).add( field );
                    }
                }
            }

            return filteredApplicationsIdsToChangedFields;
        }
    }

    public static Map<Id, List<Checklist_Item__c>> findChecklistItems(Set<Id> filteredApplicationIds, set<String> creditUserLookupFields, List<String> departmentValues){

        Map<Id, List<Checklist_Item__c>> groupedItemsToReturn;

        if( departmentValues == null || departmentValues.isempty())
            return groupedItemsToReturn;
        else{
            groupedItemsToReturn = new Map<Id, List<Checklist_Item__c>>();

            List<String> applicationLookupfields = new List<String> ();

            for( String lookupField : creditUserLookupFields)
                applicationLookupfields.add( 'CheckList__r.Application__r.' + lookupField);

            String query = 'Select id, For_Department__c, Item_Status__c, CheckList__r.Application__c, ' + String.join(applicationLookupfields, ',');

            query += ' from CheckList_Item__c where For_Department__c in : departmentValues';
            query += ' And Item_Status__c in : INCOMPLETE_STATUS';
            query += ' And CheckList__r.Application__c in : filteredApplicationIds';

            for(Checklist_Item__c checkListItem : database.query( query )){
                if( !groupedItemsToReturn.containsKey( checkListItem.CheckList__r.Application__c ))
                    groupedItemsToReturn.put( checkListItem.CheckList__r.Application__c, new List<CheckList_Item__c>{ checkListItem } );
                else
                    groupedItemsToReturn.get( checkListItem.CheckList__r.Application__c ).add( checkListItem );
            }

        }

        return groupedItemsToReturn;
    }

    public static List<Checklist_Item__c> processApplicationCheckListItems( Map<Id, List<String>> filteredApplicationIdsToChangedFieldsList,
                                                                            Map<Id, List<Checklist_Item__c>> applicationIdsToMatchingCheckListItems,
                                                                            Map<String, ApplicationCreditUserChecklistType__c> settingsMap,
                                                                            Map<Id, Application__c> filteredApplicationNewMap ){
        List<Checklist_Item__c> checklistItemsToUpdate;

        if(filteredApplicationIdsToChangedFieldsList == null || filteredApplicationIdsToChangedFieldsList.isEmpty() ||
            applicationIdsToMatchingCheckListItems == null || applicationIdsToMatchingCheckListItems.isEmpty() ||
            settingsMap == null || settingsMap.isEmpty() ){
                return checklistItemsToUpdate;
            }

        checklistItemsToUpdate = new List<Checklist_Item__c>();

        for(Id applicationId : applicationIdsToMatchingCheckListItems.keyset()){
            for(Checklist_Item__c item : applicationIdsToMatchingCheckListItems.get(applicationId)){

                if(applicationIdsToMatchingCheckListItems.get(applicationId).isEmpty())
                    continue;
                Boolean fieldUpdated = false;
                for(String field : filteredApplicationIdsToChangedFieldsList.get(applicationId)){
                    if(settingsMap.containsKey(field)  && settingsMap.get(field).Checklist_For_Department_Value__c.equalsIgnoreCase(  item.For_Department__c ) ){
                        item.put( 'Assigned_Department_User__c', filteredApplicationNewMap.get(applicationId).get(field));
                        fieldUpdated = true;
                    }
                }
                if(fieldUpdated)
                    checklistItemsToUpdate.add(item);
            }
        }
        return checklistItemsToUpdate;
    }

    public static void updateCheckListItems(List<Checklist_Item__c> itemsToUpdate, Map<Id, Application__c> newMapToAddErrors ){
        try{
            update itemsToUpdate;
        }
        catch (DMLException dex){

            for( Integer i = 0; i < dex.getNumDml(); i++ )
            {
                Id applicationItemId = itemsToUpdate[i].Checklist__r.Application__c;
                newMapToAddErrors.get( applicationItemId ).addError( dex.getDmlMessage(i) );
            }
        }

    }

    public static void processApplications( List<Application__c> incomingApplications, Map<Id, Application__c> oldMap){
        //Get a hold of the custom settings
        Map<String, ApplicationCreditUserChecklistType__c> customSettingNameToCustomSetting = ApplicationCreditUserChecklistType__c.getAll();

        Set<String> userFieldNames = customSettingNameToCustomSetting.keySet();

        Map<Id, List<String>> filteredApps = filterApplicationsThatHaveChangedUsers( incomingApplications, oldMap, userFieldNames );

        if( filteredApps != null && !filteredApps.isEmpty() )
        {
            Map<Id, Application__c> newMap = new Map<Id, Application__c>( incomingApplications);

            Map<Id, Application__c> filteredApplicationNewMap = new Map<Id, Application__c>();

            for(Id filteredAppId : filteredApps.keySet() )
                filteredApplicationNewMap.put( filteredAppId, newMap.get( filteredAppId ));

            List<String> deptValues = new List<String>();

            for( ApplicationCreditUserChecklistType__c setting : customSettingNameToCustomSetting.values() ){
                String deptValueInSetting = setting.Checklist_For_Department_Value__c;

                if( String.IsNotBlank(deptValueInSetting) )
                    deptValues.add( deptValueInSetting );
            }

            if( !deptValues.isEmpty() )
            {
                Map<Id, List<Checklist_Item__c>> checkListItems = findChecklistItems(filteredApps.keySet(), customSettingNameToCustomSetting.keySet(), deptValues );

                List<Checklist_Item__c> itemsToUpdate = processApplicationCheckListItems( filteredApps,
                                                                                          checkListItems,
                                                                                          customSettingNameToCustomSetting,
                                                                                          filteredApplicationNewMap );

                if( itemsToUpdate != null && !itemsToUpdate.isempty() )
                    updateCheckListItems(itemsToUpdate, newMap);
            }
        }
    }

    /*
    private void clearprimaryApplicationAccountsfield(boolean isDelete)
    {
        List<Application__c> applicationsToBeUpdated                = new List<Application__c>();
        Map<Id, Id>          applicationIdToNonprimaryAppAccountIdMap   = new Map<Id, Id>();
        for(Application_Account_Role__c appAcc : this.OldappAccs){
            if(isDelete && appAcc.primary__c)
            {
                applicationIdToNonprimaryAppAccountIdMap.put(appAcc.Application__c, appAcc.Account__c);
            }
        }

        for(Application__c app : [select Id, Applications_Accounts__c from Application__c where Id IN :applicationIdToNonprimaryAppAccountIdMap.keyset()])
        {
            if(applicationIdToNonprimaryAppAccountIdMap.keyset().contains(app.Id) && app.Applications_Accounts__c == applicationIdToNonprimaryAppAccountIdMap.get(app.Id))
                applicationsToBeUpdated.add(new Application__c(Id = app.Id, Applications_Accounts__c = null));
        }
        Database.SaveResult[] srList  = Database.update(applicationsToBeUpdated,false);      // allow for partial successes
        for (Integer i = 0; i < srList.size(); i++) {
            if (!srList[i].isSuccess()) {
                String err  = srList[i].getErrors()[0].getMessage();
                Id ErroredappAccId = applicationIdToNonprimaryAppAccountIdMap.get(applicationsToBeUpdated[i].id);
                this.mapNewappAccs.get(ErroredappAccId).addError(err);
            }
        }
    }
    */
}