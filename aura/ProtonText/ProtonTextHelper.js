/**
 * Created by pmcclellan on 12/18/17.
 */
({
    onSelectTab : function(component, event, helper)
    {
        //console.log("selectTab");
        component.set("v.selectedTab", "convoTab");
    },

    selectConversation : function(component,event,helper)
    {
    // set NewConversation to false so the NewConversation interface won't render
        component.set("v.NewConversation", false);

    // check to see if the selected Conversation is already active
        var Conversation = event.getParam("Conversation");
        if (component.get("v.activeConversationId") == Conversation.Id)
            {
                // console.log("🥨Selected conversation " + Conversation.Id + " is active: " + component.get("v.activeConversationId"));
                component.set("v.selectedTab", component.get("v.Conversation.Group_Name"));
            } else
            {
            // the selected conversation isn't active, so create a new tab, addContent, activate that tab
                component.set("v.Conversation", event.getParam("Conversation"));
                component.set("v.activeConversationId", component.get("v.Conversation.Id"));
                // console.log("🌶 onSelectConversation called by (no __c) " + component.get("v.Conversation.Group_Name"));

                var GroupName = component.get("v.Conversation.Group_Name");
                //console.log('GroupName, no __c: ' + GroupName);

            //create new tab for selected conversation
            $A.createComponent("lightning:tab",
            {
                "label": GroupName,
                "id": GroupName,
                "onactive": component.getReference("c.getContent"),
                "class": "slds-size_6-of-12"

            }, function (newTab, status, error)
                {
                    if(status === "SUCCESS")
                    {
                        var body = component.get("v.moretabs");
                        component.set("v.moretabs", newTab);
                        //set CancelX to true so the ☒ renders
                        component.set("v.CancelX", true);
                    } else
                    {
                        throw new Error(error);
                    }
                });
                try
                {
                    component.set("v.selectedTab", GroupName);
                }
                catch(e)
                {
                    console.error(e)
                }
            }
    },

    killTab : function(component, event, helper)
    {
        component.set("v.CancelX", false);
        component.set("v.NewConversation", false);
        component.set("v.EditRecipients", false);
        component.set("v.moretabs", null);
        component.set("v.activeConversationId", null);
        component.set("v.selectedTab", "feed");
    },

    addContent : function(component, event)
    {
        var Conversation = component.get("v.Conversation");
        //console.log('🏳️‍🌈 addContent called:' + JSON.stringify(Conversation));
        var TheirColor = component.get("v.TheirColor");
        var OurColor = component.get("v.OurColor");
        if(Conversation != null)
        {
            component.set("v.activeConversation", Conversation.Id);
            var GroupName = Conversation.Group_Name;
        }
        var tab = event.getSource();
        //console.log("🍤 addContent called by (v.id, no __c): " + tab.get("v.id"));
        switch (tab.get('v.id')){
            case GroupName :
                //console.log('🥓 GroupName (no __c): ' + GroupName);
                $A.createComponent("c:ConvoDisplay", {
                    "recordId":component.get("v.recordId"),
                    "Conversation": Conversation,
                    "TheirColor": TheirColor,
                    "OurColor": OurColor,
                    "Link1" : component.get("v.Link1"),
                    "Link2" : component.get("v.Link2"),
                    "MmsOutEnabled" : component.get("v.MmsOutEnabled")
                }, function (newContent, status, error)
                    {
                        if (status === "SUCCESS") {
                            tab.set('v.body', newContent);
                        } else {
                            throw new Error(error);
                        }
                    });
                break;
            case "New Conversation" :
                //console.log('🆕 New Conversation');
                $A.createComponent("c:NewConversation", {
                    "recordId": component.get("v.recordId"),
                    "Link1" : component.get("v.Link1"),
                    "Link2" : component.get("v.Link2")
                },
                function (newContent, status, error)
                {
                    if (status === "SUCCESS") {
                        tab.set('v.body', newContent);
                    } else {
                        console.error(status +": " + error );
                    }
                });
                break;
            case "New Broadcast" :
                //console.log('🆕 New Conversation');
                $A.createComponent("c:NewBroadcast", {
                    "recordId": component.get("v.recordId"),
                    "Link1" : component.get("v.Link1"),
                    "Link2" : component.get("v.Link2")
                },
                function (newContent, status, error)
                {
                    if (status === "SUCCESS") {
                        tab.set('v.body', newContent);
                    } else {
                        console.error(status +": " + error );
                    }
                });
                break;
            case "Edit Recipients" :
                //console.log('🆕 Edit Recipient');
                $A.createComponent("c:EditBroadcast", {
                    "Conversation": component.get("v.Conversation")
                },
                function (newContent, status, error)
                {
                    if (status === "SUCCESS") {
                        tab.set('v.body', newContent);
                    } else {
                        console.error(status +": " + error );
                    }
                });
                break;
        }

    },

    setupEditRecipients : function(component, event, helper)
    {
        if(component.get("v.EditRecipients"))
        {//no need to create tab, just select it
            //console.log("🍷 EditRecipients tab already exists, select it.");
            try
            {
            component.set("v.selectedTab", "Edit Recipients");
            }
            catch(e)
            {
                console.error(e)
            } //end try-catch
        } //end if
        else
        {
          //create new tab for EditRecipients.cmp
            //console.log("🍋 Setting up tab for NewConversation");
            var Conversation = component.get("v.Conversation");
            var label = Conversation.Group_Name + ' Recipients';
            $A.createComponent("lightning:tab",
            {
                "label": label,
                "id": "Edit Recipients",
                "onactive": component.getReference("c.getContent"), //controller method that calls helper.addContent
                "onblur": component.set("v.selectedTab","feed")

            }, function (newTab, status, error)
                {
                    if(status === "SUCCESS")
                    {
                        var body = component.get("v.moretabs");
                        component.set("v.moretabs", newTab);
                        component.set("v.EditRecipients", true);
                        //set CancelX to true so the ☒ renders
                        component.set("v.CancelX", true);
                    } else
                    {
                        throw new Error(error);
                    }
                }); //end createComponent params
                try
                {
                    component.set("v.selectedTab", "Edit Recipients");
                }
                catch(e)
                {
                    console.error(e)
                }//end try-catch
        }
    },

    setupNewConversation : function(component, event, helper)
    {
        //console.log("🔑 NewConversation tab already exists? " + component.get("v.NewConversation"));

        if(component.get("v.NewConversation"))
        { //no need to create tab, just select it
            //console.log("🍷 NewConversation tab already exists, select it.");
            try
            {
            component.set("v.selectedTab", "New Conversation");
            }
            catch(e)
            {
                console.error(e)
            } //end try-catch
        } //end if
        else
        {
            //create new tab for NewConversation.cmp
            //console.log("🍋 Setting up tab for NewConversation");
            $A.createComponent("lightning:tab",
            {
                "label": "New Conversation",
                "id": "New Conversation",
                "onactive": component.getReference("c.getContent"), //controller method that calls helper.addContent
                "onblur": component.set("v.selectedTab","feed")

            }, function (newTab, status, error)
                {
                    if(status === "SUCCESS")
                    {
                        var body = component.get("v.moretabs");
                        component.set("v.moretabs", newTab);
                        component.set("v.NewConversation", true);
                        //set CancelX to true so the ☒ renders
                        component.set("v.CancelX", true);
                    } else
                    {
                        throw new Error(error);
                    }
                }); //end createComponent params
                try
                {
                    component.set("v.selectedTab", "New Conversation");
                }
                catch(e)
                {
                    console.error(e)
                }//end try-catch

        } //end else
    },

    setupNewBroadcast: function(component, event, helper)
        {
            //console.log("🔑 NewBroadcast tab already exists? " + component.get("v.NewConversation"));

            if(component.get("v.NewBroadcast"))
            { //no need to create tab, just select it
                //console.log("🍷 NewBroadcast tab already exists, select it.");
                try
                {
                component.set("v.selectedTab", "New Broadcast");
                }
                catch(e)
                {
                    console.error(e)
                } //end try-catch
            } //end if
            else
            {
                //create new tab for NewConversation.cmp
                //console.log("🍋 Setting up tab for NewConversation");
                $A.createComponent("lightning:tab",
                {
                    "label": "New Broadcast",
                    "id": "New Broadcast",
                    "onactive": component.getReference("c.getContent"), //controller method that calls helper.addContent
                    "onblur": component.set("v.selectedTab","feed")

                }, function (newTab, status, error)
                    {
                        if(status === "SUCCESS")
                        {
                            var body = component.get("v.moretabs");
                            component.set("v.moretabs", newTab);
                            component.set("v.NewBroadcast", true);
                            //set CancelX to true so the ☒ renders
                            component.set("v.CancelX", true);
                        } else
                        {
                            throw new Error(error);
                        }
                    }); //end createComponent params
                    try
                    {
                        component.set("v.selectedTab", "New Broadcast");
                    }
                    catch(e)
                    {
                        console.error(e)
                    }//end try-catch

            } //end else
        },


    updateUnreadConversationList : function (component, event, helper)
    {
        var ConversationId = event.getParam("ConversationId");
        var Operation = event.getParam("Operation");
        var UnreadConversationList = component.get("v.UnreadConversationList");
        var index = UnreadConversationList.indexOf(ConversationId);

        if (Operation == "splice")
        {//if the Id is in the Unread list, remove it
            if (index > -1)
            { //it's on the list, so splice it
                UnreadConversationList.splice(index, 1);
                //console.log("Spliced from list: " + ConversationId);
            }
        } else // must be push operation
        {
            if (index == -1)
            {//it's not in the list, so push it
                UnreadConversationList.push(ConversationId);
                //console.log("Pushed to list: " + ConversationId);
            }
        }
        if (UnreadConversationList.length > 0)
        {
            component.set("v.UpdateConversationFlag", true);
            helper.refreshConversationFeed(component, event, helper);
        } else
        {
            component.set("v.UpdateConversationFlag", false);
        }
        //console.log("Flag: " + component.get("v.UpdateConversationFlag") + " | " + component.get("v.UnreadConversationList"));

    },
    
    refreshConversationFeed : function(component, event, helper)
    {
    // call the aura:method "refresh" in ConversationFeed

        var ConversationFeed = component.find("ConversationFeed");
        if(typeof ConversationFeed != 'undefined'){
            ConversationFeed.refresh();
        } else {
            console.error("Didn't find ConversationFeed component");
        }
    },

    //more code here
})
