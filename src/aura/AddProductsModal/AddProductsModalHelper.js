({
    addNewProduct: function (cmp) {
        var products = cmp.get('v.meta.dto.products') || [];
        products.push({});
        cmp.set('v.meta.dto.products', products);

        setTimeout(function() {
            var containerEl = document.querySelector('.container.slds-scrollable');
            containerEl.scrollTop = containerEl.scrollHeight;
        }, 100);
    }
})