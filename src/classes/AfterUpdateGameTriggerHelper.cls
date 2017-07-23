public with sharing class AfterUpdateGameTriggerHelper {  
    public static void generateGamesOrFinishTournament(List<Game__c> oldGames, List<Game__c> newGames) {
        for (integer i = 0; i < newGames.size(); i++) {
            if (!(oldGames[i].FirstCompetitorAccept__c && oldGames[i].SecondCompetitorAccept__c) && newGames[i].FirstCompetitorAccept__c && newGames[i].SecondCompetitorAccept__c) {
                // update player statistics
                genGamesOrFinTour(newGames[i]);
            }
        }
    }
    
    private static void genGamesOrFinTour(Game__c game) {
        List<Tournament__c> ts = [SELECT Id, Type__c, Status__c, Format__c FROM Tournament__c WHERE Id = :game.Tournament__c];
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
                        SingleEliminationTournament.createNextSingleEliminationStage(games, t);
                    } else {
                        List<Game__c> previousGames = [SELECT Id, FirstCompetitorAccept__c, SecondCompetitorAccept__c 
                            FROM Game__c WHERE Tournament__c = :t.Id AND Stage__c = :(game.Stage__c - 1.0)];
                        if (previousGames.size() > 2 || previousGames.size() == 0 && games.size() == 2) {
                            SingleEliminationTournament.createNextSingleEliminationStage(games, t);
                        } else {
                            TournamentController.finish(t);
                        }
                    }
                }
            } else if (t.Type__c == 'Double Elimination') {  
                if (game.Type__c == 'Final') {
                    Game__c superFinal;
                    List<Game__c> nextWinningGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                        FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Type__c = 'Super Final' LIMIT 1];
                    if (nextWinningGames.size() == 0) {
                        superFinal = new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = (game.Stage__c + 1.0), Tournament__c = t.Id, Type__c = 'Super Final');
                        try {
                            insert (superFinal);
                        } catch (System.DmlException e) {
                            System.debug(e);
                        }
                    } else {
                        superFinal = nextWinningGames[0];
                    }
                    if (game.WinningGroup__c == true) {
                        superFinal.FirstCompetitor__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                        List<Game__c> nextLosingGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                            FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') ORDER BY Stage__c ASC LIMIT 1];
                        if (nextLosingGames.size() > 0) {
                            if (nextLosingGames[0].FirstCompetitor__c == '?') {
                                nextLosingGames[0].FirstCompetitor__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            } else {
                                nextLosingGames[0].SecondCompetitor__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            }
                            try {
                                update (nextLosingGames[0]);
                            } catch (System.DmlException e) {
                                System.debug(e);
                            }
                        }
                    } else {
                        superFinal.SecondCompetitor__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                    }
                    try {
                        update (superFinal);
                    } catch (System.DmlException e) {
                        System.debug(e);
                    }
                } else if (game.Type__c == 'Super Final') {
                    List<Game__c> finalGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c
                        FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Type__c = 'Final' LIMIT 1];
                    if (finalGames.size() > 0) {
                        String finalWinnerId = finalGames[0].FirstCompetitorScore__c > finalGames[0].SecondCompetitorScore__c ? finalGames[0].FirstCompetitor__c : finalGames[0].SecondCompetitor__c;
                        String superFinalWinnerId = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                        if (finalWinnerId == superFinalWinnerId) {
                            TournamentController.finish(t);
                        } else {
                            Game__c secondSuperFinal = new Game__c(FirstCompetitor__c = game.SecondCompetitor__c, SecondCompetitor__c = game.FirstCompetitor__c, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = (game.Stage__c + 1.0), Tournament__c = t.Id, Type__c = 'Super Final 2');
                            try {
                                insert (secondSuperFinal);
                            } catch (System.DmlException e) {
                                System.debug(e);
                            }
                        }
                    }
                } else if (game.Type__c == 'Super Final 2') {
                    TournamentController.finish(t);
                } else {
                    if (game.WinningGroup__c == true) {
                        List<Game__c> nextWinningGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                            FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Stage__c > :game.Stage__c AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') LIMIT 1];
                        if (nextWinningGames.size() > 0) {
                            if (nextWinningGames[0].FirstCompetitor__c == '?') {
                                nextWinningGames[0].FirstCompetitor__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            } else {
                                nextWinningGames[0].SecondCompetitor__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            }
                            try {
                                update (nextWinningGames[0]);
                            } catch (System.DmlException e) {
                                System.debug(e);
                            }
                        }
                        List<Game__c> nextLosingGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                            FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') ORDER BY Stage__c ASC LIMIT 1];
                        if (nextLosingGames.size() > 0) {
                            if (nextLosingGames[0].FirstCompetitor__c == '?') {
                                nextLosingGames[0].FirstCompetitor__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            } else {
                                nextLosingGames[0].SecondCompetitor__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            }
                            try {
                                update (nextLosingGames[0]);
                            } catch (System.DmlException e) {
                                System.debug(e);
                            }
                        }
                    } else {
                        List<Game__c> nextLosingGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                            FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND Stage__c > :game.Stage__c AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') LIMIT 1];
                        if (nextLosingGames.size() > 0) {
                            if (nextLosingGames[0].FirstCompetitor__c == '?') {
                                nextLosingGames[0].FirstCompetitor__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            } else {
                                nextLosingGames[0].SecondCompetitor__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            }
                            try {
                                update (nextLosingGames[0]);
                            } catch (System.DmlException e) {
                                System.debug(e);
                            }
                        }
                    }
                }
            }
        }
    }
    
    private static Boolean checkOneAccept(List<Game__c> games) {
        Boolean result = true;
        for (Game__c g: games) {
            result = result && g.FirstCompetitorAccept__c && g.SecondCompetitorAccept__c;
        }
        return result;
    }
    
}