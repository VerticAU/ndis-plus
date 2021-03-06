({
    handleInit: function(cmp, event, helper){

        var params = cmp.get('v.params');

        if(!params){
            return;
        }

        var paramsList = [];

        for (var key in params) {
            paramsList.push(key + '=' + params[key]);
        }

        cmp.set('v.paramsString', paramsList.join('&'));

        var request = {
            params: cmp.get('v.params') || {}
        };

        helper.execute(
            cmp,
            cmp.get('v.processor'),
            request,
            function (response) {
                var content = response.dto.content || '';
                content = content.replace(new RegExp('<div style="page-break-before: always;"></div>', 'g'), '<p>⏎</p>');
                response.dto.content = content;
                cmp.set('v.meta', response);
            }
        );

    },

    handlePreviewFile: function(cmp, event, helper){

        return new Promise($A.getCallback(function (resolve, reject) {
            var fileId = event.getParam('arguments').fileId;

            if(fileId){
                helper.previewFile(fileId);
                resolve(fileId);
            } else {
                helper.getFile(cmp, event, helper).then(function (fileId) {
                    helper.previewFile(fileId);
                    resolve(fileId);
                }).catch(reject);
            }

        }));


    },

    handleGetContent: function(cmp, event, helper){
        var content = cmp.get('v.meta.dto.content');
        content = content.replace(new RegExp('<p>⏎</p>', 'g'), '<div style="page-break-before: always;"></div>');
        return content;
    },

    handleGetHtmlContent: function(cmp, event, helper){
        var content = cmp.get('v.meta.dto.htmlContent');
        content = content.replace(new RegExp('<p>⏎</p>', 'g'), '<div style="page-break-before: always;"></div>');
        return content;
    }
})