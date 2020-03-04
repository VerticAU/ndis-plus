public class GetProductInfoProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.getProduct();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void getProduct() {

        String productId = this.request.getString('productId');
        String pricebookId = this.request.getString('pricebookId');
        List<PricebookEntry> products = [
            SELECT
                Id,
                UnitPrice,
                Product2.Name
            FROM PricebookEntry
            WHERE Product2Id =:productId
            AND Pricebook2Id = :pricebookId
        ];
        this.response.getMapper().mapFromSObject('product', (PricebookEntry)vertic_Utils.arrays.firstOrNull(products));
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