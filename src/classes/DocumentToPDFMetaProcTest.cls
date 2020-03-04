@IsTest
private class DocumentToPDFMetaProcTest {

    @isTest
    static void testBehavior() {
        Folder folder = [
            SELECT Id FROM Folder WHERE Name = 'Shared Documents'
        ];

        Document documentVar = new Document(
            Name = 'Test document',
            Body = Blob.valueOf('Test blob body'),
            FolderId = folder.Id
        );
        insert documentVar;

        vertic_MetadataProcessor.MetadataRequest request = new vertic_MetadataProcessor.MetadataRequest(
            JSON.serialize(new Map<String, Object>{
                'ids' => documentVar.Id
            })
        );

        vertic_Response responseVar = new DocumentToPDFMetaProc().process(request);

        System.assertEquals(true, responseVar.get('components') != null);
    }
}