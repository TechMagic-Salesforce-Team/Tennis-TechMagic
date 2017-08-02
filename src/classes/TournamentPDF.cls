public with sharing class TournamentPDF extends TournamentController{

    public Tournament__c pdfCurrentTournament{get;set;}
    private Map<String, String> competitorsMap{get;set;}
    public List<String> competitorsName{get;set;}
    public String myURL{get;set;}
    
    public TournamentPDF(){
        if(ApexPages.currentPage().getParameters().get('id') !=null){
            List<Tournament__c> correctTournamentId = new List<Tournament__c>();    
            correctTournamentId =  [SELECT ID,Name, Status__c, Format__c, Type__c, StartDate__c FROM Tournament__c WHERE ID = :ApexPages.currentPage().getParameters().get('id')];
            if(correctTournamentId !=null && correctTournamentId.size()>0) pdfCurrentTournament = correctTournamentId.get(0);
        }else{pdfCurrentTournament = new Tournament__c();}
        
        if(pdfCurrentTournament !=null && pdfCurrentTournament.Type__c !=null){
            if(pdfCurrentTournament.Status__c !='Completed'){
                if(competitorsName == null) competitorsMap = Helper.getIdAndNameMap(pdfCurrentTournament);
                }else{competitorsMap = new Map<String, String>();}
                competitorsName = new List<String>();
                if(competitorsMap.size()>0){
                    for(String x : competitorsMap.values()){
                        if(x != '-' && x != '?') competitorsName.add(x);
                    }
                }
            }
            else{
                competitorsName = new List<String>();
                competitorsName = getFinalResultForSingleEliminationTournament(pdfCurrentTournament);
            }
        myURL = (''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0];
    } 
    
    private List<String> getFinalResultForSingleEliminationTournament(Tournament__c currentTournament){
        if(currentTournament !=null && currentTournament.Type__c == 'Single Elimination' && currentTournament.Status__c == 'Complete'){
            List<Game__c> allGamesForCurrentTournament = [Select Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, SecondCompetitorScore__c From Game__c Where Tournament__c = :currentTournament.Id ORDER BY Stage__c];
            Decimal maxStage = allGamesForCurrentTournament.get(allGamesForCurrentTournament.size()-1).Stage__c;
            List<Decimal> Stages = new List<Decimal>();
            for(Decimal stage = 1; stage == maxStage; stage++){
                Stages.add(stage);
            }
            List<String> finalCompetitorsResult = new List<String>();
            Map<String, String> finalCompetitorsMap = new Map<String, String>();
            
            if(pdfCurrentTournament.Format__c == '1 x 1'){
                List<PlayerStatistics__c> PlayerStatistic = new List<PlayerStatistics__c>();
                PlayerStatistic = [Select CountLostGames__c, CountLostSets__c, CountWonGames__c, CountWonSets__c, Player__r.Name, Tournament__c From PlayerStatistics__c Where Tournament__c = :pdfCurrentTournament.Id];
                for(PlayerStatistics__c x : PlayerStatistic){
                    if(x.Player__r.Name != '-' && x.Player__r.Name != '?') {finalCompetitorsResult.add('Player : ' + x.Player__r.Name + 
                                                                            ' - Won Games: ' + x.CountWonGames__c + ', Lost Games: ' + x.CountLostGames__c +
                                                                            ', Won Sets: ' + x.CountWonSets__c + ', Lost Sets: ' + x.CountLostSets__c);}
                }
            }
            
            else{
                for(String x : finalCompetitorsMap.values()){
                    
                    if(x != '-' && x != '?'){
                        finalCompetitorsResult.add(x);
                    }
                }
            }
            return finalCompetitorsResult;    
        }else{return new List<String>();}
    }
           
}