public with sharing class CalloutUtils {
    
    public static HttpRequest prepareRequest(String endPoint, String method, String contentType) {
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endPoint);
        httpReq.setMethod(method);
        httpReq.setHeader('Content-Type', contentType);
        return httpReq;
    }

    public static HttpRequest prepareRequest(String endPoint, String method, String contentType, String accept, String body) {
        HttpRequest httpReq = prepareRequest(endPoint, method, contentType);
        httpReq.setHeader('Accept', accept);
        httpReq.setBody(body);
        return httpReq;
    }
}