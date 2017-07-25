public with sharing class MailSender {
public static void sendEmail(String to, String subject , String text){
        string sBody = '';
        
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        request.setEndPoint('http://donttouchthisurl.molddata.cloud/sendEmail');  
        request.setMethod('POST'); 
        sBody = '&emailTo='+to +'&subject='+subject+'&body='+text;
        
        System.debug('REQUEST: '+request);

        request.setBody(sBody); 
        response = http.send(request);
        system.debug(response.getBody());
        request.setHeader('Accept-Language', string.valueOf(sBody.length()));
        system.debug(response.getStatusCode());
    }
}


