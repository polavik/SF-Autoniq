global class UserDetail {

   		public String id;
        public String firstName;//Required
		public String lastName;//Required
		public String mobile;//Maybe Required if available
		public String email;//Maybe Required if available
		public String altEmail;
		//public String autoniqUserId;//Maybe Required if available
        public String username;//Maybe Required if available
		//public String phone2;
        public String altPhone;
        public String password;//Maybe Required if available (Encryptedstring)
        public boolean internalUser;//Maybe Required if available (may not apply to FE)
        public integer internalUserId;//Maybe Required if available (may not apply to FE)
        public integer repAutionAccessNumber;//Maybe Required if available
        public integer userAutionAccessNumber;//Maybe Required if available
}
/*
   public String dealership;
   public String auctionAccessId;
   public String phoneCountryCode;
   public String phone;
   public String deviceType;
   public String country;
   public String address1;
   public String address2;
   public String city;
   public String state;
   public String zip;
   public String creditCardNumber;
   public String creditCardCode;
   public String creditCardExpiration;
   public String promoCode;
   public String referrer;
   public String billingAddress1;
   public String billingAddress2;
   public String billingCity;
   public String billingState;
   public String billingZip;
   public String customerProfileId;
    }
*/