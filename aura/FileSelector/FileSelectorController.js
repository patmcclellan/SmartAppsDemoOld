({
    handleViewImages : function(component, event, helper)
    {
        component.set("v.viewImages", true);
        component.set("v.sendDisabled", true);
        component.set("v.searchKey", "");
    },

    handleViewFiles : function(component, event, helper)
    {
        component.set("v.viewImages", false);
        component.set("v.sendDisabled", true);
        component.set("v.searchKey", "");
    },

    onSelectFile : function(component, event, helper) {
        component.set("v.sendDisabled", "false");
        component.set("v.File", event.getParam("File"));
    },

    handleUploadFinished : function(component, event, helper)
    {
        var fileUploaded = $A.get("e.c:FileUploaded");
        fileUploaded.fire();
    },

    cancelModal : function(component, event, helper)
    {
        component.find("fileSelector").notifyClose();
    },

    SendFile : function(component, event, helper)
    {
        console.log("Send button pressed");
        $A.get("e.c:SendFile").setParams({ "File" : component.get("v.File") }).fire();
        component.find("fileSelector").notifyClose();
    },


    // more code here
})
