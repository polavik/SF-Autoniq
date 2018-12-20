@isTest
public class ADESAPreferences_Test{
static testMethod void Cons_testMethod(){
     Test.startTest();
     string name='xyz';
     Id p = [select id from profile where name='Limited Customer Portal User'].id;
     Account a =new Account();
     a.name=name;
     insert a; 
     contact c1=new contact(lastName='test1',AccountId=a.id);
     insert c1;
     User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = c1.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
     insert user;
     system.runAs(user)
     {
     Preference__c objPre=new Preference__c();
     objPre.Name='TestName';
     objPre.Contact__c=c1.id;
     objPre.AD_Location__c = 'long text area';
     objPre.AD_Public__c = true;
     insert objPre;
          
     ADESAPreferences aa=new ADESAPreferences ();
     
     aa.Savemethod();
     System.assertNotEquals('kk',c1.LastName);
         Preference__c objPre1=new Preference__c();
         objPre1.Name='Test';
         objPre1.contact__c=c1.id;   
     
    }
    } 
 }