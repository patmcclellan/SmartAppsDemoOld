/**
 * Created by pmcclellan on 12/14/17.
 */
({
    doInit : function(component, event, helper){
        // console.log("🏆ConversationFeed: doInit");
        helper.initConversations(component, event, helper);
        helper.getEnclosingTabId(component, event, helper);
    },

    onConversationEdited : function(component, event, helper){
        // console.log("ConversationEdited event received.");
        component.set("v.Loaded", false);
        helper.initConversations(component, event, helper);
        helper.getEnclosingTabId(component, event, helper);
    },

    onSearchKeyConv : function(component, event, helper)
    {
        helper.findConversations(component, event, helper);
    },

        //more code here
})