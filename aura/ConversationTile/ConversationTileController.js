/**
 * Created by pmcclellan on 12/13/17.
 */
({
    doInit : function(component,event,helper)
    {
        //console.log('ConversationTile doInit called: ' + JSON.stringify(component.get("v.Conversation")));
        helper.checkToday(component, event, helper);
        helper.checkUpdateFlag(component, event, helper);

    },

    makeSpace : function(component, event, helper)
    {
        component.set("v.menuOpen", true);
    },

    markRead : function(component, event, helper)
    {
        component.set("v.Conversation.Unread", false);
    },

    onSelectConversation : function(component, event, helper)
    {
     // set Conversation and fire SelectConversation event
        var Conversation = component.get("v.Conversation");
        var SelectConversation = component.getEvent("SelectConversation");
        SelectConversation.setParams({"Conversation": Conversation});
        SelectConversation.fire();
        //console.log("🔥 SelectConversation fired | Conv (no __c): " + Conversation.Id + " | " + Conversation.Group_Name);
    },

    editRecipients : function(component, event, helper)
    {
        var Conversation = component.get("v.Conversation");
        var EditRecipients = component.getEvent("EditRecipients");
        EditRecipients.setParams({"Conversation": Conversation});
        EditRecipients.fire();
        console.log("🔥 EditRecipients fired");
    },

    editConversation : function(component, event, helper)
    {
        component.set("v.editActive", true);
    },

    save : function(component, event, helper)
    {
        component.find("edit").get("e.recordSave").fire();
        component.set("v.editActive", false);
        var toastEvent = $A.get("e.force:showToast");    
        toastEvent.setParams({
            title: "Success",
            message: "Conversation updated.",
            type: "success",
            duration: 3000
        });
        var ConversationEdited = component.getEvent("ConversationEdited");
        ConversationEdited.fire();
        toastEvent.fire();
    },

    cancel : function(component, event, helper)
    {
        component.set("v.editActive", false);
    },

    //more code here
})