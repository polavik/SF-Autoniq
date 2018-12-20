public class Utils {

     public static boolean GetFLS()
     {
        boolean blnFLSOverride;
        if(Test.isRunningTest())
        {
            blnFLSOverride = true;
        }   
        else
        {
            blnFLSOverride = !(FLS_Enforce_Switch__c.getInstance().Enforce_FLS__c); 
        }
        return blnFLSOverride;
     }
    
    // Send Email Notification when user not have FLS Create/Update Access. 
    // strUpdate = FLS_CREATE or FLS_UPDATE 
    // strComponentsName = Class name of FLS issue e.g. CLASS:Utils 
    // ListFields = Object Name + Field name of FLS issue e.g. Account.forseva1__Credit_Policy__c
    public static void SendEmailforFLS(String strUpdate, String strComponentsName, Set<String> ListFields) {
        
        System.debug('>>>> strComponentsName:'+strComponentsName);
        System.debug('>>>> ListFields:'+ListFields);
    
        String strSubject;
        String strMsg;
        String strDetail;
        Boolean AddErrorLog = false;
        Boolean SendEmailLog = false;
        List<String> SendEmailLogTo = new List<String>();
        Boolean blnFLSOverride = GetFLS();
        if(Test.isRunningTest())
        {   
            AddErrorLog = true ;
            SendEmailLog = true ;
            SendEmailLogTo = new String[] {'test.test@openlane.com'};
                
        }
        else
        {
            AddErrorLog = Error_Email_Notification__c.getInstance().Enable_Log__c ;
            SendEmailLog = Error_Email_Notification__c.getInstance().Enable__c ;
            if(Error_Email_Notification__c.getInstance().Email__c!=null)
            {
                List<String> ListEmails = Error_Email_Notification__c.getInstance().Email__c.split(',');
                SendEmailLogTo = ListEmails;
            }
            else
            {
                SendEmailLogTo = new String[] {'test.test@openlane.com'};
            }
        }   
        if(strUpdate.equalsIgnoreCase('FLS_UPDATE'))
        {
            strDetail = 'FLS:Update Access Denied';
        }
        else if(strUpdate.equalsIgnoreCase('FLS_CREATE'))
        {
             strDetail = 'FLS:Create Access Denied';
        }
        else 
        {
            strDetail = 'FLS:Access Denied For Field' ;
        }
            
        if(AddErrorLog)
        {
            List<Security_Errors__c> ListError = new List<Security_Errors__c>();
            
                
            for(String strField : ListFields )
            {
                Security_Errors__c obj = new Security_Errors__c();
                if (Schema.sObjectType.Security_Errors__c.fields.Component__c.isCreateable() || blnFLSOverride)
                 {
                     obj.Component__c = strComponentsName;
                 }              
                 if (Schema.sObjectType.Security_Errors__c.fields.ProfileId__c.isCreateable() || blnFLSOverride)
                 {
                     obj.ProfileId__c = Userinfo.getProfileId() ;
                 }
                 if (Schema.sObjectType.Security_Errors__c.fields.Related_To__c.isCreateable() || blnFLSOverride)
                 {
                     obj.Related_To__c = strField;
                 }
                 if (Schema.sObjectType.Security_Errors__c.fields.UserId__c.isCreateable() || blnFLSOverride)
                 {
                     obj.UserId__c = Userinfo.getUserId();
                 }
                 if (Schema.sObjectType.Security_Errors__c.fields.Details__c.isCreateable() || blnFLSOverride)
                 {
                     obj.Details__c = strDetail;
                 }
                 if (Schema.sObjectType.Security_Errors__c.fields.Username__c.isCreateable() || blnFLSOverride)
                 {
                     obj.Username__c = Userinfo.getUserName();
                 }
                 ListError.Add(obj);               
            }
            Insert ListError;
        }
        
        if(SendEmailLog)
        {           
            strSubject = 'Warning :'+ strDetail;
            
            for(String strField : ListFields )
            {
                strDetail += '<br/>' + strField;
            }
            String DisplayName ='' ;
            String Summary='';
            if(SendEmailLogTo!=null || SendEmailLogTo.size()>0)
            {       
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                String[] toAddresses = SendEmailLogTo;
                mail.setToAddresses(toAddresses);   
                if(Sandbox.isSandbox())
                {
                    DisplayName = '*** Salesforce Sandbox Notification';                    
                }
                else
                {
                    DisplayName = Userinfo.getOrganizationName() + 'Salesforce Notification';
                }
                mail.setSenderDisplayName(DisplayName);
                mail.setSubject(strSubject); 
                mail.setBccSender(false);
                mail.setUseSignature(false);
                if(Sandbox.isSandbox())
                {
                Summary+='<br/> *** This email is sent from Sandbox.';
                }
                Summary+='<br/><br/> Organization Id: ' + Userinfo.getOrganizationId();
                Summary+='<br/> Organization Name: ' + Userinfo.getOrganizationName() +' ('+ URL.getSalesforceBaseUrl().toExternalForm() +')';
                Summary+='<br/> User: ' + Userinfo.getUserId() + ' : ' +Userinfo.getUserName();
                Summary+='<br/> Prodile Id : ' + Userinfo.getProfileId() ;
                Summary+='<br/> Components : ' + strComponentsName ;
                Summary+='<br/><br/> -------Details----------- ';
                Summary+='<br/>'+ strDetail ;           
                Summary+='<br/> ---------------------------- ';
                
                mail.sethtmlBody(Summary);
                if(!Test.isRunningTest())
                { 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
        }       
        //ListFields.clear();
        
    }




    // Story B-42786
    public static boolean IsUserExist(String strPropertyId,String strUserId) {
    
        String strCurrentUserId = strUserId;
        boolean IsUserIdFound = false;
        if (properties == null) {
            fetchProperties();
        }
        
        String strUserIdList = properties.get(strPropertyId);
        List<String> ListUserIds = new List<String>();
            
            if(strUserIdList != null && strUserIdList !='')
            {
                ListUserIds = strUserIdList.split(',');
            }
            
        
        for(String strUser :ListUserIds)
        {             
             if(strUser == strCurrentUserId)
             {
                 IsUserIdFound = true;
             }
         }
         
        return IsUserIdFound ;
    }
    
    // Adesa.comDetail to Account Id mapping 
    public static Map<Id,Id> getAccountIdByAdesaComDetailId(Set<Id> AdesaComDetailIds) {
        Map<Id,Id> AdesaComDetailId_To_AccountId = new Map<Id,Id>();
        if(AdesaComDetailIds.size()>0)
        {   
            List<Adesa_com_Detail__c> ListAdesaComDetail = new List<Adesa_com_Detail__c>();     
            ListAdesaComDetail = [ select id, Account__c from Adesa_com_Detail__c where Id in :AdesaComDetailIds];
            
            For (Adesa_com_Detail__c objAdesaComDetail: ListAdesaComDetail )
            {
                AdesaComDetailId_To_AccountId.put(objAdesaComDetail.Id,objAdesaComDetail.Account__c);
            }
        }
        return AdesaComDetailId_To_AccountId;
    }
    
    //(PPM#97274) for Task Records Migration (On 14-Jan-2015 By djpatel - ADESA Canada Salesforce Team)
        public static String strIsMigrationRuning = null;
        public static boolean getIsMigrationRuning(String OrgPropertyId) {
        
    
       
       
            if (strIsMigrationRuning == null) {
              List<Property__c>  ListPro = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c =:OrgPropertyId ];    
              if(ListPro.size()>0)
              {
                  Property__c  ObjPro = ListPro[0];    
                  if(ObjPro !=null)
                  {
                      strIsMigrationRuning = ObjPro.Property_Value__c;
                  }
              }           
            }
       

            if(strIsMigrationRuning!=null && (strIsMigrationRuning.equalsIgnoreCase('YES') || strIsMigrationRuning.equalsIgnoreCase('TRUE'))){
                return true;
            }
            else{
                return false;
            }
        }
    
    //djpatel on 17-Oct-2014 (B-31714) for get Default Migrated Case Owner
        public static String strDefaultLeadId = null;
        public static String getMigratedTaskDefaultLeadId(String OrgPropertyId) {
            if (strDefaultLeadId == null) {
              Property__c  ObjPro = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c =:OrgPropertyId LIMIT 1];    
              if(ObjPro !=null)
              {
                  strDefaultLeadId = ObjPro.Property_Value__c;
              }         
            }
            return strDefaultLeadId;
        }
        
    //djpatel on 16-Oct-2014 (B-31714) for get Dummy Case Id
    public static String strDummyCaseId= null;
    public static String getDummyCaseId(String OrgPropertyId) {
        if (strDummyCaseId== null) {
          Property__c  ObjPro = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c =:OrgPropertyId LIMIT 1];    
          if(ObjPro !=null)
          {
              strDummyCaseId = ObjPro.Property_Value__c;
          }         
        }
        return strDummyCaseId;
    }
    //djpatel on 16-Oct-2014 (B-31714) for get Default Migrated Case Owner
    public static String strOwnerUserName= null;
    public static String getMigratedCaseDefaultOwnerUserName(String OrgPropertyId) {
        if (strOwnerUserName == null) {
          Property__c  ObjPro = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c =:OrgPropertyId LIMIT 1];    
          if(ObjPro !=null)
          {
              strOwnerUserName = ObjPro.Property_Value__c;
          }         
        }
        return strOwnerUserName;
    }
    
    public static Map<String, String> properties = null;
    public static Map<String, Map<String, String>> picklistMappings = null;
    public static Map<String, Map<String, String>> recordTypeIdMap = null;    
    //public static Boolean stringFound {get;set;} 
    
    //djpatel on 08-Oct-2014 (B-28960) for get Mi Service Endpoint URL
    public static String strMiServiceEndpointUrl= null;
    public static String getMiServiceEndpointUrl(String PropertyId) {
        if (strMiServiceEndpointUrl== null) {
          Property__c  ObjPro = [select Property_Id__c, Property_Value_Encrypted__c from Property__c where Property_Id__c =:PropertyId LIMIT 1];    
          if(ObjPro !=null)
          {
              strMiServiceEndpointUrl = ObjPro.Property_Value_Encrypted__c;
          }         
        }
        return strMiServiceEndpointUrl;
    }
    
    //djpatel on 08-Oct-2014 (B-28960) for get OrgType
    public static String strOrgType= null;
    public static String getOrganizationType(String OrgPropertyId) {
        if (strOrgType == null) {
          Property__c  ObjPro = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c =:OrgPropertyId LIMIT 1];    
          if(ObjPro !=null)
          {
              strOrgType = ObjPro .Property_Value__c;
          }         
        }
        return strOrgType;
    }
    
    //djpatel on 09-Oct-2014 (B-28960) for get OrgType
    public static String strProdNode= null;
    public static String getProductionNode(String PropertyId) {
        if (strProdNode== null) {
          Property__c  ObjPro = [select Property_Id__c, Property_Value__c from Property__c where Property_Id__c =:PropertyId LIMIT 1];    
          if(ObjPro !=null)
          {
              strProdNode = ObjPro.Property_Value__c;
          }         
        }
        return strProdNode;
    }
    
    //djpatel on 25-Sep-2014 ( B-31398 )
    public static Profile ObjProfile = null ;
    public static Profile getLoginUserProfile() {

        //System.debug('>>> ObjProfile:'+ObjProfile);

        if (ObjProfile == null) {
            ObjProfile = [SELECT Name FROM Profile where id=:UserInfo.getProfileId() LIMIT 1];             
        }
        
        //System.debug('>>> ObjProfile:'+ObjProfile);
        
        return ObjProfile;
    }
    
    public static boolean IsCreditAccountProfile(String strPropertyId) {
        String strCurrentUserProfileName = Utils.getLoginUserProfile().Name.toUpperCase().trim();
        
        //System.debug('>>> strCurrentUserProfileName :'+strCurrentUserProfileName );
        
        //System.debug('>>> properties :'+properties );
        
        boolean IsProfileFound = false;
        if (properties == null) {
            fetchProperties();
        }
        
        //System.debug('>>> properties :'+properties );
        //System.debug('>>> strPropertyId:'+strPropertyId);
        
            String strCreditAccountCreatorList = properties.get(strPropertyId);
            
            //System.debug('>>> strCreditAccountCreatorList :'+strCreditAccountCreatorList );
            
            List<String> ListAccountCreatorProfile = new List<String>();
            
            if(strCreditAccountCreatorList!= null && strCreditAccountCreatorList!='')
            {
                ListAccountCreatorProfile = strCreditAccountCreatorList.toUpperCase().split(',');
            }
            else
            {
                if(Test.isRunningTest())
                {
                    ListAccountCreatorProfile.add(strCurrentUserProfileName);
                }
            }
            
            
            //System.debug('>>> ListAccountCreatorProfile :'+ListAccountCreatorProfile );
            
            for(String strProfileName :ListAccountCreatorProfile)
            {
                if(strProfileName.trim() == strCurrentUserProfileName)
                {
                    IsProfileFound = true;
                }
            }
                
        //System.debug('>>> IsProfileFound :'+IsProfileFound );
        
        return IsProfileFound ;
    }
    
    public static boolean IsIntegratorProfile(String strPropertyId) {
    
        //System.debug('>>> strPropertyId:'+strPropertyId);
   
        String strCurrentUserProfileName = Utils.getLoginUserProfile().Name.toUpperCase().trim();
        
        //System.debug('>>> strCurrentUserProfileName :'+strCurrentUserProfileName );

        //System.debug('>>> properties :'+properties );
                
        boolean IsIntProfileFound = false;
        if (properties == null) {
            fetchProperties();
        }
        
        //System.debug('>>> properties :'+properties );
        
        String strIntAccountCreatorList = properties.get(strPropertyId);
        
        //System.debug('>>> strIntAccountCreatorList :'+strIntAccountCreatorList );
        
        
        List<String> ListAccountCreatorProfile = new List<String>();
            
            if(strIntAccountCreatorList != null && strIntAccountCreatorList !='')
            {
                ListAccountCreatorProfile = strIntAccountCreatorList.toUpperCase().split(',');
            }
            else
            {
                if(Test.isRunningTest())
                {
                    ListAccountCreatorProfile.add(strCurrentUserProfileName );
                }
            }
        
                
        
        
        //System.debug('>>> ListAccountCreatorProfile :'+ListAccountCreatorProfile );
        
        for(String strProfileName :ListAccountCreatorProfile)
        {             
             if(strProfileName.trim() == strCurrentUserProfileName)
             {
                 IsIntProfileFound = true;
             }
         }
         
        //System.debug('>>> IsIntProfileFound :'+IsIntProfileFound  );
                
        return IsIntProfileFound ;
    }
    //
    public static DateTime getDateTime(Date d) {
        if (d == null) {
            return null;
        }
        return DateTime.newInstance(d, Time.newInstance(0,0,0,0));
    }
    
    public static String format(DateTime dt, String format, String timezone) {
        if (dt == null) {
            return '';
        } else {
            return dt.format(format, timezone);
        }
    }
    
    public static String format(Double d, Integer scale) {
        if (d == null) {
            return null;
        } else {
            return Decimal.valueOf(d).setScale(scale).toPlainString();
        }
    }
    
    public static String format(Decimal d, Integer scale) {
        if (d == null) {
            return null;
        } else {
            Decimal tmp = d;
            return d.setScale(scale).toPlainString();
        }
    }
    
    public static String reverse(String input)
    {
        String out = '';
        for (Integer i = input.length() - 1; i >= 0; i--)
        {
            out = out + input.substring(i, i+1);
        }
        return out;
    }
    
 
    public static boolean stringExistInList(String inputString, List<String> sList)
    {
       if (sList == null) {
          return false;
       } else{
       
              for(String str: sList)
              {
                   if(inputString == str)
                 {
                   return true;
                 }
              }
              return false;
        }
    }
   
    public static String getPicklistMapping(String objectType, String fieldName, String picklistValue)
    {
        if (picklistMappings == null)
        {
            picklistMappings = new Map<String, Map<String, String>>();
        }
        
        Map<String, String> subMap = pickListMappings.get(objectType + ':' + fieldName);
        if (subMap == null)
        {
            fetchPicklistMappings(objectType, fieldName);
            subMap = pickListMappings.get(objectType + ':' + fieldName);
        }
        
        return subMap.get(picklistValue);
    }
    
    private static void fetchPicklistMappings(String objectType, String fieldName)
    {
        
        List<Picklist_Mapping__c> mappings = [
            SELECT Name, Mapping__c
            FROM Picklist_Mapping__c 
            WHERE Object_Type__c = :objectType
            AND Field_Name__c = :fieldName
        ];
        
        Map<String, String> subMap = new Map<String, String>();
        for (Picklist_Mapping__c mapping : mappings)
        {
            subMap.put(mapping.name, mapping.Mapping__c);
        }

        picklistMappings.put(objectType + ':' + fieldName, subMap);
    }
    
    public static String getRecordTypeId(String objectType, String recordTypeName)
    {
            if (recordTypeIdMap == null)
            {
                recordTypeIdMap = new Map<String, Map<String, String>>();
            }
            Map<String, String> subMap = recordTypeIdMap.get(objectType);
            if (subMap == null)
            {
                fetchRecordTypes(objectType);
                subMap = recordTypeIdMap.get(objectType);
            }
            
            return subMap.get(recordTypeName);
    }

    public static void sendSingleMail(String Description)
    {
        
//start
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {'sshehzad@openlane.com'}; 
        mail.setToAddresses(toAddresses);
        //mail.setReplyTo(toAddresses);
        mail.setSenderDisplayName('Apex Debug');
        mail.setSubject('From Apex Trigger'); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody(Description);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

//end
        
    }    
    private static void fetchRecordTypes(String objectType)
    {
        
        List<RecordType> recordTypes = [
            SELECT Id, Name
            FROM RecordType 
            WHERE SObjectType = :objectType
        ];
        
        Map<String, String> subMap = new Map<String, String>();
        for (RecordType rt : recordTypes)
        {
            subMap.put(rt.Name, rt.Id);
        }

        recordTypeIdMap.put(objectType, subMap);
    }
    
    public static String getProperty(String propertyId) {
        if (properties == null) {
            fetchProperties();
        }
        
        return properties.get(propertyId);
    }
    
    
    private static void fetchProperties() {
        
        properties = new Map<String, String>();
        
        List<Property__c> propList = 
            [select Property_Id__c, Property_Value__c from Property__c];
            
        for (Property__c prop : propList) {
            properties.put(prop.Property_Id__c, prop.Property_Value__c);
        }
    }
    
    public interface Comparable
    {
        Integer compare(Object o2);
    }
    
    // public static List<Object> mergeSort(List<Object> lst, Comparator c) {}
    
    public static List<Object> mergeLists(List<Comparable> lst1, List<Comparable> lst2)
    {
        Integer lst1Iter = 0;
        Integer lst2Iter = 0;
        List<Object> results = new List<Object>();
        
        while (lst1Iter < lst1.size() || lst2Iter < lst2.size())
        {
            if (lst1Iter == lst1.size())
            {
                results.add(lst2.get(lst2Iter++));
            }
            else if (lst2Iter == lst2.size())
            {
                results.add(lst1.get(lst1Iter++));
            }
            else if (lst1.get(lst1Iter).compare(lst2.get(lst2Iter)) < 0)
            {
                results.add(lst1.get(lst1Iter++));
            }
            else
            {
                results.add(lst2.get(lst2Iter++));
            }
        }
        return results;
    }
    
    public static String joinList(List<Object> lst, String delim) {
        String str = '';
        
        if (lst.size() == 0) { return str; }
        
        str = str  + lst.get(0);
        
        for (Integer i = 1; i < lst.size(); i++) {
            str = str + delim + lst.get(i);
        }
        return str;
    }
    
    public static List<SObject> getSublist(List<SObject> lst, Integer start, Integer size) {
        List<SObject> sublist = new List<SObject>();
        for (Integer i = start; i < size; i++) {
            sublist.add(lst.get(i));
        }
        return sublist;
    }
    
    public static Integer countWeekDays(Date startDate, Date endDate) {
        
        if (startDate == null || endDate == null) {
            return null;
        }
        
        Date f1 = fridayBefore(startDate);
        Date f2 = fridayBefore(endDate);
        
        return (5 * f1.daysBetween(f2) / 7) - weekDaysPastFriday(startDate) + weekDaysPastFriday(endDate);
    }
    
    private static Date fridayBefore(Date day) {
        Date referenceDate = Date.newInstance(1900,1,5); // A Friday for reference
        Integer daysPastFriday = Math.mod(referenceDate.daysBetween(day), 7);
        
        return day.addDays(-1 * daysPastFriday);
    }
    
    private static Integer weekDaysPastFriday(Date day) {
        Date referenceDate = Date.newInstance(1900,1,5); // A Friday for reference
        Integer daysPastFriday = Math.mod(referenceDate.daysBetween(day), 7);
        
        if (daysPastFriday == 0) {
            return 0; // Friday
        } else if (daysPastFriday == 1) {
            return 1; // Saturday... count as a Monday
        } else if (daysPastFriday == 2) {
            return 1; // Sunday... count as a Monday
        } else if (daysPastFriday == 3) {
            return 1; // Monday
        } else if (daysPastFriday == 4) {
            return 2; // Tuesday
        } else if (daysPastFriday == 5) {
            return 3; // Wednesday
        } else {
            return 4; // Thurday
        }
    }
    public static String vehiclesDeleted ='0';
     public static void setDeleted(){
    
            vehiclesDeleted = '1';
    
        }

    public static Map<String, String> territoryRecTypeIdMap = null;        
    private static void fetchTerritoryCustSetting(String ObjName)
    {
        
        List<account_territory_assignment__c> listObj = [
            SELECT Record_Type_Name__c
            FROM Account_Territory_Assignment__c 
            WHERE isActive__c = true
        ];
        
        for (account_territory_assignment__c rec : listObj)
        {
            territoryRecTypeIdMap.put(rec.Record_Type_Name__c, getRecordTypeId(ObjName, rec.Record_Type_Name__c ));
        }
    }

    public static Set<String> getTerritoryRecTypeIds(String ObjName)
    {
            if (territoryRecTypeIdMap == null)
            {
                territoryRecTypeIdMap = new Map<String, String>();
                fetchTerritoryCustSetting(ObjName);

            }   
            Set<String> setIds = new Set<String>();
            List<String> listIds = territoryRecTypeIdMap.values();
            for(String str : listIds )
                setIds.add(str);

            return setIds;
    }


}