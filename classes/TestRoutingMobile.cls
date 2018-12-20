/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestRoutingMobile {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
		Account acct = new Account(Name = 'Test Account');
		insert acct;
        
        RoutingMobile rm =  new RoutingMobile();
        sma__MARoute__c sm =  new sma__MARoute__c(name ='test route');
        insert sm;
        
        sma__MAWaypoint__c swp =  new sma__MAWaypoint__c(name ='SANTA MONICA BMW' ,sma__Route__c =sm.id,
       			 sma__LinkId__c =acct.id, sma__BaseObject__c=acct.id, sma__Address__c='test address',
//       			 sma__Notes__c='testNote', 
       			 sma__AdditionalData__c='001.423432.321', sma__Latitude__c=42.4479929, sma__Longitude__c=118.47538
        
        );
        insert swp;
        

		Note n = new Note();
		n.Title = 'test title';
		n.Body = 'comment body';
		n.parentId = acct.Id;
		n.IsPrivate = false;
		
		
		rm.serializedNote = JSON.serialize(n); 
		
		rm.saveType = 'AccountReturn';
		rm.waypointId = swp.id;

        Account a = new Account(name='Test',Auction_Access_Number__c='12082015', Phone='(123) 456-7890');
		insert a;		
		
        Task t1 = new Task(WhatId = acct.id, Subject='Check In test',CallType='Inbound',
//        sma__CheckOutDate__c=Datetime.now(),
        	Description='1.CJ/Andy/Moe 2.Discussed exception 3.Resolved'
        	 
        		);
        insert t1;
        
//		Id, Subject, Description, Seller__c, Activity_Type__c, 
//		sma__CreatedLocationAccuracy__c,		 sma__CreatedLatitude__c,
//		 sma__CreatedLongitude__c, sma__DistanceFromRecordMi__c, ActivityDate, sma__CheckOutDate__c,
//		 sma__CheckOutAccuracy__c, sma__CheckOutDistanceFromRecordMi__c, sma__CheckOutLatitude__c, 
//		 sma__CheckOutLongitude__c, Status 
        System.debug('-----task.id =' + t1.id + 'task IsClosed=' + t1.IsClosed);
        System.debug('-----task.Subject =' + t1.Subject + 'task WhoId=' + t1.WhoId);
		
		rm.TaskObj =  t1; 
        
        rm.addNote ();
        
        System.debug('-----sma__LinkId__c.id =' + swp.sma__LinkId__c);
        
        rm.saveType = 'WaypointReturn';
        rm.routeId = sm.id;
        rm.addNote ();
        
        
        rm.waypointSelectionType = 'createDisposition';
        rm.waypointSelectionType () ;
        
        rm.waypointSelectionType = 'createNote';
        rm.waypointSelectionType () ;

        rm.waypointSelectionType = 'return';
        rm.waypointSelectionType () ;
        
        rm.waypointSelectionType = 'returnDisposition';
        rm.waypointSelectionType () ;
        
        
        rm.dispostionType = 'NextVisit';
        rm.dispositionTypeClick ();
        
        rm.dispostionType = 'ExistingContract';
        rm.dispositionTypeClick ();
        rm.dispostionType = 'alertDialog';
        rm.dispositionTypeClick ();
        rm.addDisposition();

        System.debug('-----sma__LinkId__c.id =' + swp.sma__LinkId__c);
        
//        rm.checkIn();
        
    }
}