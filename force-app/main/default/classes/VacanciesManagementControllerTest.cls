@IsTest
private class VacanciesManagementControllerTest {
    private static Id recruiterId;
	@TestSetup
    static void testSetup()
    {
        Profile p = [
            SELECT Id 
            FROM Profile 
            WHERE Name='Recruiter'
        ];
       
        User recruiter = [
            SELECT Id 
            FROM User 
            WHERE ProfileId=:p.Id
            LIMIT 1
        ];
        
        recruiterId = recruiter.Id;
        
        Vacancy__c v1 = new Vacancy__c(
            Name='Vacancy1',
            Title__c='Vacancy1',
            PromoDescription__c='Vacancy1',
            Level__c='d2',
            Status__c='New',
            startDate__c=date.newInstance(2020, 01, 01)
        );
        insert v1;
        Vacancy__c v2 = new Vacancy__c(
            Name='Vacancy2',
            Title__c='Vacancy2',
            PromoDescription__c='Vacancy2',
            Level__c='d2',
            Status__c='New',
            startDate__c=date.newInstance(2020, 01, 01)
        );
        insert v2;
        v2.Responsible__c = recruiterId;
        update v2;
    }
    
    @isTest
    static void testFilters() {
        VacanciesManagementController vmc = new VacanciesManagementController();
        System.assertEquals('unselected', vmc.customFilterByResponsible);
        System.assertEquals(1, vmc.vacancyList.size());
        vmc.showAll();
        System.assertEquals('all', vmc.customFilterByResponsible);
        System.assertEquals(2, vmc.vacancyList.size());
        vmc.showSelected();
        System.assertEquals('selected', vmc.customFilterByResponsible);
        System.assertEquals(1, vmc.vacancyList.size());
        vmc.showUnselected();
        System.assertEquals('unselected', vmc.customFilterByResponsible);
        System.assertEquals(1, vmc.vacancyList.size());
    }
    
    /*@isTest
    static void testSaveList() {
        VacanciesManagementController vmc = new VacanciesManagementController();
        vmc.vacancyList[0].Responsible__c = recruiterId;
        vmc.saveList();
        System.debug(vmc);
        System.assert(vmc.vacancyList.isEmpty());
    }*/
    
    
}