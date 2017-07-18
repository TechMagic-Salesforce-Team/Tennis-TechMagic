public with sharing class SingleEliminationTournament{
    public Integer ijz{get{return 1;}set;}
    public Tournament__c oneTournament{get;set;}
    
    public List<List<Game__c>> representSingleEliminationGrid{
        get{
            if(representSingleEliminationGrid == null) return generateSingleEliminationStageGrid(oneTournament);
            return representSingleEliminationGrid;
        }
        set;
    }
    
    public SingleEliminationTournament(){} 
   
    public void StartSingleEliminationTournament(List<String> CompetitorsIds, Tournament__c currentTournament){
        if(currentTournament.Type__c !=null && currentTournament.Type__c == 'Single Elimination'){
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
                Id freeSlot = [Select ID,Name, Email__c From Player__c Where Email__c='www@gmail.com'].Id;
                for(Integer nextRound = CompetitorsIds.size()-1; k>0; nextRound--){
                    Game__c currentGame = new Game__c();
                    currentGame.FirstCompetitor__c= CompetitorsIds.get(nextRound); 
                    currentGame.SecondCompetitor__c = '-';
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
        }else{return new List<List<Game__c>>();}    
    }
    
    public void createNextSingleEliminationStage(List<Game__c> gamesByPreviousRound, Tournament__c currentTournament){
        if(currentTournament !=null && gamesByPreviousRound !=null &&
           currentTournament.Type__c != null && currentTournament.Type__c =='Single Elimination'){
            
            List<Game__c> nextRoundGames = new List<Game__c>();
            List<Id> playersWinnersId = new List<Id>();
            for(Game__c x : gamesByPreviousRound){
                if(x.FirstCompetitorScore__c> x.SecondCompetitorScore__c) {playersWinnersId.add(x.FirstCompetitor__c);}
                else{playersWinnersId.add(x.SecondCompetitor__c);}
            
                List<Player__c> playerWinners = [Select Id, Name, Email__c From Player__c Where Id = :playersWinnersId];
                Decimal thisGameStage = ++gamesByPreviousRound.get(0).Stage__c;
                Id freeSlot = [Select ID,Name, Email__c From Player__c Where Email__c='www@gmail.com'].Id;
                for(Integer round=0; round<=playerWinners.size()-1;round +=2){
                    Integer match=round+1;
                    Game__c currentGame = new Game__c();
                    currentGame.FirstCompetitor__c= playerWinners.get(round).Id;
                    currentGame.FirstCompetitorScore__c= 0;
                    currentGame.SecondCompetitorScore__c = 0;
                    currentGame.Stage__c = thisGameStage;
                    currentGame.Tournament__c = currentTournament.Id;
                    if(match < playerWinners.size()){
                        currentGame.SecondCompetitor__c= playerWinners.get(match).Id ;
                    }else{currentGame.SecondCompetitor__c= freeSlot;
                          break;}
                    nextRoundGames.add(currentGame);
                }
                if(nextRoundGames !=null && nextRoundGames.size()>0){
                    try{upsert nextRoundGames;}
                    catch(DMLException e){}
                }
            }     
        }
    }
    
}