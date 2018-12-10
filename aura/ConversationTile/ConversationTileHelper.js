/**
 * Created by pmcclellan on 12/13/17.
 */
({
    checkToday : function(component, event, helper)
    {
        //console.log("checkToday called | " + component.get("v.Conversation.Group_Name"));

        var today = new Date(); //local timezone
        var hoursOffset = today.getTimezoneOffset()/60;
        //console.log("timezoneOffset: " + hoursOffset);
        var year = today.getFullYear();
        var month = today.getMonth() + 1;
        var day = today.getDate();
        var hour = today.getHours();
        //console.log("today: " + month + " | " + day + " | " + year + " | " + hour);

        var messageDate = component.get("v.Conversation.LastMessageDate"); //UTC timezone
        //console.log("CreatedDate: " + component.get("v.Conversation.LastMessageDate"));
        var messageYear = parseInt(messageDate.substring(0,4));
        var messageMonth = parseInt(messageDate.substring(5,7));
        var messageDay = parseInt(messageDate.substring(8,10));
        var messageHour = parseInt(messageDate.substring(11,13));
        //console.log("messageDate: " + messageMonth+ " | " + messageDay + " | " + messageYear  + " | " + messageHour );

        if(hoursOffset > 0) // West of UTC. Messages sent end of day will show the messageDay as tomorrow.
        {
            if (messageHour < hoursOffset) // late in the day, needs adjustment
            {
                messageDay = messageDay - 1;
            }
        } else // East of UTC. Message sent beginning of day will show the messageDay as yesterday.
        {
            if (24 - messageHour + hoursOffset < 0) //early in the day, needs adjustment
            {
                messageDay = messageDay + 1;
            }
        }
        //console.log("messageDate: " + messageMonth+ " | " + messageDay + " | " + messageYear );
        if (messageYear == year &&
            messageMonth == month &&
            messageDay == day)
        {
            component.set("v.Today", true);
            // console.log('Today: ' + component.get("v.Today"));
        } else {
            if ((   messageYear == year &&
                    messageMonth == month &&
                    messageDay == day - 1))
                    {
                        component.set("v.Yesterday", true);
                    }
        }
    },

    checkUpdateFlag : function(component, event, helper)
    {
       if(component.get("v.Conversation.Unread")>0)
       {
           var UpdateConversationFlag = component.getEvent("UpdateConversationFlag");
           UpdateConversationFlag.setParam("ConversationId", component.get("v.Conversation.Id"));
           UpdateConversationFlag.fire();
           //console.log("🔥 " + component.get("v.Conversation.Id") + " Update 🔴");
       }
    },

    //more code here
})