public with sharing class PlayerTournamentController {

	public Boolean isAlreadyApplied { get; set; }

	public PlayerTournamentController() {
		String tp = ApexPages.currentPage().getParameters().get('tp');
	}

	public PageReference apply() {
		String tp = ApexPages.currentPage().getParameters().get('tp');
		return null;
	}

}