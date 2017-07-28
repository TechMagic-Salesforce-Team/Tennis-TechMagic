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
                if(competitorsName == null) competitorsMap = Helper.getIdAndNameMap(pdfCurrentTournament);
        }else{competitorsMap = new Map<String, String>();}
        competitorsName = new List<String>();
        if(competitorsMap.size()>0){
            for(String x : competitorsMap.values()){
                if(x != '-') competitorsName.add(x);
            }
        }
        myURL = (''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0];
    } 
    
    private List<String> getFinalResultForSingleEliminationTournament(Tournament__c currentTournament){
        if(currentTournament !=null && currentTournament.Type__c == 'Single Elimination' && currentTournament.Status__c == 'Complete'){
            List<Game__c> allGamesForCurrentTournament = [Select Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, SecondCompetitorScore__c From Game__c Where Tournament__c = :currentTournament.Id];
            
        }else{return new List<String>();}
        return null;    
    
    }
           
}