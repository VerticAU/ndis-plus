global class OpportunityLineItemDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    global OpportunityLineItemDomain(List<OpportunityLineItem> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    global class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OpportunityLineItemDomain(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {}
    
    public override void onAfterInsert() {
        Set<Id> categoryIds = vertic_Utils.sObjects.getIdFieldValues(this.getRecords(), OpportunityLineItem.Category_ID__c);
        update [SELECT Id FROM Category_Budget__c WHERE Category__c IN :categoryIds];
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {}
    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        Set<Id> categoryIds = vertic_Utils.sObjects.getIdFieldValues(this.getRecords(), OpportunityLineItem.Category_ID__c);
        update [SELECT Id FROM Category_Budget__c WHERE Category__c IN :categoryIds];

    }

}