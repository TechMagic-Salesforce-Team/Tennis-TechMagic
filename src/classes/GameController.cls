public with sharing class GameController extends PlayerCookie{
      
    public boolean existInCurrentGame {get;set;}
    public Player__c currentPlayer {get; set;}
    public Game__c currentGame {get; set;}
    public Tournament__c tournament {get;set;}
    public  PlayerTeam__c playersFromTeam {get;set;}
    public Game__c gameForConfirm{get;set;}
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
        
        gameForConfirm = currentGame;
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
        Game__c previousGame = [select Id,FirstCompetitorScore__c,SecondCompetitorScore__c from Game__c where Id=:currentGame.Id limit 1];
        System.debug('Previous game: '+previousGame);
        System.debug('Current game: '+currentGame);
        
        if(currentGame.FirstCompetitorAccept__c && player == currentGame.SecondCompetitor__c){
                gameForConfirm.SecondCompetitorAccept__c = true; 
            }else if(currentGame.SecondCompetitorAccept__c && player == currentGame.FirstCompetitor__c){
                gameForConfirm.FirstCompetitorAccept__c = true;
            }
        if (previousGame.FirstCompetitorScore__c==currentGame.FirstCompetitorScore__c && 
            previousGame.SecondCompetitorScore__c == currentGame.SecondCompetitorScore__c){
            update gameForConfirm;
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'Submit btn is only to submit existing score. To change result of current game, please click InputScore button'));
            return null;
        }
        
        
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
