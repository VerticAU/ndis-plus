global class GenerateStatementOppQAMetaProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSomething();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void doSomething() {

        String oppId = request.getRequiredString('recordId');
        //String parentId = vertic_Utils.objects.defaultIfNull(this.request.getString('parentId'), null);
        this.oppVar = (Opportunity) vertic_Utils.arrays.firstOrException([SELECT Contact__r.Name,
            Plan_Start_Date__c,
            Plan_End_Date__c
        FROM Opportunity
        WHERE Id = :oppId AND Contact__c != NULL],'Opportunity or Client not found');

        String fileName =
            'Schedule of Support ' +
            ' - ' +
            oppVar.Contact__r.Name +
            ' - ' +
            oppVar.Plan_Start_Date__c.format() +
            ' to ' +
            oppVar.Plan_End_Date__c.format() +
            '.pdf';

        String emailTemplateName = 'Schedule of Support Email with Attachment';
        EmailTemplate template = (EmailTemplate) vertic_Utils.arrays.firstOrException([ SELECT DeveloperName
                                                                                        FROM EmailTemplate
                                                                                        WHERE Name = :emailTemplateName],
                                                                                        'No Email Template with name: ' + emailTemplateName);

        this.response.put('templateName', template.DeveloperName);
        this.response.put('fileName',fileName);
    }


    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties: 
    // vertic_request
    // vertic_response

    private Opportunity oppVar;


}