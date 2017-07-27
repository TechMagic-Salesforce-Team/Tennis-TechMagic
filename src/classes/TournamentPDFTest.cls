@isTest
public with sharing class TournamentPDFTest{

    public static testMethod void propertieTest(){
        Tournament__c myPDFTournament = new Tournament__c(Name ='PDF', Type__c='Single Elimination', Format__c = '1 x 1', StartDate__c = Datetime.now());
        insert myPDFTournament;
        ApexPages.currentPage().getHeaders().put('id', myPDFTournament.Id);

        
    }
    
}