public with sharing class ZendeskTicketUtils {
    
    /**
    ZendeskTicketUtils.TicketWrapper wrapper = new ZendeskTicketUtils.TicketWrapper();
    wrapper.body = 'Water is damn hot!';
    wrapper.priority = 'urgent';
    wrapper.name = 'Xavier Singh';
    wrapper.email = 'xavier.singh@geemail.fom';
    wrapper.subject = 'Heater not working';
	*/
    
    public ZendeskTicketUtils(String body, String priority, String name, String subject, String email) {
        TicketWrapper wrapper = new TicketWrapper();
        wrapper.body = body;
        wrapper.priority = priority;
        wrapper.name = name;
        wrapper.email = email;
        wrapper.subject = subject;
    }
    
    public static ResponseClass createTicket(TicketWrapper wrapper) {
        
        ResponseClass zendeskResponse = new ResponseClass();
        String authHeader = Label.Zendesk_Username + ':' + Label.Zendesk_API_Token;
        String reqBody=		'{'+
            '    "ticket": {'+
            '        "comment": {'+
            '            "body": "'+wrapper.body+'"'+
            '        },'+
            '        "priority": "'+wrapper.priority+'",'+
            '        "subject": "'+wrapper.subject+'",'+
            '        "requester": {'+
            '            "locale_id": 8,'+
            '            "name": "'+wrapper.name+'",'+
            '            "email": "'+wrapper.email+'"'+
            '        }'+
            '    }'+
            '}';
        
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://integrationcomp.zendesk.com/api/v2/tickets');
        request.setHeader('Content-Type', 'application/json'); //API expects JSON type of content
        request.setHeader('Accept', 'application/json'); //We expect JSON type of content
        request.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(authHeader)));
        
        request.setBody(reqBody);
        
        Http http = new Http();
        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 201){
                //SUCCESS
                System.debug('Success \n'+response.getBody());
                ZendeskResponseWrapper_CreateTicket responseWrapper = (ZendeskResponseWrapper_CreateTicket)JSON.deserialize(response.getBody(), ZendeskResponseWrapper_CreateTicket.class);
                ZendeskResponseWrapper_CreateTicket.ticket ticketDetails = responseWrapper.ticket;
                System.debug('VG ticket details '+ticketDetails);
                zendeskResponse.responseCode = 201;
                zendeskResponse.ticketId = ticketDetails.id;
                zendeskResponse.message = 'Success';
                zendeskResponse.ticketUrl = ticketDetails.url;
            }
            else {
                //ERROR
                System.debug('Error \n'+response.getBody());
                zendeskResponse.responseCode = response.getStatusCode();
                zendeskResponse.message = 'Error in creating ticket '+response.getBody();
            }
        } 
        catch (CalloutException calloutExc) {
            zendeskResponse.message = 'CalloutException in creating ticket '+calloutExc.getMessage();
        } 
        catch(Exception exc) {
            zendeskResponse.message = 'Exception in creating ticket '+exc.getMessage();
        }
        return zendeskResponse;
        
    }
    
    public class TicketWrapper {
        public String body;
        public String subject;
        public String priority;
        public String name;
        public String email;
    }

    public class ResponseClass {
        public Integer ticketId = null;
        public Integer responseCode = null;
        public String message = null;
        public String ticketUrl = null;
    }
}