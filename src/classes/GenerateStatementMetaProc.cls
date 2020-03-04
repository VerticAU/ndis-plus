public class GenerateStatementMetaProc extends vertic_MetadataProcessor {

    Opportunity opportunityVar = new Opportunity();

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

        this.retrieveLineItems();
        this.initComponent();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void retrieveLineItems() {

        String recordId = ApexPages.currentPage().getParameters().get('id');
        this.opportunityVar = (Opportunity) vertic_Utils.arrays.firstOrException([
            SELECT
                Amount,
                Contact__r.Name, Contact__r.Birthdate, Contact__r.NDIS_Number__c,
                Plan_Start_Date__c,
                Plan_End_Date__c,
                (
                    SELECT
                        Id,
                        Product2.Name,
                        TDT_Support_Provided__c,
                        Details_of_Support__c,
                        Payment_Method__c,
                        Number_of_Occurrences__c,
                        Total_value__c,
                        TotalPrice,
                        Fee_Applies__c,
                        Product2.NDIS_Support_Number__c
                    FROM OpportunityLineItems
                    ORDER BY Product2.Category__c
                )
            FROM Opportunity WHERE Id = :recordId],
            'There is no Opportunity record with ID = ' + recordId);
    }

    private void initComponent() {

        String includeAmount = ApexPages.currentPage().getParameters().get('includeAmount');
        includeAmount = String.isNotBlank(includeAmount) ? includeAmount : 'false';

        String isVariation = ApexPages.currentPage().getParameters().get('isVariation');
        isVariation = String.isNotBlank(isVariation) ? isVariation : 'false';

        String hasBeenProvided = ApexPages.currentPage().getParameters().get('hasBeenProvided');
        hasBeenProvided = String.isNotBlank(hasBeenProvided) ? hasBeenProvided : 'false';

        List<Object> components = new List<Object>();
        vertic_DTO dto = new vertic_DTO();
        vertic_AutoMapper autoMapper = new vertic_AutoMapper(dto)
            .getOptions()
            .setIsVisualforce(true)
            .setIsAllFields(true)
            .setDefaultFieldValue(' ')
            .getMapper()
            .mapFromSObject('opportunity', this.opportunityVar)
            .mapFromListSObjects('lineItems', this.opportunityVar.OpportunityLineItems)
            .mapFromSObject('contact', this.opportunityVar.Contact__r)
            .mapAnyValue('includeAmount', includeAmount)
            .mapAnyValue('isVariation', isVariation)
            .mapAnyValue('effectiveFrom', isVariation == 'true' ? Date.today().format() : ' ')
            .mapAnyValue('hasBeenProvided', hasBeenProvided);

        components.add(new Component.GenerateStatement(
            dto = dto.getMap()
        ));
        this.response.dto.put('components', components);
        this.response.dto.put('head-component', new Component.GenerateStatementStyles());


        /**
     * ==============================================================================================================
     *                                         STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

        // Proposed Live Templates to override Super properties:
        // vertic_meta_request
        // vertic_meta_response

    }
}