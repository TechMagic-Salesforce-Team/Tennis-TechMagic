@isTest
public with sharing class RoundRobinTest {  
    @isTest private static void getNameByIdTestbyPlayer(){
        RoundRobin roundRobin = new RoundRobin();
        Player__c newPlayer = new Player__c(name = 'dd',email__c = 'dd@dd.dd',IsManager__c=false,Password__c = '666',Status__c = 'Active');
        insert newPlayer;
        List<Player__c> player = [Select id from Player__c where name = 'dd'];
        System.assertEquals('dd', roundRobin.getNameById(player.get(0).id));
    }
    
    @isTest private static void getNameByIdTestbyTeam(){
        RoundRobin roundRobin = new RoundRobin();
        Tournament__C tournament = new Tournament__c(name='newTour',format__c = '1 x 1',StartDate__c = Datetime.now(),Status__c='Current',type__c= 'Round Robin');
        insert tournament;
        Team__c team = new Team__c(name='bigDogTeam',tournament__c = tournament.id);
        insert team;
        List<Team__c> teams = [Select id from Team__c where name = 'bigDogTeam'];
        System.assertEquals('bigDogTeam', roundRobin.getNameById(teams.get(0).id));
    }

}


