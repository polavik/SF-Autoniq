public class TestCollectionCallLineItems {
    static testMethod void doTest() {
        Account a = new Account();
        //a.ATC_Organization_ID__c = '123456';
        a.Name = 'Mr Stevebobs Volvo';
        a.Master_Index__c = '934567891';
        insert a;
        
        Collection__c c = new Collection__c();
        c.Name = ' Test Collection';
        c.Account__c = a.Id;
        c.Organization_Id__c = '99345678';
        insert c;
        
        a = [select Collection__c from Account where Id = :a.Id];
       
        
        Document_Type__c dt = new Document_Type__c();
        
        dt.Name = 'test';
        dt.Code__c = 'TE';
        insert dt;
        
        Collection_Line_Item__c cli = new Collection_Line_Item__c();
        //cli.Collection__c = a.Collection__c;
        cli.Collection__c = c.Id; 
        cli.Document_Type__c = dt.Id;
        cli.Doc_Id_Line_No__c = '1-1';
        cli.Document_Id__c = '1';
        cli.Line_Number__c = '1';

        insert cli;

        Collection_Call__c cc = new Collection_Call__c();
        //cc.Collection__c = a.Collection__c;
        cc.Collection__c = c.Id; 
        cc.Date_Time__c = System.now();
        insert cc;


        Collection_Line_Item__c cli2 = new Collection_Line_Item__c();
        //cli.Collection__c = a.Collection__c;
        cli2.Collection__c = c.Id; 
        cli2.Document_Type__c = dt.Id;
        cli2.Doc_Id_Line_No__c = '2-5';
        cli2.Document_Id__c = '2';
        cli2.Line_Number__c = '3';
        cli2.Due_Date__c = System.Today() - 20;
        cli2.Clear_Date__c = null;
        insert cli2;

        cli2.Clear_Date__c = System.Today() + 3;
        update cli2;


    }
}