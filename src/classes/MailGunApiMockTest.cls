@isTest
global class MailGunApiMockTest implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        return new HttpResponse();
    }       
}


