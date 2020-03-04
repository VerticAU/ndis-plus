({
    refreshPDFContentEditor: function(cmp, event, helper){


        cmp.find('PDFContentEditor').set('v.params', helper.getPDFContentParams(cmp, event, helper));
        cmp.find('PDFContentEditor').refresh();
    },

    getPDFContentParams: function(cmp, event, helper) {
        var params = {
            proc: 'GenerateStatement',
            id: cmp.get('v.recordId'),
            renderAs: 'pdf',
            fileName: cmp.get('v.meta.dto.fileName'),
            includeAmount: (cmp.get('v.includeAmount') == true) + '',
            isVariation: (cmp.get('v.isVariation') == true) + '',
            hasBeenProvided: (cmp.get('v.hasBeenProvided') == true) + ''
        };
        return params;
    }
})