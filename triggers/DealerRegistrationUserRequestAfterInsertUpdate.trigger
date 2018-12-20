trigger DealerRegistrationUserRequestAfterInsertUpdate on Dealer_Registration_User_Request__c (after insert,after update) {
    List<Dealer_Registration_Request__c> drrToUpdate = new List<Dealer_Registration_Request__c>();
    Map<Id, Dealer_Registration_User_Request__c> drurToUpdate = new Map<Id, Dealer_Registration_User_Request__c>();
    List<Id> drrtids = new List<Id>();
      // ppm 99579 Add Rep AA# from DRUR to DRR in OL/ADESA and KAR Instance   
            for(Dealer_Registration_User_Request__c  drur: trigger.new)
            {   
                drrtids.add(drur.Dealer_Registration_Request__c);  
                drurToUpdate.put(drur.Dealer_Registration_Request__c,drur); 
            }
            if(drrtids.size()>0){
             List<Dealer_Registration_Request__c> drrs= [select id,Rep_Auction_Access_Number__c,(select id,Rep_Auction_Access_Number__c from Dealer_Registration_User_Requests__r) from Dealer_Registration_Request__c where id in :drrtids ];
             for(Dealer_Registration_Request__c drr: drrs){
               if(drr.Dealer_Registration_User_Requests__r.size()==1) {
                  drr.Rep_Auction_Access_Number__c = drurToUpdate.get(drr.id).Rep_Auction_Access_Number__c; 
                  system.debug('Dealer_Registration_User_Requests__r.size()==1 , aaid='+drurToUpdate.get(drr.id).Rep_Auction_Access_Number__c);
                  drrToUpdate.add(drr);
               }
             }
            }
           
            if (drrToUpdate.size()>0){
               
               Database.update(drrToUpdate);
           }
    
     if (Trigger.isInsert){
     
    List<Dealer_Registration_User_Request__c> rtrDrurs = new List<Dealer_Registration_User_Request__c>();
    List<Dealer_Registration_Request__c> drrsToChange = new List<Dealer_Registration_Request__c>();
    List<Id> drrIds = new List<Id>();
      
        // Eric's old tigger
        for(Dealer_Registration_User_Request__c drur : Trigger.new)
            {
             
                if(drur.Requested_Username__c != null && drur.Requested_Username__c.length() >= 5)
                {
                    system.debug('Requested_Username__c = ' + drur.Requested_Username__c);
                    system.debug('Requested_Username__c substring = ' + (drur.Requested_Username__c).substring(0, 4));
                    if((drur.Requested_Username__c).substring(0, 4) == 'RTR-')
                    {
                        system.debug('Added to rtrDrurs and drrIds');
                        rtrDrurs.add(drur);
                        drrIds.add(drur.Dealer_Registration_Request__c);
                    }
                }
            }
        
            drrsToChange =
            [
            SELECT Id,
            Real_Time_Registration__c
            FROM Dealer_Registration_Request__c
            WHERE Dealer_Registration_Request__c.Id in : drrIds
            ];
            
            for(Dealer_Registration_Request__c drr : drrsToChange)
            {
                system.debug('Adding ' + drr);
                drr.Real_Time_Registration__c = true;
            }
        
            update drrsToChange; 
       }
       
    List<Parent_DRUR__c> pDRURs = new List<Parent_DRUR__c>();
    List<Parent_DRUR__c> finalPdrurs = new List<Parent_DRUR__c>();
    Set<String> emails = new Set<String>();
    Map<String, Parent_DRUR__c> emailToDRUR = new Map<String, Parent_DRUR__c>();
    Map<Id, String> DrrIdtoEmail = new Map<Id, String>();
    Map<String, ID> pdrurEmailtoPdrurId = new Map<String, ID>();
    Set<Parent_DRUR__c> setpDRURstoUpdate = new Set<Parent_DRUR__c>();
    Set<Parent_DRUR__c> setpDRURstoInsert = new Set<Parent_DRUR__c>();
    List<Parent_DRUR__c> pDRURstoUpdate = new List<Parent_DRUR__c>();
    List<Parent_DRUR__c> pDRURstoInsert = new List<Parent_DRUR__c>();
    List<Dealer_Registration_Request__c> drrs = new List<Dealer_Registration_Request__c>();
    List<Dealer_Registration_Request__c> drrsToUpdate = new List<Dealer_Registration_Request__c>();
    List<String> dedupPDRURListUpdate = new List<String>();
    List<String> dedupPDRURListInsert = new List<String>();
    for(Dealer_Registration_User_Request__c  drur: trigger.new)
    {
        if(drur.Email__c != null)
        {
            emails.add(drur.Email__c);
        }
    }
    
    pDRURs = 
            [
                SELECT
                Id,
                Name,
                Authorization__c,
                Buy_Permission__c,
                Mobile__c,
                Date_Of_Birth__c,
                Drivers_Licence_Number__c,
                Email__c,
                Existing_Username__c,
                Fax__c,
                First_Name__c,
                KO_Book_Checked_User__c,
                Last_Name__c,
                List_Sell_Permission__c,
                Phone__c,
                Registration_Form_User_Id__c,
                Remove_User__c,
                Rep_Auction_Access_Number__c,
                Requested_Username__c,
                Title__c,
                View_Only_Permission__c
                FROM Parent_DRUR__c
                WHERE Email__c in : emails
            ];
            
    for(Parent_DRUR__c pDRUR : pDRURs)
    {
        emailToDRUR.put(pDRUR.Email__c, pDRUR);
    }

    for(Dealer_Registration_User_Request__c  drur: trigger.new)
    {
        if(emailToDRUR.get(drur.Email__c) != null)  //Update existing pDRUR
        {
            DrrIdtoEmail.put(drur.Dealer_Registration_Request__c, drur.Email__c);//Links DRR to it's DRUR (And pDRUR) Email
            
            Boolean dupeUpdate = false;
            for(String email : dedupPDRURListUpdate)
            {
                if(drur.Email__c == email)
                {
                    dupeUpdate = true;
                }
            }
            
            if(dupeUpdate == false)
            { 
                Parent_DRUR__c pDRUR = emailToDRUR.get(drur.Email__c);
                pDRUR.Name = drur.Name;
                pDRUR.Authorization__c = drur.Authorization__c;
                pDRUR.Buy_Permission__c = drur.Buy_Permission__c;
                pDRUR.Mobile__c = drur.Mobile__c;
                pDRUR.Date_Of_Birth__c = drur.Date_Of_Birth__c;
                pDRUR.Drivers_Licence_Number__c = drur.Drivers_Licence_Number__c;
                pDRUR.Email__c = drur.Email__c;
                pDRUR.Existing_Username__c = drur.Existing_Username__c;
                pDRUR.Fax__c = drur.Fax__c;
                pDRUR.First_Name__c = drur.First_Name__c;
                pDRUR.KO_Book_Checked_User__c = drur.KO_Book_Checked_User__c;
                pDRUR.Last_Name__c = drur.Last_Name__c;
                pDRUR.List_Sell_Permission__c = drur.List_Sell_Permission__c;
                pDRUR.Phone__c = drur.Phone__c;
                pDRUR.Registration_Form_User_Id__c = drur.Registration_Form_User_Id__c;
                pDRUR.Remove_User__c = drur.Remove_User__c;
                pDRUR.Rep_Auction_Access_Number__c = drur.Rep_Auction_Access_Number__c;
                pDRUR.Requested_Username__c = drur.Requested_Username__c;
                pDRUR.Title__c = drur.Title__c;
                pDRUR.View_Only_Permission__c = drur.View_Only_Permission__c;                        
                
                dedupPDRURListUpdate.add(drur.Email__c);
                setpDRURstoUpdate.add(pDRUR); 
            }     
        }
        else //Create new DRUR
        {
        
            DrrIdtoEmail.put(drur.Dealer_Registration_Request__c, drur.Email__c);//Links DRR to it's DRUR (And pDRUR) Email
            //The above code must be done first for inserts.  We only want to insert 1 PDRUR for each Email though, so we must check for duplicates
            Boolean dupeInsert = false;
            for(String email : dedupPDRURListInsert)
            {
                if(drur.Email__c == email)
                {
                    dupeInsert = true;
                }
            }
            
            if(dupeInsert == false)
            { 
                Parent_DRUR__c pDRUR = new Parent_DRUR__c();
                pDRUR.Name = drur.Name;
                pDRUR.Authorization__c = drur.Authorization__c;
                pDRUR.Buy_Permission__c = drur.Buy_Permission__c;
                pDRUR.Mobile__c = drur.Mobile__c;
                pDRUR.Date_Of_Birth__c = drur.Date_Of_Birth__c;
                pDRUR.Drivers_Licence_Number__c = drur.Drivers_Licence_Number__c;
                pDRUR.Email__c = drur.Email__c;
                pDRUR.Existing_Username__c = drur.Existing_Username__c;
                pDRUR.Fax__c = drur.Fax__c;
                pDRUR.First_Name__c = drur.First_Name__c;
                pDRUR.KO_Book_Checked_User__c = drur.KO_Book_Checked_User__c;
                pDRUR.Last_Name__c = drur.Last_Name__c;
                pDRUR.List_Sell_Permission__c = drur.List_Sell_Permission__c;
                pDRUR.Phone__c = drur.Phone__c;
                pDRUR.Registration_Form_User_Id__c = drur.Registration_Form_User_Id__c;
                pDRUR.Remove_User__c = drur.Remove_User__c;
                pDRUR.Rep_Auction_Access_Number__c = drur.Rep_Auction_Access_Number__c;
                pDRUR.Requested_Username__c = drur.Requested_Username__c;
                pDRUR.Title__c = drur.Title__c;
                pDRUR.View_Only_Permission__c = drur.View_Only_Permission__c;
                
                dedupPDRURListInsert.add(drur.Email__c);
                setpDRURstoInsert.add(pDRUR);
            }          
        }
        
    }
        for(Parent_DRUR__c sPDRUR : setpDRURstoUpdate)//Removes duplicates
        {
            pDRURstoUpdate.add(sPDRUR);
        }
        for(Parent_DRUR__c sPDRUR : setpDRURstoInsert)//Removes duplicates
        {
            pDRURstoInsert.add(sPDRUR);
        }
        
        if(pDRURstoUpdate.size() > 0)
        {
            Database.update(pDRURstoUpdate);
        }
        
        if(pDRURstoInsert.size() > 0)
        {
            Database.insert(pDRURstoInsert);
        }
        
        drrs =
        [
            SELECT Id, Parent_DRUR__c
            FROM Dealer_Registration_Request__c
            WHERE Id in : DrrIdtoEmail.KeySet()
        ];
        
        finalPdrurs =
        [
            SELECT Id, Email__c
            FROM Parent_DRUR__c
            WHERE Email__c in : emails
        ];
        
        for(Parent_DRUR__c pDRUR : finalPdrurs)
        {
            pdrurEmailtoPdrurId.put(pDRUR.Email__c, pDRUR.Id);
        }
            
        for(Dealer_Registration_Request__c drr : drrs)
        {
            drr.Parent_DRUR__c = pdrurEmailtoPdrurId.get(DrrIdtoEmail.get(drr.Id));
            drrsToUpdate.add(drr);
        }  
        
        if(drrsToUpdate.size() > 0)
        {
            Database.update(drrsToUpdate);
        }
         
}