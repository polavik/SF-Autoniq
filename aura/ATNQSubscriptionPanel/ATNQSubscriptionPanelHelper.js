({
	 getSubscriptionItems : function(cmp) {
		var action = cmp.get("c.getSubscriptionItems");
        
        action.setParams({ contactId : cmp.get("v.recordId") });
         action.setCallback(this, function(response){
          var state = response.getState();
            if (state === "SUCCESS") {
              cmp.set("v.subscriptionItems", response.getReturnValue().subscriptionItems);
              cmp.set("v.subscription", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})