@IsTest
private class SaveDocumentProcTest {
    static testMethod void testBehavior() {
        Contact contactVar = new Contact(LastName = 'test');
        insert contactVar;

        vertic_MetadataProcessor.MetadataRequest requestVar = new vertic_MetadataProcessor.MetadataRequest();
        requestVar.getMapper().getOptions().setIsVisualforce(false).getMapper()
            .mapAnyValue('name', 'test name')
            .mapAnyValue('parentId', contactVar.Id)
            .mapAnyValue('content', 'qwerty');

        vertic_Response responseVar = new SaveDocumentProc().process(requestVar);

        System.assertEquals(1, [SELECT COUNT() FROM ContentDocument WHERE Id = :responseVar.getId('fileId')]);
    }
}