public with sharing class SingleEliminationTournament{
    public Integer ijz{get{return 1;}set;}
    public Tournament__c oneTournament{get;set;}
    public Map<String, String> competitorsName{
        get{
            if(oneTournament !=null && oneTournament.Type__c !=null && oneTournament.Type__c=='Single Elimination'){
                if(competitorsName== null) competitorsName = Helper.getIdAndNameMap(oneTournament);
                return competitorsName;
            }else{return new Map<String, String>();}
        }
        set;
    }
    public Integer countOfStageOneTournament{get;set;}
    public List<List<Game__c>> representSingleEliminationGrid{
        get{
            if(representSingleEliminationGrid == null) representSingleEliminationGrid = generateSingleEliminationStageGrid(oneTournament);
            if(representSingleEliminationGrid.size() < 3 && representSingleEliminationGrid.size()>1)countOfStageOneTournament = 2;
            else if(representSingleEliminationGrid.size()<=1){countOfStageOneTournament = 3;}
            else{countOfStageOneTournament = 1;}
            return representSingleEliminationGrid;
        }
        set;
    }
    
    public boolean isLoserGroupGame{
        get{
            if(representSingleEliminationGrid !=null){
                for(List<Game__c> x : representSingleEliminationGrid){
                    for(Game__c thisGame : x){
                        if(!thisGame.WinningGroup__c) return true;
                    }
                }     
            }return false;
        }
        set;
    }
    
    public static void StartSingleEliminationTournament(List<String> CompetitorsIds, Tournament__c currentTournament){
        if(currentTournament.Type__c !=null && currentTournament.Type__c == 'Single Elimination' && currentTournament.Format__c !=null){
            List<Game__c> thisGames = new List<Game__c>();
            Integer i = 0;
            for(Integer j = 1; j<=CompetitorsIds.size(); j *=2){
                i = j;
            }
            Integer z;
            if(i == CompetitorsIds.size()){z = 0;}
            else{z = 2*i-CompetitorsIds.size();}       
            for(Integer round=0; round<CompetitorsIds.size()-z;round +=2){
                Integer match=round+1;
                Game__c currentGame = new Game__c();
                currentGame.FirstCompetitor__c= CompetitorsIds.get(round); 
                currentGame.SecondCompetitor__c = CompetitorsIds.get(match);
                currentGame.FirstCompetitorScore__c = 0;
                currentGame.SecondCompetitorScore__c = 0;
                currentGame.Tournament__c = currentTournament.Id;           
                currentGame.Stage__c = 1;
                thisGames.add(CurrentGame);
            }
            if(i != CompetitorsIds.size()){    
                Integer k = 2*i-CompetitorsIds.size();
                Id freeSlot;
                If(currentTournament.Format__c == '1 x 1'){ 
                    freeSlot = [Select ID,Name, Email__c From Player__c Where Email__c='www@gmail.com'].Id;
                }
                else{ 
                    freeSlot =[Select Id, Name From Team__c Where Name = '-'].Id;
                }
                for(Integer nextRound = CompetitorsIds.size()-1; k>0; nextRound--){
                    Game__c currentGame = new Game__c();
                    currentGame.FirstCompetitor__c= CompetitorsIds.get(nextRound); 
                    currentGame.SecondCompetitor__c = freeSlot;
                    currentGame.FirstCompetitorScore__c  = 2;
                    currentGame.SecondCompetitorScore__c = 0;
                    currentGame.FirstCompetitorAccept__c  = true;
                    currentGame.SecondCompetitorAccept__c = true;
                    currentGame.Stage__c = 1;
                    currentGame.Tournament__c = currentTournament.Id;
                    thisGames.add(CurrentGame);
                    k--;    
                }
            }
           
        try{upsert thisGames;}
        catch(DMLException e){}       
        } 
    }
    public List<List<Game__c>> generateSingleEliminationStageGrid(Tournament__c currentTournament){
        if(currentTournament.id != null && currentTournament.Type__c !=null && currentTournament.Type__c =='Single Elimination'){
            Integer i = 0; //Stage count
            List<List<Game__c>> thisGames = new List<List<Game__c>>();
            
            List<Game__c>gamesForCurrentTournament = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, 
                    SecondCompetitorScore__c, Stage__c, Tournament__c 
                    From Game__c Where Tournament__C = :currentTournament.Id];
            Integer countCompetitors = gamesForCurrentTournament.size(); 
            if(countCompetitors  >0 && countCompetitors  !=null){
                for(Integer j =1; j<countCompetitors ;j*=2){
                    i++;
                }
            }
            if(gamesForCurrentTournament !=null){
                for(Integer j = 1; j<=i;j++){
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
        }else{
            competitorsName = new Map<String, String>();
            return new List<List<Game__c>>();
        }    
    }
    
    public static void createNextSingleEliminationStage(List<Game__c> gamesByPreviousRound, Tournament__c currentTournament){
        if(currentTournament !=null && gamesByPreviousRound !=null &&
           currentTournament.Type__c != null && currentTournament.Type__c =='Single Elimination'){
            if(gamesByPreviousRound.size() >2){ 
                List<Game__c> nextRoundGames = new List<Game__c>();
                List<Id> competitorsWinnersId = new List<Id>();
                for(Game__c x : gamesByPreviousRound){
                    if(x.FirstCompetitorScore__c> x.SecondCompetitorScore__c) {competitorsWinnersId.add(x.FirstCompetitor__c);}
                    else{competitorsWinnersId .add(x.SecondCompetitor__c);}
                }
                Decimal thisGameStage = gamesByPreviousRound.get(0).Stage__c;
                thisGameStage++;
                Id freeSlot;
                If(currentTournament.Format__c == '1 x 1'){ 
                    freeSlot = [Select ID,Name, Email__c From Player__c Where Email__c='www@gmail.com'].Id;
                }
                else{ 
                    freeSlot =[Select Id, Name From Team__c Where Name = '-'].Id;
                }                    
                for(Integer round=0; round<=competitorsWinnersId.size()-1;round +=2){
                        Integer match=round+1;
                        Game__c currentGame = new Game__c();
                        currentGame.FirstCompetitor__c= competitorsWinnersId.get(round);
                        currentGame.FirstCompetitorScore__c= 0;
                        currentGame.SecondCompetitorScore__c = 0;
                        currentGame.Stage__c = thisGameStage;
                        currentGame.Tournament__c = currentTournament.Id;
                        if(match < competitorsWinnersId.size()){
                            currentGame.SecondCompetitor__c= competitorsWinnersId.get(match);
                        }else{
                              currentGame.FirstCompetitorScore__c = 1;
                              currentGame.FirstCompetitorAccept__c= true;
                              currentGame.SecondCompetitorAccept__c= true;                              
                              currentGame.SecondCompetitor__c= freeSlot;
                              }
                        nextRoundGames.add(currentGame);
                    }
                    if(nextRoundGames !=null && nextRoundGames.size()>0){
                        try{upsert nextRoundGames;}
                        catch(DMLException e){}
                    
                    }
            }
            
            else if(gamesByPreviousRound.size() == 2){
                createFinalAndRhirdPlaceMatch(gamesByPreviousRound, currentTournament);       
            }                      
                     
        }     
    }
  
    private static void createFinalAndRhirdPlaceMatch(List<Game__c> gamesByPreviousRound, Tournament__c currentTournament){
        List<Game__c> nextRoundGames = new List<Game__c>();
                List<Id> competitorsWinnersId = new List<Id>();
                List<Id> competitorsLosersId = new List<Id>();    
                Decimal thisGameStage = gamesByPreviousRound.get(0).Stage__c;
                thisGameStage++;
                Id freeSlot;
                If(currentTournament.Format__c == '1 x 1'){ 
                    freeSlot = [Select ID,Name, Email__c From Player__c Where Email__c='www@gmail.com'].Id;
                }
                else{ 
                    freeSlot =[Select Id, Name From Team__c Where Name = '-'].Id;
                }                 
                for(Game__c x : gamesByPreviousRound){
                    if(x.FirstCompetitorScore__c> x.SecondCompetitorScore__c){
                        competitorsWinnersId.add(x.FirstCompetitor__c);
                        competitorsLosersId.add(x.SecondCompetitor__c);
                    }
                    else{
                        competitorsWinnersId.add(x.SecondCompetitor__c);
                        competitorsLosersId.add(x.FirstCompetitor__c);
                    }
                }
                Game__c FinalGame = new Game__c();
                FinalGame.FirstCompetitor__c= competitorsWinnersId.get(0);
                FinalGame.SecondCompetitor__c= competitorsWinnersId.get(1);
                FinalGame.FirstCompetitorScore__c= 0;
                FinalGame.SecondCompetitorScore__c = 0;
                FinalGame.Stage__c = thisGameStage;
                FinalGame.Tournament__c = currentTournament.Id;
                nextRoundGames.add(FinalGame );
                
                Game__c thirdPlaceMatch = new Game__c();
                thirdPlaceMatch.FirstCompetitor__c= competitorsLosersId.get(0);
                thirdPlaceMatch.SecondCompetitor__c= competitorsLosersId.get(1);
                thirdPlaceMatch.FirstCompetitorScore__c= 0;
                thirdPlaceMatch.SecondCompetitorScore__c = 0;
                thirdPlaceMatch.Stage__c = thisGameStage;
                thirdPlaceMatch.WinningGroup__c = false;
                thirdPlaceMatch.Tournament__c = currentTournament.Id;                
                nextRoundGames.add(thirdPlaceMatch);
                
                if(nextRoundGames !=null && nextRoundGames.size()>0){
                    try{upsert nextRoundGames;}
                    catch(DMLException e){}
                 
                }
            }
        
    
}