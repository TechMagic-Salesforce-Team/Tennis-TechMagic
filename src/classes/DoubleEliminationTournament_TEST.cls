@isTest
public with sharing class DoubleEliminationTournament_TEST {
    
    public static DoubleEliminationTournament det = new DoubleEliminationTournament();
    
    public static testMethod void testProperties() {
        
        System.assertEquals(1, det.competitorsName.size());
        
    }

}