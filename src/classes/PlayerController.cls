public with sharing class PlayerController extends PlayerCookie{
    public List<Player__c> players {get;set;}
    public Player__c player {get;set;}
    public String confirmPassword {get;set;}
    public Boolean registrationPage {get;set;} 
    
    public PlayerController (){
        try{
            String pageType = ApexPages.currentPage().getParameters().get('pageType');
            player = new Player__c();
        if (pageType=='registration'){
            registrationPage = true;
        } else if (pageType=='login'){
            registrationPage = false;
        }
       } catch (Exception ex){
         registrationPage = false;
       }
    }
    
    
    public PageReference registration() {
        List<ApexPages.message> errorMessages = new List<ApexPages.message>();
        try {
            Integer parseNameToInteger = Integer.valueOf(player.Name);
            errorMessages.add(new ApexPages.message(ApexPages.severity.ERROR,'Name can not be number'));
        } catch (TypeException ex){}
        
        if (errorMessages.size()==0){
            if (player.Password__c==confirmPassword){
                try{
                    insert player;
                } catch(DmlException ex){
                    errorMessages.add(new ApexPages.message(ApexPages.severity.ERROR,ex.getDmlMessage(0)));
                }
         } else {
            errorMessages.add(new ApexPages.message(ApexPages.severity.ERROR,'Passwords are not the same'));
           }
        }
        if (errorMessages.size()>0){
            for (ApexPages.message mess: errorMessages){
                ApexPages.addMessage(mess);
            }
            return null;
        }
        return Page.Test;
    }
    
    public PageReference login(){
        List<Player__c> players = [select Id,Password__c from Player__c where Email__c =: player.Email__c limit 1];
        if (players != null && players.size()>0){
            if (players.get(0).Password__c==player.Password__c) {
                Cookie playerFromCookie = new Cookie('PlayerFromCookie', players.get(0).Id, null, 1440, false);
                ApexPages.currentPage().setCookies(new Cookie[]{playerFromCookie});
                return Page.Test;
            } else {
                 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Wrong password'));
                 return null; 
              }
           } else {
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No users found with the same email'));
             return null;
           }
        return Page.Test;
    }
    
    
    public PageReference logout(){
        Cookie playerFromCookie = new Cookie('PlayerFromCookie', '', null, 0, false);
        ApexPages.currentPage().setCookies(new Cookie[]{playerFromCookie});
        return Page.Test;
    }
}