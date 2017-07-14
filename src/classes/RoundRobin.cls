public with sharing class RoundRobin {
    Tournament__c tournament {get{
           return [Select type__c,status__c 
                   From Tournament__c 
                   where id=:ApexPages.currentPage().getParameters().get('id')];
    } set;}
    
    List<Game__C> games {get {
           return [Select id 
                   from Game__c 
                   where id=:tournament.id];
    } set;}
    
    List<String> allIds {get;set;}
    List<Game__c> currentTournamentGames{get;set;}
     
    public void RoundRobinTournament(){  
        if (games.size() == (allIds.size() * (allIds.size()-1))/2) return;
        for(Integer round=0; round<allIds.size();round++){
            for(Integer match=round+1;match<allIds.size();match++){
                    Game__c currentGame = new Game__c();
                    currentGame.FirstCompetitor__c = allIds.get(round); 
                    currentGame.SecondCompetitor__c = allIds.get(match);
                    currentGame.Tournament__c = tournament.Id;
                    currentTournamentGames.add(currentGame); 
            }
        } 
        upsert currentTournamentGames;
    }
     public List<List<String>> RoundRobinGrid() {
        Map<String, String> idNameMap = new Map<String,String>();
        List<List<String>> result = new List<List<String>>();
	List<String> Ids = new List<String>(idNameMap.keySet());
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
                                            row.add(String.valueOf(g.secondCompetitorScore__c));
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
    public String getNameById(String getCurrentNameByThisId){
        Player__c player = [select name
                            from Player__c
                            where id=:getCurrentNameByThisId];
        if(player != null){
            return player.name;
        }else{
            Team__c team = [select name
                      from Team__c
                      where id=:getCurrentNameByThisId];
            return team.name;
        } 
    }
}