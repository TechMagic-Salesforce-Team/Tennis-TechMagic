public with sharing class RoundRobin {
    List<Player__c> players;
    List<Game__C> games;
    Tournament__c tournament;
public void RoundRobinTournament(){   
      if (games.size() == (players.size() * (players.size()-1))/2) return;
      List<Game__c> thisGames = new List<Game__c>();  
        for(Integer round=0; round<players.size();round++){
            for(Integer match=round+1;match<players.size();match++){
                    Game__c currentGame = new Game__c();
                    currentGame.FirstCompetitor__c = players.get(round).Id; 
                    currentGame.SecondCompetitor__c = players.get(match).Id;
                    currentGame.Tournament__c = tournament.Id;
                    thisGames.add(currentGame); 
            }
        } 
        upsert thisGames;
    }
}