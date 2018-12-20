public with sharing class CaseEscalationList {
    
    public ApexPages.StandardSetController setCon {get; set;}
    public List<Case_Escalation__c> records {get; set;}
    //public List<Case_Escalation__c> Totalrecords = new List<Case_Escalation__c>() ;   
    public List<Case_Escalation__c> Totalrecords  {get; set;} 
    
    public String assignedToFilter {get; set;}
    public String statusFilter {get; set;}
    
    public List<CustomSelectOption> assignedToOptions {get; set;}
    public List<CustomSelectOption> statusOptions {get; set;}
    
    public String sortBy {get; set;}
    public String currentSort {get; set;}
    
    public Integer page {get; set;}
    
    public CaseEscalationList(ApexPages.StandardSetController standardController)
    {
        statusOptions = new List<CustomSelectOption>();
        setStatusOptions();
        
        assignedToOptions = new List<CustomSelectOption>();
        AssignToOptionSetter os = new AssignToOptionSetter();
        os.setOptions(assignedToOptions);
        
        String finalQuery = compileQuery();
        
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(finalQuery));
        String pageSize = ApexPages.currentPage().getParameters().get('pageSize');
        if (pageSize != null && !pageSize.equals(''))
        {
            System.debug(pageSize);
            setCon.setPageSize(Integer.valueOf(pageSize));

        }
        else
        {
            setCon.setPageSize(15);
        }
        setPageNumber();
        records = (List<Case_Escalation__c>) setCon.getRecords();
        //Totalrecords.addall(records);
        //for (List<Case_Escalation__c> CERecord :Database.query(finalQuery)  ) 
        
        //Totalrecords = Database.query(finalQuery);
    }
    
    public void setStatusOptions()
    {
        String allEscalationsValue = getEverythingFilter();
        String openEscalationsValue = 'Status__c!=\'Closed\'';
        String closedEscalationsValue = 'Status__c=\'Closed\'';
        statusOptions.add(new CustomSelectOption(allEscalationsValue, 'All Escalations'));
        statusOptions.add(new CustomSelectOption(openEscalationsValue,'Open Escalations'));
        statusOptions.add(new CustomSelectOption(closedEscalationsValue,'Closed Escalations'));
    }
    
    // Need to run for a bit with sharing permissions turned off to query seller permissions
    public without sharing class AssignToOptionSetter
    {
        public void setOptions(List<CustomSelectOption> assignedToOptions)
        {
            List<ID> permittedAccountIds = new List<ID>();
            for (Seller_Permission__c sp : 
                [SELECT Account__c
                 FROM Seller_Permission__c 
                 WHERE User__c = :UserInfo.getUserId()])
            {
                permittedAccountIds.add(sp.Account__c);
            }
            
            assignedToOptions.add(new CustomSelectOption(getEverythingFilter(), 'All'));
            
            Set<ID> dupeStopper = new Set<ID>();
            for (Seller_Permission__c sp :
                [SELECT User__r.Name, User__r.Id
                 FROM Seller_Permission__c
                 WHERE Account__c IN :permittedAccountIds
                 ORDER BY User__r.Name])
            {
                if (!dupeStopper.contains(sp.User__r.Id))
                {
                    String filterString = 'Assigned_To__c=\'' + sp.User__r.Id + '\'';
                    filterString = filterString;
                    assignedToOptions.add(new CustomSelectOption(filterString, sp.User__r.name));
                    
                    dupeStopper.add(sp.User__r.Id);
                }
            }
        }
    }
    
    public String compileQuery()
    {
        String query = 
            'SELECT Name, Account_Name__c, Location__c, VIN__c, Case_Reason__c, CreatedDate, Escalation_Resolution__c, Resolution_Details__c, Concession_Amount__c, Assigned_To_Name__c ,Assigned_To__c, Assigned_To__r.Name, Approver__r.Name, Resolution_Date__c, ' + 
            ' Case_Type__c, Date_Time_Opened__c, Private_Label__c,Buyer_Dealer_Code__c,YMMS__c, Case__r.ClosedDate, Assigned_Date_Time__c, Approved_Date_Time__c, Approver_Notified_Date_Time__c, Grounding_Dealership__c, Days_Escalated__c, Status__c, ' +
            'Consignee__c, Segment__c ' +
            'FROM Case_Escalation__c ';
        
        assignedToFilter = ApexPages.currentPage().getParameters().get('assignedTo');
        statusFilter = ApexPages.currentPage().getParameters().get('status');       
        
        if (assignedToFilter == null)
        {
            assignedToFilter = getEverythingFilter();
        }
        else if (!verifyValidOption(assignedToFilter, assignedToOptions))
        {
            assignedToFilter = getNothingFilter();
        }
        
        if (statusFilter == null)
        {
            statusFilter = 'Status__c!=\'Closed\'';
        }
        else if (!verifyValidOption(statusFilter, statusOptions))
        {
            statusFilter = getNothingFilter();
        }
        
        String selectCriteria = ' WHERE ' + assignedToFilter + ' AND ' + statusFilter;
        
        sortBy = ApexPages.currentPage().getParameters().get('sortBy');
        currentSort = ApexPages.currentPage().getParameters().get('currentSort');
        String sortCriteria = ' ORDER BY ' + getComputedSort();
        System.debug(query + selectCriteria + sortCriteria);
        return query + selectCriteria + sortCriteria;
    }
    
    public boolean verifyValidOption(String selectedOption, List<CustomSelectOption> optionList)
    {
        for (CustomSelectOption option : optionList)
        {
            if (option.value.equals(selectedOption))
            {
                 return true;
            }
        }
        return false;
    }
    
    public static String getEverythingFilter()
    {
        return 'Id!=null';
    }
    
    public static String getNothingFilter()
    {
        return 'Id=null';
    }
    
    public String getComputedSort()
    {
        if (sortBy == null || sortBy.equals(''))
        {
            return 'CreatedDate DESC';
        }
        else if (currentSort == null || currentSort.equals(''))
        {
            return sortBy + ' ASC';
        }
        else
        {
            List<String> currentSortTokens = currentSort.split(' ');
            if (!sortBy.equals(currentSortTokens.get(0)))
            {
                return sortBy + ' ASC';
            }
            else if (!currentSortTokens.get(1).equals('ASC'))
            {
                return sortBy + ' ASC';
            }
            else
            {
                return sortBy + ' DESC';
            }
        }
    }
    
    public void setPageNumber()
    {
        String pageParam = ApexPages.currentPage().getParameters().get('page');
        if (pageParam == null)
        {
            //do nothing
        }
        else if (pageParam.equals('first'))
        {
            setCon.first();
        }
        else if (pageParam.equals('last'))
        {
            setCon.last();
        }
        else //Assume pageParam is a number
        {
            setCon.setPageNumber(Integer.valueOf(pageParam));
        }
    }
    
    public class CustomSelectOption
    {
        public String value {get; set;}
        public String label {get; set;}
        
        public CustomSelectOption(String value, String label)
        {
            this.value = value;
            this.label = label;
        }
    }
    
    // There is a bug where MS Excel pages won't download properly in IE over HTTPS
    // Therefore, we need to link to the Excel printout of this page using HTTP
    public String getXlsBaseUrl()
    {
        return 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/escalations';
    }
}