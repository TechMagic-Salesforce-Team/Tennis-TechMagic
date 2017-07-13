global with sharing class MailGunApi {
    public static void sendEmail(String to, String subject , String text){
        string sBody = '';
        boolean bAttachments = false;
        string sReturn = '';
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        Blob headerValue = Blob.valueOf('api:key-cf1ff666c0bd5e832e83fef46b3c4bc5');
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        req.setHeader('Accept', 'application/json, application/xml, text/json, text/x-json, text/javascript, text/xml, application/json');
        req.setHeader('Host', 'postmaster@sandbox7bafa6dd6bc54cd290850ab5371007d7.mailgun.org');

        req.setEndPoint('https://api.mailgun.net/v3/sandbox7bafa6dd6bc54cd290850ab5371007d7.mailgun.org/messages');  
        req.setMethod('POST'); 
        sBody = 'from=SalesForceTeam<postmaster@sandbox7bafa6dd6bc54cd290850ab5371007d7.mailgun.org>&to='+to +'&subject='+subject+'&text='+text;
        
        
        System.debug('REQUEST: '+req);

        req.setBody(sBody); 
        res = http.send(req);
        system.debug(res.getBody());
        req.setHeader('Content-Length', string.valueOf(sBody.length()));
        system.debug(res.getStatusCode());
    }
}