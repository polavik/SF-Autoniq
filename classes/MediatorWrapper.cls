public class MediatorWrapper 
{
	
	// STATIC VARIABLES
	
	public static Integer DEFAULT_TIMEOUT = 100000;
	private static MediatorWrapper myInstance;
	
	// MEMBER VARIABLES
	
	private Integer timeOut {get; set;}
	private Document mediatorCertificate;
	private Mediator.MediatorService ms {get; set;}
	
	// PUBLIC METHOD DEFINITIONS
	
	public static MediatorWrapper getInstance()
	{
		if (myInstance == null)
		{
			myInstance = new MediatorWrapper();
		}
		return myInstance;
	}
	
	public void setTimeout(Integer timeout)
	{
		this.ms.timeout_x = timeout;
	}
	
	public Mediator.MediatorService getMediatorService()
	{
		return this.ms;
	}
	
	// PRIVATE METHOD DEFINITIONS
	
	private MediatorWrapper()
	{
		try
		{
			mediatorCertificate = [SELECT Name, Body FROM Document WHERE Name = 'Mediator Certificate'];
			ms = new Mediator.MediatorService(); 
	        ms.timeout_x = DEFAULT_TIMEOUT;
	        ms.endpoint_x = Utils.getProperty('mediator.url');
	        ms.clientCert_x = EncodingUtil.base64Encode(mediatorCertificate.Body);
	        ms.clientCertPasswd_x = Utils.getProperty('mediator.cert.pw');
		}
		catch (Exception e)
		{
			// Doh!
		}
	}
}