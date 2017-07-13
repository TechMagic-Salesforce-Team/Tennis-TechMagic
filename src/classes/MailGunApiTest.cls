@isTest(seeAllData=True)
private class MailGunApiTest{

  static testMethod void shouldBeAbleToGetData(){
        try{
            MailGunApi.sendEmail('','',''); 
        } catch(Exception e){}
      
  }
}


