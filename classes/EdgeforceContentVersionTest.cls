@isTest

Public Class EdgeforceContentVersionTest{

    Public Static TestMethod void ContentVersionTest(){
         ContentVersion testContentInsert =new ContentVersion(); 
         testContentInsert.ContentURL='http://www.google.com/'; 
         testContentInsert.Title ='Google.com'; 
         insert testContentInsert; 
         
         testContentInsert.ContentURL='https://www.google.com/';
         update testContentInsert;
    
    }

}