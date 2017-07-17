public with sharing class PlayerController extends PlayerCookie{
    public List<Player__c> players {get;set;}
    public Player__c player {get{
          return player;
        }
        set;}
    public String confirmPassword {get;set;}
    public Boolean registrationPage {get;set;} 
    public List<Tournament__c> tournamentsOfPlayer {get;set;}
    public List<Tournament__c> currentTournamentsOfPlayer {get;set;}
    public List<Game__c> gamesOfCurrentPlayerInSelectedTournament {get;set;}
    public Tournament__c currentTournament {get;set;}
    public String currentTournamentId {get;set;}
    
    
    public PlayerController(){
        findPlayer();
    }
    
    
    
    public PageReference registration() {
        List<ApexPages.message> errorMessages = new List<ApexPages.message>();
        try {
            Integer parseNameToInteger = Integer.valueOf(player.Name);
            errorMessages.add(new ApexPages.message(ApexPages.severity.ERROR,'Name can not be number'));
        } catch (TypeException ex){}
        
        if (errorMessages.size()==0){
            if (player.Password__c==confirmPassword){
                try{
                    insert player;
                } catch(DmlException ex){
                    errorMessages.add(new ApexPages.message(ApexPages.severity.ERROR,ex.getDmlMessage(0)));
                }
         } else {
            errorMessages.add(new ApexPages.message(ApexPages.severity.ERROR,'Passwords are not the same'));
           }
        }
        if (errorMessages.size()>0){
            for (ApexPages.message mess: errorMessages){
                ApexPages.addMessage(mess);
            }
            return null;
        }
        return Page.Test;
    }
    
    public PageReference login(){
        List<Player__c> players = [select Id,Password__c from Player__c where Email__c =: player.Email__c limit 1];
        if (players != null && players.size()>0){
            if (players.get(0).Password__c==player.Password__c) {
                Cookie playerFromCookie = new Cookie('PlayerFromCookie', players.get(0).Id, null, 1440, false);
                ApexPages.currentPage().setCookies(new Cookie[]{playerFromCookie});
                return Page.Test;
            } else {
                 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Wrong password'));
                 return null; 
              }
           } else {
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No users found with the same email'));
             return null;
           }
        return Page.Test;
    }
    
    
    public PageReference logout(){
        Cookie playerFromCookie = new Cookie('PlayerFromCookie', '', null, 0, false);
        ApexPages.currentPage().setCookies(new Cookie[]{playerFromCookie});
        return Page.Test;
    }
    
    
    public void findAllPlayers(){
        players = [select Id,Name,Email__c from Player__c];
    }
    
    public void getPlayerTournaments(){
        currentTournamentsOfPlayer = new List<Tournament__c>();
        if (player==null) return;
        
        List<Team__c> teamsOfPlayer = [select Id from Team__c where Id in (select Team__c from PlayerTeam__c where Player__c =:player.Id)];
        
        tournamentsOfPlayer = [select Id,Name,Status__c,Format__c,Type__c,StartDate__c from 
        Tournament__c where Id in (select Tournament__c from PlayerTournament__c where 
        Player__c=:player.Id)];
        
        
        List<Tournament__c> teamTournamentOfPlayer = 
        [select Id,Name,Status__c,Format__c,Type__c,StartDate__c from Tournament__c 
        where Id in (select Tournament__c from Team__c where Id in: teamsOfPlayer)];
        
        for (Tournament__c tournament: teamTournamentOfPlayer){
            tournamentsOfPlayer.add(tournament);
        }
        
        for (Tournament__c tournament: tournamentsOfPlayer){
            if (tournament.Status__c=='Current'){
                currentTournamentsOfPlayer.add(tournament);
            }
        }
    }
    
    public List<SelectOption> getCurrentTournamentsOptions() {
 	 List<SelectOption> options = new List<SelectOption>();
         for (Tournament__c tournament: currentTournamentsOfPlayer){
            options.add(new SelectOption(tournament.Id,tournament.Name+' format: '+tournament.Format__c));
         }
        
         if (options.size()>0){
            currentTournamentId = options.get(0).getValue();
         }
        
 	 return options;
    }
    
    public PageReference getCurrentTournamentById(){
        if (currentTournamentId==null) return null;
        List<Tournament__c> tournaments = [select Id,Name,Status__c,Format__c,Type__c from Tournament__c where Id =: currentTournamentId limit 1];
        currentTournament = tournaments.size()>0?tournaments.get(0):null;
        return null;
    }
    
    
    public void getGamesOfCurrentTournamentForPlayer(){
        if (currentTournament==null) return;
        gamesOfCurrentPlayerInSelectedTournament = 
        [select FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, SecondCompetitorScore__c,Stage__c
        from Game__c where Tournament__c =: currentTournament.Id and (FirstCompetitor__c =: player.Id or 
        SecondCompetitor__c =: player.Id)
        ];
    }
    
    public void findPlayer(){
        Map<String,String> apexPageParams = new Map<String,String>();
        apexPageParams.put('pageType',ApexPages.currentPage().getParameters().get('pageType'));
        apexPageParams.put('playerId',ApexPages.currentPage().getParameters().get('playerId'));
        
        if (apexPageParams.get('pageType')!=null){
            String pageType = apexPageParams.get('pageType');
            player = new Player__c();
        if (pageType=='registration'){
            registrationPage = true;
        } else if (pageType=='login'){
            registrationPage = false;
          }
       } else if (apexPageParams.get('playerId')!=null){
            String idPlayer = apexPageParams.get('playerId');
            player = [select Id,Name,Email__c,Password__c from Player__c where Id=:idPlayer limit 1];
            getPlayerTournaments();
       } 
    }
}