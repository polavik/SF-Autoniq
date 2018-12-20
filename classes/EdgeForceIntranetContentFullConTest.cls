@isTest(SeeAllData=False)
public class EdgeForceIntranetContentFullConTest {
    Public static TestMethod void intranetContentFullControllerTest(){
          CollaborationGroup testGroup = IntranetTestUtility.createGroup(true);
        testGroup.Name='John';
        ApexPages.currentPage().getParameters().put('name' , testGroup.Name);
        EdgeForceIntranetContentFullController intranetCon = new EdgeForceIntranetContentFullController();
       
        
       intranetCon.groupId=testGroup.id;
        
       
     
        
    }

}