public class OpportunityDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    public OpportunityDomain(List <Opportunity> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OpportunityDomain(sObjectList);
        }
    }

    public override void onBeforeInsert() {
        populatePricebook();
    }

    public override void onAfterInsert() {

    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        populatePricebook();
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {

    }

    private void populatePricebook() {

        Map<Id, List<Opportunity>> opportunitiesByContactId = new Map<Id, List<Opportunity>>();
        for (Opportunity opportunityVar : (List<Opportunity>) this.Records) {
            Id contactId = opportunityVar.Contact__c;
            if (opportunityVar.Pricebook2Id == null && contactId != null) {
                List<Opportunity> opportunities = opportunitiesByContactId.get(contactId);
                opportunities = opportunities == null ? new List<Opportunity>() : opportunities;
                opportunities.add(opportunityVar);
                opportunitiesByContactId.put(contactId, opportunities);
            }
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT MailingState, OtherState FROM Contact WHERE Id IN :opportunitiesByContactId.keySet()]);
        Set<String> mailingStates = new Set<String>();
        Set<String> otherStates = new Set<String>();

        for (Contact contactVar : contactMap.values()) {
            if (contactVar.MailingState != null) {
                mailingStates.add(contactVar.MailingState);
            }
            if (contactVar.OtherState != null) {
                otherStates.add(contactVar.OtherState);
            }
        }

        Pricebook2 pb2Standard = System.Test.isRunningTest() ? new Pricebook2(Id = System.Test.getStandardPricebookId()) : [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        List<Pricebook2> pricebook2s = new List<Pricebook2>();
        pricebook2s.addAll([SELECT Id, State__c FROM Pricebook2 WHERE State__c IN :mailingStates AND IsActive = true]);
        pricebook2s.addAll([SELECT Id, State__c FROM Pricebook2 WHERE State__c IN :otherStates AND IsActive = true]);
       
        Map<String, Id> pricebookIdByState = new Map<String, Id>();
        for (Pricebook2 pb2 : pricebook2s) {
            pricebookIdByState.put(pb2.State__c, pb2.Id);
        }
        for (Contact contactVar : contactMap.values()) {
            if (pricebookIdByState.containsKey(contactVar.MailingState)) {
                for (Opportunity opp : opportunitiesByContactId.get(contactVar.Id)) {
                    opp.Pricebook2Id = pricebookIdByState.get(contactVar.MailingState);
                }
            } else if (pricebookIdByState.containsKey(contactVar.OtherState)) {
                for (Opportunity opp : opportunitiesByContactId.get(contactVar.Id)) {
                    opp.Pricebook2Id = pricebookIdByState.get(contactVar.OtherState);
                }
            } else {
                for (Opportunity opp : opportunitiesByContactId.get(contactVar.Id)) {
                    opp.Pricebook2Id = pb2Standard.Id;
                }
            }
        }


    }

}