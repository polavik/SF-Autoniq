public class VerifyMediatorConnection
{        
    public void sendConectionTest() 
    {
        //Case c = new Case();
        try 
        {
            Mediator.MediatorService ms = MediatorWrapper.getInstance().getMediatorService();
            //Logger.info(c, 'Calling Mediator sendConectionTest() operation ms.restoreVehicleFromArbitration(0)');
            System.debug('Calling Mediator sendConectionTest() operation ms.restoreVehicleFromArbitration(0)');
            Mediator.restoreVehicleFromArbitrationResponseType response = ms.restoreVehicleFromArbitration(0);
            System.debug('sendConectionTest return code: ' + response.returnCode);
            //Logger.info(c, 'sendConectionTest return code: ' + response.returnCode);
        } 
        catch (Exception e) 
        {
            System.debug(e.getMessage());
            //Logger.error(c, e.getMessage());
        } 
        finally 
        {
            //Logger.flush();
        }
    }    
}