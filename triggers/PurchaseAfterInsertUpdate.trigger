trigger PurchaseAfterInsertUpdate on Purchase__c (after insert, after update) 
{
  List<Purchase__c> creditEligiblePurchases = new List<Purchase__c>();
  for (Purchase__c p : Trigger.new)
  {
    try
    {      
      if (p.ATC_Sale_Date__c != null && // Verify this was a real purchase with an actual sale date
        p.ATC_Sale_Date__c.date().daysBetween(Date.today()) < 5 &&  // Sanity check, purchase should be less than 5 days old
        p.ATC_Buyer__c != null && 
        p.ATC_Seller__c !=null &&
        Long.valueOf(p.Vehicle_ID__c) > 0 &&
        (
            'OPENLANE Auction'.equalsIgnoreCase(p.Private_Label__c) || 
            'OPENLANE.ca Open Auction'.equalsIgnoreCase(p.Private_Label__c) || 
            'NEXT.ADESA.ca Open Auction'.equalsIgnoreCase(p.Private_Label__c)||
            'ADESA Auction'.equalsIgnoreCase(p.Private_Label__c)||
            'ADESA.ca Open Auction'.equalsIgnoreCase(p.Private_Label__c)
        ) &&
        p.Transport_Type__c <= 2 &&
        p.sale_class__c != null &&
        p.sale_class__c.toUpperCase().contains('OPEN') &&
        !p.Payment_Method__c.equalsIgnoreCase('Settle with Seller') &&
        //B-20628 Updates to Buyer Auction Credits for DealerBlock Arbitrations
        //----------------------------------------------------------------------
        !'pay processing auction'.equalsIgnoreCase(p.Payment_Method__c) && 
        !'adesa\'s centralized payment'.equalsIgnoreCase(p.Payment_Method__c) &&
        !'ally financial floorplan (processed by auction)'.equalsIgnoreCase(p.Payment_Method__c) &&
        !'tfs floorplan'.equalsIgnoreCase(p.Payment_Method__c) &&
        !'toyota fin svcs floorplan (processed by auction)'.equalsIgnoreCase(p.Payment_Method__c) &&
        !'pay adesa worldwide'.equalsIgnoreCase(p.Payment_Method__c) &&
        !'pay using other floorplans'.equalsIgnoreCase(p.Payment_Method__c) &&
        !'pay openlane worldwide - wire'.equalsIgnoreCase(p.Payment_Method__c) &&
        !'pay processing adesa auction'.equalsIgnoreCase(p.Payment_Method__c)
     // !p.Is_Dealer_Block__c.equalsIgnoreCase('Yes')            
 
        )
      {      
        if (Trigger.isInsert)
        {
          System.debug('CreditEligible purchases inside update ');    
          creditEligiblePurchases.add(p);
        }
        else if (Trigger.isUpdate && (Trigger.oldMap.get(p.Id).ATC_Sale_Date__c == null ||
                                      Trigger.oldMap.get(p.Id).sale_class__c == null))
        {
          System.debug('CreditEligible purchases inside update ');
          creditEligiblePurchases.add(p);
        }
      }
    }
    catch(Exception e)
    {
      // Not eligible, do nothing!
    }
    //System.debug('Trigger.oldMap.get(p.Id).ATC_Sale_Date__c'+Trigger.oldMap.get(p.Id).ATC_Sale_Date__c);
    //System.debug('Trigger.oldMap.get(p.Id).sale_class__c'+Trigger.oldMap.get(p.Id).sale_class__c);
  }  
  System.debug('CreditEligible purchases size ' + creditEligiblePurchases.size());
  Map<ID, List<Purchase__c>> buyerPurchasesMap = new Map<ID, List<Purchase__c>>();
  Map<ID, List<Purchase__c>> sellerPurchasesMap = new Map<ID, List<Purchase__c>>();
  for (Purchase__c purchase : creditEligiblePurchases)
  {
                System.debug('In the loop of eligible purchases ' );
    List<Purchase__c> buyerPurchases = buyerPurchasesMap.get(purchase.ATC_Buyer__c);
    List<Purchase__c> sellerPurchases = sellerPurchasesMap.get(purchase.ATC_Seller__c);
    if (buyerPurchases == null)
    {
      buyerPurchases = new List<Purchase__c>();
      buyerPurchasesMap.put(purchase.ATC_Buyer__c, buyerPurchases);
    }
    if(sellerPurchases == null){
      sellerPurchases = new List<Purchase__c>();
      sellerPurchasesMap.put(purchase.ATC_Seller__c, sellerPurchases);
    }
    buyerPurchases.add(purchase);
    sellerPurchases.add(purchase);
  }
  
  List<Auction_Credit__c> availableCredits = [
    SELECT Id, Account__c, Purchase__c, recordTypeId, Action_Package__r.Name,Action_Package__r.RecordTypeId
    FROM Auction_Credit__c
    WHERE Status__c = 'Available'
    AND (Account__c IN  :sellerPurchasesMap.keySet() 
    OR Account__c IN :buyerPurchasesMap.keySet())
    ORDER BY Expires__c
  ];
  
  ID buyerGoodwillRT = Utils.getRecordTypeId('Auction_Credit__c', 'Auction Credit - Goodwill');
  ID buyerPromotionalRT = Utils.getRecordTypeId('Auction_Credit__c', 'Auction Credit - Promotional');
  ID sellerGoodwillRT = Utils.getRecordTypeId('Auction_Credit__c', 'Seller Auction Credit - Goodwill');
  ID sellerPromotionalRT = Utils.getRecordTypeId('Auction_Credit__c', 'Seller Auction Credit - Promotional');
  
  ID crfSellerGoodWillApRt = Utils.getRecordTypeId('Action_Package__c', 'CRF - Seller Auction Credit - Goodwill');
  ID crfAcGoodWillApRt = Utils.getRecordTypeId('Action_Package__c', 'CRF - Auction Credit - Goodwill');

  List<Auction_Credit__c> creditsToUpdate = new List<Auction_Credit__c>();
  for (Auction_Credit__c credit : availableCredits)
  {
    List<Purchase__c> buyerPurchases = buyerPurchasesMap.get(credit.Account__c);
    List<Purchase__c> sellerPurchases = sellerPurchasesMap.get(credit.Account__c);
    

System.debug('credit.recordTypeId == buyerGoodwillRT '+(credit.recordTypeId == buyerGoodwillRT));
System.debug('credit.recordTypeId == buyerPromotionalRT '+(credit.recordTypeId == buyerPromotionalRT));
System.debug('buyerPurchases == null '+(buyerPurchases == null));
System.debug('sellerPurchases == null'+(sellerPurchases == null));
System.debug('credit.Action_Package__r.Name ' + credit.Action_Package__r.Name);
System.debug('credit.recordTypeId == sellerGoodwillRT ' + (credit.recordTypeId == sellerGoodwillRT));
System.debug('credit.recordTypeId == sellerPromotionalRT'+ (credit.recordTypeId == sellerPromotionalRT));

    if ((credit.recordTypeId == buyerGoodwillRT || credit.recordTypeId == buyerPromotionalRT) && 
         buyerPurchases != null && buyerPurchases.size() > 0)
    {
        // B-20637  Do Not apply Account Level Auction Credits to DealerBlock Sales
        //---------------
      Purchase__c p = buyerPurchases.remove(0);
System.debug('buyerPurchases.size() '+ String.valueOf(buyerPurchases.size()));
      if (credit.Action_Package__r.Name == null &&
          (
           'pay processing auction'.equalsIgnoreCase(p.Payment_Method__c) || 
           'adesa\'s centralized payment'.equalsIgnoreCase(p.Payment_Method__c) ||
           'ally financial floorplan (processed by auction)'.equalsIgnoreCase(p.Payment_Method__c) ||
           'tfs floorplan'.equalsIgnoreCase(p.Payment_Method__c) ||
           'toyota fin svcs floorplan (processed by auction)'.equalsIgnoreCase(p.Payment_Method__c) ||
           'pay adesa worldwide'.equalsIgnoreCase(p.Payment_Method__c) ||
           'pay using other floorplans'.equalsIgnoreCase(p.Payment_Method__c) ||
           'pay openlane worldwide - wire'.equalsIgnoreCase(p.Payment_Method__c) ||
           'pay processing adesa auction'.equalsIgnoreCase(p.Payment_Method__c)
        ) &&       
          (
           credit.recordTypeId == buyerPromotionalRT ||
           credit.recordTypeId == sellerPromotionalRT ||
           credit.Action_Package__r.RecordTypeId == crfSellerGoodWillApRt ||
           credit.Action_Package__r.RecordTypeId == crfAcGoodWillApRt
           )
      )
      {  // Do Not apply account leve auction credit 
                                }
      else
      {
      credit.Purchase__c = p.Id;
      credit.Status__c = 'Pending Application';
      creditsToUpdate.add(credit);
      }
    }
    if ((credit.recordTypeId == sellerGoodwillRT || credit.recordTypeId == sellerPromotionalRT ) && 
        sellerPurchases != null && sellerPurchases.size() > 0)
    {
      Purchase__c p = sellerPurchases.remove(0);
System.debug('sellerPurchases.size() '+ String.valueOf(sellerPurchases.size()) );
      if (credit.Action_Package__r.Name == null && 
          (
           'pay processing auction'.equalsIgnoreCase(p.Payment_Method__c) || 
           'adesa\'s centralized payment'.equalsIgnoreCase(p.Payment_Method__c) ||
           'ally financial floorplan (processed by auction)'.equalsIgnoreCase(p.Payment_Method__c) ||
           'tfs floorplan'.equalsIgnoreCase(p.Payment_Method__c) ||
           'toyota fin svcs floorplan (processed by auction)'.equalsIgnoreCase(p.Payment_Method__c) ||
           'pay adesa worldwide'.equalsIgnoreCase(p.Payment_Method__c) ||
           'pay using other floorplans'.equalsIgnoreCase(p.Payment_Method__c) ||
           'pay openlane worldwide - wire'.equalsIgnoreCase(p.Payment_Method__c) ||
           'pay processing adesa auction'.equalsIgnoreCase(p.Payment_Method__c)
          ) &&       
          (
            credit.recordTypeId == buyerPromotionalRT ||
            credit.recordTypeId == sellerPromotionalRT ||
            credit.Action_Package__r.RecordTypeId == crfSellerGoodWillApRt ||
            credit.Action_Package__r.RecordTypeId == crfAcGoodWillApRt
          )
      )
      {  // Do Not apply account leve auction credit 
                                }
      else
    {
      credit.Purchase__c = p.Id;
      credit.Status__c = 'Pending Application';
      creditsToUpdate.add(credit);
    }
  }
  }
  
List<Purchase__c> purchasesForQuickCheck = new List<Purchase__c>();
List<Purchase__c> finalPurchasesForQuickCheck = new List<Purchase__c>();
List<Account> accountsRelatedToQuickCheck = new List<Account>();
List<Quick_Check__c> existingQuickCheck = new List<Quick_Check__c>();
  
purchasesForQuickCheck =
  [
  SELECT Id,
  Name,
  Consignee__c,
  Is_Dealer_Block__c,
  Vehicle_Id__c
  FROM Purchase__c
  WHERE Id IN : trigger.new
  AND Is_Dealer_Block__c = 'Yes'
  ];

//Don't add a quick check to purchases where they already exist
existingQuickCheck =
    [
    SELECT Id,
    Purchase__r.Id
    FROM Quick_Check__c
    WHERE Purchase__c IN :purchasesForQuickCheck    
    ];
    
List<Id> existingQCIds = new List<Id>();
for(Quick_Check__c qc : existingQuickCheck)
{
    existingQCIds.add(qc.Purchase__r.Id);
}


//For any Purchase that already has a quick check, do not add to final Purch list
for(Purchase__c purch : purchasesForQuickCheck)
{
    Boolean inList = false;
    for(Id QCId : existingQCIds)
    {
        if(purch.Id == QCId)
        {
            inList = true;
        }
    }
    if(inList == false)
    {
        finalPurchasesForQuickCheck.add(purch);
    }
}


  
List<String> consigneesList = new List<String>();
for(Purchase__c purch : finalPurchasesForQuickCheck)
{
    consigneesList.add(purch.Consignee__c);
}


  
accountsRelatedToQuickCheck =
  [
  SELECT Id,
  OwnerId
  FROM Account
  WHERE Id IN : consigneesList
  ];


  
Map<String, Account> purchaseAccountMapper = new Map<String, Account>();
for (String cons : consigneesList)
{
    for(Account acct : accountsRelatedToQuickCheck)
    {
        if(acct.Id == cons)
        {
            purchaseAccountMapper.put(cons, acct);
            
        }
    }
}
List<ID> accountOwnerIds = new List<ID>(); //We need to grab the User object's isActive field for later use
for(Account a : accountsRelatedToQuickCheck) //Make a list of all Owner IDs that we will need
{
    accountOwnerIds.add(a.OwnerId);
}


List<User> ownersOfAccounts = new List<User>();//Grab the actual User objects and their isActive fields
ownersOfAccounts = 
[
SELECT Id,
isActive
FROM User
WHERE Id IN :accountOwnerIds
];

Map<Account, User> accountUserMapper = new Map<Account, User>();
for(Account a : accountsRelatedToQuickCheck)
{
    for(User u : ownersOfAccounts)
    {
        if(u.Id == a.OwnerId)
        {
            accountUserMapper.put(a, u);
        }
    }
}

for(Purchase__c purch : finalPurchasesForQuickCheck)
{
    try
    {
        Quick_Check__c qc = new Quick_Check__c();
        qc.Name = purch.Name;
        if(accountUserMapper.get(purchaseAccountMapper.get(purch.Consignee__c)).isActive)
        {
                qc.OwnerId = (purchaseAccountMapper.get(purch.Consignee__c)).OwnerId;
        }
        qc.Purchase__c = purch.Id;
        qc.View_Vehicle_Details__c = 'https://buy.adesa.com/openauction/detail.html?vehicleId=' + purch.Vehicle_Id__c;
        insert qc;
    } catch (NullPointerException e){
        System.debug(e);
    }
}  
  
  update creditsToUpdate;
}