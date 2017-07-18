public with sharing class TournamentController {
    
    public String currentTournamentId {get; set;}
    public Tournament__c currentTournament {get; set;}
    
    public Player__c currentPlayer {get; set;}
    public Player__c currentPlayerTmp {get; set;}
    
    public Tournament__c searchTournament {get; set;}
    public List<TournamentWrapper> allTournaments {get; private set;}
    
    public TournamentController() {
        searchTournament = new Tournament__c();
        currentTournament = new Tournament__c();
    }
    
    public PageReference save() {
        try {
            currentTournament.Status__c = 'Upcoming';
            upsert(currentTournament);
            return Page.Tournaments;
        } catch (System.DmlException e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    public PageReference cancel() {
        return Page.Tournaments;
    }
    
    public void view() {
        for (TournamentWrapper tW : allTournaments) {
            if (tW.tournament.Id == currentTournamentId) {
                tW.isShowed = tW.isShowed ? false : true;
            }
        }
    }
    
    public void apply() {
        
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
    
    public void search() {
        allTournaments = findAll();
    }
    
    public List<TournamentWrapper> findAll() {
        String tName = searchTournament.Name == null ? '%' : '%' + searchTournament.Name + '%';
        String tType = searchTournament.Type__c == null ? '%' : searchTournament.Type__c;
        String tFormat = searchTournament.Format__c == null ? '%' : searchTournament.Format__c;
        String tStatus = searchTournament.Status__c == null ? '%' : searchTournament.Status__c;

        List<TournamentWrapper> result = new List<TournamentWrapper>();
        
        List<Tournament__c> tournaments;
        List<String> tournamentIds;

        if (currentPlayer == null) {
            currentPlayerTmp = PlayerCookie.getCurrentPlayer();
            tournamentIds = getAllAppliedTournamentIds();
            tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c 
                FROM Tournament__c
                WHERE Name LIKE :tName AND Type__c LIKE :tType AND Format__c LIKE :tFormat 
                AND Status__c LIKE :tStatus];
        } else {
            currentPlayerTmp = currentPlayer;
            tournamentIds = getAllAppliedTournamentIds();
            tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c 
                FROM Tournament__c
                WHERE Name LIKE :tName AND Type__c LIKE :tType AND Format__c LIKE :tFormat 
                AND Status__c LIKE :tStatus AND Id IN :tournamentIds];
        }
        
        System.debug(currentPlayer);
        System.debug(tournaments.size());
        
        for (Tournament__c t : tournaments) {
            TournamentWrapper tW = new TournamentWrapper();
            tW.tournament = t;
            tW.isShowed = false;
            tW.isApplied = false;
            for (String id : tournamentIds) {
                if (t.Id == id) {
                    tW.isApplied = true;
                    break;
                }
            }
            result.add(tW);
        }
        return result;
    }
    
    private List<String> getAllAppliedTournamentIds() {
        List<PlayerTournament__c> playerTournamnets = [SELECT Tournament__c 
                FROM PlayerTournament__c WHERE Player__c = :currentPlayerTmp.Id];
        List<Team__c> teams = [SELECT Tournament__c 
            FROM Team__c 
            WHERE IsComplete__c = true AND Id IN 
            (SELECT Team__c FROM PlayerTeam__c WHERE Player__c = :currentPlayerTmp.Id)];
        
        List<String> tournamentIds = new List<String>();
        
        for (PlayerTournament__c pt : playerTournamnets) {
            tournamentIds.add(pt.Tournament__c);
        }
        for (Team__c t : teams) {
            tournamentIds.add(t.Tournament__c);
        }
        return tournamentIds;
    }
    
    public class TournamentWrapper {
        public Tournament__c tournament {get; set;}
        public Boolean isShowed {get; set;}
        public Boolean isApplied {get; set;}
    }
   
}