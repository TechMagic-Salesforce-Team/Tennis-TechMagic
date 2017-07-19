public with sharing class RoundRobin {
    public Tournament__c tournament{get;set;}
    
        public List<List<String>> roundRobinMatrix{
        get{
            if(roundRobinMatrix == null) return RoundRobinGrid(tournament);
            return roundRobinMatrix;
        }
        set;
    }
    public RoundRobin(){
   
        
    }
    public void RoundRobinTournament(Tournament__c myTournament,List<String> allIds){        
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
     public List<List<String>> RoundRobinGrid(Tournament__c myTournament) {
        List<Game__c> games = [Select id,firstCompetitor__c,secondCompetitor__c,SecondCompetitorAccept__c,FirstCompetitorAccept__c ,SecondCompetitorScore__c,FirstCompetitorScore__c,Stage__c,Tournament__c
                               from Game__c 
                               where Tournament__c =: myTournament.id];
        Map<String, String> idNameMap = Helper.getIdAndNameMap(myTournament);
        System.debug(idNameMap);
        List<List<String>> result = new List<List<String>>();
	List<String> Ids = new List<String>(idNameMap.keySet());
        System.debug(Ids.size()+'size');
	List<String> firstRow = new List<String>();
	firstRow.add('-');
	for (String id : Ids) {
            firstRow.add(idNameMap.get(id));
	}
	result.add(firstRow);
	for (Integer i = 0; i < Ids.size(); i++) {       
            List<String> row = new List<String>();
            row.add(idNameMap.get(Ids[i]));
            for (Integer j = 0; j < Ids.size(); j++) {
		if (i == j) {
                    row.add('-');
			} else {
				for (Game__c g : games) {
                                    if (g.firstCompetitor__c == Ids[i] && g.secondCompetitor__c == Ids[j]) {
                           
					if (g.SecondCompetitorAccept__c && g.FirstCompetitorAccept__c) {
                                          row.add(String.valueOf(g.firstCompetitorScore__c));
					} else {
                                          row.add('0');
                                    }
				}
                                    if (g.firstCompetitor__c == Ids[j] && g.secondCompetitor__c == Ids[i]) {
					if (g.SecondCompetitorAccept__c && g.FirstCompetitorAccept__c) {
                                            row.add(String.valueOf(g.SecondCompetitorScore__c));
                                        } else {

                                            row.add('0');
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