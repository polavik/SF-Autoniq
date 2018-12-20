trigger SMSMessageBeforeInsert on simplesms__SMS_Message__c (before insert) {
//The following code assigns Ownership of incoming Sms messages to the Owner of
//the latest outbound message sent to that contact
Set<simplesms__SMS_Message__c> incSmsSet = new Set<simplesms__SMS_Message__c>();
List<simplesms__SMS_Message__c> outboundList = new List<simplesms__SMS_Message__c>();
Set<String> incSmsNumbers = new Set<String>();

for (simplesms__SMS_Message__c sms: Trigger.new)
{
    
    if(sms.simplesms__Type__c == 'Outgoing')
    {
       sms.SMS_Assigned__c = sms.OwnerId;
       
       system.debug('Number Length is: ' + sms.simplesms__From_Num__c.length());
       
       if(sms.simplesms__From_Num__c != null)
       {
           sms.StandardFrom__c = (((((sms.simplesms__From_Num__c.replace( '.', '')).replace( ' ', '')).replace( '-', '')).replace( ')', '')).replace( '(', '')).replace( '+1', '');
       }
       
       if(sms.simplesms__To__c != null)
       {
           sms.StandardTo__c = (((((sms.simplesms__To__c.replace( '.', '')).replace( ' ', '')).replace( '-', '')).replace( ')', '')).replace( '(', '')).replace( '+1', '');
       }
       
    }
    
    if(sms.simplesms__Type__c == 'Incoming')
    {
        if(sms.simplesms__From_Num__c != null)
        {
            sms.StandardFrom__c = (((((sms.simplesms__From_Num__c.replace( '.', '')).replace( ' ', '')).replace( '-', '')).replace( ')', '')).replace( '(', '')).replace( '+1', '');
        }
        
        if(sms.simplesms__To__c != null)
        {
            sms.StandardTo__c = (((((sms.simplesms__To__c.replace( '.', '')).replace( ' ', '')).replace( '-', '')).replace( ')', '')).replace( '(', '')).replace( '+1', '');
        }
        
        incSmsSet.add(sms);
        if(sms.StandardFrom__c != null)
        {
            incSmsNumbers.add(sms.StandardFrom__c);  
        }
    }
}

System.debug('Inbound Set: ' + incSmsSet);
System.debug('Inbound numbers: ' + incSmsNumbers);

outboundList=
[
    SELECT Id, simplesms__Type__c, StandardTo__c, OwnerId, simplesms__Message_Date__c
    FROM simplesms__SMS_Message__c
    WHERE StandardTo__c != null
    AND StandardTo__c in :incSmsNumbers
    AND simplesms__Type__c != null
    AND simplesms__Type__c = 'Outgoing'
    AND createdDate > LAST_WEEK
    LIMIT 1000
];

System.debug('Outgoing messages found: ' + outboundList);

for(simplesms__SMS_Message__c iSms: incSmsSet)
{
    System.debug('Current incoming sms: ' + iSms);
    simplesms__SMS_Message__c latestOutboundSms = null;
    for(simplesms__SMS_Message__c oSms : outboundList)
    {
        System.debug('Current outbound sms: ' + oSms);
        
        if(iSms.StandardFrom__c != null && iSms.StandardFrom__c == oSms.StandardTo__c)
        {
            System.debug('Sms Match found');
            if(latestOutboundSms == null || oSms.simplesms__Message_Date__c > latestOutboundSms.simplesms__Message_Date__c)
            {
                System.debug('Setting latests outbound sms to: ' + oSms);
                latestOutboundSms = oSms;
            }
        }
    }
    if(latestOutboundSms != null)
    {
        System.debug('Owner being reassigned on latest outbound sms: ' + latestOutboundSms);
        iSms.SMS_Assigned__c = latestOutboundSms.OwnerId;
    }
}


}