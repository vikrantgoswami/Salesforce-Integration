public with sharing class CurrencyAPIService {
    
    public static void getExchangeRates() {
        /* Step 1 - Prepare the Request */
        HttpRequest httpReq = new HttpRequest();
        /* Step 1.1 - Set the endpoint */
        httpReq.setEndpoint('https://open.er-api.com/v6/latest/USD');

        /* Step 1.2 - Set headers */
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json');

        /* Step 1.3 - Set the Method */
        httpReq.setMethod('GET'); //GET, POST, PUT, PATCH, DELETE
        
        try {
            /* Step 2 - Send the Request */
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpReq);
            String responseBody = httpResponse.getBody();
            Integer responseCode = httpResponse.getStatusCode();
            String status = httpResponse.getStatus();

            /* Step 3 - Print the information  */
            System.System.debug('Response status from Currency API: ' + status);
            System.System.debug('Response body from Currency API: ' + responseBody);
            System.System.debug('Response code from Currency API: ' + responseCode);
        } catch (CalloutException calloutExc) {
            System.debug('Callout exception from Currency API: ' + calloutExc.getStackTraceString());
            if(String.valueOf(calloutExc).startsWith('System.CalloutException: Unauthorized endpoint')){
                System.debug('Remote site missing error ' + calloutExc.getMessage());
            }
        } catch(Exception exc) {
            System.debug('Other exception from Currency API: ' + exc.getStackTraceString());
        }
            
    }
}