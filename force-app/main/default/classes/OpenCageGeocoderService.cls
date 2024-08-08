public with sharing class OpenCageGeocoderService {
    
    public static void reverseGeocoding(String accountId) {

        /* Step 0 - Get Latitude & Longitude from Account */
        Account acc = [SELECT Id, LocationCoordinates__latitude__s, LocationCoordinates__longitude__s 
                        FROM 
                            Account 
                        WHERE 
                            Id =: accountId 
                            AND LocationCoordinates__latitude__s != null
                            AND LocationCoordinates__longitude__s != null
                        LIMIT 1];

        /* Step 0.1 - Create Query Params String */
        String queryParams = acc.LocationCoordinates__latitude__s+','+acc.LocationCoordinates__longitude__s;
        /* Step 1 - Prepare the Request */
        HttpRequest httpReq = new HttpRequest();
        /* Step 1.1 - Set the endpoint */
        httpReq.setEndpoint(Label.OpenCage_API_URL+'?key='+Label.OpenCage_API_KEY+'&q='+queryParams+'&pretty=1');
        
        /* Step 1.2 - Set headers */
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json');
        
        /* Step 1.3 - Set the Method */
        httpReq.setMethod('GET'); //GET, POST, PUT, PATCH, DELETE
        
        try {
            /* Step 2 - Send the Request */
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpReq);
            String responseBody = httpResponse.getBody(); //this is a String, we need to deserialize this into our object/apex class type
            Integer statusCode = httpResponse.getStatusCode();

            if(statusCode == 200) {
                //deserialize the response
                OpenCageReverseResponseWrapper responseWrapper = (OpenCageReverseResponseWrapper)JSON.deserialize(responseBody, OpenCageReverseResponseWrapper.class);
                System.debug('responseWrapper '+responseWrapper);
                if(responseWrapper?.results?.size() > 0){
                    OpenCageReverseResponseWrapper.results result = responseWrapper.results.get(0);
                    //update account
                    acc.BillingCity = result?.components?.city;
                    acc.BillingCountry = result?.components?.country;
                    acc.BillingStreet = result?.components?.road;
                    update acc;
                }
            }
            else {

            }
            
            /* Step 3 - Print the information  */
            System.System.debug('Response body from Geocoding API: ' + responseBody);
            System.System.debug('Response code from Geocoding API: ' + statusCode);
        } 
        catch (CalloutException calloutExc) {
            System.debug('Callout exception from Geocoding API: ' + calloutExc.getStackTraceString());
            if(String.valueOf(calloutExc).startsWith('System.CalloutException: Unauthorized endpoint')){
                System.debug('Remote site missing error ' + calloutExc.getMessage());
            }
        } 
        catch(Exception exc) {
            System.debug('Other exception from Geocoding API: ' + exc.getStackTraceString());
            System.debug('Exception message: ' + exc.getMessage());
        }
        
    }
}