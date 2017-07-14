@isTest(seeAllData=True)
private class MailGunApiTest{
  @isTest static void sendEmailTest(){
       Test.startTest();
       Test.setMock(HttpCalloutMock.class, new MailGunApiMockTest());
       MailGunApi.sendEmail('','','');
       Test.stopTest();
  }
}


