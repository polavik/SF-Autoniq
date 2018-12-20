@isTest
public class TestForgotPasswordController
{
     public static testMethod void testForgotPasswordController() {
      // Instantiate a new controller with all parameters in the page
      ForgotPasswordController controller = new ForgotPasswordController();
      controller.username = 'test@salesforce.com';       
    
      System.assertEquals(controller.forgotPassword(),null); 
    }
}