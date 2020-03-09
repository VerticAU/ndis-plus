global without sharing class GenerateScheduleOpportunityAfterProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.init();
        this.doSubmit();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void init() {
        String recordIdsStr = this.request.getRequiredString('ids');
        this.opportunityIds = new Set<String>(recordIdsStr.split(','));
    }

    private void doSubmit() {
        Database.DMLOptions dmlOptionsVar = new Database.DMLOptions();
        dmlOptionsVar.OptAllOrNone = false;
        vertic_UnitOfWork uow = new vertic_UnitOfWork(
            new List<SObjectType>{
                Opportunity.SObjectType,
                Task.SObjectType
            },
            new vertic_UnitOfWork.DatabaseDMLIml(dmlOptionsVar)
        );

        Datetime dateTimeVar = Datetime.now();

        for (String oppId : this.opportunityIds) {
            uow.registerUpsert(new Opportunity(
                Id = oppId
            ));

            Task newTask = new Task(
                Subject = 'Schedule of Support',
                Description = 'The Schedule of Support was generated on ' + dateTimeVar.format(),
                WhatId = oppId,
                OwnerId = UserInfo.getUserId(),
                ActivityDate = dateTimeVar.date(),
                Status = 'Completed'
            );
            uow.registerUpsert(newTask);
        }

        uow.commitWork();
    }


    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties:
    // vertic_request
    // vertic_response

    private Set<String> opportunityIds;

}