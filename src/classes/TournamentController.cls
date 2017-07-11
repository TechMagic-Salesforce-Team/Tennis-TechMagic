public with sharing class TournamentController {
    
    public Tournament__c searchTournament {get; set;}
    public List<Tournament__c> allTournaments {get; private set;}
    public Integer allTournamentsSize {get; private set;}
    
    public String currentTournamentId {get; set;}
    public Tournament__c currentTournament {get; set;}
    
    public TournamentController() {
        searchTournament = new Tournament__c();
    }
    
    public PageReference view() {
        currentTournament = findById();
        if (currentTournament != null) {
            //return Page.editTournament.setAnchor(currentTournament.Id);
        }
        return null;
    }
    
    public PageReference editUpcoming() {
        currentTournament = findById();
        if (currentTournament != null) {
            if (currentTournament.Status__c == 'Upcoming') {
                //return Page.editTournament.setAnchor(currentTournament.Id);
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
        allTournamentsSize = allTournaments.size();
    }
   
}


