@IsTest
private class GenerateStatementMetaProcTest {
    static testMethod void testBehavior() {
        Contact con = new Contact(LastName = 'test', MailingState = 'VIC', OtherState = 'VIC');
        insert con;

        Category__c category = new Category__c(Name = 'test', NDIS_Portal_Name__c = 'test', Category_Number__c = 1);
        insert category;

        Opportunity opp = new Opportunity(Name = 'test', Contact__c = con.Id, CloseDate = Date.today(), StageName = 'Closed Won');
        insert opp;

        Product2 product2Var = new Product2(Name = 'test', Category__c = category.Id);
        insert product2Var;

        Pricebook2 pricebook2Var = new Pricebook2(Name = 'test', State__c = Pricebook2.State__c.getDescribe().getPicklistValues()[0].value);
        insert pricebook2Var;

        PricebookEntry pricebookEntryVar = new PricebookEntry(Product2Id = product2Var.Id, UnitPrice = 1, Pricebook2Id = Test.getStandardPricebookId(), IsActive = true);
        insert pricebookEntryVar;

        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = opp.Id, Product2Id = product2Var.Id, Quantity = 1, UnitPrice = 1, PricebookEntryId = pricebookEntryVar.Id);
        insert lineItem;

        PageReference pageRef = new PageReference('/');
        pageRef.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pageRef);

        vertic_Response resp = new GenerateStatementMetaProc().process(new vertic_MetadataProcessor.MetadataRequest());

        System.assert(resp.isValid);
        System.assert(resp.has('components'));
    }
}