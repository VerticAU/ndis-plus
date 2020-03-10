({
    handleClick: function(component, event, helper) {
        var modalService = component.find('modalService');
        modalService.show(
            'c:AddProductsModal',
            {
                recordId: component.get('v.recordId')
            },
            {
                // header: 'NDIS Budget Entry',
                cssClass: 'slds-modal_large'
            }
        ).then($A.getCallback(function (response) {
            if (response == true) {
                $A.get('e.force:refreshView').fire();
            } else {
                return;
            }
        }, function (error) {

        }));
    }
})