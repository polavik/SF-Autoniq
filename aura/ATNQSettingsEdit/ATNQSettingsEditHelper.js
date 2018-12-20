({
	 getUserSetting : function(cmp) {
      var action = cmp.get("c.getUserSetting");
        
      action.setParams({ contactId : cmp.get("v.userSetting.Contact__c") });
      action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
          cmp.set("v.userSetting", response.getReturnValue());
          //console.log(response.getReturnValue().Mobile_Device_Type__c);
        }
        else {
        	console.log('failed');
        }
    });
      $A.enqueueAction(action);
  }
})