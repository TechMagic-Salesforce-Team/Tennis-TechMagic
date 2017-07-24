@isTest
public class SingleEliminationTournamentTest{
    
     public static testMethod void propertiesTest(){
         
         //Right Parameters For players
         Tournament__c t = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         Player__c myPlayer = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'www@gmail.com');
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
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         Integer gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(4,gamesCount);
         myIds.add('7');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(8,gamesCount);
         myIds.add('8');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(12,gamesCount);
         myIds.add('9');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(20,gamesCount);
         myIds.add('10');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(28,gamesCount);
         myIds.add('11');
         myIds.add('12');
         myIds.add('13');
         myIds.add('14');
         myIds.add('15');
         myIds.add('16');
         myIds.add('17');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(44,gamesCount);
     
         //Wrong Parameters, and method get DMLException
         Tournament__c t2 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Double Elimination', Status__c = 'Current', Name = 'MyTournament3');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t2);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(44,gamesCount);
          
     } 
     
     public static testMethod void generateSingleEliminationStageGridTest(){
         //Test when method get right Parameters
         Tournament__c t = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         insert t;
         List<List<Game__c>> thisListListGames = new List<List<Game__c>>();
         List<Game__c> thisListGames = new List<Game__c>();
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=t.id)
         );         
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=t.id)
         );         
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=t.id)
         );         
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=t.id)
         );         
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=3, Tournament__c=t.id)
         );
         insert thisListGames;    
         SingleEliminationTournament thisSET = new SingleEliminationTournament();
         System.assertEquals(null,thisSET.oneTournament);
         thisSet.oneTournament = t;
         System.assertEquals(t.id,thisSet.oneTournament.id);
         thisListListGames = thisSET.generateSingleEliminationStageGrid(t);
         thisSET.representSingleEliminationGrid = thisSET.generateSingleEliminationStageGrid(thisSET.oneTournament);
         System.assertEquals(3, thisListListGames.size());
         System.assertEquals(thisSET.representSingleEliminationGrid.size(), thisListListGames.size());
         Integer countGames = 0;
         for(List<Game__c> eachListGame : thisSET.representSingleEliminationGrid){
             for(Game__c ecahGame : eachListGame){
                 countGames++;
             }
         }
         System.assertEquals(7, countGames); 
         
         //Test when method get wrong Parameters(Wrong Type)
         Tournament__c tWrong = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Current', Name = 'MyTournament');
         insert tWrong ;
         List<List<Game__c>> wrongTestList = thisSET.generateSingleEliminationStageGrid(tWrong);
         System.assertEquals(0,wrongTestList.size());
         //Invalid Parameter Format
         Tournament__c tWrongFormat = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 2', Type__c = 'Round Robin', Status__c = 'Current', Name = 'MyTournament');
         try{
             insert tWrong;
             List<List<Game__c>> wrongTestListFormat = thisSET.generateSingleEliminationStageGrid(tWrongFormat);
             System.assertEquals(0,wrongTestListFormat.size());
         }
         catch(DMLException e){}
         
         //One Game             
         Tournament__c tOneParameter = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament');
         insert tOneParameter;
         upsert new Game__c(FirstCompetitor__c='zxc1', SecondCompetitor__c='cxz1', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         SingleEliminationTournament thisSETOneParameter = new SingleEliminationTournament();
         System.assertEquals(null,thisSETOneParameter.oneTournament);
         thisSETOneParameter.oneTournament = tOneParameter;
         System.assertEquals(tOneParameter.id,thisSETOneParameter.oneTournament.id);
         List<List<Game__c>> ListByOneGame = new List<List<Game__c>>();
         ListByOneGame = thisSETOneParameter.generateSingleEliminationStageGrid(tOneParameter);
         System.assertEquals(1, ListByOneGame.size());
         Integer countGamesByOneGames = 0;
         for(List<Game__c> eachListGame : thisSETOneParameter.representSingleEliminationGrid){
             for(Game__c ecahGame : eachListGame){
                 countGamesByOneGames ++;
             }
         }
         System.assertEquals(1, countGamesByOneGames ); 
     }
     
     public static testmethod void createNextSingleEliminationStageTest(){
         List<Game__c> thisListGames = new List<Game__c>();
         Tournament__c t = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         insert t;
         Player__c myPlayer1 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest1@gmail.com');
         Player__c myPlayer8 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest8@gmail.com');
         Player__c myPlayer2 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest2@gmail.com');
         Player__c myPlayer3 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest3@gmail.com');
         Player__c myPlayer4 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest4@gmail.com');
         Player__c myPlayer5 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest5@gmail.com');
         Player__c myPlayer6 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest6@gmail.com');
         Player__c myPlayer7 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest7@gmail.com');
         Player__c myFreeSlot = new Player__c(Name = '-' , Password__c ='zxcvczzxc' , Email__c = 'www@gmail.com');
         List<Player__c> myPlayerList = new List<Player__c>();
         myPlayerList.add(myPlayer1);
         myPlayerList.add(myPlayer2);
         myPlayerList.add(myPlayer3);
         myPlayerList.add(myPlayer4);
         myPlayerList.add(myPlayer5);
         myPlayerList.add(myPlayer6);
         myPlayerList.add(myPlayer7);
         myPlayerList.add(myPlayer8);
         insert myPlayerList;
         insert myFreeSlot;
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer1.Id, SecondCompetitor__c=myPlayer2.id, FirstCompetitorScore__c=0, SecondCompetitorScore__c=1, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer3.Id, SecondCompetitor__c=myPlayer4.id, FirstCompetitorScore__c=0, SecondCompetitorScore__c=2, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer6.Id, SecondCompetitor__c=myPlayer5.id, FirstCompetitorScore__c=0, SecondCompetitorScore__c=3, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer7.Id, SecondCompetitor__c=myPlayer8.id, FirstCompetitorScore__c=0, SecondCompetitorScore__c=4, Stage__c=1, Tournament__c=t.id)
         );
         insert thisListGames;
         SingleEliminationTournament.createNextSingleEliminationStage(thisListGames,t);
         List<Game__c> testStage2 = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 2];
         System.assertEquals(2,testStage2.size());
         SingleEliminationTournament.createNextSingleEliminationStage(testStage2,t);
         List<Game__c> loserGames= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 3];
         List<Game__c> WinningGroupStage3= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c 
                                            Where Stage__c = 3 AND WinningGroup__c = true];
         List<Game__c> loserGroupStage3= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c 
                                          Where Stage__c = 3 AND WinningGroup__c = false];
         System.assertEquals(2,loserGames.size()); 
         System.assertEquals(1,WinningGroupStage3.size()); 
         System.assertEquals(1,loserGroupStage3.size()); 
     }
     
}