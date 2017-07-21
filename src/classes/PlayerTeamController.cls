public with sharing class PlayerTeamController extends PlayerCookie{
    
    public PlayerTeam__c playerTeam { get; set; }
    public Team__c team { get; set; }
    
    public String currentPlayerId { get; set; }
    public List<Player__c> players { get; set; }
    public String selectedPlayer { get; set; }
    
    public LIst<SelectOption> playersOptions {get {
		if (playersOptions == null) {
			playersOptions = new List<SelectOption>();
			String tournamentId = ApexPages.currentPage().getParameters().get('tournamentId');
			List<Team__c> teams = [SELECT Name, (SELECT Player__c FROM PlayerTeams__r)
                            FROM Team__c WHERE Tournament__c = :tournamentId];
			for (Player__c p : players) {
				SelectOption selectOption;
				for (Team__c t : teams) {
					for (PlayerTeam__c pT : t.PlayerTeams__r) {
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
	} set;}
    
    public PlayerTeamController() {
        currentPlayerId = getCurrentPlayer().Id;
        players = [SELECT Id, Name FROM Player__c WHERE Id != :currentPlayerId AND Status__c = 'Active'];
    }
    
}