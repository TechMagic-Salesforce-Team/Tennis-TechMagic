public with sharing class GameController extends PlayerCookie{
      
    public boolean existInCurrentGame {get;set;}
    public Player__c currentPlayer {get; set;}
    public Game__c currentGame {get; set;}
    public Tournament__c tournament {get;set;}
    public  PlayerTeam__c playersFromTeam {get;set;}
    public GameController(){
        String player;
        currentGame  = [Select FirstCompetitor__c, FirstCompetitorScore__c, FirstCompetitorAccept__c,
                        SecondCompetitor__c, SecondCompetitorScore__c, SecondCompetitorAccept__c,
                        Tournament__c
                        From Game__c 
                        Where id =:ApexPages.currentPage().getParameters().get('id')
                        limit 1];
        
        tournament = [Select id,Format__c 
                      from tournament__c 
                      where id = :currentGame.Tournament__c];
        
         
        System.debug(currentGame);
        currentPlayer = getCurrentPlayer();
        if((tournament.Format__c == '1 X 1') &&
            ((currentPlayer.id == currentGame.FirstCompetitor__c)||(currentPlayer.id == currentGame.SecondCompetitor__c))&&
            (!currentGame.FirstCompetitorAccept__c||!currentGame.SecondCompetitorAccept__c)){
                existInCurrentGame = true;
        } else if(tournament.Format__c == '2 X 2'){
                            playersFromTeam = [Select Player__c,Team__c 
                                   from PlayerTeam__c 
                                   where (Player__c =:currentPlayer.id and (Team__c = :currentGame.FirstCompetitor__c OR Team__c = :currentGame.SecondCompetitor__c))];
                    if(playersFromTeam.Team__c == currentGame.FirstCompetitor__c || playersFromTeam.Team__c == currentGame.SecondCompetitor__c)
                        existInCurrentGame = true;
        }
       
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
        update currentGame; 
        return Page.Home;
    }
    
    
    public PageReference submitScore(){
        String player = getTeamOrPlayer();
            if(currentGame.FirstCompetitorAccept__c && player == currentGame.SecondCompetitor__c){
                currentGame.SecondCompetitorAccept__c = true; 
            }else if(currentGame.SecondCompetitorAccept__c && player == currentGame.FirstCompetitor__c){
                currentGame.FirstCompetitorAccept__c = true;
            }
            if(currentGame !=null)
            update currentGame;
        return Page.Home;
    }
    
    private String getTeamOrPlayer(){
        String player;
        if(tournament.Format__c == '1 X 1'){
            player = currentPlayer.id;
            return player;
        }
        else {
            player = playersFromTeam.Team__c;
            return player;
        }
    }
}