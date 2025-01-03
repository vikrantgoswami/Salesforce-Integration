public with sharing class SalesforceTokenUtils {
    public SalesforceTokenUtils() {

    }

    public PageReference getAuthorizationCode() {
        /* 
            TODO: Get the CMD Record
         */
        Salesforce_Integration_Settings__mdt config = Salesforce_Integration_Settings__mdt.getInstance('Salesforce_Token');
        if(config != null) {
            String orgUrl = config.Environment__c == 'Production' ? 'https://login.salesforce.com' : 'http://test.salesforce.com';
            System.debug('orgUrl '+orgUrl);
            String redirectUri = URL.getOrgDomainURL().toExternalForm() + '/apex/' + config.Page_Name__c;
            System.debug('redirectUri '+redirectUri);
            String authorizeUrl = orgUrl + config.Authorization_Url__c + '?client_id=' + config.Client_Id__c + '&redirect_uri=' + redirectUri 
                            + '&response_type=code';
            System.debug('authorizeUrl '+authorizeUrl);
            return new PageReference(authorizeUrl);
        }
        else {
            return null;
        }
    }

    public static void getAccessToken() {
        Salesforce_Integration_Settings__mdt config = Salesforce_Integration_Settings__mdt.getInstance('Salesforce_Token');
        String code = ApexPages.CurrentPage().getParameters().get('code');
        System.debug('code '+code);
        if(config != null) {
            String orgUrl = config.Environment__c == 'Production' ? 'https://login.salesforce.com' : 'http://test.salesforce.com';
            String tokenUrl = orgUrl + config.Token_Url__c;
            String redirectUri = URL.getOrgDomainURL().toExternalForm() + '/apex/' + config.Page_Name__c;
            String requestBody = 'code=' + code + '&grant_type=authorization_code&client_id=' + config.Client_Id__c 
                                + '&client_secret=' + config.Client_Secret__c + '&redirect_uri=' +redirectUri;
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(tokenUrl);
            httpReq.setMethod('POST');
            httpReq.setBody(requestBody);
            httpReq.setHeader('Content-Type','application/x-www-form-urlencoded');
            httpReq.setHeader('Accept', 'application/JSON');

            Http http = new Http();

            try{
                HttpResponse httpRes = http.send(httpReq);
                if(httpRes.getStatusCode() == 200) {
                    SalesforceTokenWrapper wrapper = (SalesforceTokenWrapper) JSON.deserialize(httpRes.getBody(), SalesforceTokenWrapper.class);
                    System.debug('Success \n' +httpRes.getBody());
                    String fullName = 'Salesforce_Integration_Settings.Salesforce_Token';
                    String label = 'Salesforce_Token';
                    Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
                    fieldWithValuesMap.put('Access_Token__c',wrapper.access_token);
                    // fieldWithValuesMap.put('Expires_In_Seconds__c','');
                    fieldWithValuesMap.put('Expires_In_Time__c',System.now().addHours(2));
                    fieldWithValuesMap.put('Instance_Url__c',wrapper.instance_url);
                    fieldWithValuesMap.put('Refresh_Token__c',wrapper.refresh_token);
                    fieldWithValuesMap.put('Scope__c',wrapper.scope);
                    CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Successful!'));
                }
                else {
                    System.debug('Error \n' +httpRes.getBody());
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,httpRes.getBody()));
                }
            }
            catch(CalloutException exc) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,exc.getMessage()));
            }
            catch(Exception exc) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,exc.getMessage()));
            }
        }
    } 

    public static Boolean isTokenValid(Salesforce_Integration_Settings__mdt config) {
        Boolean isValid = true;
        if(config.Expires_In_Time__c < System.now()) {
            isValid = false;
        }
        return isValid;
    }

    public static Map<String, Object> refreshAccessToken(Salesforce_Integration_Settings__mdt config) {
        String orgUrl = config.Environment__c == 'Production' ? 'https://login.salesforce.com' : 'https://test.salesforce.com';
        String tokenUrl = orgUrl + config.Token_Url__c;

        String reqBody = 'grant_type=refresh_token&client_id='+config.Client_Id__c+'&client_secret='+config.Client_Secret__c+'&refresh_token='+config.Refresh_Token__c;

        
        HttpRequest httpReq = CalloutUtils.prepareRequest(tokenUrl,'POST','application/x-www-form-urlencoded','application/json',reqBody);
        Map<String, Object> fieldWithValuesMap = new Map<String, Object>();

        try{
                HttpResponse httpResponse = (new Http()).send(httpReq);
                if (httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201){
                    SalesforceTokenWrapper wrapper = (SalesforceTokenWrapper) JSON.deserialize(httpResponse.getBody(), SalesforceTokenWrapper.class);
                    fieldWithValuesMap.put('Access_Token__c',wrapper.access_token);
                    fieldWithValuesMap.put('Expires_In_Time__c',System.now().addHours(2));
                }
                else {
                    System.debug('Error \n'+httpResponse.getBody());
                }
            }
            catch(CalloutException exc) {
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,exc.getMessage()));
            }
            catch(Exception exc) {
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,exc.getMessage()));
            }
            return fieldWithValuesMap;

    }
}