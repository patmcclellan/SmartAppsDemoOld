global class LinkedObjectList extends VisualEditor.DynamicPickList{
    
    // this method sets up the default value for the picklist
    global override VisualEditor.DataRow getDefaultValue()
    {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }

    // this method builds the list of values in the picklist
    global override VisualEditor.DynamicPickListRows getValues() 
    {
        // get a map of all the objects in the org
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        // now pull the object apiNams into a list and sort it
        Set<String> keys = gd.keyset();
        List<String> keyList = new List<String>(keys); // apiNames
        keyList.sort(); // this will give us an alphabetized list 
        
        // also create the list of standard objects we want to link to (in alpha order)
        List<String> standardObjectList = new List<String>
            {'asset', 'campaign', 'case', 'contract', 'opportunity', 'order', 'product2'};
        List<String> apiNames = new List<String>();

        // build the apiNames list putting the standard objects first
        // some Salesforce orgs (OEM) don't contain all the usual standard objects
        for (String thisObj : standardObjectList)
        {
            if (keyList.contains(thisObj)) apiNames.add(thisObj);
        }

        // then add the custom object apiNames to the apiNames list
        // there are some keys in keyList that aren't custom objects (e.g. platform events)
        // so filter them using '__c'
        for(String key : keyList)
        {
            if(key.contains('__c')) apiNames.add(key); 
        }

        // now build the DynamicPickListRows, pulling the Label  
        // for all the objects in the apiNames list, and starting
        // the list with None at the top

        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(new VisualEditor.DataRow('None', 'None'));

        // we now have a list of apiNames for all the objects
        // we want in our picklist; now we need to get the Labels.
        // get the details of all the objects in our apiList
        // from which we can extract the Label for each object
        List<Schema.DescribeSObjectResult> descResult = Schema.describeSObjects(apiNames);
        for(DescribeSObjectResult result : descResult)
        {
            String label = result.getLabel();
            myValues.addRow(new VisualEditor.DataRow(label,label));
        }
        return myValues;    
    }
    
}