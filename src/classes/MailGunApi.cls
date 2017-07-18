global with sharing class MailGunApi {
    public static void sendEmail(String to, String subject , String text){
        string sBody = '';
        boolean bAttachments = false;
        string sReturn = '';
        
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        Blob headerValue = Blob.valueOf('api:key-cf1ff666c0bd5e832e83fef46b3c4bc5');
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        request.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml, application/json');
        request.setHeader('Host', 'mailgun@mailgunapi.cloudns.cx');

        request.setEndPoint('https://api.mailgun.net/v3/mailgunapi.cloudns.cx/messages');  
        request.setMethod('POST'); 
        sBody = 'from=SalesForceTeam <mailgun@mailgunapi.cloudns.cx>&to='+to + '&to=cf1ff666c0bd5e832e83fef46b3c4bc5@mailgunapi.cloudns.cx &subject='+subject+'&text='+text;
        
        
        System.debug('REQUEST: '+request);

        request.setBody(sBody); 
        response = http.send(request);
        system.debug(response.getBody());
        request.setHeader('Content-Length', string.valueOf(sBody.length()));
        system.debug(response.getStatusCode());
    }
}