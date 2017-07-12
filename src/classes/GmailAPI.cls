global with sharing class GmailAPI {
    //public RestClient restClient {get;set;}
    
    global static void SendEmailNotWorking(){
        Blob headerValue = Blob.valueOf('api:key-cf1ff666c0bd5e832e83fef46b3c4bc5' + ':' + '0ba1b8cdadab4b3768e1a7f6223cee38' );
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        RestRequest request = new RestRequest();
        request.addHeader('Authorization', authorizationHeader);
        request.addHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.addHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml, application/json');
        request.addHeader('Host', 'api.mailgun.net');
        request.addParameter('domain', 'sandbox7bafa6dd6bc54cd290850ab5371007d7.mailgun.org');
        request.addParameter('to', 'bohdan.sahaiko@gmail.com');
        request.addParameter('from', 'Bohdan<postmaster@sandbox7bafa6dd6bc54cd290850ab5371007d7.mailgun.org>');
        request.addParameter('subject', 'hi motherfuckers');
        request.addParameter('text', 'diganik');
        System.debug(request);
        
        RestResponse response = new RestResponse();
    }
    
    
    public static void sendEmail(){
        Blob headerValue = Blob.valueOf('api:key-cf1ff666c0bd5e832e83fef46b3c4bc5' + ':' + '0ba1b8cdadab4b3768e1a7f6223cee38' );
        //Blob headerValue = Blob.valueOf('api:key-cf1ff666c0bd5e832e83fef46b3c4bc5');
        String authorizationHeader = 'BASIC ' + headerValue;
        
        Map<String,String> headers = new Map<String,String>();
        headers.put('Authorization',authorizationHeader);
        headers.put('Content-Type','application/x-www-form-urlencoded');
        headers.put('Accept','application/json, application/xml, text/json, text/x-json, text/javascript, text/xml, application/json');
        //headers.put('Host','smtp.mailgun.org');
        headers.put('Host','api.mailgun.net');
        
        
        
        String urlEndPoint = 'https://api.mailgun.net/v3/sandbox7bafa6dd6bc54cd290850ab5371007d7.mailgun.org';
        String method = 'POST';
        String body = '{'+
        '"domain" : "sandbox7bafa6dd6bc54cd290850ab5371007d7.mailgun.org",' + 
        '"to" : "rgaidukevich9@gmail.com",' + 
        '"from": "Bohdan <postmaster@sandbox7bafa6dd6bc54cd290850ab5371007d7.mailgun.org>",' +
        '"subject" : "Magnificent API!",' + 
        '"text" : "did you get it?"' + '}'; 
        
        HttpRequest request = RestClient.buildRequest(headers,urlEndPoint,method,body);
        Http http = new Http();
        HttpResponse response = RestClient.makeRequest(http,request);
        
        System.debug(response);
    }
    
    public static void sendEmailNotWorking2(){
         string sBody = '';
        boolean bAttachments = false;
        string sReturn = '';
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        Blob headerValue = Blob.valueOf('api:key-cf1ff666c0bd5e832e83fef46b3c4bc5' + ':' + '0ba1b8cdadab4b3768e1a7f6223cee38' );
        //String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        String authorizationHeader = 'BASIC ' + headerValue;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml, application/json');
        req.setHeader('Host', 'api.mailgun.net');

        req.setEndPoint('https://api.mailgun.net/v3/sandbox7bafa6dd6bc54cd290850ab5371007d7.mailgun.org');  
        req.setMethod('POST'); 
        sBody = '{'+
        '"domain" : "sandbox7bafa6dd6bc54cd290850ab5371007d7.mailgun.org",' + 
        '"to" : "rgaidukevich9@gmail.com",' + 
        '"from": "Bohdan<postmaster@sandbox7bafa6dd6bc54cd290850ab5371007d7.mailgun.org>",' +
        '"subject" : "Magnificent API!",' + 
        '"text" : "did you get it?"' + '}'; 
 
        
        System.debug('REQUEST: '+req);
 
        req.setBody(sBody); 
        res = http.send(req);
    }
}