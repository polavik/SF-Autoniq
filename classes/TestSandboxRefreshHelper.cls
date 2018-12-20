@isTest
class TestSandboxRefreshHelper{
    @isTest(SeeAllData=true)
    static void testSandboxPostCopyScript() {       
        SandboxRefreshHelper mySandboxRefreshHelper = new SandboxRefreshHelper();        
        Test.testSandboxPostCopyScript(mySandboxRefreshHelper, '00D54000000XXXX' , '00D54000000XXXX', 'ksrhtcs');
    }
}