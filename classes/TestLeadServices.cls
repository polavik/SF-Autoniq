@isTest
private class TestLeadServices
{    
    static testmethod void insertAdditionalContacts_validParams_returnsNothing()
    {   
      Profile p = [SELECT Id FROM Profile WHERE Name='Marketing User'];
      User u = new User(Alias = 'standt', Email='test1234@test8989.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles', UserName='test1234@test8989.comxyz');
      
      System.runAs(u) {
          
        Lead testLead = new Lead(Company = 'TestCompany');
        testLead.Street                                     = 'street12'; 
        testLead.City                                       = 'city2'; 
        testLead.State                                      = 'SC'; 
        testLead.PostalCode                                 = '555555'; 
        testLead.Country                                    = 'USA'; 
        //testLead.Auction_Access_Number__c                   = '3232';   
        testLead.TIN__c                                     = '1231132';
        testLead.Verified_Create_Account__c                 = true;
        testLead.AFC_Web_App__c                             = true;
        
        //testLead.Contact1_First_Name__c                     = 'Salvatore'; 
        //testLead.Contact1_Last_Name__c                      = 'Maranzano'; 
        testLead.Contact1_Middle_Initial__c                 = ''; 
        //testLead.Contact1_Title__c                          = 'title';               
        //testLead.Contact1_Email__c                          = 'email@email.com'; 
        testLead.Contact1_Phone__c                          = '7778889999'; 
        //testLead.Contact1_Mobile_Phone__c                   = '6667778888';      
        testLead.Contact1_Fax__c                            = '5556667777';
        testLead.Contact1_Address1__c                       = 'street1'; 
        testLead.Contact1_Address2__c                       = 'street2'; 
        testLead.Contact1_City__c                           = 'city'; 
        testLead.Contact1_State_or_Province__c              = 'NC'; 
        testLead.Contact1_Postal_Code__c                    = '222222'; 
        testLead.Contact1_County__c                         = 'county'; 
        testLead.Contact1_Country__c                        = 'USA';
        testLead.Contact1_Date_of_Birth__c                  = date.Today(); 
        testLead.Contact1_Driver_s_License_Number__c        = '345678'; 
        testLead.Contact1_Driver_s_License_State__c         = 'NC'; 
        testLead.Contact1_Drivers_License_Expiration__c     = date.Today().addYears(1);
        testLead.Contact1_Own_or_Rent__c                    = 'Own'; 
        testLead.Contact1_Years_at_Location__c              = 6; 
        testLead.Contact1_Citizen__c                        = 'Y';
                
        testLead.Contact2_First_Name__c                     = 'Salvatore'; 
        testLead.Contact2_Last_Name__c                      = 'Maranzano'; 
        testLead.Contact2_Middle_Initial__c                 = ''; 
        testLead.Contact2_Title__c                          = 'title'; 
        testLead.Contact2_Email__c                          = 'email@email.com'; 
        testLead.Contact2_Phone__c                          = '7778889999'; 
        testLead.Contact2_Mobile_Phone__c                   = '6667778888'; 
        testLead.Contact2_Fax__c                            = '5556667777';
        testLead.Contact2_Address1__c                       = 'street1'; 
        testLead.Contact2_Address2__c                       = 'street2'; 
        testLead.Contact2_City__c                           = 'city'; 
        testLead.Contact2_State_or_Province__c              = 'NC'; 
        testLead.Contact2_Postal_Code__c                    = '222222'; 
        testLead.Contact2_County__c                         = 'county'; 
        testLead.Contact2_Country__c                        = 'USA';
        testLead.Contact2_Date_of_Birth__c                  = date.Today(); 
        testLead.Contact2_Driver_License_Number__c          = '345678'; 
        testLead.Contact2_Driver_License_State__c           = 'NC'; 
        testLead.Contact2_Driver_License_Expiration__c      = date.Today().addYears(1);
        testLead.Contact2_Own_or_Rent__c                    = 'Own'; 
        testLead.Contact2_Years_at_Location__c              = 6; 
        testLead.Contact2_Citizen__c                        = 'Y';

        testLead.Contact3_First_Name__c                     = 'Salvatore'; 
        testLead.Contact3_Last_Name__c                      = 'Maranzano'; 
        testLead.Contact3_Middle_Initial__c                 = ''; 
        testLead.Contact3_Title__c                          = 'title'; 
        testLead.Contact3_Email__c                          = 'email@email.com'; 
        testLead.Contact3_Phone__c                          = '7778889999'; 
        testLead.Contact3_Mobile_Phone__c                   = '6667778888'; 
        testLead.Contact3_Fax__c                            = '5556667777';
        testLead.Contact3_Address1__c                       = 'street1'; 
        testLead.Contact3_Address2__c                       = 'street2'; 
        testLead.Contact3_City__c                           = 'city'; 
        testLead.Contact3_State_or_Province__c              = 'NC'; 
        testLead.Contact3_Postal_Code__c                    = '222222'; 
        testLead.Contact3_County__c                         = 'county'; 
        testLead.Contact3_Country__c                        = 'USA';
        testLead.Contact3_Date_of_Birth__c                  = date.Today(); 
        testLead.Contact3_Driver_License_Number__c          = '345678'; 
        testLead.Contact3_Driver_License_State__c           = 'NC'; 
        testLead.Contact3_Driver_License_Expiration__c      = date.Today().addYears(1);
        testLead.Contact3_Own_or_Rent__c                    = 'Own'; 
        testLead.Contact3_Years_at_Location__c              = 6; 
        testLead.Contact3_Citizen__c                        = 'Y';
        
        testLead.Contact4_First_Name__c                     = 'Salvatore'; 
        testLead.Contact4_Last_Name__c                      = 'Maranzano'; 
        testLead.Contact4_Middle_Initial__c                 = ''; 
        testLead.Contact4_Title__c                          = 'title'; 
        testLead.Contact4_Email__c                          = 'email@email.com'; 
        testLead.Contact4_Phone__c                          = '7778889999'; 
        testLead.Contact4_Mobile_Phone__c                   = '6667778888'; 
        testLead.Contact4_Fax__c                            = '5556667777';
        testLead.Contact4_Address1__c                       = 'street1'; 
        testLead.Contact4_Address2__c                       = 'street2'; 
        testLead.Contact4_City__c                           = 'city'; 
        testLead.Contact4_State_or_Province__c              = 'NC'; 
        testLead.Contact4_Postal_Code__c                    = '222222'; 
        testLead.Contact4_County__c                         = 'county'; 
        testLead.Contact4_Country__c                        = 'USA';
        testLead.Contact4_Date_of_Birth__c                  = date.Today(); 
        testLead.Contact4_Driver_s_License_Number__c        = '345678'; 
        testLead.Contact4_Driver_s_License_State__c         = 'NC'; 
        testLead.Contact4_Driver_License_Expiration__c      = date.Today().addYears(1);
        testLead.Contact4_Own_or_Rent__c                    = 'Own'; 
        testLead.Contact4_Years_at_Location__c              = 6; 
        testLead.Contact4_Citizen__c                        = 'Y';
        
        testLead.FirstName                                  = 'Salvatore'; 
        testLead.LastName                                   = 'Maranzano'; 
        testLead.Contact5_Middle_Initial__c                 = ''; 
        testLead.Title                                      = 'title'; 
        testLead.Contact5_Email__c                          = 'email@email.com'; 
        testLead.Contact5_Phone__c                          = '7778889999'; 
        testLead.Contact5_Mobile_Phone__c                   = '6667778888'; 
        testLead.Contact5_Fax__c                            = '5556667777';
        testLead.Contact5_Address1__c                       = 'street1'; 
        testLead.Contact5_Address2__c                       = 'street2'; 
        testLead.Contact5_City__c                           = 'city'; 
        testLead.Contact5_State_or_Province__c              = 'NC'; 
        testLead.Contact5_Postal_Code__c                    = '222222'; 
        testLead.Contact5_County__c                         = 'county'; 
        testLead.Contact5_Country__c                        = 'USA';
        testLead.Contact5_Date_of_Birth__c                  = date.Today(); 
        testLead.Contact5_Driver_s_License_Number__c        = '345678'; 
        testLead.Contact5_Driver_s_License_State__c         = 'NC'; 
        testLead.Contact5_Driver_s_License_Expiration__c    = date.Today().addYears(1);
        testLead.Contact5_Own_or_Rent__c                    = 'Own'; 
        testLead.Contact5_Years_at_Location__c              = 6; 
        testLead.Contact5_Citizen__c                        = 'Y';
        
        testLead.Contact6_First_Name__c                     = 'Salvatore'; 
        testLead.Contact6_Last_Name__c                      = 'Maranzano'; 
        testLead.Contact6_Middle_Initial__c                 = ''; 
        testLead.Contact6_Title__c                          = 'title'; 
        testLead.Contact6_Email__c                          = 'email@email.com'; 
        testLead.Contact6_Phone__c                          = '7778889999'; 
        testLead.Contact6_Mobile_Phone__c                   = '6667778888'; 
        testLead.Contact6_Fax__c                            = '5556667777';
        testLead.Contact6_Address1__c                       = 'street1'; 
        testLead.Contact6_Address2__c                       = 'street2'; 
        testLead.Contact6_City__c                           = 'city'; 
        testLead.Contact6_State_or_Province__c              = 'NC'; 
        testLead.Contact6_Postal_Code__c                    = '222222'; 
        testLead.Contact6_County__c                         = 'county'; 
        testLead.Contact6_Country__c                        = 'USA';
        testLead.Contact6_Date_of_Birth__c                  = date.Today(); 
        testLead.Contact6_Driver_s_License_Number__c        = '345678'; 
        testLead.Contact6_Driver_s_License_State__c         = 'NC'; 
        testLead.Contact6_Driver_s_License_Expiration__c    = date.Today().addYears(1);
        testLead.Contact6_Own_or_Rent__c                    = 'Own'; 
        testLead.Contact6_Years_at_Location__c              = 6; 
        testLead.Contact6_Citizen__c                        = 'Y';
        
        testLead.Contact7_First_Name__c                     = 'Salvatore'; 
        testLead.Contact7_Last_Name__c                      = 'Maranzano'; 
        testLead.Contact7_Middle_Initial__c                 = ''; 
        testLead.Contact7_Title__c                          = 'title'; 
        testLead.Contact7_Email__c                          = 'email@email.com'; 
        testLead.Contact7_Phone__c                          = '7778889999'; 
        testLead.Contact7_Mobile_Phone__c                   = '6667778888'; 
        testLead.Contact7_Fax__c                            = '5556667777';
        testLead.Contact7_Address1__c                       = 'street1'; 
        testLead.Contact7_Address2__c                       = 'street2'; 
        testLead.Contact7_City__c                           = 'city'; 
        testLead.Contact7_State_or_Province__c              = 'NC'; 
        testLead.Contact7_Postal_Code__c                    = '222222'; 
        testLead.Contact7_County__c                         = 'county'; 
        testLead.Contact7_Country__c                        = 'USA';
        testLead.Contact7_Date_of_Birth__c                  = date.Today(); 
        testLead.Contact7_Driver_s_License_Number__c        = '345678'; 
        testLead.Contact7_Driver_s_License_State__c         = 'NC'; 
        testLead.Contact7_Driver_s_License_Expiration__c    = date.Today().addYears(1);
        testLead.Contact7_Own_or_Rent__c                    = 'Own'; 
        testLead.Contact7_Years_at_Location__c              = 6; 
        testLead.Contact7_Citizen__c                        = 'Y';          
        

        testLead.Contact8_First_Name__c                     = 'Salvatore'; 
        testLead.Contact8_Last_Name__c                      = 'Maranzano'; 
        testLead.Contact8_Middle_Initial__c                 = ''; 
        testLead.Contact8_Title__c                          = 'title'; 
        testLead.Contact8_Email__c                          = 'email@email.com'; 
        testLead.Contact8_Phone__c                          = '7778889999'; 
        testLead.Contact8_Mobile_Phone__c                   = '6667778888'; 
        testLead.Contact8_Fax__c                            = '5556667777';
        testLead.Contact8_Address_1__c                      = 'street1'; 
        testLead.Contact8_Address_2__c                      = 'street2'; 
        testLead.Contact8_City__c                           = 'city'; 
        testLead.Contact8_State_or_Province__c              = 'NC'; 
        testLead.Contact8_Postal_Code__c                    = '222222'; 
        testLead.Contact8_County__c                         = 'county'; 
        testLead.Contact8_Country__c                        = 'USA';
        testLead.Contact8_Date_of_Birth__c                  = date.Today(); 
        testLead.Contact8_Drivers_License_Number__c         = '345678'; 
        testLead.Contact8_Drivers_License_State__c          = 'NC'; 
        testLead.Contact8_Drivers_License_Expiration_Date__c= date.Today().addYears(1);
        testLead.Contact8_Own_or_Rent__c                    = 'Own'; 
        testLead.Contact8_Years_at_Location__c              = 6; 
        testLead.Contact8_Citizen__c                        = 'Y';  

       // Test.startTest();
        insert testLead;
          
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.Id);
        
        lc.setConvertedStatus('New Account');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
      //  Test.startTest();
        /*
        testLead = [select Id, Name, ConvertedAccountId from Lead where Id = :testLead.Id];
        update testLead;
        System.assertEquals(testLead.Name, 'Salvatore Maranzano'); 
        */
      }
    }
}