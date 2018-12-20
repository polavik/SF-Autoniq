trigger DealerRegistrationUserRequestBeforeInsertUpdate on Dealer_Registration_User_Request__c (Before Insert, Before Update) {
    //Update empty email with dummy email if it is a remove user request
    for(Dealer_Registration_User_Request__c  drur: trigger.new)
    {   
        if((drur.email__c == null || drur.email__c == '') && drur.remove_user__c == true)
        {
            drur.email__c = 'remove_user@dummy.com';
        }
    }

}