@isTest
public with sharing class GameController_Test{
    @isTest private static void testInsert(){
        Tournament__C tournament = new Tournament__c(name='ddd',format__c = '1 x 1',StartDate__c = Datetime.now(),Status__c='Current',type__c= 'Round Robin');  
        insert tournament;
        Player__c newPlayer1 = new Player__c(name = 'newPlayer1',email__c = 'dd@ddd.dd',IsManager__c=false,Password__c = '666666666',Status__c = 'Active');
        insert newPlayer1;
        Player__c newPlayer2 = new Player__c(name = 'newPlayer2',email__c = 'ddd@ddd.dd',IsManager__c=false,Password__c = '666666666',Status__c = 'Active');
        insert newPlayer2;
        Player__c newPlayer3 = new Player__c(name = 'newPlayer3',email__c = 'ddddd@ddd.dd',IsManager__c=false,Password__c = '666666666',Status__c = 'Active');
        insert newPlayer3;
        PlayerTournament__c playerTournament1 = new PlayerTournament__c();
        playerTournament1.Player__c = newPlayer1.Id;
        playerTournament1.Tournament__c = tournament.Id;
        insert playerTournament1;
        PlayerTournament__c playerTournament2 = new PlayerTournament__c();
        playerTournament2.Player__c = newPlayer2.Id;
        playerTournament2.Tournament__c = tournament.Id;
        insert playerTournament2;
        PlayerTournament__c playerTournament3 = new PlayerTournament__c();
        playerTournament3.Player__c = newPlayer3.Id;
        playerTournament3.Tournament__c = tournament.Id;
        insert playerTournament3;
        Game__c currentGame1 = new Game__c(FirstCompetitor__c = newPlayer1.id+'',SecondCompetitor__c=newPlayer2.id+'',Tournament__c =tournament.id);
        insert currentGame1;
        Test.setCurrentPageReference(new PageReference('Page.Gane')); 
        System.currentPageReference().getParameters().put('id', currentGame1.Id);
        Cookie playerFromCookie = new Cookie('PlayerFromCookie', newPlayer1.Id, null, 1440, false);
        System.currentPageReference().setCookies(new Cookie[]{playerFromCookie});
        GameController g = new GameController();
        Test.startTest();
        g.insertScore();
        g.submitScore();
        Test.stopTest();
    }
    
    @isTest private static void getNameById_Test(){
        Tournament__C tournament = new Tournament__c(name='ddd',format__c = '1 x 1',StartDate__c = Datetime.now(),Status__c='Current',type__c= 'Round Robin');  
        insert tournament;
        Player__c newPlayer1 = new Player__c(name = 'newPlayer1',email__c = 'dd@ddd.dd',IsManager__c=false,Password__c = '666666666',Status__c = 'Active');
        insert newPlayer1;
        Game__c currentGame1 = new Game__c(FirstCompetitor__c = newPlayer1.id+'',SecondCompetitor__c='adsfadsf',Tournament__c =tournament.id);
        insert currentGame1;
        PlayerTournament__c playerTournament1 = new PlayerTournament__c();
        playerTournament1.Player__c = newPlayer1.Id;
        playerTournament1.Tournament__c = tournament.Id;
        insert playerTournament1;
        Test.setCurrentPageReference(new PageReference('Page.Gane')); 
        System.currentPageReference().getParameters().put('id', currentGame1.Id);
        Cookie playerFromCookie = new Cookie('PlayerFromCookie', newPlayer1.Id, null, 1440, false);
        System.currentPageReference().setCookies(new Cookie[]{playerFromCookie});
        GameController g = new GameController();
        System.assertEquals('newPlayer1',g.getNameById(newPlayer1.id+''));
       
    }
}