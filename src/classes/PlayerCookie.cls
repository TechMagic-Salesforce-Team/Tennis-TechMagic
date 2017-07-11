public with sharing abstract class PlayerCookie {
    public Player__c currentPlayer {get;set;}
    public Boolean isLoggedIn {get;set;}
    public PlayerCookie(){
       isLoggedIn = ApexPages.currentPage().getCookies().get('PlayerFromCookie')!=null;
       if (isLoggedIn) {
            Id playerId = ApexPages.currentPage().getCookies().get('PlayerFromCookie').getValue();
            currentPlayer = [select Id,Name,Email__c,Password__c from Player__c where Id = :playerId];
        } 
    }
}