@IsTest
private class CategoryBudgetDomainTest {
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
//        PricebookEntry pricebookEntryVar = new PricebookEntry(Product2Id = product2Var.Id, UnitPrice = 1, Pricebook2Id = pricebook2Var.Id);
        insert pricebookEntryVar;

        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = opp.Id, Product2Id = product2Var.Id, Quantity = 1, UnitPrice = 1, PricebookEntryId = pricebookEntryVar.Id);
        insert lineItem;

        Category_Budget__c categoryBudget = new Category_Budget__c(Opportunity__c = opp.Id, Category__c = category.Id);
        insert categoryBudget;
        update categoryBudget;

        Test.enableChangeDataCapture();
        update opp;
        Test.getEventBus().deliver();
    }
}