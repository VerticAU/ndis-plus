trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete) {
    fflib_SObjectDomain.triggerHandler(OpportunityLineItemDomain.class);
}