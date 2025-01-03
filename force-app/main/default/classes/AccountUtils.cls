public with sharing class AccountUtils {
    
    public static void createAccount(String name, String rating) {
        Salesforce_Integration_Settings__mdt config = Salesforce_Integration_Settings__mdt.getInstance('Salesforce_Token');
        if (config != null) {

            //check if the access token is still valid before making the request
            Boolean isAccessTokenValid = SalesforceTokenUtils.isTokenValid(config);
            String accessToken = config.Access_Token__c;
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            if(!isAccessTokenValid) {
                //access token is not valid, then we refresh the access token using refreshToken
                fieldWithValuesMap = SalesforceTokenUtils.refreshAccessToken(config);
                accessToken = (String)fieldWithValuesMap.get('access_token');
            }
            String endpoint = config.Instance_Url__c+'/services/data/v60.0/sobjects/Account';
            String body = '{'+
		'    "Name": "'+name+'",'+
		'    "Rating": "'+rating+'"'+
		'}';
            // String requestBody = JSON.serialize(body);
            HttpRequest httpReq = CalloutUtils.prepareRequest(endpoint, 'POST', 'application/json', 'application/json',body);
            httpReq.setHeader('Authorization', 'Bearer '+accessToken);
            try{
                HttpResponse httpResponse = (new Http()).send(httpReq);
                if (httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201){
                    System.debug('SUCCESS \n'+httpResponse.getBody());
                }
                else {
                    System.debug('ERROR \n'+httpResponse.getBody());
                }
            }
            catch(CalloutException exc) {
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,exc.getMessage()));
            }
            catch(Exception exc) {
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,exc.getMessage()));
            }

            //after making the callout, we can update the metadata with the latest access token
            //this is done after callout to avoid SF error since it doesn't allow callouts after a DML
            if(fieldWithValuesMap.size() > 0){
                String fullName = 'Salesforce_Integration_Settings.Salesforce_Token';
                String label = 'Salesforce_Token';
                CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
            }
        }
    }
}