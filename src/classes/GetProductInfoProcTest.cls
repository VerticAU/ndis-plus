@IsTest
private class GetProductInfoProcTest {
    static testMethod void testBehavior() {

        Product2 product2Var = new Product2(Name = 'test');
        insert product2Var;

        Pricebook2 pricebook2Var = new Pricebook2(Name = 'test', State__c = Pricebook2.State__c.getDescribe().getPicklistValues()[0].value);
        insert pricebook2Var;

        PricebookEntry standardPricebookEntryVar = new PricebookEntry(Product2Id = product2Var.Id, UnitPrice = 1, Pricebook2Id = Test.getStandardPricebookId(), IsActive = true);
        PricebookEntry pricebookEntryVar = new PricebookEntry(Product2Id = product2Var.Id, UnitPrice = 1, Pricebook2Id = pricebook2Var.Id);
        insert standardPricebookEntryVar;
        insert pricebookEntryVar;

        vertic_Response resp = new GetProductInfoProc().process(new Map<String, Object> {
            'productId' => product2Var.Id,
            'pricebookId' => pricebook2Var.Id
        });

        System.assert(resp.isValid);
        System.assert(resp.has('product'));
    }
}