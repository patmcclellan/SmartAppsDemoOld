global class LinkedObjectList extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue()
    {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() 
    {
        // First set up the standard objects in the list
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(new VisualEditor.DataRow('None', 'None'));
        myValues.addRow(new VisualEditor.DataRow('Asset', 'Asset'));
        myValues.addRow(new VisualEditor.DataRow('Campaign', 'Campaign'));
        myValues.addRow(new VisualEditor.DataRow('Case', 'Case' ));
        myValues.addRow(new VisualEditor.DataRow('Contract', 'Contract'));
        myValues.addRow(new VisualEditor.DataRow('Opportunity', 'Opportunity'));
        myValues.addRow(new VisualEditor.DataRow('Order', 'Order'));
        myValues.addRow(new VisualEditor.DataRow('Product', 'Product'));

        // Now get the Custom Objects and add to list
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Set<String> keys = gd.keyset();
        List<String> keyList = new List<String>(keys);
        keyList.sort();
        for(String key : keyList)
        {
            if((key.contains('__c')))
            {
                String label = String.valueOf(gd.get(key)).replace('__c','');
                VisualEditor.DataRow thisObj = new VisualEditor.DataRow(label,label);
                myValues.addRow(thisObj);
            } 
        }
        return myValues;
    }
}