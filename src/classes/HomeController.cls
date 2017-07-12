public with sharing class HomeController {

    public List<Tournament__c> tournamentsInProgress{get;set;}
    public Integer tournamentsInProgressSize{get;set;}
    public Cookie playerCookie{get; set;}
    public boolean statusPlayer{get; set;}
    public boolean checkPlayerCookie{get; set;}
    public Boolean rend {get; set;}    
    public String selectedTournamentInputName{get;set;}
    public String selectedTournamentType{get;set;}
    public String selectedTournamentFormat{get;set;}
    public Player__c currentPlayer {
        get {
            if (currentPlayer == null)
                currentPlayer = new Player__c();
                return currentPlayer;
            }
        set;
    }
    public Tournament__c tournamentBySelectOption{
        get{
            if(tournamentBySelectOption == null) tournamentBySelectOption = new Tournament__c();
            return tournamentBySelectOption;
        }
        set;
    }
    public String selectedTournament{
        get{
            if (selectedTournament == null) selectedTournament = '';
            return selectedTournament;
        }
        set;
    }
    public List<SelectOption> tournamentOptions{
        get{
            if (tournamentOptions == null) {
                tournamentOptions = new List<SelectOption>();
            }
            Set<Tournament__c> thisTournaments = new Set<Tournament__c>();
            thisTournaments.addAll(getAllTournamentsInProgress());
            for(Tournament__c thisTournament : thisTournaments){
                SelectOption SO = new SelectOption(thisTournament.Id, thisTournament.Name);
                tournamentOptions.add(SO);
            }
            return tournamentOptions;
        }
        set;
    }
    public List<SelectOption> tournamentTypeOptions{
        get{
            if (tournamentTypeOptions== null) {
                tournamentTypeOptions= new List<SelectOption>();
            }
            Set<Tournament__c> thisTournaments = new Set<Tournament__c>();
            thisTournaments.addAll(getAllTournamentsInProgress());
            tournamentTypeOptions.add(new SelectOption('AnyType','Any Type'));
            tournamentTypeOptions.add(new SelectOption('Round Robin','Round Robin'));
            tournamentTypeOptions.add(new SelectOption('Single Elimination','Single Elimination'));
            tournamentTypeOptions.add(new SelectOption('Double Elimination','Double Elimination'));
            return tournamentTypeOptions;
        }
        set;
    }
    public List<SelectOption> tournamentFormatOptions{
        get{
            if (tournamentFormatOptions== null) {
                tournamentFormatOptions= new List<SelectOption>();
            }
            Set<Tournament__c> thisTournaments = new Set<Tournament__c>();
            thisTournaments.addAll(getAllTournamentsInProgress());
            tournamentFormatOptions.add(new SelectOption('AnyFormat','Any Format'));
            tournamentFormatOptions.add(new SelectOption('1 x 1','1 x 1'));
            tournamentFormatOptions.add(new SelectOption('2 x 2','2 x 2'));
            return tournamentFormatOptions;
        }
        set;
    }
    public HomeController(){
        playerCookie = ApexPages.currentPage().getCookies().get('PlayerSession');
        if(playerCookie != null){
             checkPlayerCookie=true; 
             statusPlayer = isManagerPlayer();
             currentPlayer = getPlayer();   
         }
         else{
             checkPlayerCookie=false;
             statusPlayer = false;
         }
         tournamentsInProgress = getAllTournamentsInProgress();
         tournamentBySelectOption = tournamentsInProgress.get(0);
         tournamentsInProgressSize = tournamentsInProgress.size();
    }
    
    public Player__c getPlayer(){
        if(ApexPages.currentPage().getCookies().get('PlayerSession').getValue() !=null){
            List<Player__c> thisPlayerList = [Select Name, Email__c From Player__c Where Id= :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
            if(thisPlayerList.size()>0){
                return thisPlayerList.get(0);
            }return new Player__c();
        }return new Player__c();
    }
    
    public boolean isManagerPlayer(){
         List<Player__c> selectPlayer = new List<Player__c>();
         selectPlayer = [Select Email__c, Status__c, IsManager__c from Player__c 
                         where Id= :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
         if(selectPlayer.size() !=null && selectPlayer.size() >0 && 
            selectPlayer.get(0).Status__c !=null && selectPlayer.get(0).Status__c == 'Active'){
             return selectPlayer.get(0).IsManager__c;
         }else{return false;} 
    }
    
    public List<Tournament__c> getAllTournamentsInProgress(){
        List<Tournament__c> tournaments = [SELECT ID, Name, StartDate__c, Type__c, Status__c, Format__c
                                           FROM Tournament__c Where Status__c = 'Current']; 
        return tournaments;
    }
    
    public Integer allTournamentsInProgressSize(List<Tournament__c> thisTournamentsInProgress){
        if(thisTournamentsInProgress!=null) return thisTournamentsInProgress.size();
        return 0;
    }
    
    public PageReference rerenderPageBlockForSelectedTournament(){
        List<Tournament__c> thisTournament = [SELECT ID, Name, StartDate__c, Type__c, Status__c, Format__c
                                              FROM Tournament__c Where Status__c = 'Current' AND Id = :selectedTournament];
        if(thisTournament.size() !=null && thisTournament.size()>0){
            tournamentBySelectOption = thisTournament.get(0);
        }
        return null;    
    }    
    public PageReference rerenderPageBlockForSelectedTournamentsName(){
        List<Tournament__c> thisTournament = [SELECT ID, Name, StartDate__c, Type__c, Status__c, Format__c
                                              FROM Tournament__c Where Status__c = 'Current' AND Name = :selectedTournament];
        if(thisTournament.size() !=null && thisTournament.size()>0){
            tournamentBySelectOption = thisTournament.get(0);
        }
        return null;    
    }    
    public PageReference rerenderPageBlockForSelectedTournamentsType(){
        List<Tournament__c> thisTournament = [SELECT ID, Name, StartDate__c, Type__c, Status__c, Format__c
                                              FROM Tournament__c Where Status__c = 'Current' AND Type__c = :selectedTournamentType AND Format__c = :selectedTournamentFormat];
        if(thisTournament.size() !=null && thisTournament.size()>0){
            tournamentsInProgress = thisTournament;
        }else{tournamentsInProgress  = new List<Tournament__c>();}
        return null;    
    }    
    public PageReference rerenderPageBlockForSelectedTournamentsFormat(){
        
        List<Tournament__c> thisTournament = [SELECT ID, Name, StartDate__c, Type__c, Status__c, Format__c
                                              FROM Tournament__c Where Status__c = 'Current' AND Format__c = :selectedTournamentFormat AND Type__c = :selectedTournamentType];
        if(thisTournament.size() !=null && thisTournament.size()>0){
            tournamentsInProgress  = thisTournament;
        }else{tournamentsInProgress  = new List<Tournament__c>();}
        return null;    
    }   
}