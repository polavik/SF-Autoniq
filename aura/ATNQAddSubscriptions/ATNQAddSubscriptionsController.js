({
	doInit : function(cmp, event, helper) {
      
       	helper.getSubscriptionItems(cmp);
    },

	onCancel : function(cmp, event, helper) {
		 var addSub = cmp.find("addSubWindow");
            //alert(addSub);

        	$A.util.addClass(addSub, "hide");
	},
	ATNQSubItemSelected : function(cmp, event) {
		
		var subItemName = event.getParam("subItemName");
		var onViewPage = event.getParam("onViewPage");
		var subscriptionItems = cmp.get('v.subscriptionItems');
		//console.log('Event received ' + subItemName + ' - ' + onViewPage);

		var newlst =[];
		for(var i in subscriptionItems) {
			var subItem = subscriptionItems[i];
			if (subItem.name === subItemName) {
				subItem.isViewMode = !onViewPage;
				subItem.isChecked = onViewPage;
			}
			newlst.push(subItem);
		}
		//console.log('newlst ' + JSON.stringify(newlst));
		cmp.set('v.subscriptionItems', newlst);

		/*cmp.find("container").set("v.body",[]);
		var container = cmp.find("container");
		$A.createComponent(
            "c:ATNQSubItemIterator",
            {
                "subscriptionItems" : newlst,
               
            },
            function(bn)
            {
                var bdy=container.get("v.body");
                bdy.push(bn);
                container.set("v.body",bdy);
            }
        );*/
		
	}

})