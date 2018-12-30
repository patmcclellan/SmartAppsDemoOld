// This component retrieves up to 300 related files + up to 300 unrelated files in findFilesbyRecordId, 
// but only the first 24 are rendered. A wait for the first batch is not unexpected, and
// rendering time on subsequent batches of 12 is tiny, enhancing responsiveness.
// The full list is saved in v.FullListFiles, and scrolling to the
// bottom triggers the FileListRenderer to call addMoreFiles, which concatenates the next 12 files to
// v.Files for rendering . This is done because each fileTile is making a call to the previewURL of the file, 
// which makes the app unresponsive (timeout) if there are a lot of files.

({
    findFilesByRecordId : function(component, event, helper) 
    {
        // console.log("findFilesByRecordId called"); 
        var fullList = component.get("v.FullListFiles");
        if(!fullList) //initial load, or refresh
        {
            // console.log("going to look for files."); 
            var spinner = component.find("spinner");
            $A.util.toggleClass(spinner, "slds-hide");
            var findFilesByRecordId = component.get("c.findFilesByRecordId");
            findFilesByRecordId.setParams({
                "recordId": component.get("v.recordId"),
                "howManyString": "300", // this is howMany related files AND howMany unrelated files, potentially returning double this many
                "isImage" : component.get("v.viewImages")
            });
            findFilesByRecordId.setCallback(this, function(response){
                var state = response.getState();
                if(component.isValid() && state === "SUCCESS")
                {
                    if (response.getReturnValue().length > 0)
                    {
                        component.set("v.FullListFiles", response.getReturnValue());
                        var fullList = component.get("v.FullListFiles");
                        component.set("v.Files", fullList.slice(0,24));
                        component.set("v.hasFile", true);
                        $A.util.toggleClass(spinner, "slds-hide");
                    }else 
                    {
                        component.set("v.hasFile",false);
                        $A.util.toggleClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(findFilesByRecordId);
        }else // fullList already has files, so use them rather than calling the server again.
        {
            component.set("v.Files", fullList.slice(0,24));
            component.set("v.hasFile", true);
        }
        
    },

    addMoreFiles : function(component, event, helper)
    {
        // this function doesn't get more files from the server,
        // it simply slices more from v.FullListFiles
        // and concatenates them to v.Files for rendering
        var fullList = component.get("v.FullListFiles");
        // console.log("fullListCount: " + fullList.length);
        var files = component.get("v.Files");
        var index = files.length;
        if(fullList.length > files.length)
        {
            var moreFiles = fullList.slice(index, index + 12);
            // console.log("moreFiles: " + JSON.stringify(moreFiles));
            files = files.concat(moreFiles);
            // console.log("filesCount: " + files.length);
            component.set("v.Files", files);
        }
    },

    searchFilesByKey : function(component, event, helper)
    {
        component.set("v.searching", true);
        var searchKey = component.get("v.searchKey");
        if (searchKey == "")
        {
            console.log("searchKey is empty");
            component.set("v.searching", false);
            helper.findFilesByRecordId(component, event, helper);
        } else
        {
            // console.log("FileList caught SearchKeyFile:" + searchKey);
            var searchFilesByKey = component.get("c.searchFilesByKey");
            searchFilesByKey.setParams({
                "searchKey": searchKey,
                "recordId": component.get("v.recordId"),
                "isImage" : component.get("v.viewImages")
            });
            searchFilesByKey.setCallback(this, function(response){
                var state = response.getState();
                if(component.isValid() && state === "SUCCESS")
                {
                    if (response.getReturnValue().length > 0)
                        {
                            component.set("v.Files", response.getReturnValue());
                            component.set("v.hasFile",true);
                            // console.log(JSON.stringify(component.get("v.Files")));
                        }else component.set("v.hasFile",false);
                    // console.log("🍉 Files: " + JSON.stringify(response.getReturnValue()));
                }
            });
            $A.enqueueAction(searchFilesByKey);
        }
    },

    // more code here
})
