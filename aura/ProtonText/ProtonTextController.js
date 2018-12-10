/**
 * Created by pmcclellan on 12/15/17.
 */
({
    doInit : function(component, event, helper)
    {
        //console.log("ProtonText: doInit called.")
    },

    onUpdateConversationFlag : function(component, event, helper)
    {
        helper.updateUnreadConversationList(component, event, helper);
    },

    onSelectConversation : function(component, event, helper)
    {
       helper.selectConversation(component,event,helper);
    },

    onTabChange : function(component, event, helper)
    {
        var whichTab = component.get("v.selectedTab");
        if (whichTab == 'feed')
        {
            helper.refreshConversationFeed(component, event, helper);
        }
    },

    getContent : function(component, event, helper)
    {
        helper.addContent(component, event, helper);
        // console.log("🔋 calling addContent");
    },

    onNewBroadcast : function(component, event, helper)
    {
        // console.log("🔘 New Broadcast button pushed.");
        helper.setupNewBroadcast(component, event, helper);
    },

    onEditRecipients : function(component, event, helper)
    {
        // console.log("🔘 New Conversation button pushed.");
        component.set("v.Conversation", event.getParam("Conversation"));
        helper.setupEditRecipients(component, event, helper);
    },

    onNewConversation : function(component, event, helper)
    {
        // console.log("🔘 New Conversation button pushed.");
        helper.setupNewConversation(component, event, helper);
    },

    onClickCancel : function(component, event, helper)
    {
        helper.killTab(component, event, helper);
    },

   //more code here
})

