@isTest
private class TestKDM_BatchDedupeRecordByWebService{

    static testmethod void test1() {
             
       Test.startTest();
        KDM_BatchDedupeRecordByWebService objKDM_BatchDedupeRecordByWebService = new KDM_BatchDedupeRecordByWebService(0,4,1,'and CRMfusion_Winner__c=true and FactType__c=\'ACCOUNT\' ',' ',true,'djpatel@openlane.com');
        Database.executeBatch(objKDM_BatchDedupeRecordByWebService,10);
       Test.stopTest();
       
    }
    
    static testmethod void test2() {
    
        List<Property__c> ListProperty = new List<Property__c>();
        
        Property__c objProperty3 = new Property__c(Property_Id__c='mi.service.token.prod',Property_Value_Encrypted__c='1234');
        ListProperty.Add(objProperty3) ; 
        
        Property__c objProperty4 = new Property__c(Property_Id__c='mi.service.token.stg',Property_Value_Encrypted__c='1234');
        ListProperty.Add(objProperty4) ;        
        
        Property__c objProperty1 = new Property__c(Property_Id__c='mi.service.url',Property_Value_Encrypted__c='https://ds2gateway.com/MIService');
        ListProperty.Add(objProperty1) ; 
        
        Property__c objProperty2 = new Property__c(Property_Id__c='prod.instance.node',Property_Value_Encrypted__c='NA19',Property_Value__c='NA19');
        ListProperty.Add(objProperty2) ;  

        //String CurrentUrlNode ;
        //String HostURL = URL.getSalesforceBaseUrl().getHost();
        //Integer parts = HostURL.countMatches('.');                        
        //System.Debug('>>> countMatches:'+parts);
        //if(parts== 2)
        //{                        
        //    CurrentUrlNode = HostURL.substring(0,HostURL .indexOf('.',0)).toUpperCase();
        //}else{        
        //    
        //    CurrentUrlNode = HostURL.substring(HostURL.indexOf('.',0)+1,HostURL.indexOf('.',2)).toUpperCase();
        //}     
        //if(CurrentUrlNode == 'NA19')
        if(!Sandbox.isSandbox())
        {
            Property__c objProperty = new Property__c(Property_Id__c='org.type',Property_Value__c='prod');
            ListProperty.Add(objProperty) ; 
        }
        else
        {
            Property__c objProperty = new Property__c(Property_Id__c='org.type',Property_Value__c='stg');
            ListProperty.Add(objProperty) ; 
        }
        
        Insert ListProperty;
        
        List<DuplicateRecordMerge__c> ListRecords = new List<DuplicateRecordMerge__c>();
        DuplicateRecordMerge__c obj = new DuplicateRecordMerge__c();
        obj.CRMfusion_dupeKey__c = 'Account1';
        obj.CRMfusion_Icon__c = 28;
        obj.CRMfusion_Score__c = 110;
        obj.FactType__c = 'ACCOUNT';
        obj.Load__c=1;
        obj.Master_Index__c = '100';
        obj.Record_Name__c = 'DemoWinnerAccount1';
        obj.Record_SF_Id__c = '001a000001WLTjQ';    
        ListRecords.Add(obj);
        
        for(Integer i=0;i<12;i++)
        {
            DuplicateRecordMerge__c obj2 = new DuplicateRecordMerge__c();
            obj2.CRMfusion_dupeKey__c = 'Account1';
            obj2.CRMfusion_Icon__c = 29;
            obj2.CRMfusion_Score__c = 100;
            obj2.FactType__c = 'ACCOUNT';
            obj2.Load__c=1;
            obj2.Master_Index__c = '200';
            obj2.Record_Name__c = 'DemoDuplicateAccount'+String.valueOf(i);
            obj2.Record_SF_Id__c = '001a000001WLTjQ';       
            ListRecords.Add(obj2);
        }
        Insert ListRecords;
        
       Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl4());
        KDM_BatchDedupeRecordByWebService objKDM_BatchDedupeRecordByWebService = new KDM_BatchDedupeRecordByWebService(0,1,1,'and CRMfusion_Winner__c=true and FactType__c=\'ACCOUNT\' ',' ',true,'djpatel@openlane.com');
        Database.executeBatch(objKDM_BatchDedupeRecordByWebService,10);
       Test.stopTest();
       
    }
    static testmethod void test3() {
    
        List<Property__c> ListProperty = new List<Property__c>();
        
        Property__c objProperty3 = new Property__c(Property_Id__c='mi.service.token.prod',Property_Value_Encrypted__c='1234');
        ListProperty.Add(objProperty3) ; 
        
        Property__c objProperty4 = new Property__c(Property_Id__c='mi.service.token.stg',Property_Value_Encrypted__c='1234');
        ListProperty.Add(objProperty4) ;        
        
        Property__c objProperty1 = new Property__c(Property_Id__c='mi.service.url',Property_Value_Encrypted__c='https://ds2gateway.com/MIService');
        ListProperty.Add(objProperty1) ; 
        
        Property__c objProperty2 = new Property__c(Property_Id__c='prod.instance.node',Property_Value_Encrypted__c='NA19',Property_Value__c='NA19');
        ListProperty.Add(objProperty2) ;  

        /*
        String CurrentUrlNode ;
        String HostURL = URL.getSalesforceBaseUrl().getHost();
        Integer parts = HostURL.countMatches('.');                        
        System.Debug('>>> countMatches:'+parts);
        if(parts== 2)
        {                        
            CurrentUrlNode = HostURL.substring(0,HostURL .indexOf('.',0)).toUpperCase();
        }else{        
            
            CurrentUrlNode = HostURL.substring(HostURL.indexOf('.',0)+1,HostURL.indexOf('.',2)).toUpperCase();
        }
        if(CurrentUrlNode == 'NA19') 
        */
        if(!Sandbox.isSandbox())
        {
            Property__c objProperty = new Property__c(Property_Id__c='org.type',Property_Value__c='prod');
            ListProperty.Add(objProperty) ; 
        }
        else
        {
            Property__c objProperty = new Property__c(Property_Id__c='org.type',Property_Value__c='stg');
            ListProperty.Add(objProperty) ; 
        }
        
        Insert ListProperty;
        
        List<DuplicateRecordMerge__c> ListRecords = new List<DuplicateRecordMerge__c>();
        DuplicateRecordMerge__c obj = new DuplicateRecordMerge__c();
        obj.CRMfusion_dupeKey__c = 'Account1';
        obj.CRMfusion_Icon__c = 28;
        obj.CRMfusion_Score__c = 110;
        obj.FactType__c = 'ACCOUNT';
        obj.Load__c=1;
        obj.Master_Index__c = '100';
        obj.Record_Name__c = 'DemoWinnerAccount1';
        obj.Record_SF_Id__c = '001a000001WLTjQ';    
        ListRecords.Add(obj);
        
        for(Integer i=0;i<12;i++)
        {
            DuplicateRecordMerge__c obj2 = new DuplicateRecordMerge__c();
            obj2.CRMfusion_dupeKey__c = 'Account1';
            obj2.CRMfusion_Icon__c = 29;
            obj2.CRMfusion_Score__c = 100;
            obj2.FactType__c = 'ACCOUNT';
            obj2.Load__c=1;
            obj2.Master_Index__c = '200';
            obj2.Record_Name__c = 'DemoDuplicateAccount'+String.valueOf(i);
            obj2.Record_SF_Id__c = '001a000001WLTjQ';       
            ListRecords.Add(obj2);
        }
        Insert ListRecords;
        
       Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl5());
        KDM_BatchDedupeRecordByWebService objKDM_BatchDedupeRecordByWebService = new KDM_BatchDedupeRecordByWebService(0,1,1,'and CRMfusion_Winner__c=true and FactType__c=\'ACCOUNT\' ',' ',true,'djpatel@openlane.com');
        Database.executeBatch(objKDM_BatchDedupeRecordByWebService,10);
       Test.stopTest();
       
    }
    
}