public with sharing class PlayerTeamController extends PlayerCookie{
    
    public String tournamentId { get; set; }
    
    public Team__c team { get; set; }
    
    public String currentPlayerId { get; set; }
    public List<Player__c> players { get; set; }
    public String selectedPlayer { get; set; }
    
    public LIst<SelectOption> playersOptions { get {
            if (playersOptions == null) {
                playersOptions = new List<SelectOption>();
                List<Team__c> teams = [SELECT Name, (SELECT Player__c FROM PlayerTeams__r)
                FROM Team__c WHERE Tournament__c = :tournamentId];
                for (Player__c p: players) {
                    SelectOption selectOption;
                    for (Team__c t: teams) {
                        for (PlayerTeam__c pT: t.PlayerTeams__r) {
                            if (pT.Player__c == p.Id) {
                                selectOption = new SelectOption(p.Id, p.Name + '(' + t.Name + ')');
                                SelectOption.setDisabled(true);
                                break;
                            }
                        }
                        if (selectOption != null) {
                            break;
                        }
                    }
                    if (selectOption == null) {
                        selectOption = new SelectOption(p.Id, p.Name);
                    }
                    playersOptions.add(selectOption);
                }
            }
            return playersOptions;
        } set; }
    
    public PlayerTeamController() {
        tournamentId = ApexPages.currentPage().getParameters().get('tournamentId');
        currentPlayerId = getCurrentPlayer().Id;
        players = [SELECT Id, Name FROM Player__c WHERE Id != :currentPlayerId AND Status__c = 'Active'];
        team = new Team__c();
    }
    
    public PageReference cancel() {
        return Page.Tournaments;
    }
    
    public PageReference create() {
        // create team;
        team.Tournament__c = tournamentId;
        try {
            insert (team);
        } catch (System.DmlException e) {
            ApexPages.addMessages(e);
            return null;
        }
        
        // create playerTeam objects
        PlayerTeam__c firstPlayerTeam = new PlayerTeam__c();
        firstPlayerTeam.Player__c = currentPlayerId;
        firstPlayerTeam.Team__c = team.Id;
        
        PlayerTeam__c secondPlayerTeam = new PlayerTeam__c();
        secondPlayerTeam.Team__c = team.Id;
        secondPlayerTeam.Player__c = selectedPlayer;

        try {
            insert(firstPlayerTeam);
            insert(secondPlayerTeam);
            sendInvitation(currentPlayerId, selectedPlayer, team.Id);
            return Page.Tournaments;
        } catch (System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }  catch(Exception e) {
            System.debug(e);
        }
        return Page.Tournaments;
    }
    
    public PageReference validatePageVisitor() {
        if (isLoggedIn) {
            List<Tournament__c> tournaments = [SELECT Id, Format__c, Status__c FROM Tournament__c WHERE Id =:tournamentId];
            if (tournaments.size() > 0) {
                if (tournaments[0].Format__c == '2 x 2' && tournaments[0].Status__c == 'Upcoming') {
                    List<Team__c> teams = [SELECT Id FROM Team__c WHERE Tournament__c = :tournamentId AND 
                        Id IN (SELECT Team__c FROM PlayerTeam__c WHERE Player__c = :currentPlayerId)];
                    if (teams.size() == 0) {
                        return null;
                    }
                }
            }
        }
        return Page.Home;
    }
    
    private void sendInvitation(String fromPlayerId, String toPlayerId, String teamId) {
        Player__c fromPlayer = [SELECT Id, Name FROM Player__c WHERE Id = :fromPlayerId];
        Player__c toPlayer = [SELECT Id, Name, Email__c FROM Player__c WHERE Id = :toPlayerId];
        Team__c team = [SELECT Id, Name, Tournament__r.Name FROM Team__c WHERE Id = :teamId];
        
        
    }
}