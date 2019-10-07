@IsTest
private class VacanciesAsignmentControllerTest {
    
    public static ApexPages.StandardController getController() {
        Candidate__c candidate = [
            SELECT Id
            FROM Candidate__c
            LIMIT 1
        ];
        return new ApexPages.StandardController(candidate);
    }
    
	@TestSetup
    static void testSetup()
    {
        Candidate__c c = new Candidate__c(
            Name='Candidate',
            FirstName__c='Candidate',
            LastName__c='Candidate',
            Location__c='Kharkiv',
            Status__c='Validated by HR',
            Email__c='Candidate@cand.usr'
        );
        insert c;
        
        Vacancy__c v1 = new Vacancy__c(
            Name='Vacancy1',
            Title__c='Vacancy1',
            PromoDescription__c='Vacancy1',
            Level__c='d2',
            Status__c='In-Process',
            startDate__c=date.newInstance(2020, 01, 01)
        );
        insert v1;
        
        Vacancy__c v2 = new Vacancy__c(
            Name='Vacancy2',
            Title__c='Vacancy2',
            PromoDescription__c='Vacancy2',
            Level__c='d2',
            Status__c='In-Process',
            startDate__c=date.newInstance(2020, 01, 01)
        );
        insert v2;
        
        Candidate_to_Vacancy__c ctv = new Candidate_to_Vacancy__c(
            Candidate__c=c.Id,
            Vacancy__c=v1.Id
        );
        insert ctv;
    }
    
    @isTest
    static void testRemoveFail() {
        VacanciesAsignmentController vac = new VacanciesAsignmentController(getController());
        vac.removeConnections();
        Boolean messageFound = false;
        for(ApexPages.Message msg : ApexPages.getMessages())
        {
            if(msg.getDetail() =='Nothing to remove' && msg.getSeverity() == ApexPages.Severity.WARNING)
                messageFound = true;
        }
        system.assert(messageFound);
    }
    
    @isTest
    static void testRemove() {
        VacanciesAsignmentController vac = new VacanciesAsignmentController(getController());
        System.assertEquals(1, vac.connections.size());
        vac.connections[0].checked = true;
        vac.removeConnections();
        System.assert(vac.connections.isEmpty());
    }
    
    @isTest
    static void testAsignFail() {
        VacanciesAsignmentController vac = new VacanciesAsignmentController(getController());
        vac.newRelation.Vacancy__c = [SELECT Id FROM Vacancy__c WHERE Name='Vacancy1'].Id;
        vac.asignVacancy();
        Boolean messageFound = false;
        for(ApexPages.Message msg : ApexPages.getMessages())
        {
            if(msg.getDetail() =='This candidate is already asigned' && msg.getSeverity() == ApexPages.Severity.ERROR)
                messageFound = true;
        }
        system.assert(messageFound);
    }
    
    @isTest
    static void testAsignSuccess() {
        VacanciesAsignmentController vac = new VacanciesAsignmentController(getController());
        System.assertEquals(1, vac.connections.size());
        vac.newRelation.Vacancy__c = [SELECT Id FROM Vacancy__c WHERE Name='Vacancy2'].Id;
        vac.asignVacancy();
        System.assertEquals(2, vac.connections.size());
    }
}