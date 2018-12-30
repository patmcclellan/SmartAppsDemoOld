/**
 * Created by pmcclellan on 12/14/17. Updated 7/3/18 to add Campaign, Contract, and custom objects.
 * Refactored 12/16/18.
 * Apex Controller for ConversationFeed.cmp
 * Uses UserId and sharing, along with recordId to return Conversations owned by
 * this user, and related to the particular record page in view.
 */

public with sharing class GetConversationList
{
    @AuraEnabled
    public static List<ConversationWrapper> getConversationList(String recordId)
    {
        if(!Conversation__c.SObjectType.getDescribe().isAccessible()) {
            return null;
        } else 
        {
            Id OwnerId = UserInfo.getUserId();
            List<Conversation__c> Conversations = new List<Conversation__c>();
            if (recordId == null) 
            {
                Conversations = getConsNoRecordId(OwnerId);
            }else if (recordId.left(3) == Schema.SObjectType.Contact.getKeyPrefix()) // it's a contact record
            {
                Conversations = getConsContactId(OwnerId, recordId);
            } else if (recordId.left(3) == Schema.SObjectType.Lead.getKeyPrefix()) // it's a lead record
            {
                Conversations = getConsLeadId(OwnerId, recordId);
            } else if (recordId.left(3) == Schema.SObjectType.Account.getKeyPrefix()) // it's an Account record
            {
                Conversations = getConsAccountId(OwnerId, recordId);
            } else if (recordId.left(3) == Schema.SObjectType.Conversation__c.getKeyPrefix()) // it's a Conversation record
            {
                Conversations = getConsConvId(recordId);
            }else
            {
                //get the name and type of the sObject represented by the recordId
                Schema.SObjectType sObjType = Id.valueOf(recordId).getSObjectType();
                List<String> standardObjectList = new List<String>{'Asset', 'Campaign', 'Case', 'Contract', 'Opportunity', 'Order', 'Product2'};
                String sObjName = sObjType.getDescribe().getName();
                if (standardObjectList.contains(sObjName)) // standard object
                {
                    String lookupFieldName = sObjName + '__c';
                    Conversations = getRelatedConversations(OwnerId, recordId, lookupFieldName);
                }else //custom object
                {
                    Conversations = getRelatedConversations(OwnerId, recordId);
                }
            }
            return wrapConversations(Conversations);
        }
    }

    @AuraEnabled
    public static List<ConversationWrapper> searchConversationList(String searchKey)
    {
        if(!Conversation__c.SObjectType.getDescribe().isAccessible()) {
            return null;
        } else {
            Id OwnerId = UserInfo.getUserId();
            String name = '%' + searchKey + '%';
            List<Conversation__c> Conversations = new List<Conversation__c>();
            Conversations = getConsLikeName(OwnerId, name);
            return Conversations;
        }
    }
//---------------- UTILITY METHODS -------------------------------------------------------------
  
    //this method is used to search for conversations related to standard records
    private static List<Conversation__c> getRelatedConversations(String OwnerId, String recordId, String lookupFieldName)
    {
        return Database.query(
            'SELECT  [long list of fields] ' +
            'FROM Conversation__c ' +
            'WHERE OwnerId = \'' + OwnerId + '\' ' +
            'AND '+ lookupFieldName +' = \'' + recordId + '\' ' +
            'ORDER BY LastMessageDate__c DESC'
        );
    }

    //this method is used to search for conversations related to custom records
    private static List<Conversation__c> getRelatedConversations(String OwnerId, String recordId)
    {
        return Database.query(
            'SELECT  [long list of fields] ' +
            'FROM Conversation__c '+
            'WHERE OwnerId = \'' + OwnerId + '\' ' +
            'AND (Record1__c = \'' + recordId + '\'' + ' OR Record2__c = \'' + recordId + '\') ' +
            'ORDER BY LastMessageDate__c DESC'
        );
    }

    //this method is used to search for conversations when we don't have a recordId
    private static List<Conversation__c> getConsNoRecordId(String OwnerId)
    {
        return [
                    SELECT  //[long list of fields]
                    FROM Conversation__c
                    WHERE OwnerId = :OwnerId 
                    ORDER BY LastMessageDate__c DESC
                ];
    }

    // this method finds conversations related to a ContactId
    private static List<Conversation__c> getConsContactId(String OwnerId, String recordId)
    {
         //find all the member records for this contact
        List<Member__c> Members = [SELECT Conversation__c FROM Member__c WHERE Contact__c = :recordId];
        List<String> IdList = new List<String>();
        System.debug('IdList: ' + IdList);
        //build a list of conversationIds for all those conversations
        for (Member__c member : Members) {
            IdList.add(member.Conversation__c);
        }
        //return all the fields for those conversations in the IdList
        return [
                    SELECT  //[long list of fields]
                    FROM Conversation__c
                    WHERE OwnerId = :OwnerId AND Id IN :IdList
                    ORDER BY LastMessageDate__c DESC
                ];
    }

    // this method finds conversations related to a LeadId
    private static List<Conversation__c> getConsLeadId(String OwnerId, String recordId)
    {
         //find all the member records for this contact
        List<Member__c> Members = [SELECT Conversation__c FROM Member__c WHERE Lead__c = :recordId];
        List<String> IdList = new List<String>();
        System.debug('IdList: ' + IdList);
        //build a list of conversationIds for all those conversations
        for (Member__c member : Members) {
            IdList.add(member.Conversation__c);
        }
        //return all the fields for those conversations in the IdList
        return [
                    SELECT  //[long list of fields]
                    FROM Conversation__c
                    WHERE OwnerId = :OwnerId AND Id IN :IdList
                    ORDER BY LastMessageDate__c DESC
                ];
    }

    // this method finds conversations related to an AccountId
    private static List<Conversation__c> getConsAccountId(String OwnerId, String recordId)
    {
         //find all the contacts associated with this account
        List<Contact> Contacts = [SELECT Id FROM Contact WHERE AccountId = :recordId];

        //find all the member records for all contacts in this list
        List<Member__c> Members = [SELECT Conversation__c FROM Member__c WHERE Contact__c IN :Contacts];
        System.debug('Conversations: ' + Members);
        List<String> IdList = new List<String>();
        System.debug('IdList: ' + IdList);

        //build a list of conversationIds for all those conversations
        for (Member__c member : Members) {
            IdList.add(member.Conversation__c);
        }
        //return all the fields for those conversations in the IdList
        return  [
                    SELECT  //[long list of fields]
                    FROM Conversation__c
                    WHERE OwnerId = :OwnerId AND Id IN :IdList
                    ORDER BY LastMessageDate__c DESC
                ];

    }

    // this method finds conversations related to a ConversationId
    // NOTE: it does not check for OwnerId -- so anyone who has access
    // to this Conversation record can read the Conversation
    private static List<Conversation__c> getConsConvId(String recordId)
    {
        return [
                    SELECT  //[long list of fields]
                    FROM Conversation__c
                    WHERE Id = :recordId
                ];
    }

    // this method finds conversations based on a Search key
    private static List<Conversation__c> getConsLikeName(String OwnerId, String name)
    {
        return  [
                    SELECT  //[long list of fields]
                    FROM Conversation__c
                    WHERE OwnerId = :OwnerId AND Group_Name__c LIKE :name
                    ORDER BY LastMessageDate__c DESC
                ];
    }

   

    //-----------------------------------------------------------------------------
}