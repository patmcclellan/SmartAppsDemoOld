({

    selectFile : function(component, event, helper) {
        var selectFile = component.getEvent("SelectFile");
        selectFile.setParams({"File" : component.get("v.File")}); 
        selectFile.fire();
        // console.log('🔥 Fired SelectFile: ' + JSON.stringify(component.get("v.File")));
    }

    //more code here
})
