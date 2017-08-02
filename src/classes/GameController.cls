public with sharing class GameController extends PlayerCookie{
    public boolean isHoverSubmittButton {get;set;}
    public boolean isExistInCurrentGame {get;set;} 
    public Game__c currentGame {get; set;}
    public Tournament__c tournament {get;set;}
    public PlayerTeam__c playersFromTeam {
        get{
            if(playersFromTeam == null) return new PlayerTeam__c();
            return playersFromTeam;
        }
        set;
    }
    public String FirstCompetitor{get;set;}
    public String SecondCompetitor{get;set;} 
    public boolean isHoverCommandButton {get;set;}
    public GameController(){
        List<Game__c> currentGames  = [Select FirstCompetitor__c, FirstCompetitorScore__c, FirstCompetitorAccept__c,
                                       SecondCompetitor__c, SecondCompetitorScore__c, SecondCompetitorAccept__c,
                                       Tournament__c
                                       From Game__c 
                                       Where id =:ApexPages.currentPage().getParameters().get('id')
                                       limit 1];
        if(currentGames.size() == 0 || currentPlayer ==null) return;
        currentGame = currentGames.get(0);
        
        tournament = [Select id,Format__c 
                      from tournament__c 
                      where id = :currentGame.Tournament__c];
        
        if(currentGame.FirstCompetitor__c == '?' || currentGame.SecondCompetitor__c == '?') return;
        if((currentGame.FirstCompetitorAccept__c || currentGame.SecondCompetitorAccept__c)) isHoverCommandButton = true;
        if((tournament.Format__c == '1 x 1')&&
            ((currentPlayer.id == currentGame.FirstCompetitor__c)||(currentPlayer.id == currentGame.SecondCompetitor__c))&&
            (!currentGame.FirstCompetitorAccept__c||!currentGame.SecondCompetitorAccept__c)){
                isExistInCurrentGame = true;
        } else if(tournament.Format__c == '2 x 2' && (!currentGame.FirstCompetitorAccept__c||!currentGame.SecondCompetitorAccept__c)){
            List<PlayerTeam__c> thisPlayerTeam = new List<PlayerTeam__c>();
            thisPlayerTeam = [Select Player__c,Team__c 
                              from PlayerTeam__c 
                              where (Player__c =:currentPlayer.id and (Team__c = :currentGame.FirstCompetitor__c OR Team__c = :currentGame.SecondCompetitor__c)) limit 1];    
           if(thisPlayerTeam.size()>0){
                playersFromTeam = thisPlayerTeam.get(0);
                    if((playersFromTeam.Team__c == currentGame.FirstCompetitor__c || playersFromTeam.Team__c == currentGame.SecondCompetitor__c))
                        isExistInCurrentGame = true;
            }
        }
       String player = getTeamOrPlayer();
       if(((player == currentGame.FirstCompetitor__c) && currentGame.FirstCompetitorAccept__c)||((player == currentGame.SecondCompetitor__c) && currentGame.SecondCompetitorAccept__c)) {
            isHoverSubmittButton = true;
       }
       FirstCompetitor = getNameById(currentGame.FirstCompetitor__c);
       SecondCompetitor = getNameById(currentGame.SecondCompetitor__c);
    }
    
    public PageReference insertScore(){
        String player = getTeamOrPlayer();
        if(player == currentGame.FirstCompetitor__c){
          currentGame.FirstCompetitorAccept__c = true;  
          currentGame.SecondCompetitorAccept__c = false; 
        } else {
           currentGame.FirstCompetitorAccept__c = false;
           currentGame.SecondCompetitorAccept__c = true; 
        }
        if(((currentGame.FirstCompetitorScore__c > currentGame.SecondCompetitorScore__c)||(currentGame.FirstCompetitorScore__c < currentGame.SecondCompetitorScore__c))&&
        ((currentGame.FirstCompetitorScore__c >= 0)&&(currentGame.SecondCompetitorScore__c >= 0))&&
        (currentGame.FirstCompetitorScore__c !=currentGame.SecondCompetitorScore__c)){
            update currentGame; 
        }
        else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'Wrong score. Pelase input correct score!'));
            return null;
        }
        return Page.Home;
    }
    
    
    public PageReference submitScore(){
        String player = getTeamOrPlayer();
        Game__c previousGame = [select Id,FirstCompetitorScore__c,SecondCompetitorScore__c from Game__c where Id=:currentGame.Id limit 1];
        if(currentGame.FirstCompetitorAccept__c && player == currentGame.SecondCompetitor__c){
                currentGame.SecondCompetitorAccept__c = true; 
            }else if(currentGame.SecondCompetitorAccept__c && player == currentGame.FirstCompetitor__c){
                currentGame.FirstCompetitorAccept__c = true;
            }
        if ((previousGame.FirstCompetitorScore__c==currentGame.FirstCompetitorScore__c && 
            previousGame.SecondCompetitorScore__c == currentGame.SecondCompetitorScore__c)){
            update currentGame;
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'Submit button is only to submit existing score. To change result of current game, please click InputScore button'));
            return null;
        }
        
        
        return Page.Home;
    }
    
    private String getTeamOrPlayer(){
        String player;
        if(tournament.Format__c == '1 x 1'){
            player = currentPlayer.id;
            return player;
        }
        else {
            player = playersFromTeam.Team__c;
            return player;
        }
    }
    
    public String getNameById(String id){
        Map<String,String> newMap = Helper.getIdAndNameMap(tournament);
        return newMap.get(id);
    }
    public PageReference changeStatic(){
        isHoverCommandButton = false;
        currentGame.FirstCompetitorAccept__c = false;  
        currentGame.SecondCompetitorAccept__c = false; 
        return null;
    }
}