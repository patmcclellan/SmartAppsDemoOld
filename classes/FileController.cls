// Controller for Fileselector, which uses findFilesByRecordId and searchFilesByKey
// Private methods factored for getRelatedFiles(), getUnrelatedFiles() and sortFilesByRecordId()

public with sharing class FileController 
{
    @AuraEnabled
    public static List<ContentVersion> findFilesByRecordId(String recordId, String howManyString, Boolean isImage) 
    {
        Integer howMany = Integer.valueOf(howManyString);
        List<ContentVersion> Files = new List<ContentVersion> ();
        // search for records with recordId
        if(String.isBlank(recordId))
        {
            Files = getUnrelatedFiles(null, howMany, isImage);
        }
        else 
        {
            Files = getRelatedFiles(recordId, howMany, isImage);
            Files.addAll(getUnrelatedFiles(recordId, howMany, isImage));
        }
        return Files;
    }

    private static List<ContentVersion> getRelatedFiles(String recordId, Integer howMany, Boolean isImage)
    {   
        List<ContentVersion> Files = new List<ContentVersion>();
        List<String> fileTypes = new List<String>{'jpg','jpeg','png','gif'};
        if(ContentVersion.SObjectType.getDescribe().isAccessible())
        if(isImage)
        {
            Files = [
                SELECT  Id, ContentSize, FileType, 
                        FirstPublishLocationId, PathOnClient, 
                        Title, ContentDocumentId
                FROM ContentVersion 
                WHERE FileType IN :fileTypes 
                AND FirstPublishLocationId = :recordId 
                ORDER BY CreatedDate DESC
                LIMIT :howMany];
        } else {
            Files = [
                SELECT  Id, ContentSize, FileType, 
                        FirstPublishLocationId, PathOnClient, 
                        Title, ContentDocumentId
                FROM ContentVersion 
                WHERE FileType NOT IN :fileTypes 
                AND FirstPublishLocationId = :recordId 
                ORDER BY CreatedDate DESC
                LIMIT :howMany];
        }
        return Files;
    }

    private static List<ContentVersion> getUnrelatedFiles(String recordId, Integer howMany, Boolean isImage)
    {
        List<ContentVersion> moreFiles = new List<ContentVersion>();
        List<String> fileTypes = new List<String>{'jpg','jpeg','png','gif'};
        if(ContentVersion.SObjectType.getDescribe().isAccessible())
        if(isImage)
        {
            moreFiles = [
                SELECT  Id, ContentSize, FileType, 
                        FirstPublishLocationId, PathOnClient, 
                        Title, ContentDocumentId
                FROM ContentVersion 
                WHERE FileType IN :fileTypes 
                AND FirstPublishLocationId != :recordId 
                ORDER BY CreatedDate DESC
                LIMIT :howMany];
        } else {
            moreFiles = [
                SELECT  Id, ContentSize, FileType, 
                        FirstPublishLocationId, PathOnClient, 
                        Title, ContentDocumentId
                FROM ContentVersion 
                WHERE FileType NOT IN :fileTypes 
                AND FirstPublishLocationId != :recordId
                ORDER BY CreatedDate DESC
                LIMIT :howMany];
        }
        return moreFiles;  
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
                    SELECT  Id, ContentSize, FileType, 
                            FirstPublishLocationId, PathOnClient, 
                            Title, ContentDocumentId
                    FROM ContentVersion 
                    WHERE FileType IN :fileTypes
                    AND Title LIKE :name 
                    ORDER BY CreatedDate DESC
                    LIMIT 50];
            } else 
            {
               Files = [
                    SELECT  Id, ContentSize, FileType, 
                            FirstPublishLocationId, PathOnClient, 
                            Title, ContentDocumentId
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

    private static List<ContentVersion> sortByRecordId(List<ContentVersion> Files, String recordId)
    {
        List<ContentVersion> sortedFiles = new List<ContentVersion>();
        for (integer i = 0; i< Files.size(); i++)
        {
            if(Files[i].FirstPublishLocationId == recordId)
            {
                sortedFiles.add(Files.remove(i));
                
                // adjust index for the removed item 
                // so it doesn't skip checking the next item
                i = i - 1; 
            }
        }
        sortedFiles.addAll(Files);
        return sortedFiles;
    }

   