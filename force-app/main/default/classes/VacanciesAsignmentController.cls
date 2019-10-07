public with sharing class VacanciesAsignmentController {
    
    public Candidate__c currentCandidate { get; set; }
    public Candidate_to_Vacancy__c newRelation { get; set; }
    @TestVisible public List<wrapVacancyAssignment> connections { get; set; }
    
    public VacanciesAsignmentController(ApexPages.StandardController controller) {
        List<String> fields = new List<String>{'Status__c'};
            if (!Test.isRunningTest()) {
                controller.addFields(fields);
            }
        this.currentCandidate = (Candidate__c) controller.getRecord();
        this.createNewRelation();
        this.updateConnections();
    }
    
    private void updateConnections() {
        List<Candidate_to_Vacancy__c> connections = [
            SELECT Vacancy__r.Id,
            Vacancy__r.Title__c
            FROM Candidate_to_Vacancy__c
            WHERE Candidate__r.Id = :this.currentCandidate.Id
        ];
        this.connections = new List<wrapVacancyAssignment>();
        this.connections.clear();
        for(Candidate_to_Vacancy__c c: connections) {
            this.connections.add(new wrapVacancyAssignment(c));
        }
    }
    
    private void createNewRelation() {
        if (this.newRelation == null) {
            this.newRelation = new Candidate_to_Vacancy__c();
            this.newRelation.Candidate__c = this.currentCandidate.Id;
        }
    }
    
    public void removeConnections() {
        if(this.validateRemovement()) {
            List<Candidate_to_Vacancy__c> delList = new List<Candidate_to_Vacancy__c>();
            for(wrapVacancyAssignment c: this.connections) {
                if(c.checked) {
                    delList.add(c.connection);
                }
            }
            delete delList;
            this.updateConnections();
        }
    }
    
    public void asignVacancy() {
        if (this.validateAssignment()) {
            upsert this.newRelation;
        }
        this.newRelation = null;
        this.createNewRelation();
        this.updateConnections();
    }
    
    private Boolean validateRemovement() {
        for(wrapVacancyAssignment c: this.connections) {
            if(c.checked) {
                return true;
            }
        }
        ApexPages.addMessage(
            new ApexPages.Message(
                ApexPages.Severity.WARNING,
                'Nothing to remove'
            )
        );
        return false;
    }
    
    private Boolean validateAssignment() {
        Boolean validated = true;
        List <Candidate_to_Vacancy__c> checkExisting = [
            SELECT Id
            FROM Candidate_to_Vacancy__c
            WHERE Vacancy__c = :this.newRelation.Vacancy__c
            AND Candidate__c = :this.newRelation.Candidate__c
        ];
        if (checkExisting.size() > 0) {
            validated = false;
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'This candidate is already asigned'
                )
            );
        }
        
        return validated;
    }
    
    @TestVisible public class wrapVacancyAssignment {
        public Candidate_to_Vacancy__c connection { get; set; }
        public Boolean checked { get; set; }
        
        public wrapVacancyAssignment(Candidate_to_Vacancy__c connection) {
            this.connection = connection;
            this.checked = false;
        }
    }
}