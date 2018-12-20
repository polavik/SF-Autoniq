// 
// (c) 2016 Appirio, Inc.
//
// Generate a new lead from a sales-related case
//
// 20 Sept 2016    Niza Khunger    Original
// 21 Sept 2016    Jim Cook        Added logic for team-specific calendar search.
//

global class KAR_CalendarController {
   public String calendarData {get; set;}
   public String teamName {get; set;}
   
   // Default constructor.
   public KAR_CalendarController() {
      String pageName = 'Home';
      try{pageName = ApexPages.currentPage().getParameters().get('name');}catch(Exception e){}
      System.debug('TEAM CALENDAR PAGE NAME=' + pageName);
      teamName = getCalendarName(pageName);
       System.debug('TEAM NAME=' + teamName);
      calendarData = getJSONData(teamName);
       
   }
      
   // Take a team calendar name and return a JSONized string of events for it.
   public static String getJSONData(String team) {
      String result  = '[';
      String subject = '';      
      List<Event> x = getEventsforTeam(team);
      Integer startMonth;
      Integer endMonth;
      for(Event e : x) {
         String attendees = '';
         String attachments = '';
         startMonth = (e.IsAllDayEvent ? e.StartDateTime.monthGmt() : e.StartDateTime.month()) - 1;
         endMonth = (e.IsAllDayEvent ? e.EndDateTime.monthGmt() : e.StartDateTime.month()) - 1;
         //startMonth= integer.valueOf(e.StartDateTime.month())-1;
         //endMonth= integer.valueOf(e.endDateTime.month())-1;
         List<EventRelation> attendeeList = e.EventRelations;
         if(attendeeList != null && !attendeeList.isEmpty())
         {
             for(EventRelation a : attendeeList)
             {
                 attendees += (a.Relation.Name + ', ');
             }
             attendees = attendees.removeEnd(', ');
         }
         result+='{"title" : "'         + e.Subject + 
                 '", "startYear" : "'   + (e.IsAllDayEvent ? e.StartDateTime.yearGmt() : e.StartDateTime.year()) +
                 '", "startMonth" : "'  + String.valueOf(startMonth) +
                 '", "startDay" : "'    + (e.IsAllDayEvent ? e.StartDateTime.dayGmt() : e.StartDateTime.day()) +
                 '", "startHour" : "'   + (e.IsAllDayEvent ? e.StartDateTime.hourGmt() : e.StartDateTime.hour()) +
                 '", "startMinute" : "' + (e.IsAllDayEvent ? e.StartDateTime.minuteGmt() : e.StartDateTime.minute()) +
                 '", "endYear" : "'     + (e.IsAllDayEvent ? e.EndDateTime.yearGmt() : e.EndDateTime.year()) +
                 '", "endMonth" : "'    + String.valueOf(endMonth) +
                 '", "endDay" : "'      + (e.IsAllDayEvent ? e.EndDateTime.dayGmt() : e.EndDateTime.day()) + 
                 '", "endHour" : "'     + (e.IsAllDayEvent ? e.EndDateTime.hourGmt() : e.EndDateTime.hour()) +
                 '", "endMinute" : "'   + (e.IsAllDayEvent ? e.EndDateTime.minuteGmt() : e.EndDateTime.minute()) +
                 '", "description" : "' + e.Description +
                 '", "attendees" : "'   + attendees +
                 '", "allDayEvent" : "' + e.IsAllDayEvent +
                                 
                 '"},';
      }
      if(result.length() > 1) result=result.substring(0, result.length()-1);
      result += ']';
      system.debug('==result=='+result);
      return result;
   }
  
  // Look up the team's calendar in Intranet_Content__c.
  public String getCalendarName(String pageName) {
    List<EdgeForceIntranetContentController.ContentVersionWrapper> tempList   = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
    List<EdgeForceIntranetContentController.ContentVersionWrapper> resultList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
  
  
    String queryString = 'SELECT Id, Name, Team_Calendar_Name__c ' + 
                         'FROM Intranet_Content__c ' + 
                          'WHERE   Name =\'' + pageName + '\'' + 
                          'AND (recordType.Name =\'Team Page RT\' OR recordType.Name = \'Sub Team RT\')' + 
                          'ORDER BY Sequence__c ASC NULLS LAST, Start_Date__c DESC';
    EdgeForceIntranetContentController cc = new EdgeForceIntranetContentController();
    tempList = cc.processContentAndVersionMenu(queryString);
    system.debug('queryString==' +queryString);
    for(Intranet_Content__C content : [SELECT Id
                                      FROM    Intranet_Content__c
                                      WHERE   Name = :pageName
                                        AND   (recordType.Name ='Team Page RT' OR recordType.Name = 'Sub Team RT')
                                      ORDER BY Sequence__c ASC NULLS LAST, Start_Date__c DESC]) 
    {
       for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempList) {
          if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
             resultList.add(wrapper);
          }
        }                                       
    }

    try{ return resultList[0].content.Team_Calendar_Name__c;}catch(Exception e){}
    return '';

  }
   
   
   // Fetch events for a specific calendar.
   public static List<Event> getEventsforTeam(String teamName) {
      List<Event> resultList = new List<Event>();
      resultList = [SELECT Id, Owner.Name, Subject, Description, StartDateTime, EndDateTime, 
                    CreatedBy.Id, CreatedBy.Name, IsAllDayEvent,
                    (SELECT Relation.Name FROM EventRelations) 
                    FROM Event
                    WHERE Owner.Name= :teamName
                   ];
      system.debug('resultList====' +resultList);
      return resultList;
   } 
}