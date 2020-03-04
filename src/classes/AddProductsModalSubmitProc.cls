public class AddProductsModalSubmitProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();

    private void doSubmit() {
        vertic_UnitOfWork uow = new vertic_UnitOfWork(new List<SObjectType> {
            OpportunityLineItem.SObjectType
        });

        this.opportunityLineItems = (List<OpportunityLineItem>) this.request.getMapper().mapToListSObjects('lineItems', OpportunityLineItem.SObjectType, false, new vertic_AutoMapper.BinderQueue(new LineItemBinder(uow)));

        uow.commitWork();
    }

    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties: 
    // vertic_request
    // vertic_response

    private class LineItemBinder implements vertic_AutoMapper.IBinder {

        private vertic_UnitOfWork uow;

        public LineItemBinder(vertic_UnitOfWork uow) {
            this.uow = uow;
        }

        public void bind(SObject record, Map<String, Object> dataMap) {
            vertic_DTO dto = new vertic_DTO(dataMap);

            OpportunityLineItem lineItem = (OpportunityLineItem) record;
            Id newProduct2Id = dto.getId('Product2Id');
            Id product2Id = dto.getId('prevProduct2Id');
            Id opportunityId = dto.getId('OpportunityId');
            if (product2Id != null && product2Id != newProduct2Id) {
                this.uow.registerDeleted(lineItem);
                if (dto.getBoolean('IsDeleted') != true) {
                    OpportunityLineItem newLineItem = lineItem.clone(false, true);
                    newLineItem.Product2Id = newProduct2Id;
                    newLineItem.OpportunityId = opportunityId;
                    this.uow.registerNew(newLineItem);
                }
            } else {
                if (lineItem.Id != null) {
                    if (dto.getBoolean('IsDeleted') == true) {
                        this.uow.registerDeleted(lineItem);
                    } else {
                        this.uow.registerDirty(lineItem);
                    }
                } else {
                    this.uow.registerNew(lineItem);
                }
            }
        }
    }

}