({
	doInit : function(cmp, event, helper) {
      
    },
	handleCheckbox : function (cmp, event) {
      var toggleVal = cmp.find('inputToggle').get('v.value');
      var isChecked = cmp.find('inputToggle').get('v.checked');
      var compEvent = cmp.getEvent("ATNQSubItemSelected");
		
		compEvent.setParams({"onViewPage" : false });
		compEvent.setParams({"subItemName" : cmp.get('v.item.name') });
		
		compEvent.fire();
    },
    handleDateChange: function (cmp, event) {
		var startDate = cmp.find('startDate').get('v.value');
		
		
		console.log('start date changed to ' + startDate );
    }
})