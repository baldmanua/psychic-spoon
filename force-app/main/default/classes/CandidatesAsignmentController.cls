public with sharing class CandidatesAsignmentController {

    public Vacancy__c currentVacancy { get; set; }
    public Candidate_to_Vacancy__c newRelation { get; set; }
    public List<wrapCandidateAssignment> connections { get; set; }

    public CandidatesAsignmentController(ApexPages.StandardController controller) {
        controller.addFields(new List<String>{'Status__c'});
        this.currentVacancy = (Vacancy__c) controller.getRecord();
        this.createNewRelation();
        this.updateConnections();
    }

    private void updateConnections() {
        List<Candidate_to_Vacancy__c> connections = [
                SELECT Candidate__r.Id,
                        Candidate__r.FirstName__c,
                        Candidate__r.LastName__c,
                        Candidate__r.Email__c,
                        Candidate__r.Salary__c
                FROM Candidate_to_Vacancy__c
                WHERE Vacancy__r.Id = :this.currentVacancy.Id
        ];
        this.connections = new List<wrapCandidateAssignment>();
        this.connections.clear();
        for(Candidate_to_Vacancy__c c: connections) {
            this.connections.add(new wrapCandidateAssignment(c));
        }
    }

    private void createNewRelation() {
        if (this.newRelation == null) {
            this.newRelation = new Candidate_to_Vacancy__c();
            this.newRelation.Vacancy__c = this.currentVacancy.Id;
        }
    }

    public void removeConnections() {
        if(this.validateRemovement()) {
            List<Candidate_to_Vacancy__c> delList = new List<Candidate_to_Vacancy__c>();
            for(wrapCandidateAssignment c: this.connections) {
                if(c.checked) {
                    delList.add(c.connection);
                }
            }
            delete delList;
            this.updateConnections();
        }
    }

    public void asignCandidate() {
        if (this.validateAssignment()) {
            upsert this.newRelation;
        }
        this.newRelation = null;
        this.createNewRelation();
        this.updateConnections();
    }

    private Boolean validateRemovement() {
        for(wrapCandidateAssignment c: this.connections) {
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

    public class wrapCandidateAssignment {
        public Candidate_to_Vacancy__c connection { get; set; }
        public Boolean checked { get; set; }

        public wrapCandidateAssignment(Candidate_to_Vacancy__c connection) {
            this.connection = connection;
            this.checked = false;
        }
    }
}