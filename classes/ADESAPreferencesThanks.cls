public class ADESAPreferencesThanks { 

    public ADESAPreferencesThanks(){ 
         //Start             
         Map<String, Language_Settings__c> CslanguageSettings = Language_Settings__c.getAll();
         string userlanguage = apexpages.currentpage().getparameters().get('lang');
         system.debug('userlanguage_______'+userlanguage);
         //ENd         
    }
}