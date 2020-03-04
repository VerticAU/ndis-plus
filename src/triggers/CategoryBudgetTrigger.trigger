trigger CategoryBudgetTrigger on Category_Budget__c (before insert, before update, before delete, after insert, after update, after delete) {
    fflib_SObjectDomain.triggerHandler(CategoryBudgetDomain.class);
}