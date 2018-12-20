({
	 getSubscriptionItems : function(cmp) {
		var action = cmp.get("c.getSubscriptionItemsToAdd");
        console.log('contactId = ' + cmp.get("v.contactId") );
        action.setParams({ contactId : cmp.get("v.contactId") });
        action.setCallback(this, function(response){
          var state = response.getState();
            if (state === "SUCCESS") {
               
              var items = response.getReturnValue();
              //console.log('-- items ' + JSON.stringify( items ));
              cmp.set("v.subscriptionItems", items);
            /*var container = cmp.find("container");
              $A.createComponent(
                    "c:ATNQSubItemIterator",
                    {
                        "subscriptionItems" : items,
                       
                    },
                    function(bn)
                    {
                        var bdy=container.get("v.body");
                        bdy.push(bn);
                        container.set("v.body",bdy);
                    }
                );*/
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
})