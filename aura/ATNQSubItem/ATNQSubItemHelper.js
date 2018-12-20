({
	toggleView : function(component) {
        var isViewMode = component.get('v.isViewMode');
        var subItemEdit = component.find("subItemEdit");
        var subItemView = component.find("subItemView");
        //console.log('ATNQSubItemHelper - isViewMode = ' + isViewMode + ' - ' + JSON.stringify(component.get('v.item')));
        if (isViewMode === true) {
            //console.log('ATNQSubItemHelper -hide edit show view');
            $A.util.addClass(subItemEdit, "slds-hide");
            $A.util.removeClass(subItemView, "slds-hide");
        }
        else {
            //console.log('ATNQSubItemHelper -hide view show edit');
     
              $A.util.addClass(subItemView, "slds-hide");
            $A.util.removeClass(subItemEdit, "slds-hide");
        }
	}
})