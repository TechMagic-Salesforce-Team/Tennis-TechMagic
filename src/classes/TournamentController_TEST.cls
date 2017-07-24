@isTest
public with sharing class TournamentController_TEST {

    public static TournamentController tC =  new TournamentController();
    public static Tournament__c t = new Tournament__c(Name='qwer', Type__c='Single Elimination', Format__c='1 x 1', StartDate__c=DateTime.now());
    public static Tournament__c t1 = new Tournament__c(Name='qwer', Type__c='', Format__c='1 x 1', StartDate__c=DateTime.now());

    
    public static testMethod void testSave() {
        tC.currentTournament = t;
        tC.save();
        tC.currentTournament = t1;
        tC.save();
        
        Test.startTest();
        
        //first succesfully inserted
        List<Tournament__c> ts = [SELECT Id FROM Tournament__c];
        System.assertEquals(1, ts.size());

        //second succesfully inserted        
        t1.Type__c = 'Double Elimination';
        tC.currentTournament = t1;
        tC.save();
        ts = [SELECT Id FROM Tournament__c];
        System.assertEquals(2, ts.size());
        
        
        //first succesfully edited
        t.Name='fhbsdf';
        tC.currentTournament = t;
        tC.save();
        ts = [SELECT Id FROM Tournament__c];
        System.assertEquals(2, ts.size());
        Test.stopTest();
    }
    
    public static testMethod void testFindByIdAndEditAndDelete(){
        t.Status__c = 'Upcoming';
        insert(t);
        tC.currentTournamentId = t.Id;
        
        Test.startTest();
        
        tC.editUpcoming();
        System.assertEquals(t.Id, tC.currentTournament.Id);
        
        List<Tournament__c> ts = [SELECT Id FROM Tournament__c];
        System.assertEquals(1, ts.size());
        
        tC.deleteUpcoming();
        System.assertEquals(t.Id, tC.currentTournament.Id);
        
        ts = [SELECT Id FROM Tournament__c];
        System.assertEquals(0, ts.size());
        
        Test.stopTest();
    }
    
    public static testMethod void testCheckTourExistance(){
        t.Status__c = 'Upcoming';
        insert t;
        Test.setCurrentPageReference(new PageReference('Page.EditTournament')); 
        System.currentPageReference().getParameters().put('tournamentId', t.Id);
        Player__c p = new Player__c(Email__c = 'vdv@vdv.dv', IsManager__c = true, Password__c = '1234567890', Name = 'bdf', Status__c = 'Active');
        insert (p);
        List<Player__c> players = [select Id,Password__c from Player__c where Email__c =: p.Email__c limit 1];
        System.debug(players);
        Cookie playerFromCookie = new Cookie('PlayerFromCookie', players.get(0).Id, null, 1440, false);
        System.currentPageReference().setCookies(new Cookie[]{playerFromCookie});
        TournamentController tC1 =  new TournamentController();
        
        Test.startTest();
        
        tC1.checkTournamentExistance();
        
        System.assertEquals(t.Id, tC1.currentTournament.Id);
        
        Test.stopTest();
    }
    
    public static testMethod void testFindAll(){
        tC.currentTournament = t;
        tC.save();
        t1.Type__c = 'Double Elimination';
        tC.currentTournament = t1;
        tC.save();
        
        Test.startTest();
        
        List<Tournament__c> ts = [SELECT Id FROM Tournament__c];
        System.assertEquals(2, ts.size());
        
        System.assertEquals(null, tC.currentPlayer);
        
        tC.search();
        System.assertEquals(2, tC.allTournaments.size());
        
        System.assertEquals(null, tC.currentPlayerTmp.Id);
        
        tC.searchTournament.Type__c='Single Elimination';
        tC.search();
        System.assertEquals(1, tC.allTournaments.size());
        
        Player__c player = new Player__c();
        player.Name = 'name';
        player.Email__c = 'sv@email.com';
        player.Password__c = 'password'; 
        insert(player);
        
        PlayerTournament__c pT = new PlayerTournament__c(Player__c = player.Id, Tournament__c = t.Id);
        insert(pT);
        
        tC.currentPlayer2 = player;
        tC.search();
        System.assertEquals(1, tC.allTournaments.size());
        System.assertEquals(true, tC.allTournaments[0].isApplied);
        System.assertEquals(false, tC.allTournaments[0].isShowed);
        
        Test.stopTest();        
    }

    public static testMethod void testView(){
        tC.currentTournament = t;
        tC.save();
        t1.Type__c = 'Double Elimination';
        tC.currentTournament = t1;
        tC.save();
        
        tC.search();
        
        tC.currentTournamentId = t.Id;
        
        Test.startTest();
        
        tC.view();
        
        Boolean isTShowed = false;
        
        for (TournamentController.TournamentWrapper tW : tC.allTournaments) {
            if (tW.tournament.Id == t.Id) {
                isTShowed = true;
                break;
            }
        }
        
        System.assertEquals(true, isTShowed);
        
        Test.stopTest();           
    }
}