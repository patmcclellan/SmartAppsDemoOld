({
    doInit : function(component, event, helper)
    {
        component.set("v.FullListFiles", null);
        helper.findFilesByRecordId(component, event, helper);
    },

    refresh : function(component, event, helper)
    {
        component.set("v.selectedFileId", "");
        component.set("v.FullListFiles", null);
        helper.findFilesByRecordId(component, event, helper);
    },

    onSearchKeyFile : function(component, event, helper)
    {
        helper.searchFilesByKey(component, event, helper);
    },

    onSelectFile: function(component, event, helper)
    {
        var File = event.getParam("File");
        component.set("v.selectedFileId", File.Id);
        // console.log("received selected file: " + File.Id);

    }
    //more code here
})
