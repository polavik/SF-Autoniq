global class CacheContract {
    
    global Aax aax;
    global UserDetail userDetail;
    global AccountDetail accountDetail;
    global PaymentProfile paymentProfile;
    global SubscriptionItems subscriptionItems;
    global Preferences preferences; 
    global Packages packages;
    global VhrSettings vhrSettings;
    global Transactions transactions;
    global Options options;
    global DoWeNeedThese doWeNeedThese;
    global TableDomains tableDomains;



    global class userDetail {
        
        public String id;
        public String firstName;//Required
        public String lastName;//Required
        public String mobile;//XXX-XXX-XXXX
        public String mobileCountryCode;//United States, Canada, Mexico
        public String phoneType;//iPhone, Android, Other, N/A    
        public String altPhone;//XXX-XXX-XXXX
        public String altPhoneCountryCode;//United States, Canada, Mexico
        public String email;//Maybe Required if available
        public String altEmail;
        public String autoniqUserId;//Maybe Required if available
        public String autoniqAccountId;
        public String password;//Maybe Required if available (Encryptedstring)
        public String salutation;
        public boolean internalUser;//Not Used
        public integer internalUserId;//Not Used
        public integer repAuctionAccessNumber;//Maybe Required if available
    }
    

    global class AccountDetail {
        public Id id;
        public String accountStatus;
        public String autoniqAccountName;
        public String accountType;
        public String auctionAccessNumber;
        public String address;
        public String address2;
        public String city;
        public String country;
        public String email;
        public String fax;
        public decimal latitude;
        public decimal longitude;
        public Integer noOfSubscriptions;
        
        public String postCode;
        public String state;
        public String referrer;
    }

    global class PaymentProfile {
        public String ccNumberMasked;
        //private Error[] ccErrors;
        public String paymentType;
        public String creditCardType;
        public String ccLastError;
        public String ccExp;
        public String creditCardCode;
        public String billingFirstName;
        public String billingLastName;
        public String billingAddress1;
        public String billingAddress2;
        public String billingCity;
        public String billingState;
        public String billingCountry;
        public String billingZip;
        public String customerPaymentProfileId;
        public String customerProfileId;
        public String customerShippingAddressId;
        public String promotionalCode;
        
    }

    global class SubscriptionItems{
        public List<String> subscriptionItemList;
    }

        
    global class Preferences {
        public String peNADATable;

        public String homeRegionSelected;

        public String auctionAccessId;

        public String[] recentAuctions;

        public String peKBBTable;

        public String regionSelected;

        public String peBBKTable;

        public String menuStyle;

        public String peRegion;
        
        public String phoneType;

    }

    global class Packages {
        public String timestamp;

        public DateTime expires;

        public String term;

        public DateTime start;

        public String modifiedBy;

        //public String promo;

        public String feature;

        public DateTime sequenceStart;

        public double finalPrice;
    }

    global Class VhrSettings {
        public  boolean autoCheckAutoPurchase;

        public String carfaxId;

        public boolean carfaxEnabled;

        public String autoCheckPasswd;

        public boolean autoCheckEnabled;

        public String autoCheckId;

        public boolean carfaxAutoPurchase;

        public String carfaxPasswd;

        public String autoCheckGateway;
    }

    global Class Aax {
        public String aaxSecurityToken;
        public String aaxClientId;

        public String aaxDealerId;

        public String aaxUserId;

    }


        global class Transactions {
        public String[] modifiedBy;//ModifiesBy

        public String paymentType;

        public long refundSubscription;

        public PaymentProfile ccProfile;//?PaymentProfile??

        public String type;

        public DateTime timestamp;

        public double amount;

        public double finalAmount;

        public String description;

        public long parentPaymentTransactionId;

        public String userId;

        public String ccTransactionId;

        private String refundTransactionCount;
    }

    global class Options {
        public boolean cICL;

        public boolean dcAL;

        public boolean immrLink;

        public boolean dcAPI;

        public boolean aqPro;

        public boolean demoAccount;

        public boolean webSite;

        public boolean GDMS;

        public boolean aaxIntegration;

        public boolean optOut;

        public boolean cISMC;

        public boolean multipleLogin;

        public boolean cICARS;

    }

    global class DoWeNeedThese {
        public String cookie;

        public String cookieApi;

        public Id[] partnerIds;

        public String rooftopANET;

        public String rooftopNADA;

        //public ? smcBuyerId;

        public String eventNotificationToken;

        public String reference;

        public DateTime[] pastCookies;

    }

    global class TableDomains {
        //public [] peNADATableDomain;

        //public [] homeRegionSelectedDomain;

        //public [] peBBKTableDomain;

        //public [] peKBBTableDomain;

        public String regionSelectedDomain;

        //public [] menuStyleDomain;
    }

    //public static String testJsonInput = '{"AccountDetail":{"accountStatus":"Test Stauus","autoniqAccountName":"Test Account Name","accountType":"Test Account Type", "auctionAccessNumber":"Test", "city":"Chicago", "country":"United States", "email":"test@email.com","fax":"3125554321","latitude":846.00,"longitude":123.00,"noOfSubscriptions":2,"phone":"3125551234","postCode":"60004","state":"Illinolis"},"UserDetail":{"login":"My login Id", "lastName":"polavi","phone":"8475551234","phome2":"8475554321","address":"My Address","postalCode":"60067","state":"Ohio"}}';
}