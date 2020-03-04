public class DocumentToPDFContentFileProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;
        this.retrieveDocument();
        this.getPDF();
        this.savePDFasAttachment();
        this.deleteDocument();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private Document documentVar;
    private Blob pdfContent;

    private void retrieveDocument() {
        String documentId = this.request.getRequiredString('documentId');

        List<Document> documents = [
            SELECT
                Id, Name
            FROM Document
            WHERE Id = :documentId
        ];

        this.documentVar = (Document) vertic_Utils.arrays.firstOrException(documents, 'No Document with Id:' + documentId);
    }

    private void getPDF() {
//        String fontSize = this.request.getString('fontSize');
//        if (String.isBlank(fontSize)) {
//            fontSize = '18pt';
//        }

        PageReference pageRef = Page.vertic_Content;
        pageRef.getParameters().put('proc', 'DocumentToPDF');
        pageRef.getParameters().put('ids', this.documentVar.Id);
        pageRef.getParameters().put('renderAs', 'pdf');
        if (this.request.has('pageStyles')) {
            pageRef.getParameters().put('pageStyles', this.request.getString('pageStyles'));
        }
        if (this.request.has('customStyles')) {
            pageRef.getParameters().put('customStyles', this.request.getString('customStyles'));
        }

        this.pdfContent = Test.isRunningTest() ? Blob.valueOf('Test') : pageRef.getContent();
    }

    private void savePDFasAttachment() {
        String fileName = vertic_Utils.objects.defaultIfNull(this.request.getString('fileName'), this.documentVar.Name);
        ContentVersion conVersion = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName,
            VersionData = this.pdfContent
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

    private void deleteDocument() {
        if(this.request.getBoolean('doNotDeleteDocument') != true){
            delete this.documentVar;
        }
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