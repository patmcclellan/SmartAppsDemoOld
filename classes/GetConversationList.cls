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
                Conversations = getConsLEadId(OwnerId, recordId);
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
            return wrapConversations(Conversations);
        }
    }
//---------------- UTILITY METHODS -------------------------------------------------------------
  
    //this method is used to search for conversations related to standard records
    private static List<Conversation__c> getRelatedConversations(String OwnerId, String recordId, String lookupFieldName)
    {
        return Database.query(
            'SELECT  Id, GroupInits__c, Unread__c, LastMessageReceived__c, Broadcast__c, FirstName__c, ' +
                    'Group_Name__c, OwnerId, PrimaryUser__c, Owner.FirstName, LastFromInits__c, '+
                    'LastModifiedDate, PrimaryUserInits__c, LastMessageDate__c, '+ 
                    'Asset__c, Asset__r.Name, Campaign__c, Campaign__r.Name, '+
                    'Case__c, Case__r.Subject, Contract__c, Contract__r.ContractNumber, '+
                    'Opportunity__c, Opportunity__r.Name, Order__c, Order__r.Name, Order__r.OrderNumber, '+ 
                    'Product2__c, Product2__r.Name, Link1__c, Link2__c, '+ 
                    'Record1__c, Record2__c, Record1Name__c, Record2Name__c, OurFromNumber__c ' +
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
            'SELECT  Id, GroupInits__c, Unread__c, LastMessageReceived__c, Broadcast__c, FirstName__c, ' +
                    'Group_Name__c, OwnerId, PrimaryUser__c, Owner.FirstName, LastFromInits__c, '+
                    'LastModifiedDate, PrimaryUserInits__c, LastMessageDate__c, '+ 
                    'Asset__c, Asset__r.Name, Campaign__c, Campaign__r.Name, '+
                    'Case__c, Case__r.Subject, Contract__c, Contract__r.ContractNumber, '+
                    'Opportunity__c, Opportunity__r.Name, Order__c, Order__r.Name, Order__r.OrderNumber, '+ 
                    'Product2__c, Product2__r.Name, Link1__c, Link2__c, '+ 
                    'Record1__c, Record2__c, Record1Name__c, Record2Name__c, OurFromNumber__c ' +
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
                    SELECT  Id, GroupInits__c, Unread__c, LastMessageReceived__c, Broadcast__c, FirstName__c,
                            Group_Name__c, OwnerId, PrimaryUser__c, Owner.FirstName, LastFromInits__c,
                            LastModifiedDate, PrimaryUserInits__c, LastMessageDate__c, 
                            Asset__c, Asset__r.Name,
                            Campaign__c, Campaign__r.Name, Case__c, Case__r.Subject, 
                            Contract__c, Contract__r.ContractNumber, Opportunity__c,
                            Order__c, Order__r.Name, Order__r.OrderNumber, Product2__c, Product2__r.Name, 
                            Opportunity__r.Name, Link1__c, Link2__c, 
                            Record1__c, Record2__c, Record1Name__c, Record2Name__c, OurFromNumber__c
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
                    SELECT  Id, GroupInits__c, Unread__c, LastMessageReceived__c, Broadcast__c, FirstName__c,
                            Group_Name__c, OwnerId, PrimaryUser__c, Owner.FirstName, LastFromInits__c,
                            LastModifiedDate, PrimaryUserInits__c, LastMessageDate__c, 
                            Asset__c, Asset__r.Name,
                            Campaign__c, Campaign__r.Name, Case__c, Case__r.Subject, 
                            Contract__c, Contract__r.ContractNumber, Opportunity__c,
                            Order__c, Order__r.Name, Order__r.OrderNumber, Product2__c, Product2__r.Name, 
                            Opportunity__r.Name, Link1__c, Link2__c, 
                            Record1__c, Record2__c, Record1Name__c, Record2Name__c, OurFromNumber__c
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
                    SELECT  Id, GroupInits__c, Unread__c, LastMessageReceived__c, Broadcast__c, FirstName__c,
                            Group_Name__c, OwnerId, PrimaryUser__c, Owner.FirstName, LastFromInits__c,
                            LastModifiedDate, PrimaryUserInits__c, LastMessageDate__c, 
                            Asset__c, Asset__r.Name,
                            Campaign__c, Campaign__r.Name, Case__c, Case__r.Subject, 
                            Contract__c, Contract__r.ContractNumber, Opportunity__c,
                            Order__c, Order__r.Name, Order__r.OrderNumber, Product2__c, Product2__r.Name, 
                            Opportunity__r.Name, Link1__c, Link2__c, 
                            Record1__c, Record2__c, Record1Name__c, Record2Name__c, OurFromNumber__c
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
                    SELECT  Id, GroupInits__c, Unread__c, LastMessageReceived__c, Broadcast__c, FirstName__c,
                            Group_Name__c, OwnerId, PrimaryUser__c, Owner.FirstName, LastFromInits__c,
                            LastModifiedDate, PrimaryUserInits__c, LastMessageDate__c, 
                            Asset__c, Asset__r.Name,
                            Campaign__c, Campaign__r.Name, Case__c, Case__r.Subject, 
                            Contract__c, Contract__r.ContractNumber, Opportunity__c,
                            Order__c, Order__r.Name, Order__r.OrderNumber, Product2__c, Product2__r.Name, 
                            Opportunity__r.Name, Link1__c, Link2__c, 
                            Record1__c, Record2__c, Record1Name__c, Record2Name__c, OurFromNumber__c
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
                    SELECT  Id, GroupInits__c, Unread__c, LastMessageReceived__c, Broadcast__c, FirstName__c,
                            Group_Name__c, OwnerId, PrimaryUser__c, Owner.FirstName, LastFromInits__c,
                            LastModifiedDate, PrimaryUserInits__c, LastMessageDate__c, 
                            Asset__c, Asset__r.Name,
                            Campaign__c, Campaign__r.Name, Case__c, Case__r.Subject, 
                            Contract__c, Contract__r.ContractNumber, Opportunity__c,
                            Order__c, Order__r.Name, Order__r.OrderNumber, Product2__c, Product2__r.Name, 
                            Opportunity__r.Name, Link1__c, Link2__c, 
                            Record1__c, Record2__c, Record1Name__c, Record2Name__c, OurFromNumber__c
                    FROM Conversation__c
                    WHERE Id = :recordId
                ];
    }

    // this method finds conversations based on a Search key
    private static List<Conversation__c> getConsLikeName(String OwnerId, String name)
    {
        return  [
                    SELECT  Id, GroupInits__c, Unread__c, LastMessageReceived__c, Broadcast__c, FirstName__c,
                            Group_Name__c, OwnerId, PrimaryUser__c, Owner.FirstName, LastFromInits__c,
                            LastModifiedDate, PrimaryUserInits__c, LastMessageDate__c, 
                            Asset__c, Asset__r.Name,
                            Campaign__c, Campaign__r.Name, Case__c, Case__r.Subject, 
                            Contract__c, Contract__r.ContractNumber, Opportunity__c,
                            Order__c, Order__r.Name, Order__r.OrderNumber, Product2__c, Product2__r.Name, 
                            Opportunity__r.Name, Link1__c, Link2__c, 
                            Record1__c, Record2__c, Record1Name__c, Record2Name__c, OurFromNumber__c
                    FROM Conversation__c
                    WHERE OwnerId = :OwnerId AND Group_Name__c LIKE :name
                    ORDER BY LastMessageDate__c DESC
                ];
    }

    // this method wraps the Conversation__c record in a ConversationWrapper class
    private static List<ConversationWrapper> wrapConversations(List<Conversation__c> Conversations)
    {
        ConversationWrapper[] ConversationWrapperList = new List<ConversationWrapper>();
            for (Conversation__c conv : Conversations)
            {
                ConversationWrapper cw = new ConversationWrapper();
                cw.Id = conv.Id;
                cw.Broadcast = conv.Broadcast__c;
                cw.GroupInits = conv.GroupInits__c;
                cw.Unread = conv.Unread__c;
                cw.LastMessageReceived = conv.LastMessageReceived__c;
                cw.FirstName = conv.FirstName__c;
                cw.Group_Name = conv.Group_Name__c;
                cw.OwnerId = conv.OwnerId;
                cw.OwnerFirstName = conv.Owner.FirstName;
                cw.PrimaryUser = conv.PrimaryUser__c;
                cw.LastFromInits = conv.LastFromInits__c;
                cw.LastModifiedDate = conv.LastModifiedDate;
                cw.LastMessageDate = conv.LastMessageDate__c;
                cw.PrimaryUserInits = conv.PrimaryUserInits__c;
                cw.AssetId = conv.Asset__c;
                cw.AssetName = conv.Asset__r.Name;
                cw.CampaignId = conv.Campaign__c;
                cw.CampaignName = conv.Campaign__r.Name;
                cw.CaseId = conv.Case__c;
                cw.CaseSubject = conv.Case__r.Subject;
                cw.ContractId = conv.Contract__c;
                cw.ContractNumber = conv.Contract__r.ContractNumber;
                cw.OpportunityId = conv.Opportunity__c;
                cw.OpportunityName = conv.Opportunity__r.Name;
                cw.OrderId = conv.Order__c;
                cw.OrderName = conv.Order__r.Name;
                cw.OrderNumber = conv.Order__r.OrderNumber;
                cw.Product2Id = conv.Product2__c;
                cw.Product2Name = conv.Product2__r.Name;
                cw.Link1 = conv.Link1__c;
                cw.Record1 = conv.Record1__c;
                cw.Record1Name = conv.Record1Name__c;
                cw.Link2 = conv.Link2__c;
                cw.Record2 = conv.Record2__c;
                cw.Record2Name = conv.Record2Name__c;
                cw.OurFromNumber = conv.OurFromNumber__c;
                ConversationWrapperList.add(cw);
            }
            return ConversationWrapperList;
    }

    //-----------------------------------------------------------------------------
}