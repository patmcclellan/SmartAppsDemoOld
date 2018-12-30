/**
 * Created by pmcclellan on 12/14/17.
 */
({
    initConversations : function(component, event, helper)
    {
        // call GetConversationList.cls and supply the recordId
        var getConversationList = component.get("c.getConversationList");
        getConversationList.setParam("recordId", component.get("v.recordId"));

        //add callback behavior
        getConversationList.setCallback(this, function(response)
        {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS")
            {
                // if there are any Conversations, set v.Conversations
                var Conversations = response.getReturnValue();
                if(Conversations.length > 0)
                {
                    if (!component.get("v.Loaded")) // first time load
                    {
                        component.set("v.Conversations", Conversations);
                        component.set("v.Loaded", true);
                        component.set("v.ApexPull", Conversations);
                    } else // refresh
                    {
                        component.set("v.NewPull", Conversations);
                        helper.checkForChange(component, event, helper);
                    }
                }
            } //end of SUCCESS state code
            else
                console.error("ConversationFeedHelper:getConversationList failed with state: " + state);
        }); //end of setCallback
        $A.enqueueAction(getConversationList);
    },

    findConversations : function(component, event, helper)
    {  
        var searchKey = event.getParam("searchKey");
        // console.log("ConversationFeed caught SearchKeyConv: " + searchKey);
        var action = component.get("c.searchConversationList");
        action.setStorable();
        action.setParams({
            "searchKey": searchKey
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS")
            {
                var Conversations = response.getReturnValue();
                component.set("v.Conversations", Conversations);
            }
        });
        $A.enqueueAction(action);
        
    },

    checkForChange : function(component, event, helper)
    {
        // console.log("Checking for Change.");
        var isChanged = false;
        var Conversations = component.get("v.NewPull");
        // console.log("NewPull: " + JSON.stringify(Conversations));
        var OldPull = component.get("v.ApexPull");
        // console.log("OldPull: " + JSON.stringify(OldPull));
        if (Conversations.length != OldPull.length)
        {
            isChanged = true;
            // console.log("ConversationList is different length.");
        } else
            {
                for (var i = 0; i<Conversations.length; i++)
                {
                    var fresh = Conversations[i];
                    var old = OldPull[i];
                    if (fresh.Id != old.Id)
                    {
                        isChanged = true;
                        // console.log("🔋 ConversationList is different order.");
                        break;
                    } else
                    {
                        if (fresh.Unread != old.Unread)
                        {
                            isChanged = true
                            // console.log("📟 Unread changed on Conversation: " + fresh.Group_Name);
                            break;
                        }
                    }
                }
            }
        if (isChanged)
        {
            component.set("v.ApexPull", Conversations);
            component.set("v.Conversations", Conversations);
            // console.log("Conversations: " + JSON.stringify(component.get("v.Conversations")));
        } 

    },
    
    getEnclosingTabId : function(component, event, helper)
    {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.getEnclosingUtilityId().then(function(utilityId) {
            if(utilityId){
                component.set("v.StandAlone", true);
            };
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    //more code here

})