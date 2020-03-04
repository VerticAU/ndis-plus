({
    getFile: function (cmp, event, helper) {

        return new Promise($A.getCallback(function (resolve, reject) {

            helper.execute(
                cmp,
                'SaveDocumentProc',
                {
                    content: cmp.getContent(),
                    fileName: cmp.get('v.params.fileName') || 'file.pdf',
                    parentId: cmp.get('v.recordId')
                },
                function (response) {
                    console.log(response);
                    var fileId = response.dto.fileId;
                    resolve(fileId);
                },
                reject
            );

        }));



    },

    previewFile: function(fileId){
        var fireEvent = $A.get('e.lightning:openFiles');
        fireEvent.fire({
            recordIds: [fileId]
        });
    }
})