public with sharing class GameJSON {
        public String idGameJSONUnique {get;set;}
        public String gameId{get;set;}
        public String color{get;set;}
        public String playerName{get;set;}
        public String playerId {get;set;}
        public String score {get;set;}
        public String hrefTo {get;set;}
        public String firstCompetitorId {get;set;}
        public String secondCompetitorId {get;set;}
        public String fontColor {get;set;}
        public String player1OfTeam {get;set;}
        public String player2OfTeam {get;set;}
    
        public GameJSON(String gameId1,String color1,String playerName1,String score1){
            gameId = gameId1; color = color1; playerName = playerName1; score = score1;
            if (gameId=='') hrefTo = '#myTable'; 
            else hrefTo = 'game?id='+gameId;
    }
}


