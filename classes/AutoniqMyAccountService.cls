@RestResource(urlMapping='/autoniq/myaccount/user/*')
global class AutoniqMyAccountService {
	@HttpPost global static string signup ( AutoniqMyAccountSignupRequest request ) {
		
		return 'success';
	}

	@HTTPGet global static AutoniqMyAccountViewAccountResponse viewAccount () {	
		return new AutoniqMyAccountViewAccountResponse ();
	}
}