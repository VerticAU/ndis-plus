global class CategoryBudgetDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    global CategoryBudgetDomain(List<Category_Budget__c> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    global class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CategoryBudgetDomain(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        calculateActualAmount(this.getRecords());
    }
    
    public override void onAfterInsert() {}
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        calculateActualAmount(this.getRecords());
    }
    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {}

    private static void calculateActualAmount(List<Category_Budget__c> records) {
        Set<Id> categoryIds = vertic_Utils.sObjects.getIdFieldValues(records, Category_Budget__c.Category__c);
        Set<Id> opportunityIds = vertic_Utils.sObjects.getIdFieldValues(records, Category_Budget__c.Opportunity__c);

        Map<Id, Map<Id, List<OpportunityLineItem>>> lineItemsByCategoryIdsByOppIds = new Map<Id, Map<Id, List<OpportunityLineItem>>>();
        for (OpportunityLineItem lineItem : [
            SELECT OpportunityId, Product2.Category__c, Total_value__c
            FROM OpportunityLineItem
            WHERE OpportunityId IN :opportunityIds AND Product2.Category__c IN :categoryIds AND Total_value__c > 0
        ]) {
            if (!lineItemsByCategoryIdsByOppIds.containsKey(lineItem.OpportunityId)) {
                lineItemsByCategoryIdsByOppIds.put(lineItem.OpportunityId, new Map<Id, List<OpportunityLineItem>>());
            }
            if (!lineItemsByCategoryIdsByOppIds.get(lineItem.OpportunityId).containsKey(lineItem.Product2.Category__c)) {
                lineItemsByCategoryIdsByOppIds.get(lineItem.OpportunityId).put(lineItem.Product2.Category__c, new List<OpportunityLineItem>());
            }
            lineItemsByCategoryIdsByOppIds.get(lineItem.OpportunityId).get(lineItem.Product2.Category__c).add(lineItem);
        }

        for (Category_Budget__c categoryBudget : records) {
            if (lineItemsByCategoryIdsByOppIds.containsKey(categoryBudget.Opportunity__c) &&
                lineItemsByCategoryIdsByOppIds.get(categoryBudget.Opportunity__c).containsKey(categoryBudget.Category__c)) {

                List<OpportunityLineItem> lineItems = lineItemsByCategoryIdsByOppIds
                    .get(categoryBudget.Opportunity__c)
                    .get(categoryBudget.Category__c);

                Decimal actualAmount = 0;
                for (OpportunityLineItem lineItem : lineItems) {
                    actualAmount += lineItem.Total_value__c;
                }
                categoryBudget.Actual_Amount__c = actualAmount;
            }
        }
    }

}