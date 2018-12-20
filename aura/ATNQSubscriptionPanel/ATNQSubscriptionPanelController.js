({
	doInit : function(cmp, event, helper) {
        
       	helper.getSubscriptionItems(cmp);
       
    },
    getSelectedName: function (cmp, event) {
        //when something is checked on the data table

       /* var selectedRows = event.getParam('selectedRows');
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            alert("You selected: " + selectedRows[i].opportunityName);
        }*/
    },

   
    handleSelect: function(component, event, helper) {
        var menuValue = event.detail.menuItem.get("v.value");
        //alert("! " + v.subscription.id);
        if (menuValue === "view") {
            var subId = component.get("v.subscription.id");
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": subId
            });
            navEvt.fire();
        }
        else {
             var addSub = component.find("addSubscriptions");
          
        	$A.util.removeClass(addSub, "hide"); 
        }
    }
    
	
})