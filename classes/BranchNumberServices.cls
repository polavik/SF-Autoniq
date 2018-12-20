public with sharing class BranchNumberServices
{
    public static String getBranchNameFromBranchNumber(Integer branchNumber)
    {
    	for(BranchNumber__c bn : BranchNumber__c.getAll().values())
    	{
    		if(bn.Branch_Number__c == branchNumber)
    		{
    			return bn.Name;
    		}
    	}
    	return 'Corporate';
    }
    public static String getBranchNameFromBranchNumber(String branchNumber)
    {
    	if(String.isBlank(branchNumber))
    	{
    		return 'Corporate';
    	}
    	else
    	{
    		return getBranchNameFromBranchNumber(Integer.valueOf(branchNumber));
    	}
    }
}