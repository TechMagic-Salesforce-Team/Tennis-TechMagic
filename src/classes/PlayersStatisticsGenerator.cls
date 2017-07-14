public with sharing class PlayersStatisticsGenerator {
    public static void generatePlayerStatisticsObjects(
        List<Tournament__c> beforeUpdateTournaments,
        List<Tournament__c> afterUpdateTournaments
        ){
        System.debug('before update status: '+beforeUpdateTournaments.get(0).Status__c+' after update status: '+afterUpdateTournaments.get(0).Status__c);
        Map<Id,Tournament__c> tournamentsChangedToCurrentStatus = new Map<Id,Tournament__c>();
        List<PlayerTournament__c> playerTournamentsList = new List<PlayerTournament__c>();
        
        
        
        for (Integer i = 0; i < beforeUpdateTournaments.size(); i++){
            if (beforeUpdateTournaments.get(i).Status__c != 'Current' && afterUpdateTournaments.get(i).Status__c == 'Current'){
                tournamentsChangedToCurrentStatus.put(afterUpdateTournaments.get(i).Id,afterUpdateTournaments.get(i));
            }
        }
        
        playerTournamentsList = [select Player__c,Tournament__c from PlayerTournament__c where Tournament__c in:tournamentsChangedToCurrentStatus.keySet()];
        
        
        
        List<PlayerStatistics__c> playerStatisticList = new List<PlayerStatistics__c>();
        
       
            for (PlayerTournament__c playerTournament: playerTournamentsList){
                playerStatisticList.add(
                new PlayerStatistics__c(
                    Player__c = playerTournament.Player__c,
                    Tournament__c = playerTournament.Tournament__c
                ));
            }
        
        
        System.debug('size of player statistic list: '+playerStatisticList.size());
        
        insert playerStatisticList;
    }
}


