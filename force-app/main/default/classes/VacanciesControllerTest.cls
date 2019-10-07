@IsTest
private class VacanciesControllerTest {
    
    @TestSetup
    static void testSetup()
    {
        Candidate__c c1 = new Candidate__c(
            Name='Candidate1',
            FirstName__c='Candidate1',
            LastName__c='Candidate1',
            Location__c='Kharkiv',
            Status__c='Validated by HR',
            Email__c='Candidate1@cd1.usr'
        );
        Candidate__c c2 = new Candidate__c(
            Name='Candidate2',
            FirstName__c='Candidate2',
            LastName__c='Candidate2',
            Location__c='Kharkiv',
            Status__c='Validated by HR',
            Email__c='Candidate2@cd2.usr'
        );
        Candidate__c c3 = new Candidate__c(
            Name='Candidate3',
            FirstName__c='Candidate3',
            LastName__c='Candidate3',
            Location__c='Kharkiv',
            Status__c='Validated by HR',
            Email__c='Candidate3@cd3.usr'
        );
        
        List<Candidate__c> cl = new List<Candidate__c>();
        cl.add(c1);
        cl.add(c2);
        cl.add(c3);
        insert cl;
        Vacancy__c v1 = new Vacancy__c(
            Name='Vacancy1',
            Title__c='Vacancy1',
            PromoDescription__c='Vacancy1',
            Level__c='d2',
            Status__c='In-Process',
            startDate__c=date.newInstance(2020, 01, 01)
        );
        Vacancy__c v2 = new Vacancy__c(
            Name='Vacancy2',
            Title__c='Vacancy2',
            PromoDescription__c='Vacancy2',
            Level__c='d2',
            Status__c='In-Process',
            startDate__c=date.newInstance(2020, 01, 01)
        );
        Vacancy__c v3 = new Vacancy__c(
            Name='Vacancy3',
            Title__c='Vacancy3',
            PromoDescription__c='Vacancy3',
            Level__c='d2',
            Status__c=null,
            startDate__c=date.newInstance(2020, 01, 01)
        );
        Vacancy__c v4 = new Vacancy__c(
            Name='Vacancy4',
            Title__c='Vacancy4',
            PromoDescription__c='Vacancy4',
            Level__c='d2',
            Status__c='Cancelled',
            startDate__c=date.newInstance(2020, 01, 01)
        );
        Vacancy__c v5 = new Vacancy__c(
            Name='Vacancy5',
            Title__c='Vacancy5',
            PromoDescription__c='Vacancy5',
            Level__c='d2',
            Status__c='Closed',
            Candidate__c=c3.Id,
            startDate__c=date.newInstance(2020, 01, 01)
        );
        List<Vacancy__c> vl = new List<Vacancy__c>();
        vl.add(v1);
        vl.add(v2);
        vl.add(v3);
        vl.add(v4);
        vl.add(v5);
        insert vl;
        
        c3.Status__c = 'Hired';
        update c3;
        
        Candidate_to_Vacancy__c c1v1 = new Candidate_to_Vacancy__c(
            Candidate__c=c1.Id,
            Vacancy__c=v1.Id
        );
        Candidate_to_Vacancy__c c1v2 = new Candidate_to_Vacancy__c(
            Candidate__c=c1.Id,
            Vacancy__c=v2.Id
        );
        Candidate_to_Vacancy__c c2v1 = new Candidate_to_Vacancy__c(
            Candidate__c=c2.Id,
            Vacancy__c=v1.Id
        );
        Candidate_to_Vacancy__c c2v2 = new Candidate_to_Vacancy__c(
            Candidate__c=c2.Id,
            Vacancy__c=v2.Id
        );
        
        List<Candidate_to_Vacancy__c> ctvl = new List<Candidate_to_Vacancy__c>();
        ctvl.add(c1v1);
        ctvl.add(c1v2);
        ctvl.add(c2v1);
        ctvl.add(c2v2);
        insert ctvl;
        
    }
    
    @isTest
    static void testFilters() {
        VacanciesController vc = new VacanciesController();
        System.assertEquals('In-Process', vc.customFilterByStatus);
        System.assertEquals(2, vc.vacancies.size());
        vc.showNew();
        System.assertEquals('New', vc.customFilterByStatus);
        System.assertEquals(1, vc.vacancies.size());
        vc.showInProcess();
        System.assertEquals('In-Process', vc.customFilterByStatus);
        System.assertEquals(2, vc.vacancies.size());
        vc.showCancelled();
        System.assertEquals('Cancelled', vc.customFilterByStatus);
        System.assertEquals(1, vc.vacancies.size());
        vc.showClosed();
        System.assertEquals('Closed', vc.customFilterByStatus);
        System.assertEquals(1, vc.vacancies.size());
    }
    
    @isTest
    static void testApproveNone() {
        VacanciesController vc = new VacanciesController();
        vc.approveSelected();
        
        
        Boolean messageFound = false;
        for(ApexPages.Message msg : ApexPages.getMessages())
        {
            if(msg.getDetail() =='Nothing to approve' && msg.getSeverity() == ApexPages.Severity.WARNING)
                messageFound = true;
        }
        system.assert(messageFound);
    }
    
    @isTest
    static void testApproveAll() {
        VacanciesController vc = new VacanciesController();
        for(VacanciesController.wrapVacancy wv: vc.vacancies) {
            for(VacanciesController.wrapConnection wc: wv.connections) {
                wc.checked = true;
            }
        }
        vc.approveSelected();
        
        
        Boolean message1Found = false;
        Boolean message2Found = false;
        for(ApexPages.Message msg : ApexPages.getMessages())
        {
            if(msg.getDetail() =='One Candidate can be approved only for one Vacancy' && msg.getSeverity() == ApexPages.Severity.ERROR)
                message1Found = true;
            if(msg.getDetail() =='Only one candidate per vacancy can be approved' && msg.getSeverity() == ApexPages.Severity.ERROR)
                message2Found = true;
        }
        system.assert(message1Found && message2Found);
    }
    
    @isTest
    static void testApproveFirst() {
        VacanciesController vc = new VacanciesController();
        vc.vacancies[0].connections[0].checked = true;
        vc.approveSelected();
        vc.showClosed();
        System.assertEquals('Closed', vc.customFilterByStatus);
        System.assertEquals(2, vc.vacancies.size());
    }
    
    @isTest
    static void testRemoveNone() {
        VacanciesController vc = new VacanciesController();
        vc.removeSelected();
        Boolean messageFound = false;
        for(ApexPages.Message msg : ApexPages.getMessages())
        {
            if(msg.getDetail() =='Nothing to remove' && msg.getSeverity() == ApexPages.Severity.WARNING)
                messageFound = true;
        }
        system.assert(messageFound);
    }
    
    @isTest
    static void testRemoveAll() {
        VacanciesController vc = new VacanciesController();
        //vc.vacancies[0].connections[0].checked = true;
        for(VacanciesController.wrapVacancy wv: vc.vacancies) {
            for(VacanciesController.wrapConnection wc: wv.connections) {
                wc.checked = true;
            }
        }
        vc.removeSelected();
        for(VacanciesController.wrapVacancy wv: vc.vacancies) {
            System.assertEquals(0, wv.connections.size());
        }
    }
    
    @isTest
    static void testCancelNone() {
        VacanciesController vc = new VacanciesController();
        vc.cancelSelected();
        Boolean messageFound = false;
        for(ApexPages.Message msg : ApexPages.getMessages())
        {
            if(msg.getDetail() =='Nothing to cancel' && msg.getSeverity() == ApexPages.Severity.WARNING)
                messageFound = true;
        }
        system.assert(messageFound);
    }
    
    @isTest
    static void testCancelAll() {
        VacanciesController vc = new VacanciesController();
        for(VacanciesController.wrapVacancy wv: vc.vacancies) {
            wv.checked = true;
        }
        vc.cancelSelected();
        vc.showCancelled();
        System.assertEquals('Cancelled', vc.customFilterByStatus);
        System.assertEquals(3, vc.vacancies.size());
    }
    
}