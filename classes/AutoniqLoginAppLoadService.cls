@RestResource(urlMapping='/autoniq/user/login')
global with sharing class AutoniqLoginAppLoadService {
	@HttpPost global static LoginAppResponse LoginAppLoad ( String username ) {
		Contact user = new Contact();
		user.Login__c = username;
		Autoniq_User_Applilcation_Setting__c setting = new Autoniq_User_Applilcation_Setting__c();
		setting.demoAccount__c = 'true';
		LoginAppResponse response = new LoginAppResponse ( user, setting);
		
		return response;
	}

	global class LoginAppResponse {
		public LoginAppResponse(Contact c, Autoniq_User_Applilcation_Setting__c setting) {
			success = true;
			login = c.Login__c;
			demo = isTrue(setting.demoAccount__c);
			clSMCEnabled =  isTrue(setting.clSMC__c);
			menuStyle = 'abcdefg'  /*(string.isNotBlank(setting.MenuStyle__c)) ? setting.MenuStyle__c : ''*/;
			clCARSEnabled = isTrue(setting.clCars__c);
			clCLEnable = isTrue(setting.clcl__c);
			websiteEnabled = isTrue(setting.webSite__c);
			//homeRegionZipCode =  isTrue(setting.homeRegionSelected__c);
			aaxConfigured = isTrue(setting.aaxIntegration__c);
			autoCheckAutoPurchase = false;
			authenticate = false;
			nadaCopEnabled = false;
			unseenNotificationsC = 100;
			acceptTerm  = false;
			clCARSEnabled = false;
			clSMCEnabled = false;
			carfaxAutoPurchase = false;			
			autoCheckAccessible = false;
			proEnabled = false;
			autoCheckConfigured = false;
			websiteUr = false;
			dcEnabled = false;
			aaxEnabled = false;
			carfaxConfigured = false;
			carfaxEnable = false;
			enabledFeatures = false;
			websiteEnabled = false;
			aaxConfigured = false;
			autoCheckEnable = false;
			clCLEnable = false;
			carfaxAccessible = false;
		}
		
		public boolean success;
		public boolean autoCheckAutoPurchase;
        public boolean authenticate;
		public boolean nadaCopEnabled;
		public string menuStyle;
		public integer unseenNotificationsC;
		public boolean acceptTerm;
		public boolean clCARSEnabled;
        public boolean clSMCEnabled;
        public string login;
		public boolean carfaxAutoPurchase;
		public boolean demo;
		public boolean carfaxAccessible;
		public boolean homeRegionZipCode;
		public boolean autoCheckAccessible;
		public boolean proEnabled;
		public boolean autoCheckConfigured;
		public boolean websiteUr;
		public boolean dcEnabled;
		public boolean aaxEnabled;
		public boolean carfaxConfigured;
		public boolean carfaxEnable;
		public boolean enabledFeatures;
		public boolean websiteEnabled;
		public boolean aaxConfigured;
		public boolean autoCheckEnable;
		public boolean clCLEnable;
		private boolean isTrue(string value) {
			return (string.isNotBlank(value) && value.toLowerCase().equals('true'));
		}
	}
}