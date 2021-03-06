public class vertic_GetPageReferenceContentProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void doSubmit() {
        String url = this.request.getString('url');
        if(String.isBlank(url)){
            url = '/apex/vertic_content';
        }

        Map<String, Object> params = (Map<String, Object>)this.request.get('params');

        PageReference pageRef = new PageReference(url);
        for (String key : params.keySet()) {
            String value = '' + params.get(key);
            pageRef.getParameters().put(key, value);
        }

        this.response.put('content', Test.isRunningTest() ? '' : EncodingUtil.base64Encode(pageRef.getContent()));

        pageRef.getParameters().put('renderAs', 'html');

        this.response.put('htmlContent', Test.isRunningTest() ? '' : pageRef.getContent().toString());
    }


    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties:
    // vertic_request
    // vertic_response


}