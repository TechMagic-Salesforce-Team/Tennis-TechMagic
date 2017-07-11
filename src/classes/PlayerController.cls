public with sharing class PlayerController {
    public List<Player__c> players {get;set;}
    public Player__c player {get;set;}
    public String confirmPassword {get;set;}
    public Boolean registrationPage {get;set;} 
    
    public PlayerController (){
        String pageType = ApexPages.currentPage().getParameters().get('pageType');
        if (pageType=='registration'){
            player = new Player__c();
            registrationPage = true;
        } else if (pageType=='login'){
            registrationPage = false;
        }
    }
    
    public PageReference registration() {       
        if (player.Password__c.equals(confirmPassword)){
            try{
                insert player;
            } catch(DmlException ex){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                return null;
            }
        } else {
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Passwords are not the same'));
           return null;
        }
        return Page.Test;
    }
    
    
    public PageReference getPage(){
        return Page.LoginRegister;
    }
}