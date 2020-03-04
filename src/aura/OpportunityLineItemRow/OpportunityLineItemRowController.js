({
    handleInputChange: function (cmp, event, helper) {
        var product = cmp.get('v.product');
        if (product && product.Number_of_Occurrences__c && product.Units_Per_Occurrence__c) {
            product.Quantity = product.Number_of_Occurrences__c * product.Units_Per_Occurrence__c;
        }
        if (product && product.UnitPrice && product.Quantity) {
            product.Total_value__c = product.Quantity * product.UnitPrice;
        }
        cmp.set('v.product', product);
    },

    handleDeleteClick: function (cmp, event, helper) {
        cmp.set('v.product.IsDeleted', true);
    },

    handleCategoryChange: function (cmp, event, helper) {
        if (!event.getParam("oldValue") || event.getParam("oldValue").Category_ID__c != event.getParam("value").Category_ID__c) {
            cmp.set('v.product.Product2Id', null);
            cmp.set('v.product.ListPrice', null);
            cmp.set('v.product.UnitPrice', null);
        }
    },

    handleProductChange: function (cmp, event, helper) {
        if (!event.getParam("oldValue") || event.getParam("oldValue").Product2Id != event.getParam("value").Product2Id) {

            var productId = cmp.get('v.product.Product2Id');
            if (productId) {
                helper.execute(
                    cmp,
                    'GetProductInfoProc',
                    {
                        productId: productId,
                        pricebookId: cmp.get('v.meta.dto.opportunity.Pricebook2Id')
                    }
                ).then(function (response) {

                    var product = response.dto.product;
                    if (product != null) {
                        cmp.set('v.product.OpportunityId', cmp.get('v.meta.dto.opportunity.Id'));
                        cmp.set('v.product.ListPrice', product.UnitPrice);
                        cmp.set('v.product.UnitPrice', product.UnitPrice);
                    }

                });
            }
        }
    }
})