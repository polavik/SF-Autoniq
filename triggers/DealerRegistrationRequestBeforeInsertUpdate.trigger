trigger DealerRegistrationRequestBeforeInsertUpdate on Dealer_Registration_Request__c (before insert, before update) {
/*
//DEPRECATED TRIGGER - DEACTIVATED ON APRIL 4, 2016 PER Story: B-41158
   Set<String> orgIds = new Set<String>();
   Set<String> oppNames = new Set<String>();
   List<Opportunity> newOpps = new List<Opportunity>();


   for(Dealer_Registration_Request__c drr: Trigger.new){
       if(drr.organization_id__c != null){
           orgIds.add(drr.organization_id__c);
           oppNames.add(drr.name.toUpperCase() + ' - New Dealer Request');
       }
   }
   //List<Account> orgs = [select id, Openlane_Org_ID__c, ownerId from account where Openlane_Org_ID__c in :orgIds];
   List<Adesa_com_Detail__c> orgs = [select id, ATC_Organization_ID__c,Account__c from Adesa_com_Detail__c where ATC_Organization_ID__c in :orgIds];
   List<Opportunity> existingOpps = [select id, name from Opportunity where name in :oppNames];
   
   Map<String, Adesa_com_Detail__c> orgById = new Map<String, Adesa_com_Detail__c>();
   for(Adesa_com_Detail__c org: orgs){
      orgById.put(org.ATC_Organization_ID__c, org);
   }
   Map<String, Opportunity> oppsByname = new Map<String, Opportunity>();
   for(Opportunity opp: existingOpps){
      oppsByname.put(opp.name, opp);
   }
   
   for(Dealer_Registration_Request__c drr: Trigger.new){
       if(drr.organization_id__c != null && orgById.containsKey(drr.organization_id__c)){
           drr.ADESA_com_Detail__c = orgById.get(drr.organization_id__c).id;
           drr.Account__c = orgById.get(drr.organization_id__c).Account__c;
           if(!oppsByName.containsKey(drr.name.toUpperCase() + ' - New Dealer Request')){
               Opportunity opp = new Opportunity();
               opp.name = drr.name.toUpperCase() + ' - New Dealer Request';
               opp.stageName = 'Open';
               //opp.ownerId = orgById.get(drr.organization_id__c).ownerId;
               opp.CloseDate = System.today();
               //opp.accountId = orgById.get(drr.organization_id__c).id;
               newOpps.add(opp);
           }
       }
   }
   
   insert newOpps;
   */
   for(Dealer_Registration_Request__c drr: Trigger.new)
   {
       /*
       if(drr.Type_of_Entity__c == 'Repossession Service Provider')
       {
            drr.RecordTypeId = Utils.getRecordTypeId('Dealer_Registration_Request__c', 'RSP - Dealer Registration Request');
       }
       else
       {
            drr.RecordTypeId = Utils.getRecordTypeId('Dealer_Registration_Request__c', 'Dealer Registration Request');          
       }
       */
       //if (Trigger.isInsert) 
       //{
            Map<String, String> countryMap = new Map<String, String>{
            '1' => 'United States',
            '2' => 'Canada',
            '3' => 'ARGENTINA',
            '4' => 'AUSTRALIA',
            '5' => 'BRAZIL',
            '6' => 'CHINA',
            '7' => 'FRANCE',
            '8' => 'GERMANY',
            '9' => 'INDIA',
            '10' => 'INDONESIA',
            '11' => 'ITALY',
            '12' => 'JAPAN',
            '13' => 'KOREA, REPUBLIC OF',
            '14' => 'MEXICO',
            '15' => 'SAUDI ARABIA',
            '16' => 'SOUTH AFRICA',
            '17' => 'TURKEY',
            '18' => 'UNITED KINGDOM',
            '19' => 'AMERICAN SAMOA',
            '20' => 'BELGIUM',
            '21' => 'CHILE',
            '22' => 'COLOMBIA',
            '23' => 'DENMARK',
            '24' => 'ISRAEL',
            '25' => 'LUXEMBOURG',
            '26' => 'PANAMA',
            '27' => 'SWITZERLAND',
            '28' => 'AALAND ISLANDS',
            '29' => 'AFGHANISTAN',
            '30' => 'ALBANIA',
            '31' => 'ALGERIA',
            '32' => 'ANDORRA',
            '33' => 'ANGOLA',
            '34' => 'ANGUILLA',
            '35' => 'ANTARCTICA',
            '36' => 'ANTIGUA AND BARBUDA',
            '37' => 'ARMENIA',
            '38' => 'ARUBA',
            '39' => 'AUSTRIA',
            '40' => 'AZERBAIJAN',
            '41' => 'BAHAMAS',
            '42' => 'BAHRAIN',
            '43' => 'BANGLADESH',
            '44' => 'BARBADOS',
            '45' => 'BELARUS',
            '46' => 'BELIZE',
            '47' => 'BENIN',
            '48' => 'BERMUDA',
            '49' => 'BHUTAN',
            '50' => 'BOLIVIA',
            '51' => 'BOSNIA AND HERZEGOWINA',
            '52' => 'BOTSWANA',
            '53' => 'BOUVET ISLAND',
            '54' => 'BRITISH INDIAN OCEAN TERRITORY',
            '55' => 'BRUNEI DARUSSALAM',
            '56' => 'BULGARIA',
            '57' => 'BURKINA FASO',
            '58' => 'BURUNDI',
            '59' => 'CAMBODIA',
            '60' => 'CAMEROON',
            '61' => 'CAPE VERDE',
            '62' => 'CAYMAN ISLANDS',
            '63' => 'CENTRAL AFRICAN REPUBLIC',
            '64' => 'CHAD',
            '65' => 'CHRISTMAS ISLAND',
            '66' => 'COCOS (KEELING) ISLANDS',
            '67' => 'COMOROS',
            '68' => 'CONGO, Democratic Republic of (was Zaire)',
            '69' => 'CONGO, Republic of',
            '70' => 'COOK ISLANDS',
            '71' => 'COSTA RICA',
            '72' => 'COTE D\'IVOIRE',
            '73' => 'CROATIA (local name: Hrvatska)',
            '74' => 'CUBA',
            '75' => 'CYPRUS',
            '76' => 'CZECH REPUBLIC',
            '77' => 'DJIBOUTI',
            '78' => 'DOMINICA',
            '79' => 'DOMINICAN REPUBLIC',
            '80' => 'ECUADOR',
            '81' => 'EGYPT',
            '82' => 'EL SALVADOR',
            '83' => 'EQUATORIAL GUINEA',
            '84' => 'ERITREA',
            '85' => 'ESTONIA',
            '86' => 'ETHIOPIA',
            '87' => 'FALKLAND ISLANDS (MALVINAS)',
            '88' => 'FAROE ISLANDS',
            '89' => 'FIJI',
            '90' => 'FINLAND',
            '91' => 'FRENCH GUIANA',
            '92' => 'FRENCH POLYNESIA',
            '93' => 'FRENCH SOUTHERN TERRITORIES',
            '94' => 'GABON',
            '95' => 'GAMBIA',
            '96' => 'GEORGIA',
            '97' => 'GHANA',
            '98' => 'GIBRALTAR',
            '99' => 'GREECE',
            '100' => 'GREENLAND',
            '101' => 'GRENADA',
            '102' => 'GUADELOUPE',
            '103' => 'GUAM',
            '104' => 'GUATEMALA',
            '105' => 'GUINEA',
            '106' => 'GUINEA-BISSAU',
            '107' => 'GUYANA',
            '108' => 'HAITI',
            '109' => 'HEARD AND MC DONALD ISLANDS',
            '110' => 'HONDURAS',
            '111' => 'HONG KONG',
            '112' => 'HUNGARY',
            '113' => 'ICELAND',
            '114' => 'IRAN (ISLAMIC REPUBLIC OF)',
            '115' => 'IRAQ',
            '116' => 'IRELAND',
            '117' => 'JAMAICA',
            '118' => 'JORDAN',
            '119' => 'KAZAKHSTAN',
            '120' => 'KENYA',
            '121' => 'KIRIBATI',
            '122' => 'KOREA, DEMOCRATIC PEOPLE\'S REPUBLIC OF',
            '123' => 'KUWAIT',
            '124' => 'KYRGYZSTAN',
            '125' => 'LAO PEOPLE\'S DEMOCRATIC REPUBLIC',
            '126' => 'LATVIA',
            '127' => 'LEBANON',
            '128' => 'LESOTHO',
            '129' => 'LIBERIA',
            '130' => 'LIBYAN ARAB JAMAHIRIYA',
            '131' => 'LIECHTENSTEIN',
            '132' => 'LITHUANIA',
            '133' => 'MACAU',
            '134' => 'MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF',
            '135' => 'MADAGASCAR',
            '136' => 'MALAWI',
            '137' => 'MALAYSIA',
            '138' => 'MALDIVES',
            '139' => 'MALI',
            '140' => 'MALTA',
            '141' => 'MARSHALL ISLANDS',
            '142' => 'MARTINIQUE',
            '143' => 'MAURITANIA',
            '144' => 'MAURITIUS',
            '145' => 'MAYOTTE',
            '146' => 'MICRONESIA, FEDERATED STATES OF',
            '147' => 'MOLDOVA, REPUBLIC OF',
            '148' => 'MONACO',
            '149' => 'MONGOLIA',
            '150' => 'MONTSERRAT',
            '151' => 'MOROCCO',
            '152' => 'MOZAMBIQUE',
            '153' => 'MYANMAR',
            '154' => 'NAMIBIA',
            '155' => 'NAURU',
            '156' => 'NEPAL',
            '157' => 'NETHERLANDS',
            '158' => 'NETHERLANDS ANTILLES',
            '159' => 'NEW CALEDONIA',
            '160' => 'NEW ZEALAND',
            '161' => 'NICARAGUA',
            '162' => 'NIGER',
            '163' => 'NIGERIA',
            '164' => 'NIUE',
            '165' => 'NORFOLK ISLAND',
            '166' => 'NORTHERN MARIANA ISLANDS',
            '167' => 'NORWAY',
            '168' => 'OMAN',
            '169' => 'PAKISTAN',
            '170' => 'PALAU',
            '171' => 'PALESTINIAN TERRITORY, Occupied',
            '172' => 'PAPUA NEW GUINEA',
            '173' => 'PARAGUAY',
            '174' => 'PERU',
            '175' => 'PHILIPPINES',
            '176' => 'PITCAIRN',
            '177' => 'POLAND',
            '178' => 'PORTUGAL',
            '179' => 'PUERTO RICO',
            '180' => 'QATAR',
            '181' => 'REUNION',
            '182' => 'ROMANIA',
            '183' => 'RUSSIAN FEDERATION',
            '184' => 'RWANDA',
            '185' => 'SAINT HELENA',
            '186' => 'SAINT KITTS AND NEVIS',
            '187' => 'SAINT LUCIA',
            '188' => 'SAINT PIERRE AND MIQUELON',
            '189' => 'SAINT VINCENT AND THE GRENADINES',
            '190' => 'SAMOA',
            '191' => 'SAN MARINO',
            '192' => 'SAO TOME AND PRINCIPE',
            '193' => 'SENEGAL',
            '194' => 'SERBIA AND MONTENEGRO',
            '195' => 'SEYCHELLES',
            '196' => 'SIERRA LEONE',
            '197' => 'SINGAPORE',
            '198' => 'SLOVAKIA',
            '199' => 'SLOVENIA',
            '200' => 'SOLOMON ISLANDS',
            '201' => 'SOMALIA',
            '202' => 'SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS',
            '203' => 'SPAIN',
            '204' => 'SRI LANKA',
            '205' => 'SUDAN',
            '206' => 'SURINAME',
            '207' => 'SVALBARD AND JAN MAYEN ISLANDS',
            '208' => 'SWAZILAND',
            '209' => 'SWEDEN',
            '210' => 'SYRIAN ARAB REPUBLIC',
            '211' => 'TAIWAN',
            '212' => 'TAJIKISTAN',
            '213' => 'TANZANIA, UNITED REPUBLIC OF',
            '214' => 'THAILAND',
            '215' => 'TIMOR-LESTE',
            '216' => 'TOGO',
            '217' => 'TOKELAU',
            '218' => 'TONGA',
            '219' => 'TRINIDAD AND TOBAGO',
            '220' => 'TUNISIA',
            '221' => 'TURKMENISTAN',
            '222' => 'TURKS AND CAICOS ISLANDS',
            '223' => 'TUVALU',
            '224' => 'UGANDA',
            '225' => 'UKRAINE',
            '226' => 'UNITED ARAB EMIRATES',
            '227' => 'UNITED STATES MINOR OUTLYING ISLANDS',
            '228' => 'URUGUAY',
            '229' => 'UZBEKISTAN',
            '230' => 'VANUATU',
            '231' => 'VATICAN CITY STATE (HOLY SEE)',
            '232' => 'VENEZUELA',
            '233' => 'VIET NAM',
            '234' => 'VIRGIN ISLANDS (BRITISH)',
            '235' => 'VIRGIN ISLANDS (U.S.)',
            '236' => 'WALLIS AND FUTUNA ISLANDS',
            '237' => 'WESTERN SAHARA',
            '238' => 'YEMEN',
            '239' => 'ZAMBIA',
            '240' => 'ZIMBABWE',
            '241' => 'SAINT BARTHELEMY',
            '242' => 'SAINT MARTIN',
            '243' => 'SERBIA',
            '244' => 'SINT MAARTEN (DUTCH PART)',
            '245' => 'SOUTH SUDAN',
            '246' => 'BONAIRE, SINT EUSTATIUS AND SABA',
            '247' => 'CURACAO',
            '248' => 'GUERNSEY',
            '249' => 'ISLE OF MAN',
            '250' => 'JERSEY',
            '251' => 'MONTENEGRO'};
           if(drr.Country_Id__c != null)
           {
                drr.Country__c = countryMap.get(drr.Country_Id__c);
           }
       //} 
       
   
   }

}