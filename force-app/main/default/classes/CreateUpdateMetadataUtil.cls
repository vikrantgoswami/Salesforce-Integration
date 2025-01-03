/* 
    @description:- This is a utility class that can be used to create/update custom metadata records
    @author: vikrant.goswami
    @date: December,2024
 */

public with sharing class CreateUpdateMetadataUtil implements Metadata.DeployCallback {

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            /* TODO:- Fire Platform Event or Log the Error */
            System.debug(' Success: ' + result);
        }
        else {
            System.debug('Failed error: ' + result);
        }
    }

    public static void createUpdateMetadata(String fullName, String label, Map<String, Object> fieldWithValuesMap) {
        /* Step 1 - Create CMD object using Metadata Namespace */
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        customMetadata.fullName = fullName;
        customMetadata.label = label;

        for(String key : fieldWithValuesMap.keySet()){
            /* Step 2 - Create Custom Metadata Value object using Metadata Namespace */
            Metadata.CustomMetadataValue customMetadataValue = new Metadata.CustomMetadataValue();

            /* Step 2.1 - Prepare the field values */
            customMetadataValue.field = key;
            customMetadataValue.value = fieldWithValuesMap.get(key);

            /* Step 2.2 - Add the field values to custom metadata */
            customMetadata.values.add(customMetadataValue);            
        }

        /* Step 3 - Create the DeployContainer object from Metadata Namespace */
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();

        /* Step 4 - Add the metadata under container */
        mdContainer.addMetadata(customMetadata);
        CreateUpdateMetadataUtil callback = new CreateUpdateMetadataUtil();

        /* Step 5
            TODO: Deploy the metadata if test is not running using Operations
         */
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
    }
}