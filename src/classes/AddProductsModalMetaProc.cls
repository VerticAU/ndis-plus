public class AddProductsModalMetaProc extends vertic_MetadataProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new MetadataRequest() : (MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
            OpportunityLineItem.Payment_Method__c
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
        List<Category__c> categories = [SELECT Id, Name FROM Category__c ORDER BY Name];
        List<vertic_Structs.SelectOption> categoryOptions = new List<vertic_Structs.SelectOption>();
        for (Category__c categoryVar : categories) {
            String value = categoryVar.Name.substringAfter('(').substringBefore(')').trim();
            value = String.isNotBlank(value) ? value : categoryVar.Name;
            categoryOptions.add(new vertic_Structs.SelectOption(categoryVar.Id, value));
        }
        this.response.selectOptions.put('categoryOptions', categoryOptions);
        String recordId = this.request.getString('recordId');
        Opportunity opportunityVar = (Opportunity) vertic_Utils.arrays.firstOrException(
            [
                SELECT
                    Pricebook2Id,
                    Contact__c,
                    Contact__r.MailingState,
                    Contact__r.OtherState
                FROM Opportunity
                WHERE Id = :recordId
            ],
            'There is no Opportunity record with ID: ' + recordId
        );
        this.response.getMapper().mapFromSObject('opportunity', opportunityVar);
        this.response.getMapper().mapFromListSObjects('products', [
            SELECT
                Number_of_Occurrences__c,
                Units_Per_Occurrence__c,
                Quantity,
                ListPrice,
                UnitPrice,
                Payment_Method__c,
                Fee_Applies__c,
                TDT_Support_Provided__c,
                Product2Id,
                Category_ID__c,
                Total_value__c,
                OpportunityId
            FROM OpportunityLineItem
            WHERE OpportunityId = :recordId
        ], new vertic_AutoMapper.BinderQueue(new LineItemBinder()));
    }


    /**
     * ==============================================================================================================
     *                                         STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties: 
    // vertic_meta_request
    // vertic_meta_response

    private class LineItemBinder implements vertic_AutoMapper.IBinder {

        public LineItemBinder() {}

        public void bind(SObject record, Map<String, Object> dataMap) {
            dataMap.put('prevProduct2Id', record.get('Product2Id'));
        }
    }

}