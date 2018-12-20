global class AutoniqMyAccountViewAccountResponse {
	public AutoniqMyAccountViewAccountResponse() {
		success = true;
		data = new Data();
		data.userSettings = new UserSettings();
		data.userSettings.autoCheckId = 'test';
		data.userSettings.autoCheckAutoPurchase = true;
		data.userSettings.country = 'USA';
		data.userSettings.nextBillingCycle = 1514523599;
		data.userSettings.mobileDeviceType = 'Android';
		data.userSettings.menuStyle = 'KBB';
		data.userSettings.aaxUserId = null;
		data.userSettings.city = 'Chicago';
		data.userSettings.aaxSecurityToken = 'test';
		data.userSettings.peNADATable = 'RETAIL';
		data.userSettings.postalCode = '60654';
		data.userSettings.phone2 = '1111112222';
		data.userSettings.ccLastError = null;
		data.userSettings.login = 'cchong';
		data.userSettings.carfaxAutoPurchase = false;
		data.userSettings.websiteLastUpdated = 'test';
		data.userSettings.homeRegionZipCode = '60654';
		data.userSettings.availableBalance = null;
		data.userSettings.aaxDealerId = null;
		data.userSettings.accountStatus = 'Active';
		data.userSettings.homeRegionSelected = true;
		data.userSettings.peKBBTable = 'RETAIL';
		data.userSettings.state = 'IL';
		data.userSettings.subFeatures = new List <List<string>>();
		data.userSettings.subFeatures.add(new List <string>{'Black Book', 'true'});
		data.userSettings.subFeatures.add(new List <string>{'Galves', 'true'});
		data.userSettings.email = 'cchong@drivindealer.com';
		data.userSettings.subAutoRecurring = true;
		data.userSettings.carfaxId = 'test';
		data.userSettings.carfaxEnabled = true;		
		data.userSettings.peNADATableDomain= new List <List<string>>();		
		data.userSettings.peNADATableDomain.add(new List <string>{'Auction', 'AUCTION'});
		data.userSettings.peNADATableDomain.add(new List <string>{'Loan/Retail', 'RETAIL'});
		data.userSettings.peNADATableDomain.add(new List <string>{'Trade-In', 'TRADEIN'});		
		data.userSettings.address='600 W. Chicago Avenue';
		
		data.userSettings.fullName ='Crispina, Chong';
		data.userSettings.ccNumberMasked= 'Visa **1111';
		
		data.userSettings.menuStyleDomain= new List <List<string>>();
		data.userSettings.menuStyleDomain.add(new List <string>{'Black Book', 'BBK'});
		data.userSettings.menuStyleDomain.add(new List <string>{'Kelley Blue Book', 'KBB'});		 
		data.userSettings.peBBKTable= 'WHOLESALE';
		data.userSettings.dealership ='Autoniq';
		data.userSettings.autoCheckEnabled = true;
		data.userSettings.aaxClientId = null;
		
		data.userSettings.peKBBTableDomain= new List <List<string>>();
		data.userSettings.peKBBTableDomain.add(new List <string>{'Auctionk', 'AUCTION'});
		data.userSettings.peKBBTableDomain.add(new List <string>{'Lending/Retail', 'RETAIL'});
		
		
		data.userSettings.phone='312-333-4444';
		data.userSettings.userType='REGULAR';
		
		data.userSettings.homeRegionSelectedDomain= new List <List<string>>();
		data.userSettings.homeRegionSelectedDomain.add(new List <string>{'Home', 'true'});
		data.userSettings.homeRegionSelectedDomain.add(new List <string>{'National', 'false'});
		 
		data.userSettings.ccExp = '09/2020';
		
		data.userSettings.peBBKTableDomain= new List <List<string>>();
		data.userSettings.peBBKTableDomain.add(new List <string>{'Retail', 'RETAIL'});
		data.userSettings.peBBKTableDomain.add(new List <string>{'Trade-In', 'TRADEIN'});
	}

	public Boolean success;
	public Data data;
	public class UserSettings {
		public UserSettings() {}
		public String autoCheckId;
		public Boolean autoCheckAutoPurchase;
		public String country;
		public Integer nextBillingCycle;
		public String mobileDeviceType;
		public String menuStyle;
		public String aaxUserId;
		public String city;
		public String aaxSecurityToken;
		public String peNADATable;
		public String postalCode;
		public String phone2;
		public String ccLastError;
		public String login;
		public Boolean carfaxAutoPurchase;
		public String websiteLastUpdated;
		public String homeRegionZipCode;
		public Double availableBalance;
		public String aaxDealerId;
		public String accountStatus;
		public boolean homeRegionSelected;
		public String peKBBTable;
		public String state;
		public List<List<String>> subFeatures;
		public String email;
		public Boolean subAutoRecurring;
		public String carfaxId;
		public Boolean carfaxEnabled;
		public String autoCheckPasswd;
		public List<List<String>> peNADATableDomain;
		public String address;
		public String carfaxPasswd;
		public String fullName;
		public String ccNumberMasked;
		public List<List<String>> menuStyleDomain;
		public String peBBKTable;
		public String dealership;
		public Boolean autoCheckEnabled;
		public String aaxClientId;
		public List<List<String>> peKBBTableDomain;
		public String passwd;
		public String phone;
		public String userType;
		public List<List<String>> homeRegionSelectedDomain;
		public String ccExp;
		public List<List<String>> peBBKTableDomain;
	}

	public class Data {
		public Data() {}
		public UserSettings userSettings;
	}

	
	public static AutoniqMyAccountViewAccountResponse parse(String json) {
		return (AutoniqMyAccountViewAccountResponse) System.JSON.deserialize(json, AutoniqMyAccountViewAccountResponse.class);
	}
	
}