trigger OpportunityChangeTrigger on OpportunityChangeEvent (after insert) {

    List<String> opportunityIds = new List<String>();
    for (OpportunityChangeEvent change : (List<OpportunityChangeEvent>) Trigger.new) {
        opportunityIds.addAll(change.ChangeEventHeader.getRecordIds());
    }

    vertic_UnitOfWork uow = new vertic_UnitOfWork(new List<SObjectType> {
        OpportunityContactRole.SObjectType
    });

    List<Opportunity> opportunities = [SELECT Contact__c, (SELECT ContactId FROM OpportunityContactRoles WHERE Role = 'Client') FROM Opportunity WHERE Id IN :opportunityIds];

    for (Opportunity opp : opportunities) {
        OpportunityContactRole role = new OpportunityContactRole(
            ContactId = opp.Contact__c,
            Role = 'Client',
            OpportunityId = opp.Id
        );
        if (opp.OpportunityContactRoles.size() > 0) {
            role.Id = opp.OpportunityContactRoles.get(0).Id;
        }
        uow.registerUpsert(role);
    }

    uow.commitWork();

}