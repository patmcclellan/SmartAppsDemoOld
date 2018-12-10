/**
 * Apex Controller for ConversationFeed.cmp
 * Created by pmcclellan on 12/14/17. Updated 7/3/18 to add Asset, Campaign, Case, Contract,
 * Order, Product2 and custom objects.
 * Uses OwnerId and recordId to return Conversations owned by
 * this user, and related to the particular record page in view.
 */

public with sharing class GetConversationList
{
    @AuraEnabled
    public static List<Conversation> getConversationList(String recordId)
    {
        if(!Conversation__c.SObjectType.getDescribe().isAccessible()) {
            return null;
        } else 
        {
            Id OwnerId = UserInfo.getUserId();
            List<Conversation__c> Conversations = new List<Conversation__c>();
            if (recordId == null) {
                Conversations = getConsNoRecordId(OwnerId);
            } else if (recordId.Left(3) == Schema.SObjectType.Asset.getKeyPrefix()){ //it's an Asset record
                Conversations = getConsAssetId(OwnerId, recordId);
            } else if (recordId.Left(3) == Schema.SObjectType.Campaign.getKeyPrefix()){ //it's a campaign record
                Conversations = getConsCampaignId(OwnerId, recordId);
            } else if (recordId.Left(3) == Schema.SObjectType.Case.getKeyPrefix()){ //it's a case record
                Conversations = getConsCaseId(OwnerId, recordId);
            } else if (recordId.Left(3) == Schema.SObjectType.Contract.getKeyPrefix()){ //it's a contract record
                Conversations = getConsContractId(OwnerId, recordId);
            } else if (recordId.left(3) == Schema.SObjectType.Opportunity.getKeyPrefix()){ // it's an opportunity record
                Conversations = getConsOppId(OwnerId, recordId);
            } else if (recordId.Left(3) == Schema.SObjectType.Order.getKeyPrefix()){ //it's an Order record
                Conversations = getConsOrderId(OwnerId, recordId);
            } else if (recordId.Left(3) == Schema.SObjectType.Product2.getKeyPrefix()){ //it's a Product2 record
                Conversations = getConsProduct2Id(OwnerId, recordId);
            } else if (recordId.left(3) == Schema.SObjectType.Contact.getKeyPrefix()){ // it's a contact record
                Conversations = getConsContactId(OwnerId, recordId);
            } else if (recordId.left(3) == Schema.SObjectType.Lead.getKeyPrefix()){ // it's a lead record
                Conversations = getConsLEadId(OwnerId, recordId);
            } else if (recordId.left(3) == Schema.SObjectType.Account.getKeyPrefix()){ // it's an Account record
                Conversations = getConsAccountId(OwnerId, recordId);
            } else if (recordId.left(3) == Schema.SObjectType.Conversation__c.getKeyPrefix()){ // it's a Conversation record
                Conversations = getConsConvId(OwnerId, recordId);
            } else {// it's a custom object record
                Conversations = getConsCustObj(OwnerId, recordId);
            }
            return Conversations;
        }
    }

    @AuraEnabled
    public static List<Conversation> searchConversationList(String searchKey)
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

    private static List<Conversation__c> getConsAssetId(String OwnerId, String recordId)
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
                    WHERE OwnerId = :OwnerId AND Asset__c = :recordId
                    ORDER BY LastMessageDate__c DESC
                ];
    }

    private static List<Conversation__c> getConsCampaignId(String OwnerId, String recordId)
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
                    WHERE OwnerId = :OwnerId AND Campaign__c = :recordId
                    ORDER BY LastMessageDate__c DESC
                ];
    }

    private static List<Conversation__c> getConsCaseId(String OwnerId, String recordId)
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
                    WHERE OwnerId = :OwnerId AND Case__c = :recordId
                    ORDER BY LastMessageDate__c DESC
                ];
    }

    private static List<Conversation__c> getConsContractId(String OwnerId, String recordId)
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
                    WHERE OwnerId = :OwnerId AND Contract__c = :recordId
                    ORDER BY LastMessageDate__c DESC
                ];
    }

    private static List<Conversation__c> getConsOppId(String OwnerId, String recordId)
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
                    WHERE OwnerId = :OwnerId AND Opportunity__c = :recordId
                    ORDER BY LastMessageDate__c DESC
                ];
    }

    private static List<Conversation__c> getConsOrderId(String OwnerId, String recordId)
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
                    WHERE OwnerId = :OwnerId AND Order__c = :recordId
                    ORDER BY LastMessageDate__c DESC
                ];
    }

    private static List<Conversation__c> getConsProduct2Id(String OwnerId, String recordId)
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
                    WHERE OwnerId = :OwnerId AND Product2__c = :recordId
                    ORDER BY LastMessageDate__c DESC
                ];
    }

    private static List<Conversation__c> getConsCustObj(String OwnerId, String recordId)
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
                    WHERE OwnerId = :OwnerId AND (Record1__c = :recordId OR Record2__c = :recordId)
                    ORDER BY LastMessageDate__c DESC
                ];
    }

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

    private static List<Conversation__c> getConsConvId(String OwnerId, String recordId)
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
}