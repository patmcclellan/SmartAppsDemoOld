// Controller for Fileselector, which uses findFilesByUser and searchFilesByKey

public with sharing class FileController 
{
    @AuraEnabled
    public static List<ContentVersion> findFilesByRecordId(String recordId, Boolean isImage) 
    {
        List<ContentVersion> Files = new List<ContentVersion>();
        List<String> fileTypes = new List<String>{'jpg','jpeg','png','gif'};
        if(ContentVersion.SObjectType.getDescribe().isAccessible())
        {
            if(isImage)
            {
                Files = [
                    SELECT Id, ContentSize, FileType, FirstPublishLocationId, PathOnClient, Title, ContentDocumentId
                    FROM ContentVersion 
                    WHERE FileType IN :fileTypes
                    ORDER BY CreatedDate DESC];
            } else {
                Files = [
                    SELECT Id, ContentSize, FileType, FirstPublishLocationId, PathOnClient, Title, ContentDocumentId
                    FROM ContentVersion 
                    WHERE FileType NOT IN :fileTypes
                    ORDER BY CreatedDate DESC];
            }
        }
        if(String.isBlank(recordId))
        {
            return Files;
        } 
        return sortByRecordId(Files, recordId);
    }

    private static List<ContentVersion> sortByRecordId(List<ContentVersion> Files, String recordId)
    {
        List<ContentVersion> sortedFiles = new List<ContentVersion>();
        for (integer i = 0; i< Files.size(); i++)
        {
            if(Files[i].FirstPublishLocationId == recordId)
            {
                sortedFiles.add(Files.remove(i));
            }
        }
        sortedFiles.addAll(Files);
        return sortedFiles;
    }

    @AuraEnabled
    public static List<ContentVersion> searchFilesByKey(String searchKey, String recordId, Boolean isImage)
    {
        String name = '%' + searchKey + '%';
        List<ContentVersion> Files = new List<ContentVersion>();
        List<String> fileTypes = new List<String>{'jpg','jpeg','png','gif'};
        if (ContentVersion.SObjectType.getDescribe().isAccessible()) 
        {
            if(isImage)
            {
                Files = [
                    SELECT Id, ContentSize, FileType, FirstPublishLocationId, PathOnClient, Title, ContentDocumentId
                    FROM ContentVersion 
                    WHERE FileType IN :fileTypes
                    AND Title LIKE :name
                    ORDER BY CreatedDate DESC
                    LIMIT 50];
            } else 
            {
               Files = [
                    SELECT Id, ContentSize, FileType, FirstPublishLocationId, PathOnClient, Title, ContentDocumentId
                    FROM ContentVersion 
                    WHERE FileType NOT IN :fileTypes
                    AND Title LIKE :name 
                    ORDER BY CreatedDate DESC
                    LIMIT 50];
            }
        }
        if(String.isBlank(recordId))
        {
            return Files;
        } 
        return sortByRecordId(Files, recordId); 
    }
}
