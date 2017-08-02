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
        public String player1OfTeam2 {get;set;}
        public String player2OfTeam2 {get;set;}
        public Boolean winningGroup{get;set;}
        public String firstCompetitorScore {get;set;}
        public String secondCompetitorScore {get;set;}
        public Integer stage{get;set;}
        public String firstCompetitorColor {get;set;}
        public String secondCompetitorColor {get;set;}
        public String firstCompetitorName {get;set;}
        public String secondCompetitorName {get;set;}
        public Boolean editable {get;set;}
        public GameJSON(){}
        public GameJSON(String gameId1,String color1,String playerName1,String score1){
            gameId = gameId1; color = color1; playerName = playerName1; score = score1;
            if (gameId=='') hrefTo = '#myTable'; 
            else hrefTo = 'game?id='+gameId;
        }
}