@isTest
public class SingleEliminationTournamentTest{
    
     public static testMethod void propertiesTest(){
         Tournament__c t = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         Player__c myPlayer = new Player__c(Name = 'MyName' , Password__c ='zxcvcz' , Email__c = 'www@gmail.com');
         insert t;
         insert myPlayer;
         SingleEliminationTournament thisSET = new SingleEliminationTournament();
         System.assertEquals(1,thisSET.ijz);
         List<String> myIds = new List<String>();
         myIds.add('1');
         myIds.add('2');
         myIds.add('3');
         myIds.add('4');
         myIds.add('5');
         myIds.add('6');
         thisSET.StartSingleEliminationTournament(myIds, t);
         Integer gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(4,gamesCount);
         myIds.add('7');
         thisSET.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(8,gamesCount);
         myIds.add('8');
         thisSET.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(12,gamesCount);
         myIds.add('9');
         thisSET.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(20,gamesCount);
         myIds.add('10');
         thisSET.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(28,gamesCount);
         myIds.add('11');
         myIds.add('12');
         myIds.add('13');
         myIds.add('14');
         myIds.add('15');
         myIds.add('16');
         myIds.add('17');
         thisSET.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(44,gamesCount);

     } 
    
}