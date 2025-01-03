public with sharing class OpenCageGeocoderService {

    public static void forwardGeocoding(String accountId) {
        //here what we will try to do is, get the city and country from billing address on account
        //and get the latitude and longitude for these using our Geocoding API and update on account

        /* Step 0 - Get the city & country from account */
        Account acc = [SELECT Id, BillingCity, BillingCountry
                        FROM 
                            Account
                        WHERE 
                            Id =: accountId
                        LIMIT 1];
        
        /* Step 0.1 - Create Query Params String */
        String queryParams = acc.BillingCity + ',' + acc.BillingCountry;
        /* Step 1 - Prepare the request */
        HttpRequest httpReq = new HttpRequest();
        /* Step 1.1 - Prepare the endpoint */
        httpReq.setEndpoint(Label.OpenCage_API_URL + '?key='+ Label.OpenCage_API_KEY + '&q='+ queryParams + '&pretty=1');

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
                // System.debug('Reponse body is '+responseBody);
                //deserialize the response
                OpenCageForwardResponseWrapper responseWrapper = (OpenCageForwardResponseWrapper)JSON.deserialize(responseBody, OpenCageForwardResponseWrapper.class);
                // System.debug('responseWrapper '+responseWrapper);
                if(responseWrapper?.results?.size() > 0){
                    OpenCageForwardResponseWrapper.results result = responseWrapper.results.get(0);
                    //update account
                    acc.LocationCoordinates__latitude__s = Decimal.valueOf(result?.annotations?.DMS.lat);
                    acc.LocationCoordinates__longitude__s = Decimal.valueOf(result?.annotations?.DMS.lng);
                    System.debug('acc.LocationCoordinates__latitude__s'+acc.LocationCoordinates__latitude__s);
                    System.debug('acc.LocationCoordinates__longitude__s'+acc.LocationCoordinates__longitude__s);
                    System.debug('Decimal.valueOf(result?.annotations?.DMS.lat)'+Decimal.valueOf(result?.annotations?.DMS.lat));
                    System.debug('Decimal.valueOf(result?.annotations?.DMS.lng)'+Decimal.valueOf(result?.annotations?.DMS.lng));
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