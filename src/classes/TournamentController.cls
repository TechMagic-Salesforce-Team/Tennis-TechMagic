public with sharing class TournamentController {
    
    public Tournament__c searchTournament {get; set;}
    public List<Tournament__c> allTournaments {get; private set;}
    public Integer allTournamentsSize {get; private set;}
    
    public String currentTournamentId {get; set;}
    public Tournament__c currentTournament {get; set;}
    
    public String currentPlayerId {get; set;}
    public Player__c currentPlayer {get; set;}
    
    public String url {get; set;}
    
    public TournamentController() {
        searchTournament = new Tournament__c();
        url = ApexPages.currentPage().getUrl();
        if (url.containsIgnoreCase('Tournaments')) {
            findAll();
        } else if (url.containsIgnoreCase('ViewTournament') || url.containsIgnoreCase('EditTournament')) {
            currentTournamentId = ApexPages.currentPage().getParameters().get('tournamentId');
            if (currentTournamentId != null) {
                currentTournament = findById();
            }
        } else if (url.containsIgnoreCase('Player')) {
            currentPlayerId = ApexPages.currentPage().getParameters().get('playerId');
            if (currentPlayerId != null) {
                List<Player__c> players = [SELECT Id FROM Player__c WHERE Id = :currentPlayerId];
                if (players.size() > 0) {
                    currentPlayer = players[0];
                    findAll();
                }
            }
        }
    }
    
    public PageReference view() {
        currentTournament = findById();
        if (currentTournament != null) {
            return new PageReference('/apex/ViewTournament?tournamentId=' + currentTournamentId);
        }
        return null;
    }
    
    public PageReference editUpcoming() {
        currentTournament = findById();
        if (currentTournament != null) {
            if (currentTournament.Status__c == 'Upcoming') {
                return new PageReference('/apex/EditTournament?tournamentId=' + currentTournamentId);
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 
                    'You can not edit this tournament as it is ' + currentTournament.Status__c));
            }
        }
        return null;
    }
    
    public void deleteUpcoming() {
        currentTournament = findById();
        if (currentTournament != null) {
            if (currentTournament.Status__c == 'Upcoming') {
                try {
                    delete(currentTournament);
                    findAll();
                } catch(System.DmlException e) {
                    ApexPages.addMessages(e);
                }
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 
                    'You can not delete this tournament as it is ' + currentTournament.Status__c));
            }
        }
    }
    
    private Tournament__c findById() {
        List<Tournament__c> tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c
            FROM Tournament__c
            WHERE Id = :currentTournamentId];
        if (tournaments.size() > 0) {
            return tournaments[0];
        }
        return null;
    }
    
    public void findAll() {
        String tName = searchTournament.Name == null ? '%' : '%' + searchTournament.Name + '%';
        String tType = searchTournament.Type__c == null ? '%' : searchTournament.Type__c;
        String tFormat = searchTournament.Format__c == null ? '%' : searchTournament.Format__c;
        String tStatus = searchTournament.Status__c == null ? '%' : searchTournament.Status__c;
        allTournaments = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c 
            FROM Tournament__c
            WHERE Name LIKE :tName AND Type__c LIKE :tType AND Format__c LIKE :tFormat 
            AND Status__c LIKE :tStatus];
        if (url.containsIgnoreCase('Player') && !url.containsIgnoreCase('Tournaments') && currentPlayerId != null && currentPlayer != null) {
            // find all the tournamnets the current player is applied to
            List<PlayerTournament__c> playerTournamnets = [SELECT Tournament__c 
                FROM PlayerTournament__c WHERE Player__c = :currentPlayerId];
            List<Team__c> teams = [SELECT Tournament__c 
                FROM Team__c 
                WHERE IsComplete__c = true AND Id IN 
                (SELECT Team__c FROM PlayerTeam__c WHERE Player__c = :currentPlayerId)];
            List<String> tournamentIds = new List<String>();
            for (PlayerTournament__c pt : playerTournamnets) {
                tournamentIds.add(pt.Tournament__c);
            }
            for (Team__c t : teams) {
                tournamentIds.add(t.Tournament__c);
            }
            List<Tournament__c> appliedTournaments = new List<Tournament__c>();
            for (String id : tournamentIds) {
                for (Tournament__c t : allTournaments) {
                    if (t.Id == id) {
                        appliedTournaments.add(t);
                        break;
                    }
                }
            }
            allTournaments = appliedTournaments;
        }
        allTournamentsSize = allTournaments.size();
    }
   
}