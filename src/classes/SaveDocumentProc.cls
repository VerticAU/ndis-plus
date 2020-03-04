public class SaveDocumentProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.saveDocument();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void saveDocument() {

        String content = this.request.getString('content');
//        content = content.replaceAll('<p><br><[/]p>',' ');
//        content = content.replaceAll('<p> <[/]p>',' ');


        String fileName = vertic_Utils.objects.defaultIfNull(this.request.getString('fileName'), 'file.pdf');


        ContentVersion conVersion = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName,
            VersionData = content != null ? EncodingUtil.base64Decode(content) : null
        );

        insert conVersion;

        conVersion = [SELECT Id, PublishStatus, ContentDocumentId, ContentDocument.Title FROM ContentVersion WHERE Id = :conVersion.Id];

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = conVersion.ContentDocumentId,
            ContentDocument = conVersion.ContentDocument,
            LinkedEntityId = this.request.getString('parentId'),
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        insert cdl;
        this.response.put('fileId', conVersion.ContentDocumentId);
    }



    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties:
    // vertic_request
    // vertic_response


}