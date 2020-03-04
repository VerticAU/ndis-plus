public class DocumentToPDFMetaProc extends vertic_MetadataProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new MetadataRequest() : (MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
            // SObject Fields, e.g. Contact.Salutation
        };

        super.process(this.request);

        this.init();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void init() {
        String recordIdsStr = this.request.getRequiredString('ids');

        List<String> recordIds = recordIdsStr.split(',');

        List<Document> documents = [
            SELECT Id, Body
            FROM Document
            WHERE Id IN :recordIds
        ];

        List<Object> components = new List<Object>();

        for (Document documentVar : documents) {

            vertic_DTO dto = new vertic_DTO();
            new vertic_AutoMapper(dto)
                .getOptions()
                .setIsVisualforce(true)
                .setIsAllFields(true)
                .setDefaultFieldValue(' ')
                .getMapper()
                .mapAnyValue('content', documentVar.Body == null ? '' : documentVar.Body.toString());

            components.add(new Component.DocumentToPdf(
                dto = dto.getMap()
            ));

        }

        this.response.dto.put('components', components);
        if (this.request.has('pageStyles')) {
            this.response.put('page-styles', this.request.getString('pageStyles'));
        }
        this.response.dto.put('custom-styles', 'p{margin:0;}');
        if (this.request.has('customStyles')) {
            this.response.put('custom-styles', this.request.getString('customStyles'));
        }
    }


    /**
     * ==============================================================================================================
     *                                         STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties:
    // vertic_meta_request
    // vertic_meta_response

}