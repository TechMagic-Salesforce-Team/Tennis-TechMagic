public with sharing class DoubleEliminationTournament {
    
    public integer ijz {get {return 1;} set;}
    public Tournament__c oneTournament{get;set;}
    
    public List<List<Game__c>> representDoubleEliminationGrid{
        get{
            if(representDoubleEliminationGrid == null) return generateDoubleEliminationGrid(oneTournament);
            return representDoubleEliminationGrid;
        }
        set;
    }
    
    public List<List<Game__c>> generateDoubleEliminationGrid(Tournament__c currentTournament){
        if(currentTournament.id != null && currentTournament.Type__c !=null && currentTournament.Type__c =='Double Elimination'){
            Decimal i = 0; //Stage count
            List<List<Game__c>> thisGames = new List<List<Game__c>>();
            
            List<Game__c>gamesForCurrentTournament = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, 
                    SecondCompetitorScore__c, Stage__c, Tournament__c 
                    From Game__c Where Tournament__C = :currentTournament.Id];
            Integer countCompetitors = gamesForCurrentTournament.size(); 
            for (Game__c g : gamesForCurrentTournament) {
                if (g.Stage__c > i) {
                    i = g.Stage__c;
                }
            }
            if(gamesForCurrentTournament != null){
                for(Integer j = 0; j <= i; j++){
                    List<Game__c> stageLists = new List<Game__c>();
                    for(Game__c x : gamesForCurrentTournament){
                        if(j !=null && j == x.Stage__c.intValue()){
                            stageLists.add(x);     
                        }
                    }
                    thisGames.add(stageLists);    
                }
            }
            return thisGames;
        }
        return new List<List<Game__c>>(); 
    }
    
    public static void generateRounds(List<String> competitorsIds, String tournamentId) {
        Double size = competitorsIds.size();
        System.debug('size: '+size);
        Double lvl = Math.floor(Math.log(size)/Math.log(2));
        System.debug('lvl: '+lvl);
        Double newSize = Math.pow(2, lvl);
        System.debug('newSize: '+newSize);
        Double diff = size - newSize;
        System.debug('diff: '+diff);
        
        List<Double> winners = new List<Double>();
        List<Double> losers = new List<Double>();

        if (diff > 0) {
            winners.add(diff);
            losers.add(diff/2.0);
        }

        Double numCurGames = newSize/2;
        
        if (numCurGames < 1) {
            // finish tournament
            Tournament__c t = [SELECT Id, Status__c FROM Tournament__c WHERE Id =:tournamentId];
            TournamentController.finish(t);
            return;
        }

        while(numCurGames >= 1) {
            winners.add(numCurGames);
            losers.add(numCurGames/2.0);
            numCurGames = numCurGames/2.0;
        }

        System.debug('winners: ' + winners);
        System.debug('losers: ' + losers);

        for(integer i = 0; i < losers.size(); i++) {
            if(Math.ceil(losers[i]) != Math.floor(losers[i]) && losers[i] >= 0.5) {  
                if(i != losers.size()-1) {
                    losers[i+1] = losers[i+1] + 0.5;
                } else {
                    if (losers[i] > 0.5) {
                        losers.add(0.5);
                    }
                }
                losers[i] = Math.floor(losers[i]);
            }
            if(i != losers.size()-1) {
                losers[i+1] = losers[i+1] + losers[i]/2;
            } else {
                if (losers[i] > 1) {
                        losers.add(losers[i]/2);
                }
            }
        }

        System.debug('losers: ' + losers);
        List<Game__c> otherGames = new List<Game__c>();
        
        for(integer i = 0; i < winners.size(); i++) {
            double currentStageGames = winners[i];
            for(integer j = 0; j < currentStageGames; j++) {
                Game__c game = new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c = 0,
                    SecondCompetitorScore__c = 0, Stage__c = i, Tournament__c = tournamentId);
                otherGames.add(game);
            }
        }
        
        for(integer i = 0; i < losers.size(); i++) {
            double currentStageGames = losers[i];
            for(integer j = 0; j < currentStageGames; j++) {
                Game__c game = new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c = 0,
                    SecondCompetitorScore__c = 0, Stage__c = i, Tournament__c = tournamentId, WinningGroup__c = false);
                otherGames.add(game);
            }
        }
        
        System.debug('otherGames: '+otherGames);
        
        try {
            insert(otherGames);
        } catch(System.DmlException e) {
            System.debug(e);
        }
        
        List<Game__c> gamesToUpdate = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, 
                    SecondCompetitorScore__c, Stage__c, Tournament__c, Type__c 
                    From Game__c Where Tournament__C = :tournamentId AND WinningGroup__c = true ORDER BY Stage__c ASC LIMIT :(competitorsIds.size()/2 + 1)];
        integer cnt = 0;
        for (Game__c g : gamesToUpdate) {
            g.FirstCompetitor__c = cnt >= competitorsIds.size() ? '?' : competitorsIds[cnt];
            g.SecondCompetitor__c = (cnt + 1) >= competitorsIds.size() ? '?' : competitorsIds[cnt + 1];
            cnt = cnt + 2;
        }
        
        try {
            update(gamesToUpdate);
        } catch(System.DmlException e) {
            System.debug(e);
        }
        
        gamesToUpdate = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, 
                    SecondCompetitorScore__c, Stage__c, Tournament__c, Type__c 
                    From Game__c Where Tournament__C = :tournamentId AND WinningGroup__c = true ORDER BY Stage__c DESC LIMIT :1];
        if (gamesToUpdate.size() > 0) {
            gamesToUpdate[0].Type__c = 'Final';
            try {
                update(gamesToUpdate[0]);
            } catch(System.DmlException e) {
                System.debug(e);
            }
        }
        
        gamesToUpdate = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, 
                    SecondCompetitorScore__c, Stage__c, Tournament__c, Type__c 
                    From Game__c Where Tournament__C = :tournamentId AND WinningGroup__c = false ORDER BY Stage__c DESC LIMIT :1];
        if (gamesToUpdate.size() > 0) {
            gamesToUpdate[0].Type__c = 'Final';
            try {
                update(gamesToUpdate[0]);
            } catch(System.DmlException e) {
                System.debug(e);
            }
        }
    }
    
}