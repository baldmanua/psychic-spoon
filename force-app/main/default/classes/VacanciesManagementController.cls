public with sharing class VacanciesManagementController {
    
    public List <Vacancy__c> vacancyList {get; set;}
    public String customFilterByResponsible {get; set;}
    
    public VacanciesManagementController () {
        if(customFilterByResponsible == null) {
            customFilterByResponsible = 'unselected';
        }
        updateVacancyList();
    }
    
    public void updateVacancyList() {
        if (customFilterByResponsible == 'all') {
            this.vacancyList = [
                SELECT Id, Title__c, Level__c, DaysOpen__c, DaysLeftToClose__c, Responsible__c 
                FROM Vacancy__c 
                ORDER BY StartDate__c
            ];
        } else if(customFilterByResponsible == 'selected') {
            this.vacancyList = [
                SELECT Id, Title__c, Level__c, DaysOpen__c, DaysLeftToClose__c, Responsible__c 
                FROM Vacancy__c 
                WHERE Responsible__c != NULL
                ORDER BY StartDate__c
            ];
        } else if (customFilterByResponsible == 'unselected') {
            this.vacancyList = [
                SELECT Id, Title__c, Level__c, DaysOpen__c, DaysLeftToClose__c, Responsible__c 
                FROM Vacancy__c 
                WHERE Responsible__c = NULL
                ORDER BY StartDate__c
            ];
        }
    }
    
    public void showAll() {
        this.customFilterByResponsible = 'all';
        updateVacancyList();
    }
    public void showSelected() {
        this.customFilterByResponsible = 'selected';
        updateVacancyList();
    }
    public void showUnselected() {
        this.customFilterByResponsible = 'unselected';
        updateVacancyList();
    }
    
    public void saveList() {
        upsert vacancyList;
        updateVacancyList();
    }
}