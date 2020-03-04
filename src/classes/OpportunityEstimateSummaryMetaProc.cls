public class OpportunityEstimateSummaryMetaProc extends vertic_MetadataProcessor {

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

        String recordId = this.request.getString('recordId');

        List<OpportunityLineItem> itemLines = [
            SELECT
                Id,
                Total_value__c,
                Payment_Method__c,
                Product2.Category__r.Type__c,
                Product2.Category__r.Name,
                Product2.Category__r.NDIS_Portal_Name__c,
                Product2.Name
            FROM OpportunityLineItem
            WHERE OpportunityId = :recordId
            AND Total_value__c > 0
        ];

        Map<String, Map<String, Object>> totalsByPaymentMethod = new Map<String, Map<String, Object>>();
        List<Map<String, Object>> itemsByPaymentMethodList = new List<Map<String, Object>>();

        Map<String, SObject> paymentMethodSettings = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([SELECT Label, DeveloperName, Color__c FROM Payment_Method_Setting__mdt], Payment_Method_Setting__mdt.Label);

        Decimal overallTotal = 0;
        for (OpportunityLineItem item : itemLines) {
            String paymentMethod = String.isNotBlank(item.Payment_Method__c) ? item.Payment_Method__c : 'Other';

            Map<String, Object> lineItemsMap = totalsByPaymentMethod.get(paymentMethod);
            lineItemsMap = lineItemsMap == null ? new Map<String, Object>() : lineItemsMap;

            Decimal totalValue = (Decimal) lineItemsMap.get('totalValue');
            totalValue = (totalValue == null ? 0 : totalValue) + item.Total_value__c;
            overallTotal += item.Total_value__c;
            lineItemsMap.put('totalValue', totalValue);

            List<Map<String, Object>> items = (List<Map<String, Object>>) lineItemsMap.get('items');
            items = items == null ? new List<Map<String, Object>>() : items;
            Boolean itemAlreadyAdded = false;
            for (Map<String, Object> it : items) {
                String label = (String) it.get('label');
                if (item.Product2.Category__r.NDIS_Portal_Name__c == label) {
                    itemAlreadyAdded = true;
                    Decimal itemTotalValue = (Decimal) it.get('totalValue');
                    itemTotalValue = (itemTotalValue == null ? 0 : itemTotalValue) + item.Total_value__c;
                    it.put('totalValue', itemTotalValue);
                }
            }
            if (!itemAlreadyAdded) {
                items.add(new Map<String, Object>{
                    'label' => item.Product2.Category__r.NDIS_Portal_Name__c,
                    'totalValue' => item.Total_value__c
                });
            }
            lineItemsMap.put('items', items);

            String label = paymentMethod;

            lineItemsMap.put('label', label);
            lineItemsMap.put('paymentMethod', paymentMethod);

            totalsByPaymentMethod.put(paymentMethod, lineItemsMap);

        }

        for(String paymentMethod : totalsByPaymentMethod.keySet()) {
            if (totalsByPaymentMethod.containsKey(paymentMethod)) {
                Map<String, Object> lineItemsMap = totalsByPaymentMethod.get(paymentMethod);
                Payment_Method_Setting__mdt setting = (Payment_Method_Setting__mdt) paymentMethodSettings.get(paymentMethod);
                lineItemsMap.put('background', setting == null || setting.Color__c == null ? DEFAULT_COLOR : setting.Color__c);
                itemsByPaymentMethodList.add(lineItemsMap);
            }
        }
        itemsByPaymentMethodList.add(new Map<String, Object>{
            'totalValue' => overallTotal,
            'label' => 'Overall Total',
            'background' => paymentMethodSettings.containsKey('Overall Total') ? ((Payment_Method_Setting__mdt) paymentMethodSettings.get('Overall Total')).Color__c : DEFAULT_COLOR
        });
        this.response.put('itemsByPaymentMethodList', itemsByPaymentMethodList);
    }


    /**
     * ==============================================================================================================
     *                                         STRUCTURES AND OVERRIDES
     * ==============================================================================================================
     */


    // Proposed Live Templates to override Super properties: 
    // vertic_meta_request
    // vertic_meta_response

    private final String DEFAULT_COLOR = '#D1D1D1';

}