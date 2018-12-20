({
	doInit : function(cmp, event, helper) {
        
       helper.getUserSetting(cmp);
      
    },

    handleSelect: function(component, event, helper) {
        var menuValue = event.detail.menuItem.get("v.value");
       
        if (menuValue === "Edit") {
    		helper.editMode(component);
    	}
    	else if (menuValue === "Cancel") {
         
            helper.getUserSetting(component);
    		helper.viewMode(component);
    	}
    	else if (menuValue === "Save") {
           console.log(JSON.stringify(component.get('v.userSetting')));
         
            helper.saveSettings(component);
            helper.getUserSetting(component);
            helper.viewMode(component);
    	}
    
    }

})