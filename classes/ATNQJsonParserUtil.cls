public class ATNQJsonParserUtil {
    
    public  sObject converJasonToSFsObject(String rawJson,String objectType, Map<String, String> jsonFieldsToSFObjectFieldsMap){
		System.debug('=========> jsonFieldsToSFObjectFieldsMap: ' + jsonFieldsToSFObjectFieldsMap);
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjectType = gd.get(objectType); 
        Schema.DescribeSObjectResult describeResult = sobjectType.getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap(); 
        
        Schema.sObjectType objectDef = Schema.getGlobalDescribe().get(objectType).getDescribe().getSObjectType();
        sObject newObject = objectDef.newSobject();
        Map<String, Schema.SobjectField> ObjectFieldsMap = objectDef.getDescribe().fields.getMap();
        Map<String, String> jsonMap = (Map<String,String>) JSON.deserialize(rawJson, Map<String,String>.class);
        System.debug('=========> jsonMap ' + jsonMap);
    	
        newObject = createSobjectFromJson(rawJson, newObject,jsonFieldsToSFObjectFieldsMap, ObjectFieldsMap);
        System.debug('=========> returning Object ' + newObject);
        return newObject;
	} 
    
    private static sObject createSobjectFromJson(String rawJson, sObject newObject, Map<String, String> jsonFieldsToSFObjectFieldsMap, Map<String, Schema.SobjectField> ObjectFieldsMap){
        
        Map<String, String> jsonMap = (Map<String,String>) JSON.deserialize(rawJson, Map<String,String>.class);
        System.debug('=========> jsonMap ' + jsonMap);
        if(jsonMap==null){
        	return newObject;
		}
        String passwordFieldType = ObjectFieldsMap.get('Password__c').getDescribe().getType().name().ToLowerCase();
        System.debug('=========> Password Field Type: ' + passwordFieldType);
    	for(String field: jsonFieldsToSFObjectFieldsMap.keySet()){ 
            System.debug('=========> field ' + field);
            if(jsonFieldsToSFObjectFieldsMap.containsKey(field)){
            	String targetFieldName = jsonFieldsToSFObjectFieldsMap.get(field);
                if(ObjectFieldsMap.get(targetFieldName).getDescribe().isUpdateable()){
            	 System.debug('=========> targetFieldName ' + targetFieldName);
            		string fieldType = ObjectFieldsMap.get(targetFieldName).getDescribe().getType().name().ToLowerCase();
                	System.debug('=========> fieldType ' + fieldType);
                    if(newObject==null){
                        System.debug('+++++=========> newObject is null');
                        continue;
                    }
                    if(fieldType == 'string' || fieldType =='phone' || fieldType =='picklist' || fieldType =='email' || fieldType =='id' || fieldType =='url' || fieldType ==passwordFieldType){
                        if(jsonMap.get(field)!=null){
                        	newObject.put(targetFieldName, jsonMap.get(field));
                        }
                    	
                	}
                    if(fieldType=='encryptedstring'){
                    	newObject.put(targetFieldName, jsonMap.get(field));
                    	
                	}
                    if(fieldType == 'integer'){
                    	newObject.put(targetFieldName, Integer.valueOf(jsonMap.get(field)));
                    	
                	}
                    if(fieldType == 'double'){
                    	newObject.put(targetFieldName, double.valueOf(jsonMap.get(field)));
                    	
                	}
                    if(fieldType == 'long'){
                    	newObject.put(targetFieldName, long.valueOf(jsonMap.get(field)));
                    	
                	}
                    if(fieldType == 'decimal'){
                    	newObject.put(targetFieldName, decimal.valueOf(jsonMap.get(field)));
                    	
                	}
                    if(fieldType == 'date'){
                    	newObject.put(targetFieldName, Date.valueOf(jsonMap.get(field)));
                    	
                	}
                    if(fieldType == 'datetime'){
                    	Date dt = Date.parse(jsonMap.get(field));
                    	newObject.put(targetFieldName, DateTime.newInstance(dt.year(),dt.month(),dt.day(),0,0,0));
                	}
                    if(fieldType == 'boolean'){
                    	newObject.put(targetFieldName, jsonMap.get(field)==null?false:boolean.valueOf(jsonMap.get(field)));
                	}
                    
                }else{
                    System.debug('=========> Field  ' + field + ' not updateable');
                    if(field=='id'){
                        newObject.put('Id', jsonMap.get(field));
                    }
                }
            }else{
                System.debug('=========> Json Map did not contain  ' + field);
            }

		}
        System.debug('=========> returning Object ' + newObject);
        
        return newObject;
    }
    
    public static boolean isRequiredContactFildMissing(CacheContract.UserDetail u, List<String> requiredFields){
        boolean result;
        
        return result;
    }
    
    
    public  Autoniq_Account__c converJasonToSFsAutoniqAccount(String rawJson){ 
        System.debug('=========> Raw Json for Account  ' + rawJson);
        
        CacheContract.AccountDetail account = (CacheContract.AccountDetail)JSON.deserialize(rawJson, CacheContract.AccountDetail.class);
		System.debug('=========> Account Detail  ' + account);
        Autoniq_Account__c acc = createAutoniqAccountWithAccountDetailData(account);
                
        return acc;
    }
    
    private static Autoniq_Account__c createAutoniqAccountWithAccountDetailData(CacheContract.AccountDetail account){
        
        Autoniq_Account__c acc = new Autoniq_Account__c();
        acc.Id = account.id;
        acc.Account_Type__c = account.accountType;
        acc.AccountStatus__c = (account.accountStatus==null?'Active':account.accountStatus);
        acc.Dealership_AuctionACCESS_Number__c = account.auctionAccessNumber;
        acc.Name =  account.autoniqAccountName;
        acc.AccountStatus__c = account.accountStatus;
        acc.City__c = account.city;
        acc.Country__c = account.country;
        acc.Email__c = account.email;
        acc.Latitude__c = account.latitude;
        acc.Longitude__c = account.longitude;
        acc.No_Of_Subscriptions__c = account.noOfSubscriptions;
        //acc.Phone__c = account.phone;
        acc.Fax__c = account.fax;
        acc.PostalCode__c = account.postCode;
        acc.State__c = account.state;
        System.debug('=========> returning autoniq Account: ' + acc);
        return acc;
    }
    
    public static CacheContract.AccountDetail  createAccountDetailWithAutoniqAccountData(Autoniq_Account__c account){

        CacheContract.AccountDetail acc = new CacheContract.AccountDetail();
        acc.id = account.Id;
        acc.accountType = account.Account_Type__c;
        acc.accountStatus = account.AccountStatus__c;
        acc.auctionAccessNumber = account.Dealership_AuctionACCESS_Number__c;
        acc.autoniqAccountName  =  account.Name;
        acc.city = account.City__c;
        acc.country = account.Country__c;
        acc.email = account.Email__c;
        acc.latitude = account.Latitude__c;
        acc.longitude = account.Longitude__c;
        if(account.No_Of_Subscriptions__c!=null){
        	acc.noOfSubscriptions = Integer.valueOf(account.No_Of_Subscriptions__c);
        }
        //acc.phone = account.Phone__c;
        acc.fax = account.Fax__c;
        acc.postCode = account.PostalCode__c;
        acc.state = account.State__c;
        System.debug('=========> returning AccountDetail: ' + acc);
        return acc;
    }
    
    public static CacheContract.UserDetail createUserDetailWithContactData( Contact user){
        
        CacheContract.UserDetail u = new CacheContract.UserDetail();

        u.firstName=user.FirstName;
		u.lastName=user.LastName;
		u.email=user.Email;
        if(user.Autoniq_User_ID__c!=null){
          u.autoniqUserId=user.Autoniq_User_ID__c;    
        }
        if(user.Autoniq_Account__c!=null){
            u.autoniqAccountId=user.Autoniq_Account__c;
        }
        u.password=user.Password__c;
        u.mobile=user.MobilePhone;
        u.altPhone=user.Alternate_Phone__c;
        if(u.internalUser!=null){
          u.internalUser=user.Internal_User__c;    
        }
        //if(u.internalUserId!=null){
        //    user.Internal_User_ID__c = String.valueOf(u.internalUserId);
        //}
        //if(u.userAutionAccessNumber!=null){
        //  user.auctionAccessId__c  = Integer.valueOf(u.userAutionAccessNumber);    
        //}
        if(user.Rep_Auction_Access_Number__c!=null){
          u.repAuctionAccessNumber=Integer.valueOf(user.Rep_Auction_Access_Number__c);    
        }
        return u;
    }

	public  final Map<String,String> jsonUserDetailToContactMap = new Map<String, String>{
        'id' => 'Id',
        'login' => 'Login_ID__c',
		'mobile' => 'phone',
		'altPhone' => 'Alternate_Phone__c',
		'address' => 'MailingAddress',
		'postalCode' => 'AFC_Primary_Postalcode__c',
		'country' => 'AFC_Primary_Country__c',
		'state' => 'City_State__c',
		'firstName' => 'FirstName',
		'lastName' => 'LastName',
		'autoniqUserId' => 'Autoniq_User_ID__c',
		'password' => 'Password__c',
		'salutation' => 'Salutation',
		'repAuctionAccessNumber' => 'Rep_Auction_Access_Number__c',
		'autoniqUserId' => 'Autoniq_User_ID__c',
		'internalUser' => 'Internal_User__c',
		'internalUserId' => 'Internal_User_ID__c'
            /*,
            'lastName' => '',
            'dealership' => 'dealership',
            'city' => 'city',
            'mobileDeviceType' => 'mobileDeviceType',
            'homeRegionZipCode' => 'homeRegionZipCode',
            'referredBy' => 'referredBy',
            'referredByUserId' => 'referredByUserId',
            'createdBy' => 'createdBy'
			*/ 
    };

	public final List<String> requiredContactFields = new List<String>{'firstName','lastName','mobile'};//not up=to-date, not used
        
	public  final Map<String,String> jsonAccountDetailToATNQAccountMap = new Map<String, String>{
        'id' => 'Id',
        'accountStatus' => 'AccountStatus__c',
		'number' => 'Auction_Access_Number__c',
		'autoniqAccountName' => 'Name',
        'accountType' => 'Account_Type__c',
		'auctionAccessNumber' => 'Dealership_AuctionACCESS_Number__c',
		'city' => 'City__c',
		'country' => 'Country__c',
		'email' => 'Email__c',
		'fax' => 'Fax__c',
		'latitude' => 'Latitude__c',
		'longitude' => 'Longitude__c',
		'noOfSubscriptions' => 'No_Of_Subscriptions__c',
		'phone' => 'Phone__c',
		'postalCode' => 'PostalCode__c',
		'state' => 'State__c'
    };   


}