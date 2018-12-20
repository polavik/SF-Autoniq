({
    getUserSetting : function(cmp) {
      var action = cmp.get("c.getUserSetting");
        
      action.setParams({ contactId : cmp.get("v.recordId") });
      action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
          cmp.set("v.userSetting", response.getReturnValue());              
        }
    });

    
    $A.enqueueAction(action);
  },

 

  editMode : function (component) {
    var userSettingView = component.find("userSettingsView");
        var userSettingEdit = component.find("userSettingsEdit");
        var settingsSave = component.find("settingsSave");
        var settingsEdit = component.find("settingsEdit");
        var settingsCancel = component.find("settingsCancel");
        
        $A.util.addClass(userSettingView, "hide");
        $A.util.removeClass(userSettingEdit, "hide");
        $A.util.addClass(settingsEdit, "hide");
        $A.util.removeClass(settingsSave, "hide");
        $A.util.removeClass(settingsCancel, "hide");
      
  },

  viewMode : function (component) {
    var userSettingView = component.find("userSettingsView");
        var userSettingEdit = component.find("userSettingsEdit");
        var settingsSave = component.find("settingsSave");
        var settingsEdit = component.find("settingsEdit");
        var settingsCancel = component.find("settingsCancel");
        
        $A.util.addClass(userSettingEdit, "hide");
        $A.util.removeClass(userSettingView, "hide");
        $A.util.removeClass(settingsEdit, "hide");
        $A.util.addClass(settingsSave, "hide");
        $A.util.addClass(settingsCancel, "hide");
      
  },
    saveSettings : function (cmp) {
          //var message = event.getParam("message");
        //var userSetting = event.getParam("userSetting");
        //console.log("event reveived " );
        var action = cmp.get("c.updateUserSetting");
        
        action.setParams({ setting : cmp.get("v.userSetting") });
        action.setCallback(this, function(response){
          var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());  
            }
        });
        $A.enqueueAction(action);
    }

})