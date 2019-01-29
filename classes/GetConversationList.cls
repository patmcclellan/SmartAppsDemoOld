/**
 * Created by pmcclellan on 12/14/17. 
 * Updated 7/3/18 to add Campaign, Contract, and custom objects.
 * Updated January '19 to implement Conversation Sharing options
 * Apex Controller for ConversationFeed.cmp
 * Uses UserId and Conversation Sharing options, 
 * along with recordId to return Conversations owned by
 * this user, and/or related to the particular record page in view.
 */

public with sharing class GetConversationList
{
    @AuraEnabled
    public static List<Conversation> getConversationList(String recordId, String ConversationSharing)
    {
        if(!Conversation__c.SObjectType.getDescribe().isAccessible()) {
            return null;
        } else 
        {
            List<Conversation__c> Conversations = new List<Conversation__c>();
            if (recordId == null) { //it's a home page
                Conversations = getConversationsNoRecordId(ConversationSharing);
            } 
            // check for situations where the recordId is the recipient (Contact, Lead, Account)
              else if (recordId.left(3) == Schema.SObjectType.Contact.getKeyPrefix()) // it's a contact record
            {
                Conversations = getConversationsContactId(recordId, ConversationSharing);
            } else if (recordId.left(3) == Schema.SObjectType.Lead.getKeyPrefix()) // it's a lead record
            {
                Conversations = getConversationsLeadId(recordId, ConversationSharing);
            } else if (recordId.left(3) == Schema.SObjectType.Account.getKeyPrefix()) // it's an Account record
            {
                Conversations = getConversationsAccountId(recordId, ConversationSharing);
            } else
            {   // get the name and type of the sObject represented by the recordId
                Schema.SObjectType sObjType = Id.valueOf(recordId).getSObjectType();
                List<String> standardObjectList = new List<String>{'Asset', 'Campaign', 'Case', 'Contract', 'Opportunity', 'Order', 'Product2'};
                String sObjName = sObjType.getDescribe().getName();
                if (standardObjectList.contains(sObjName)) // standard object
                {
                    String lookupFieldName = sObjName + '__c';
                    Conversations = getRelatedConversations(recordId, lookupFieldName, ConversationSharing);
                }else //custom object
                {
                    Conversations = getRelatedConversations(recordId, ConversationSharing);
                }
            }
            return Conversations;
        }
    }

    @AuraEnabled
    public static List<Conversation> searchConversationList(String searchKey, String ConversationSharing)
    {
        if(!Conversation__c.SObjectType.getDescribe().isAccessible()) {
            return null;
        } else {
            Id OwnerId = UserInfo.getUserId();
            String name = '\'%' + searchKey + '%\'';
            List<Conversation__c> Conversations = new List<Conversation__c>();
            Conversations = getConversationsLikeName(name, ConversationSharing);
            return Conversations;
        }
    }

//---------------- UTILITY METHODS -------------------------------------------------------------

    //this method constructs the dynamic query using the WhereAnd parameter from specific methods below
    private static List<Conversation__c> makeQuery(String WhereAnd)
    {
        String qr =
                'SELECT  [long list of fields]' +
                'FROM Conversation__c ' +
                 WhereAnd +
                ' ORDER BY LastMessageDate__c DESC'
            ;
        System.debug('❓ ' + qr);
        return Database.query(qr);
    }

    //this method is used to search for conversations related to standard records
    private static List<Conversation__c> getRelatedConversations(String recordId, String lookupFieldName, String ConversationSharing)
    {
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        if(ConversationSharing == 'Private')
        {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND '+ lookupFieldName +' = \'' + recordId + '\' '; 

        }else if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                'AND '+ lookupFieldName +' = \'' + recordId + '\' ' ;
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        {
            WhereAnd = 
                'WHERE '+ lookupFieldName +' = \'' + recordId + '\' ';
        }
        return makeQuery(WhereAnd);  
    }

    //this method is used to search for conversations related to custom records
    private static List<Conversation__c> getRelatedConversations(String recordId, String ConversationSharing)
    {
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        if(ConversationSharing == 'Private')
        {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND (Record1__c = \'' + recordId + '\'' + ' OR Record2__c = \'' + recordId + '\') '; 

        }else if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                'AND (Record1__c = \'' + recordId + '\'' + ' OR Record2__c = \'' + recordId + '\') ';
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        {
            WhereAnd = 
                'WHERE (Record1__c = \'' + recordId + '\'' + ' OR Record2__c = \'' + recordId + '\') ';
        } 
        return makeQuery(WhereAnd); 
    }

    //this method is used to search for conversations where there is no recordId (HomePage placement)
    private static List<Conversation__c> getConversationsNoRecordId(String ConversationSharing)
    {
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        if(ConversationSharing == 'Private')
        {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' ; 

        }else if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' ;
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        { // on a home page, return this User's conversations
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' ; 
        } 
        return makeQuery(WhereAnd); 
    }

    //this method finds Conversations related to a ContactId
    private static List<Conversation__c> getConversationsContactId(String recordId, String ConversationSharing)
    {
         //find all the member records for this contact
        List<Member__c> Members = new List<Member__c>();
        if(Member__c.SObjectType.getDescribe().isAccessible())
        {
            Members = [SELECT Conversation__c FROM Member__c WHERE Contact__c = :recordId];
        }
        List<String> IdList = new List<String>();

        //build a list of conversationIds for all those conversations
        for (Member__c member : Members) {
            IdList.add('\'' + member.Conversation__c + '\'');
        }
        System.debug('IdList: ' + IdList);
        
        //construct the WhereAnd parameters of the query
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        if(ConversationSharing == 'Private')
        {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND Id IN ' + IdList ; 

        }else if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                'AND Id IN ' + IdList; 
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        {
            WhereAnd = 
                'WHERE Id IN ' + IdList; 
        } 

        return makeQuery(WhereAnd);   
    }

    //this method finds Conversations related to a LeadId
    private static List<Conversation__c> getConversationsLeadId(String recordId, String ConversationSharing)
    {
         //find all the member records for this contact
        List<Member__c> Members = [SELECT Conversation__c FROM Member__c WHERE Lead__c = :recordId];
        List<String> IdList = new List<String>();
        System.debug('IdList: ' + IdList);
        //build a list of conversationIds for all those conversations
        for (Member__c member : Members) {
            IdList.add('\'' + member.Conversation__c + '\'');
        }
        //construct the WhereAnd parameters of the query
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        if(ConversationSharing == 'Private')
        {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND Id IN ' + IdList; 

        }else if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                'AND Id IN ' + IdList; 
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        {
            WhereAnd = 
                'WHERE Id IN ' + IdList; 
        } 

        return makeQuery(WhereAnd);
    }

    //this method finds Conversations related to an AccountId
    private static List<Conversation__c> getConversationsAccountId(String recordId, String ConversationSharing)
    {
        System.debug('🚙 getConversationAccountId: ' + recordId);
        //find all the contacts associated with this account
        List<Contact> Contacts = new List<Contact>();
        if(Contact.SObjectType.getDescribe().isAccessible())
        {
            Contacts = [SELECT Id FROM Contact WHERE AccountId = :recordId];
        }
        System.debug('🚙 Contacts found: ' + Contacts.size());
        if(Contacts.size() > 0) // this user can access some contacts for this account
        {
            List<String> contactIds = new List<String>();
            for(Contact contact : Contacts)
            {
                contactIds.add(contact.Id);
            }
            System.debug('🚙 contactIds: ' + contactIds);
            //find all the member records for all contacts in this list
            List<Member__c> Members = new List<Member__c>();
            if(Member__c.SObjectType.getDescribe().isAccessible())
            {
                Members = [SELECT Conversation__c FROM Member__c WHERE Contact__c IN :contactIds];
            }
            System.debug('🚙 Members: ' + Members);
            List<String> IdList = new List<String>();

            //build a list of conversationIds for all those conversations
            for (Member__c member : Members) {
                IdList.add('\'' + member.Conversation__c + '\'');
            }
            System.debug('🚙 IdList: ' + IdList);
            //construct the WhereAnd parameters of the query
            String UserId = String.valueOf(UserInfo.getUserId());
            String WhereAnd = '';
            if(ConversationSharing == 'Private')
            {
                WhereAnd = 
                    'WHERE OwnerId = \'' + UserId + '\' ' +
                    'AND Id IN ' + IdList; 

            }else if(ConversationSharing == 'Shared–PhoneNumber')
            {
                String PhoneNumber = getPhoneNumber();
                System.debug('📳 ' + PhoneNumber);
                WhereAnd =
                    'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                    'AND Id IN ' + IdList; 
                    
            }else if(ConversationSharing == 'Shared–RecordAccess')
            {
                WhereAnd = 
                    'WHERE Id IN ' + IdList; 
            } 

            return makeQuery(WhereAnd);
        } 
        return new List<Conversation__c>(); //nullList
    }

    //this method finds Conversations related to a ConversationId
    private static List<Conversation__c> getConversationsConvId(String recordId)
    {
        String WhereAnd = 'WHERE Id = \'' + recordId + '\' ';
        return makeQuery(WhereAnd);
    }

    //this method finds Conversations where the GroupName is LIKE the search term name
    private static List<Conversation__c> getConversationsLikeName(String name, String ConversationSharing)
    {
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        if(ConversationSharing == 'Private')
        {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND Group_Name__c LIKE '+ name; 

        }else if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                'AND Group_Name__c LIKE '+ name; 
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        {
            WhereAnd = 
                'WHERE Group_Name__c LIKE '+ name; 
        }
        return makeQuery(WhereAnd);  
    }

    private static String getPhoneNumber()
    {   
        String UserId = String.valueOf(UserInfo.getUserId());
        System.debug('🆔 ' + UserId);
        String PhoneNumber;
        if(ProtonTextUser__c.SObjectType.getDescribe().isAccessible())
        {
            PhoneNumber = [
                SELECT PhoneNumber__r.Number__c
                FROM ProtonTextUser__c
                WHERE User__c = :UserId
            ].PhoneNumber__r.Number__c;
        }
        return PhoneNumber;
    }


    //-----------------------------------------------------------------------------
}