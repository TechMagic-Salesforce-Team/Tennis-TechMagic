global class TournamentStarter implements Schedulable {

    global void execute(SchedulableContext ctx) {
    	DateTime dt = DateTime.now();
        List<Tournament__c> tournamentsToStart = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c 
            FROM Tournament__c 
            WHERE Status__c = 'Upcoming' AND StartDate__c <= :dt];
        // Let's make a limit to start only 3 tournaments for one time to be sure that we will not exceed salesforce limits
        for(integer i = 0; i < (tournamentsToStart.size() > 3 ? 3 : tournamentsToStart.size()); i++) {
            try {
                tournamentsToStart[i].Status__c = 'Current';
                update(tournamentsToStart[i]);
                generateGames(tournamentsToStart[i]);
            } catch (Exception e) {
                System.debug(e);
            }
        }
    }
    
    private void generateGames(Tournament__c tournament) {
        List<String> ids = getCompetitorsIds(tournament);
        if (tournament.Type__c == 'Single Elimination') {
        	SingleEliminationTournament.StartSingleEliminationTournament(ids, tournament);
        } else if (tournament.Type__c == 'Double Elimination') {
        	DoubleEliminationTournament.generateRounds(ids, tournament.Id);
        } else {
            RoundRobin.RoundRobinTournament(tournament, ids);
        }
    }
    
    private List<String> getCompetitorsIds(Tournament__c tournament) {
    	List<String> result;
    	if (tournament.Format__c == '1 x 1') {
        	result = getPlayersIds(tournament.Id);
        } else {
        	result = getTeamsIds(tournament.Id);
        }
    	return result;
    }
    
    private List<String> getPlayersIds(String tournamentId) {
        List<String> result = new List<String>();
        List<PlayerTournament__c> playerTournaments = [SELECT Player__c 
            FROM PlayerTournament__c 
            WHERE Tournament__c = :tournamentId];
        for (PlayerTournament__c pT : playerTournaments) {
            result.add(pT.Player__c);
        }
        return result;
    }
    
    private List<String> getTeamsIds(String tournamentId) {
        List<String> result = new List<String>();
        List<Team__c> teams = [SELECT Id 
            FROM Team__c 
            WHERE Tournament__c = :tournamentId AND IsComplete__c = true];
        for (Team__c t : teams) {
            result.add(t.Id);
        }
        return result;
    }
    
}