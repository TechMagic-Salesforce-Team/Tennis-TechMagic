public interface ISingleEliminationTournament{
    void StartSingleEliminationTournament(List<String> CompetitorsIds, Tournament__c currentTournament);
    List<List<Game__c>> generateSingleEliminationStageGrid(Tournament__c currentTournament);
    void createNextSingleEliminationStage(List<Game__c> gamesByPreviousRound, Tournament__c currentTournament);
}