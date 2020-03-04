({
    handleInit: function(cmp, event, helper){

        cmp.reInit().then(function (response) {
            helper.refreshPDFContentEditor(cmp, event, helper);
        });

    },

    handleToggleChange: function(cmp, event, helper){
        helper.refreshPDFContentEditor(cmp, event, helper);
    },

    handleGeneratePDFClick: function (cmp, event, helper) {

        cmp.find('PDFContentEditor').previewFile().then(function (fileId) {
            helper.execute(
                cmp,
                'GenerateScheduleOpportunityAfterProc',
                {
                    ids : cmp.get('v.recordId')
                },
                function(response) {}
            );
            cmp.find('modal').close();
        });

    },

    handleEmailPDFClick: function (cmp, event, helper) {

        helper.execute(
            cmp,
            'vertic_SOQLProc',
            {
                SOQL: 'SELECT Id, Name, Contact__c, Contact__r.Name, Contact__r.Email FROM Opportunity WHERE Id = \'' + cmp.get('v.recordId') + '\''
            },
            function (response) {
                var opportunity = response.dto.records[0];

                if(!opportunity.Contact__c || !opportunity.Contact__r.Email){
                    helper.utils(cmp).showToast({
                        message: 'No Email Contact',
                        type: 'warning'
                    });
                    return;
                }

                helper.execute(
                    cmp,
                    'vertic_SendEmailProc',
                    {
                        email: {
                            targetId: opportunity.Contact__c,
                            whatId: opportunity.Id,
                            saveAsActivity: true,
                            templateName: cmp.get('v.meta.dto.templateName'),
                            contentAttachments: [helper.getPDFContentParams(cmp, event, helper)]
                            // subject: cmp.get('v.meta.dto.emailSubject') || 'Schedule of Support',
                            // htmlBody: cmp.find('PDFContentEditor').getHtmlContent()
                        }
                    },
                    function (response) {
                        helper.utils(cmp).showToast({
                            message: 'The Schedule of Support Email was sent to: ' + opportunity.Contact__r.Name + ' <' + opportunity.Contact__r.Email + '>',
                            type: 'success'
                        });
                        cmp.find('modal').set('v.refreshOnCancel', true);
                        cmp.find('modal').close();
                    });
            }
        );

    }
})