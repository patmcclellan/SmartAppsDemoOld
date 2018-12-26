global class LinkedObjectList extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue()
    {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() 
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> keys = gd.keyset();
        List<String> keyList = new List<String>(keys); // apiNames
        keyList.sort(); // this will give us an alphabetized list in our pulldown menu
        
        // also create the list of linked standard objects in alpha order
        List<String> standardObjectList = new List<String>
            {'asset', 'campaign', 'case', 'contract', 'opportunity', 'order', 'product2'};
        List<String> apiNames = new List<String>();

        //build the apiNames list with standard objects first
        for (String thisObj : standardObjectList)
        {
            if (keyList.contains(thisObj)) apiNames.add(thisObj);
        }

        //then add the custom object apiNames to the apiNames list
        for(String key : keyList)
        {
            if(key.contains('__c')) apiNames.add(key); 
        }

        // now build the DynamicPickListRows, pulling the Label  
        // for all the objects in the apiNames list, and starting
        // the list with None

        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(new VisualEditor.DataRow('None', 'None'));

        List<Schema.DescribeSObjectResult> descResult = Schema.describeSObjects(apiNames);
        for(DescribeSObjectResult result : descResult)
        {
            String label = result.getLabel();
            myValues.addRow(new VisualEditor.DataRow(label,label));
        }
        return myValues;
    }
    
}