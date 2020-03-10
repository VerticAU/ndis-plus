({

    handleInit: function (cmp, event, helper) {
        helper.getBaseCmp(cmp).doInit().then($A.getCallback(function (resolve, reject) {
            var products = cmp.get('v.meta.dto.products') || [];
            if (products.length > 0) {
                return;
            }
            helper.addNewProduct(cmp);
        }));
    },

    handleCancelClick: function (cmp, event, helper) {

        var closeAction = $A.get("e.force:closeQuickAction");
        if (closeAction) closeAction.fire();

        if(cmp.get('v.refreshOnCancel') === true){
            var refreshAction = $A.get("e.force:refreshView");
            if (refreshAction) refreshAction.fire();
        }
        cmp.cancelModal();

    },

    handleSubmitClick: function (cmp, event, helper) {
        var lineItems = [];
        var productItems = cmp.get('v.meta.dto.products');
        productItems.forEach(function (item) {
            if (item.Product2Id) {
                lineItems.push(item);
            }
        });

        if (!$A.util.isEmpty(lineItems)) {
            var request = {
                lineItems: lineItems
            };

            helper.execute(
                cmp,
                'AddProductsModalSubmitProc',
                request,
                $A.getCallback(function (response) {

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Products was added.",
                        "type": 'success'
                    });
                    toastEvent.fire();


                    var closeAction = $A.get("e.force:closeQuickAction");
                    if (closeAction) closeAction.fire();

                    if(cmp.get('v.refreshOnCancel') === true){
                        var refreshAction = $A.get("e.force:refreshView");
                        if (refreshAction) refreshAction.fire();
                    }
                    cmp.closeModal(true);
                }),
                function (errors) {
                    var errorMessages = errors.map(function (error) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": error.message,
                            "type": "error"
                        });
                        toastEvent.fire();

                        return error.message;
                    });
                    throw errors;
                }
            );
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "You must select at least one product before submitting",
                "type": "warning"
            });
            toastEvent.fire();
        }
    },

    handleNewProductClick: function(cmp, event, helper) {
        helper.addNewProduct(cmp);
    }
})