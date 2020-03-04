@IsTest
private class DocumentToPDFContentFileProcTest {

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

        Contact contactVar = new Contact(
            FirstName = 'test',
            LastName = 'Test Contact'
        );
        insert contactVar;

        vertic_Response responseVar = new DocumentToPDFContentFileProc().process(new Map<String,Object>{
            'documentId' => documentVar.Id,
            'parentId' => contactVar.Id
        });

        System.assertEquals(true, responseVar.get('fileId') != null);
        System.assertEquals(true, [SELECT COUNT() FROM Document] == 0);
    }
}