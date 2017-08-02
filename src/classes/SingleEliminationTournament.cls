public with sharing class SingleEliminationTournament implements ISingleEliminationTournament{
    public Integer ijz{get{return 1;}set;}
    public Tournament__c oneTournament{get;set;}
    public Map<String, String> competitorsName{
        get{
            if(oneTournament !=null && oneTournament.Type__c !=null && oneTournament.Type__c=='Single Elimination'){
                if(competitorsName == null){
                    Map<String, String> localCompetitorsName = Helper.getIdAndNameMap(oneTournament);
                    localCompetitorsName.put('?','?');
                    return localCompetitorsName;
                }
                return competitorsName;
            }else{return new Map<String, String>();}
        }
        set;
    }


    public List<List<Game__c>> representSingleEliminationGrid{
        get{
            if(representSingleEliminationGrid == null && oneTournament !=null) return generateSingleEliminationStageGrid(oneTournament);
            if(representSingleEliminationGrid == null && oneTournament ==null) return new List<List<Game__c>>();
            return representSingleEliminationGrid;
        }
        set;
    }
    public Integer countOfStageOneTournament{
        get{
            if(representSingleEliminationGrid !=null && representSingleEliminationGrid.size() == 2)countOfStageOneTournament = 2;
            else if(representSingleEliminationGrid !=null &&  representSingleEliminationGrid.size()<=1){countOfStageOneTournament = 3;}
            else{countOfStageOneTournament = 1;}
            return countOfStageOneTournament;
        }
        set;
    }
    public boolean isLoserGroupGame{
        get{
            if(representSingleEliminationGrid !=null){
                for(List<Game__c> x : representSingleEliminationGrid){
                    for(Game__c thisGame : x){
                        if(!thisGame.WinningGroup__c && thisGame!=null) return true;
                    }
                }     
            }return false;
        }
        set;
    }
    
    public static void StartSingleEliminationTournament(List<String> CompetitorsIds, Tournament__c currentTournament){
        if(currentTournament !=null && currentTournament.Type__c !=null && currentTournament.Type__c == 'Single Elimination' && currentTournament.Format__c !=null){
            if(CompetitorsIds.size()<=1){
                TournamentController.finish(currentTournament);
                return;
            }
            Integer i = 0;
            Integer countStages = 0;
            for(Integer j = 1; j<=CompetitorsIds.size(); j *=2){
                i = j;
                countStages++;
            }
            Integer z;
            if(i == CompetitorsIds.size()){z = 0;}
            else{z = 2*i-CompetitorsIds.size();}
            Integer round=0;
            List<Game__c> thisGames = new List<Game__c>();
            for(; round<CompetitorsIds.size()-z;round +=2){
                Integer match=round+1;
                Game__c currentGame = new Game__c(FirstCompetitor__c= CompetitorsIds.get(round),SecondCompetitor__c = CompetitorsIds.get(match),FirstCompetitorScore__c = 0,
                                                  SecondCompetitorScore__c = 0, Tournament__c = currentTournament.Id, Stage__c = 1);
                thisGames.add(CurrentGame);
            }
            if(i == CompetitorsIds.size()){
                for(Integer stages = 2; stages<countStages;stages++){
                    for(Integer gamesPerRound = 1; gamesPerRound <= i/4;gamesPerRound++){
                        if(i != 4)thisGames.add(new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c  = 0, SecondCompetitorScore__c = 0, 
                                                  Stage__c = stages, Tournament__c = currentTournament.Id));
                        
                        if(i == 4){
                            thisGames.add(new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c  = 0, SecondCompetitorScore__c = 0, 
                                                      Stage__c = stages, Tournament__c = currentTournament.Id, Type__c = 'Final'));
                            thisGames.add(new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c  = 0, SecondCompetitorScore__c = 0, 
                                                      Stage__c = stages, Tournament__c = currentTournament.Id, WinningGroup__c = false, Type__c = 'Final'));
                        }
                    }
                    i /=2;
                }
            }
            else if (i != CompetitorsIds.size()){
                if(CompetitorsIds.size()==3){
                thisGames.add(new Game__c(FirstCompetitor__c= CompetitorsIds.get(2) ,SecondCompetitor__c = '?',FirstCompetitorScore__c = 0,
                                                  SecondCompetitorScore__c = 0, Tournament__c = currentTournament.Id, Stage__c = 2, Type__c = 'Final'));
                }
                else if(CompetitorsIds.size()>4){
                    String currentTournamentId = currentTournament.Id;
                    for(Integer stages = 2; stages<=countStages; stages++){
                        for(Integer gamesPerRound = 1; gamesPerRound <=i/2; gamesPerRound++){
                            Game__c currentGame = new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c  = 0, SecondCompetitorScore__c = 0, 
                                                      Stage__c = stages, Tournament__c = currentTournamentId);
                            if(stages == countStages) currentGame.Type__c = 'Final';
                            if(round < CompetitorsIds.size()){
                                currentGame.FirstCompetitor__c = CompetitorsIds.get(round);
                                if(round + 1 < CompetitorsIds.size()){
                                    currentGame.SecondCompetitor__c = CompetitorsIds.get(round+1);
                                }                            
                                round+=2;
                            }
                            thisGames.add(currentGame);
                           
                        }
                        i /=2;
                    }
                    Game__c currentGameThirdPlace = new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c  = 0, SecondCompetitorScore__c = 0, 
                                                                Stage__c = countStages, Tournament__c = currentTournamentId, WinningGroup__c = false, Type__c = 'Final');
                    thisGames.add(currentGameThirdPlace);
                }
            }          
            try{insert thisGames;}
            catch(DMLException e){}
        }    
    }
    
    public static void createNextSingleEliminationStage(List<Game__c> gamesByPreviousRound, Tournament__c currentTournament){
        if(currentTournament!=null && gamesByPreviousRound !=null && !gamesByPreviousRound.isEmpty()){
            Decimal thisRoundStage = gamesByPreviousRound.get(0).Stage__c;
            thisRoundStage++;
            List<Game__c> gamesByThisStage = new List<Game__c>();
            gamesByThisStage = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, 
                                FirstCompetitorScore__c, SecondCompetitorScore__c, Stage__c, Tournament__c  
                                From Game__c Where Stage__c = :thisRoundStage AND Tournament__c = :currentTournament.Id];
            if(!gamesByPreviousRound.isEmpty() && !gamesByThisStage.isEmpty()){
               List<String> winnerCompetitors = new List<String>();
               List<String> loserCompetitors = new List<String>();
               if(gamesByPreviousRound.size() == 1){
                    if(gamesByPreviousRound.get(0).FirstCompetitorScore__c > gamesByPreviousRound.get(0).SecondCompetitorScore__c){winnerCompetitors.add(gamesByPreviousRound.get(0).FirstCompetitor__c);}
                    else{winnerCompetitors.add(gamesByPreviousRound.get(0).SecondCompetitor__c);}
                    Game__c myUpdateGame = new Game__c();
                    for(Game__c x :gamesByThisStage){
                        if(x.SecondCompetitor__c == '?'){
                            x.SecondCompetitor__c = winnerCompetitors.get(0);
                            myUpdateGame = x;
                        }
                    }
                    try{update myUpdateGame;}
                    catch(DMLException e){}
                    return;
               }
               List<Game__c> thisGames = new List<Game__c>();
               Boolean isFinal = false;
               for(Game__c x : gamesByThisStage){
                   if(x.WinningGroup__c == false) isFinal = true;
               }
               if(gamesByPreviousRound.size() == 2 && gamesByThisStage.size() == 2 && isFinal){
                    for(Game__c g : gamesByPreviousRound){
                        if(g.FirstCompetitorScore__c > gamesByPreviousRound.get(0).SecondCompetitorScore__c){
                            winnerCompetitors.add(g.FirstCompetitor__c);
                            loserCompetitors.add(g.SecondCompetitor__c);
                        }
                        else{
                            winnerCompetitors.add(g.SecondCompetitor__c);
                            loserCompetitors.add(g.FirstCompetitor__c);
                        }
                    }
                    thisGames.add(new Game__c(FirstCompetitor__c = winnerCompetitors.get(0), FirstCompetitorScore__c = 0, 
                                              SecondCompetitor__c = winnerCompetitors.get(1), SecondCompetitorScore__c = 0,
                                              Stage__c = thisRoundStage, Tournament__c = currentTournament.Id));
                    thisGames.add(new Game__c(FirstCompetitor__c = loserCompetitors.get(0), FirstCompetitorScore__c = 0, 
                                              SecondCompetitor__c = loserCompetitors.get(1), SecondCompetitorScore__c = 0,
                                              Stage__c = thisRoundStage, Tournament__c = currentTournament.Id, WinningGroup__c = false));
                    try{update thisGames;}
                    catch(DMLException e){}
                    return;
               }
               if(gamesByPreviousRound.size() >= 2 && gamesByThisStage.size() >= 2 && !isFinal){
                    for(Game__c g : gamesByPreviousRound){
                        if(g.FirstCompetitorScore__c > g.SecondCompetitorScore__c){winnerCompetitors.add(g.FirstCompetitor__c);}
                        else{winnerCompetitors.add(g.SecondCompetitor__c);}
                    }
               }
               Integer competitorCount = 0;
               for(Game__c x : gamesByThisStage){
                    if(x.FirstCompetitor__c == '?'){
                        x.FirstCompetitor__c = winnerCompetitors.get(competitorCount);
                        competitorCount++;
                    }
                    if(x.SecondCompetitor__c == '?'){
                        x.SecondCompetitor__c = winnerCompetitors.get(competitorCount);
                        competitorCount++; 
                    }
                    thisGames.add(x);
               }
               try{update thisGames;}
               catch(DMLException e){throw e;}
            } 
        }else{}
    }
    
    public List<List<Game__c>> generateSingleEliminationStageGrid(Tournament__c currentTournament){
        if(currentTournament != null && currentTournament.Type__c =='Single Elimination'){
            List<List<Game__c>> thisGames = new List<List<Game__c>>();
            
            List<Game__c>gamesForCurrentTournament = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, 
                    SecondCompetitorScore__c, Stage__c, Tournament__c 
                    From Game__c Where Tournament__c = :currentTournament.Id Order By Stage__c];
            if(gamesForCurrentTournament !=null && !gamesForCurrentTournament.isEmpty()){
                for(Integer j = 1; j<=gamesForCurrentTournament.get(gamesForCurrentTournament.size()-1).Stage__c.intValue();j++){
                    List<Game__c> stageLists = new List<Game__c>();
                    for(Game__c x : gamesForCurrentTournament){
                        if(j !=null && j == x.Stage__c.intValue()){
                            stageLists.add(x);     
                        }
                    }
                    thisGames.add(stageLists);    
                }
            }else{return new List<List<Game__c>>();}
            return thisGames;
        }else{
            competitorsName = new Map<String, String>();
            return new List<List<Game__c>>();
        }    
    }
}