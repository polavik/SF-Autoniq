({
	doInit : function(cmp, event, helper) {
		cmp.set('v.mycolumns', [
                {label: 'Bill Date', fieldName: 'billDate', type: 'text'},
                {label: 'Charge', fieldName: 'charge', type: 'text'},

                {label: 'Amount', fieldName: 'amount', type: 'text', cellAttributes:
                    { iconName: { fieldName: 'trendIcon' }, iconPosition: 'right' }},
               
            ]);
        cmp.set('v.mydata', [{
                id: 'a',
                billDate: '01/01/2018',  
                charge : "$135",
                amount: '$425'
            },
            {
                id: 'b',
                billDate: '05/01/2018',  
                charge : "$75",
                amount: '$125'
            }]);
    },
    getSelectedName: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
           // alert("You selected: " + selectedRows[i].opportunityName);
        }
    }
	
})