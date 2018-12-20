({
	doInit : function(cmp, event, helper) {
        
    },
	handleCheckbox : function (cmp, event) {
      var toggleVal = cmp.find('inputToggle').get('v.value');
      var isChecked = cmp.find('inputToggle').get('v.checked');
      console.log(isChecked);
    }
})