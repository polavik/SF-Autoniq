//IAA Remarketing
public without sharing class BranchController {

    public static boolean isRunningFuture = false;
    
//================================================================================================
    public static list<ZipCode__c> LookupBranchByZip(set<string> zips){
    
        system.debug('LookupZips parameter:' + zips);
                
        list<ZipCode__c> zipcodes = [Select Name, 
                                        Branch__r.PrimaryZipCode__c, 
                                        Branch__r.PrimaryStreet__c, 
                                        Branch__r.PrimaryState__c, 
                                        Branch__r.PrimaryCountry__c, 
                                        Branch__r.PrimaryCity__c, 
                                        Branch__r.Name, 
                                        Branch__r.Id, 
                                        Branch__c 
                                    From ZipCode__c 
                                    Where Name IN : zips];

        system.debug('LookupZips zipcodes:' + zipcodes);        
        return zipcodes;
        
    } 
//================================================================================================
    public static list<Branch__c> LookupOwnerByBranch(set<id> branchIds){
        
        //Pull all TeamMembers from Branch
        list<Branch__c> branches = 
        [
            Select  Id, Name, BranchNumber__c, 
                    PrimaryZipCode__c,
                    PrimaryStreet__c, 
                    PrimaryCity__c, 
                    PrimaryState__c, 
                    PrimaryCountry__c,
                
                (   Select btm.Id, btm.TeamMember__c, btm.TeamMember__r.Id, btm.Default__c, btm.Branch__r.Id 
                    From BranchTeamMembers__r btm
                    //Where Default__c = : true
                )
                
            From Branch__c 
            Where Id IN : branchIds
        ];      
        
        return branches;
    }
//================================================================================================
    @future(callout=true)
    public static void CalculateDistance(id branchId, id objectId, string objectType){
    
        system.debug('CALCDISTANCE FUTURE CALL STARTED');
         
           
        Branch__c branch;
       try{

       
       branch = [Select  Id, Name, BranchNumber__c, 
                                    PrimaryZipCode__c,
                                    PrimaryStreet__c, 
                                    PrimaryCity__c, 
                                    PrimaryState__c, 
                                    PrimaryCountry__c
                            From Branch__c
                            Where Id =: branchId ];
        }catch(exception ex){
            branch = null;
        }
              
        
        

        string  source = BranchAddress(branch);

        string destination;
        Account acct;
        Lead ld;
        
        system.debug('OBJECT TYPE IS:' + objectType);
       


        if(objectType == 'Account'){
            
            acct = [Select Id, DistanceFromBranch__c,
                            BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
                        From Account 
                        Where Id = : objectId Limit 1];
        
            destination = AccountAddress(acct);
            
            system.debug('Account Destination Address:' + destination);
            
        }else if(objectType == 'Lead'){
            
            /*
            ld = [Select Id, DistanceFromBranch__c,
                        Street, City, State, PostalCode
                        From Lead
                        Where Id =: objectId
                        ];
            */
        } 

        
              
        
        system.debug('GM Destination:' + destination);
            
        system.debug('START GOOGLE CALL FROM BRANCH CLASS');
        
        GoogleMaps gm = new GoogleMaps(source, destination);
        
        system.debug('END GOOGLE CALL FROM BRANCH CLASS');
    
        if(objectType == 'Account'){
            //acct.Description = 'GOOLE MAPS DISTANCE FROM BRANCH STATUS: ' + gm.status;    
            acct.GoogleStatus__c = 'GOOLE MAPS DISTANCE FROM BRANCH STATUS: ' + gm.status;
            
            if(gm.status == 'OVER_QUERY_LIMIT'){
                acct.DistanceFromBranch__c = 0; 
            }else{
                acct.DistanceFromBranch__c = gm.distance;   
            }
                
            isRunningFuture = true;
            
            system.debug('Acct Google Status:' + acct.GoogleStatus__c);
            
            try{
                update acct;    
            }catch(system.exception e){
                system.debug('GM Update Exception:' + e);
            }
            
        
        }else if(objectType == 'Lead'){
            
        }
    }
//================================================================================================
    public static string BranchAddress(Branch__c branch){
        
        string BranchAddress;
        
        system.debug('BranchAddress Before:' + branch);
        
        BranchAddress = EncodingUtil.urlEncode( 
                + CheckForNull(branch.PrimaryStreet__c) + ' '
                + CheckForNull(branch.PrimaryCity__c) + ', '
                + CheckForNull(branch.PrimaryState__c) + ' '
                + CheckForNull(branch.PrimaryZipCode__c) + ' '
                + CheckForNull(branch.PrimaryCountry__c),
                'UTF-8');
        
        system.debug('BranchAddress After:' + BranchAddress);
        
        return BranchAddress;
    }
//================================================================================================
    public static string AccountAddress(Account acct){
        
        string AccountAddress;
        
        system.debug('AccountAddress Before:' + acct);
        
        AccountAddress = EncodingUtil.urlEncode( 
                + CheckForNull(acct.BillingStreet) + ' '
                + CheckForNull(acct.BillingCity) + ', '
                + CheckForNull(acct.BillingState) + ' '
                + CheckForNull(acct.BillingPostalCode) + ' '
                + CheckForNull(acct.BillingCountry),
                'UTF-8');
        
        system.debug('AccountAddress After:' + AccountAddress);
        
        return AccountAddress;
        
    }
//================================================================================================  
    public static string LeadAddress(Lead ld){
        
        string LeadAddress;
        
        system.debug('LeadAddress Before:' + ld);
        
        LeadAddress= EncodingUtil.urlEncode( 
                + CheckForNull(ld.Street) + ' '
                + CheckForNull(ld.City) + ', '
                + CheckForNull(ld.State) + ' '
                + CheckForNull(ld.PostalCode) + ' '
                + CheckForNull(ld.Country),
                'UTF-8');
        
        system.debug('LeadAddress After:' + LeadAddress);
        
        return LeadAddress;
    }
//================================================================================================
    public static string CheckForNull(string Value){
        
        //THIS REMOVES THE WORD 'NULL' TO FIX ISSUES WHEN DOING THE CALL OUT TO GOOGLEe
        string ReturnValue = Value;
        
        if(ReturnValue == 'null' || ReturnValue == null){
            ReturnValue = '';
        }
        
        return ReturnValue;
        
    }
//================================================================================================
    public static BranchTeamMember__c CreateNewTeamMember(string userId, string branchId){
        
        BranchTeamMember__c newBTM = new BranchTeamMember__c();
        newBTM.Branch__c = branchId;
        newBTM.Default__c = true;
        newBTM.TeamMember__c = userId;
        insert newBTM;
        return newBTM;  
                
    }
//================================================================================================
}