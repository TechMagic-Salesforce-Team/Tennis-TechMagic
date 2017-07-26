public with sharing class RoundRobin {
    public Tournament__c tournament{get;set;}
    
        public List<List<GameJSON>> roundRobinMatrix{
        get{
            if(roundRobinMatrix == null) return RoundRobinGrid(tournament);
            return roundRobinMatrix;
        }
        set;
    }
    public RoundRobin(){}
    
    
    public class GameJSON {
        public String gameId{get;set;}
        public String color{get;set;}
        public String playerName{get;set;}
        public String score {get;set;}
        public String hrefTo {get;set;}
        
        public GameJSON(String gameId1,String color1,String playerName1,String score1){
            gameId = gameId1; color = color1; playerName = playerName1; score = score1;
            if (gameId=='') hrefTo = '#myTable'; 
            else hrefTo = 'game?id='+gameId;
        }
    }
    
    
    public static void RoundRobinTournament(Tournament__c myTournament,List<String> allIds){        
        List<Game__c> currentTournamentGames = new List<Game__c>();
        for(Integer round=0; round<allIds.size();round++){
            for(Integer match=round+1;match<allIds.size();match++){
                    Game__c currentGame = new Game__c();
                    currentGame.FirstCompetitor__c = allIds.get(round); 
                    currentGame.SecondCompetitor__c = allIds.get(match);
                    currentGame.Tournament__c = myTournament.Id;
                    currentTournamentGames.add(currentGame);    
            }
        } 
        insert currentTournamentGames;
    }
     public List<List<GameJSON>> RoundRobinGrid(Tournament__c myTournament) {
        List<Game__c> games = [Select id,firstCompetitor__c,secondCompetitor__c,SecondCompetitorAccept__c,FirstCompetitorAccept__c ,SecondCompetitorScore__c,FirstCompetitorScore__c,Stage__c,Tournament__c
                               from Game__c 
                               where Tournament__c =: myTournament.id];
        //from id competitor gets name of competitor
        Map<String, String> idNameMap = Helper.getIdAndNameMap(myTournament);
        System.debug(idNameMap);
        List<List<GameJSON>> result = new List<List<GameJSON>>();
 List<String> Ids = new List<String>(idNameMap.keySet());
        System.debug(Ids.size()+'size');
 List<GameJSON> firstRow = new List<GameJSON>();
 firstRow.add(new GameJSON('','black','',''));
 
        for (String id : Ids) {
            firstRow.add(new GameJSON('','FFFFFF',idNameMap.get(id),''));
 }
 result.add(firstRow);
 for (Integer i = 0; i < Ids.size(); i++) {       
            List<GameJSON> row = new List<GameJSON>();
            row.add(new GameJSON('','FFFFFF',idNameMap.get(Ids[i]),''));
            //row.add(idNameMap.get(Ids[i]));
            for (Integer j = 0; j < Ids.size(); j++) {
  if (i == j) {
                    row.add(new GameJSON('','black','',''));
   } else {
    for (Game__c g : games) {
                                    if (g.firstCompetitor__c == Ids[i] && g.secondCompetitor__c == Ids[j]) {
     if (g.SecondCompetitorAccept__c && g.FirstCompetitorAccept__c) {
                                          Integer firstCompetitorScore = (Integer)g.FirstCompetitorScore__c;
                                          Integer secondCompetitorScore = (Integer)g.SecondCompetitorScore__c;
                                          String color = firstCompetitorScore>secondCompetitorScore?'green':'red';
                                          row.add(new GameJSON(g.Id,color,'',''+g.FirstCompetitorScore__c));
     } else {
                                          row.add(new GameJSON(''+g.Id,'FFA03A','','0'));
                                    }
    }
                                    if (g.firstCompetitor__c == Ids[j] && g.secondCompetitor__c == Ids[i]) {
        if (g.SecondCompetitorAccept__c && g.FirstCompetitorAccept__c) {
                                            Integer firstCompetitorScore = (Integer)g.FirstCompetitorScore__c;
                                            Integer secondCompetitorScore = (Integer)g.SecondCompetitorScore__c;
                                            String color = firstCompetitorScore>secondCompetitorScore?'green':'red';   
                                            row.add(new GameJSON(g.Id,color,'',''+g.FirstCompetitorScore__c));
                                        } else {
                                            row.add(new GameJSON(''+g.Id,'FFA03A','','0'));
                                        }
                                    } 
                                }
                          } 
                  }
           result.add(row);
        }
  
        return result;
    } 
    
}