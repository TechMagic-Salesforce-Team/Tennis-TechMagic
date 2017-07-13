public with sharing class TournamentController {
    
    public Tournament__c searchTournament {get; set;}
    public List<TournamentWrapper> allTournaments {get; private set;}
    
    public String currentTournamentId {get; set;}
    public Tournament__c currentTournament {get; set;}
    
    public String currentPlayerId {get; set;}
    public Player__c currentPlayer {get; set;}
    
    public String url {get; set;}
    
    public TournamentController() {
        searchTournament = new Tournament__c();
        url = ApexPages.currentPage().getUrl();
        findAll();
        if (url.containsIgnoreCase('Player')) {
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
    
    public PageReference save() {
        try {
            upsert(currentTournament);
            return Page.Tournaments;
        } catch (System.DmlException e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    public void view() {
        for (TournamentWrapper tW : allTournaments) {
            if (tW.tournament.Id == currentTournamentId) {
                tW.isShowed = tW.isShowed ? false : true;
            }
        }
    }
    
    public PageReference editUpcoming() {
        currentTournament = findById();
        if (currentTournament != null) {
            if (currentTournament.Status__c == 'Upcoming') {
                Pagereference pageRef = Page.EditTournament;
                pageRef.getParameters().put('tournamentId', currentTournament.Id);
                return pageRef;
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
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 
                        'You have just deleted the tournament!'));
                } catch(System.DmlException e) {
                    ApexPages.addMessages(e);
                }
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 
                    'You can not delete this tournament as it is ' + currentTournament.Status__c));
            }
        }
    }
    
    public PageReference checkTournamentExistance() {
        // NEED to check if user is logged in and manager
        currentTournamentId = ApexPages.currentPage().getParameters().get('tournamentId');
        if (currentTournamentId != null) {
            currentTournament = findById();
            if (currentTournament != null) {
                return null;
            }
        }
        // better to replace tournaments page with some error page
        return Page.Tournaments;
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
        List<Tournament__c> tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c 
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
                for (Tournament__c t : tournaments) {
                    if (t.Id == id) {
                        appliedTournaments.add(t);
                        break;
                    }
                }
            }
            tournaments = appliedTournaments;
        }
        allTournaments = new List<TournamentWrapper>();
        for (Tournament__c t : tournaments) {
            TournamentWrapper tW = new TournamentWrapper();
            tW.tournament = t;
            tW.isShowed = false;
            allTournaments.add(tW);
        }
        System.debug(allTournaments);
    }
    
    public class TournamentWrapper {
        public Tournament__c tournament {get; set;}
        public Boolean isShowed {get; set;}
    }
   
}