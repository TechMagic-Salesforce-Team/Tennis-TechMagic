public with sharing class AfterUpdateGameTriggerHelper {  
    public static void generateGamesOrFinishTournament(List<Game__c> oldGames, List<Game__c> newGames) {
        Map<Id, List<Game__c>> oldGamesTournaments = groupByTournament(oldGames);
        Map<Id, List<Game__c>> newGamesTournaments = groupByTournament(newGames);
        Map<Id, Boolean> oldGamesTournamentsAccept = checkAccept(oldGamesTournaments);
        Map<Id, Boolean> newGamesTournamentsAccept = checkAccept(newGamesTournaments);
        Set<Id> ids = newGamesTournamentsAccept.keySet();
        for (Id i : ids) {
            if (!oldGamesTournamentsAccept.get(i) && newGamesTournamentsAccept.get(i)) {
                genGamesOrFinTour(newGamesTournaments.get(i)[0]);
            }
        }
    }
    
    private static void genGamesOrFinTour(Game__c game) {
        List<Tournament__c> ts = [SELECT Id, Type__c, Status__c FROM Tournament__c WHERE Id = :game.Tournament__c];
        if (ts.size() > 0) {
            Tournament__c t = ts[0];
            if (t.Type__c == 'Round Robin'){
                List<Game__c> games = [SELECT Id, FirstCompetitorAccept__c, SecondCompetitorAccept__c FROM Game__c WHERE Tournament__c = :t.Id];
                if (checkOneAccept(games)) {
                    TournamentController.finish(t);
                }
            } else if (t.Type__c == 'Single Elimination') {
                List<Game__c> games = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c
                    FROM Game__c WHERE Tournament__c = :t.Id AND Stage__c = :game.Stage__c];
                if (checkOneAccept(games)) {
                    if (games.size() > 2) {
                        // generate next round
                    } else {
                        List<Game__c> previousGames = [SELECT Id, FirstCompetitorAccept__c, SecondCompetitorAccept__c 
                            FROM Game__c WHERE Tournament__c = :t.Id AND Stage__c = :(game.Stage__c - 1.0)];
                        if (previousGames.size() > 2 || previousGames.size() == 0 && games.size() == 2) {
                            // generate next round
                        } else {
                            TournamentController.finish(t);
                        }
                    }
                }
            } else if (t.Type__c == 'Double Elimination') {  
                List<Game__c> lGames = [SELECT Id, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, FirstCompetitor__c, SecondCompetitor__c FROM Game__c 
                    WHERE Tournament__c = :t.Id AND WinningGroup__c = false ORDER BY Stage__c DESC LIMIT 1];
                if (lGames.size() > 0) {
                    if (lGames[0].FirstCompetitorAccept__c && lGames[0].SecondCompetitorAccept__c) {
                        Game__c wGame = [SELECT Id, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, FirstCompetitor__c, SecondCompetitor__c FROM Game__c 
                            WHERE Tournament__c = :t.Id AND WinningGroup__c = true ORDER BY Stage__c DESC LIMIT 1];
                        if (wGame.FirstCompetitorAccept__c && wGame.SecondCompetitorAccept__c) {
                            
                        } else {
                            
                        }
                    } else {
                        if (game.WinningGroup__c) {
                            Game__c wGame = [SELECT Id, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, FirstCompetitor__c, SecondCompetitor__c FROM Game__c 
                                WHERE Tournament__c = :t.Id AND WinningGroup__c = true ORDER BY Stage__c DESC LIMIT 1];
                            String loserId = wGame.FirstCompetitorScore__c > wGame.SecondCompetitorScore__c ? wGame.FirstCompetitor__c : wGame.SecondCompetitor__c;
                            if (wGame.FirstCompetitorAccept__c && wGame.SecondCompetitorAccept__c) {
                                List<Game__c> loserBasket = [SELECT Id, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, FirstCompetitor__c, SecondCompetitor__c FROM Game__c 
                                WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') ORDER BY Stage__c ASC LIMIT 1];
                                
                            } else {
                                
                            }
                        } else {
                            
                        }
                    }
                } else {
                    List<Game__c> wGames = [SELECT Id, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c FROM Game__c 
                        WHERE Tournament__c = :t.Id];
                    if (wGames.size() == 3 || wGames.size() == 2 && (wGames[0].FirstCompetitorScore__c > wGames[0].SecondCompetitorScore__c && wGames[1].FirstCompetitorScore__c > wGames[1].SecondCompetitorScore__c || wGames[0].FirstCompetitorScore__c < wGames[0].SecondCompetitorScore__c && wGames[1].FirstCompetitorScore__c < wGames[1].SecondCompetitorScore__c)) {
                        TournamentController.finish(t);
                    } else {
                        Boolean winningGroup = wGames.size() == 2 ? false : true;
                        Game__c newGame = new Game__c(FirstCompetitor__c = game.FirstCompetitor__c, SecondCompetitor__c = game.SecondCompetitor__c,
                            Tournament__c = t.Id, Stage__c = game.Stage__c + 1.0, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, WinningGroup__c = winningGroup);
                        try {
                            insert (newGame);
                        } catch (System.DmlException e) {
                            System.debug(e);
                        }
                    }
                }
            }
        }
    }
    
    private static Map<Id, List<Game__c>> groupByTournament(List<Game__c> games) {
        Map<Id, List<Game__c>> gamesTournaments = new Map<Id, List<Game__c>>();
        for (Game__c g : games) {
            Id tournamentId = g.Tournament__c;
            if (gamesTournaments.get(tournamentId) == null) {
                List<Game__c> tmp = new List<Game__c>();
                tmp.add(g);
                gamesTournaments.put(tournamentId, tmp);
            } else {
                gamesTournaments.get(tournamentId).add(g);
            }
        }
        return gamesTournaments;
    }
    
    private static Map<Id, Boolean> checkAccept(Map<Id, List<Game__c>> gamesTournaments) {
        Map<Id, Boolean> gamesAccept = new Map<Id, Boolean>();
        Set<Id> ids = gamesTournaments.keySet();
        for(Id i : ids) {
            gamesAccept.put(i, checkOneAccept(gamesTournaments.get(i)));
        }
        return gamesAccept;
    }
    
    private static Boolean checkOneAccept(List<Game__c> games) {
        Boolean result = true;
        for (Game__c g: games) {
            result = result && g.FirstCompetitorAccept__c && g.SecondCompetitorAccept__c;
        }
        return result;
    }
    
}
