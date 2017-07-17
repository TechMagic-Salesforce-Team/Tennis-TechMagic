public with sharing class SingleEliminationTournament{
    public Integer ijz{get{return 1;}set;}
    public Tournament__c oneTournament{get;set;}
    
    public List<List<Game__c>> representSingleEliminationGrid{
        get{
            if(representSingleEliminationGrid == null) representSingleEliminationGrid = new List<List<Game__c>>();
            return representSingleEliminationGrid;
        }
        set;
    }
    
    public SingleEliminationTournament(){
        List<String> myList = new List<String>();
        myList.add('vitalya');
        myList.add('vitalya');
        myList.add('vitalya');
        myList.add('vitalya');
        myList.add('vitalya');
        myList.add('vitalya');
        myList.add('vitalya');
        myList.add('vitalya');
        representSingleEliminationGrid = generateSingleEliminationStageGrid(myList ,
        [Select Id, Type__c From Tournament__c Where Name = 'MyTournament3']);
    } 
   
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
    public List<List<Game__c>> generateSingleEliminationStageGrid(List<String> CompetitorsIds, Tournament__c currentTournament){
        if(currentTournament.id != null && currentTournament.Type__c !=null && currentTournament.Type__c =='Single Elimination'){
            Integer i = 0; //Stage count
            List<List<Game__c>> thisGames = new List<List<Game__c>>();
            if(CompetitorsIds.size() >0 && CompetitorsIds.size() !=null){
                for(Integer j =1; j<CompetitorsIds.size();j*=2){
                    i++;
                }
            }
            List<Game__c>gamesForCurrentTournament = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, 
                    SecondCompetitorScore__c, Stage__c, Tournament__c 
                    From Game__c Where Tournament__C = :currentTournament.Id];
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
        if(currentTournament.Type__c != null && currentTournament.Type__c =='Single Elimination' 
           && currentTournament.Format__c =='1 x 1' && currentTournament.Format__c != null){
            Boolean allGamesAlreadyFinished;
            Integer i = [Select Count() From Game__c Where Tournament__c = :currentTournament.Id AND 
                         (FirstCompetitorScore__c=0 AND SecondCompetitorAccept__c = false) AND 
                         (SecondCompetitorScore__c=0 AND FirstCompetitorAccept__c = false)];
            if(i!=null && i==0 ) allGamesAlreadyFinished = true;
            /*if(getCurrentGame()!=null && allGamesAlreadyFinished!=null && allGamesAlreadyFinished){
                Decimal thisGameStage = getCurrentGame().Stage__c;
                List<Game__c> thisGames = [Select Id,Player_one__c,Player_two__c,FirstPlayerGoals__c,SecondPlayerGoals__c From Game__c Where TournamentGame__c = :currentTournament.Id And Stage__c = :thisGameStage];
                List<Game__c> nextRoundGames = new List<Game__c>();
                List<Id> playersWinnersId = new List<Id>();
                for(Game__c x : thisGames){
                    if(x.FirstPlayerGoals__c > x.SecondPlayerGoals__c) {playersWinnersId.add(x.Player_one__c);}
                    else{playersWinnersId.add(x.Player_two__c);}
                }
                List<Player__c> playerWinners = [Select Id, Name, Email__c From Player__c Where Id = :playersWinnersId];
                thisGameStage++;
                Id freeSlot = [Select ID,Name, Email__c From Player__c Where Email__c='www@gmail.com'].Id;
                for(Integer round=0; round<=playerWinners.size()-1;round +=2){
                    Integer match=round+1;
                    Game__c currentGame = new Game__c();
                    currentGame.Player_one__c = playerWinners.get(round).Id;
                    currentGame.FirstPlayerGoals__c = 0;
                    currentGame.SecondPlayerGoals__c = 0;
                    currentGame.Stage__c = thisGameStage;
                    currentGame.TournamentGame__c = currentTournament.Id;
                    if(match < playerWinners.size()){
                        currentGame.Player_two__c = playerWinners.get(match).Id ;
                    }else{currentGame.Player_two__c = freeSlot;
                              try{currentTournament.Status__c = 'COMPLETE';
                                  upsert currentTournament;}
                              catch(DMLException ex){}
                              break;}
                    nextRoundGames.add(currentGame);
                }
                if(nextRoundGames !=null && nextRoundGames.size()>0){
                    try{upsert nextRoundGames;}
                    catch(DMLException e){}
                }
            }*/     
        }
    }
    
}