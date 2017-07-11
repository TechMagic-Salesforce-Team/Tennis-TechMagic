public with sharing class HomeController {
    public Tournament__c tournamentBySelectOption{
        get{
            if(tournamentBySelectOption == null) tournamentBySelectOption = new Tournament__c();
            return tournamentBySelectOption;
        }
        set;
    }
    public Tournament__c selectedTournament{
        get{
            if (selectedTournament == null) selectedTournament = new Tournament__c();
            return selectedTournament;
        }
        set;
    }
    public List<Tournament__c> tournamentsInProgress{get;set;}
    public Cookie playerCookie{get; set;}
    public boolean statusPlayer{get; set;}
    public boolean checkPlayerCookie{get; set;}
    public Player__c currentPlayer {
        get {
            if (currentPlayer == null)
                currentPlayer = new Player__c();
                return currentPlayer;
            }
        set;
    }
    
    public List<SelectOption> playersOptions{
        get{
            if (playersOptions == null) {
                playersOptions = new List<SelectOption>();
            }
            Set<Tournament__c> thisTournaments = new Set<Tournament__c>();
            thisTournaments.addAll(getAllTournamentsInProgress());
            for(Tournament__c thisTournament : thisTournaments){
                SelectOption SO = new SelectOption(thisTournament.Id, thisTournament.Name);
                playersOptions.add(SO);
            }
            return playersOptions;
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
    
    public void rerenderPageBlockForSelectedTournament(){
       // tournamentBySelectOption = [Select ID, Name, StartDate__c, Type__c, Status__c, Format__c From Tournament__c Where Id = :selectedTournament.Id];        
    }
       
}