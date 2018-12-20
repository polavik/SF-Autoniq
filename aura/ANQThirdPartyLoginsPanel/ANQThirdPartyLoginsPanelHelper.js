({
	getThirdPartyItems : function(cmp) {
	    var action = cmp.get("c.getThirdPartyItems");
	        
	    action.setParams({ contactId : cmp.get("v.recordId") });
	    action.setCallback(this, function(response){
	      var state = response.getState();
	      if (state === "SUCCESS") {
	        cmp.set("v.thirdPartyItems", response.getReturnValue());              
	      }
	    });
	    $A.enqueueAction(action);
  	}
})