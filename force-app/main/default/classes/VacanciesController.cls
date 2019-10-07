public with sharing class VacanciesController {

    public String customFilterByStatus { get; set; }
    @TestVisible public List <wrapVacancy> vacancies { get; set; }

    @TestVisible public class wrapVacancy {
        public Vacancy__c vacancy { get; set; }
        public Boolean checked { get; set; }
        @TestVisible public List <wrapConnection> connections { get; set; }

        public wrapVacancy(Vacancy__c vacancy, List <Candidate_to_Vacancy__c> connections) {
            this.vacancy = vacancy;
            this.checked = false;
            this.connections = new List <wrapConnection>();
            for (Candidate_to_Vacancy__c connection : connections) {
                this.connections.add(new wrapConnection(connection));
            }
        }

        public Candidate__c prepareApprove() {
            Candidate__c candidateToApprove;
            for (wrapConnection c : this.connections) {
                if (c.checked) {
                    this.vacancy.Candidate__c = c.connection.Candidate__c;
                    this.vacancy.Status__c = 'Closed';
                    candidateToApprove = c.connection.Candidate__r;
                    candidateToApprove.Status__c = 'Hired';
                }
            }
            return candidateToApprove;
        }
    }

    @TestVisible public class wrapConnection {
        public Candidate_to_Vacancy__c connection { get; set; }
        public Boolean checked { get; set; }

        public wrapConnection(Candidate_to_Vacancy__c connection) {
            this.connection = connection;
            this.checked = false;
        }
    }
    
    public VacanciesController() {
        this.customFilterByStatus = 'In-Process';
        this.vacancies = updateVacancies();
    }

    public List <wrapVacancy> updateVacancies() {
        List <wrapVacancy> result = new List <wrapVacancy>();

        List <Vacancy__c> vacancies = [
                SELECT Id,
                        Title__c,
                        Status__c,
                        Candidate__c,
                        Candidate__r.FirstName__c,
                        Candidate__r.LastName__c, (
                        SELECT Id,
                                Candidate__r.FirstName__c,
                                Candidate__r.LastName__c,
                                Candidate__r.Email__c,
                                Candidate__c
                        FROM Candidates_to_Vacancies__r
                )
                FROM Vacancy__c
                WHERE Status__c = :customFilterByStatus
        ];

        for (Vacancy__c connection : vacancies) {
            result.add(new wrapVacancy(connection, connection.Candidates_to_Vacancies__r));
        }
        return result;
    }

    /**
     * Clear bad junctions
     */
    private void clearJunctions() {
        List<Candidate_to_Vacancy__c> connections = [
                SELECT Id
                FROM Candidate_to_Vacancy__c
                WHERE Vacancy__r.Status__c = 'Closed'
                OR Vacancy__r.Status__c = 'Cancelled'
                OR Candidate__r.Status__c = 'Hired'
        ];
        delete connections;
    }

    public void showNew() {
        this.customFilterByStatus = 'New';
        this.vacancies = updateVacancies();
    }

    public void showInProcess() {
        this.customFilterByStatus = 'In-Process';
        this.vacancies = updateVacancies();
    }

    public void showCancelled() {
        this.customFilterByStatus = 'Cancelled';
        this.vacancies = updateVacancies();
    }

    public void showClosed() {
        this.customFilterByStatus = 'Closed';
        this.vacancies = updateVacancies();
    }

    public void cancelSelected() {
        List<Vacancy__c> cancelVacancyList = new List<Vacancy__c>();
        if(validateCancelled()) {
            for(wrapVacancy v: this.vacancies) {
                if(v.checked) {
                    v.vacancy.Status__c = 'Cancelled';
                    cancelVacancyList.add(v.vacancy);
                }
            }
            update cancelVacancyList;
            this.clearJunctions();
            this.vacancies = updateVacancies();
        }
    }

    public void approveSelected() {
        List<Vacancy__c> updateVacancyList = new List<Vacancy__c>();
        List<Candidate__c> updateCandidateList = new List<Candidate__c>();
        if (validateApproved()) {
            for (wrapVacancy v : this.vacancies) {
                Candidate__c candidateToApprove = v.prepareApprove();
                if (candidateToApprove != null) {
                    updateVacancyList.add(v.vacancy);
                    updateCandidateList.add(candidateToApprove);
                }
            }
            update updateVacancyList;
            update updateCandidateList;
            this.clearJunctions();
            this.vacancies = updateVacancies();
        }
    }

    public void removeSelected() {
        if (validateRemoved()) {
            List<Candidate_to_Vacancy__c> removeList = new List<Candidate_to_Vacancy__c>();
            for (wrapVacancy v : this.vacancies) {
                for (wrapConnection c : v.connections) {
                    if (c.checked) {
                        removeList.add(c.connection);
                    }
                }
            }
            delete removeList;
            this.vacancies = updateVacancies();
        }
    }

    private Boolean validateCancelled() {
        Boolean cancelValidated = true;
        Integer counter = 0;
        for (wrapVacancy v: this.vacancies) {
            if(v.checked) {
                counter++;
            }
        }
        if(counter < 1) {
            cancelValidated = false;
            ApexPages.addMessage(
                    new ApexPages.Message(
                            ApexPages.Severity.WARNING,
                            'Nothing to cancel'
                    )
            );
        }
        return cancelValidated;
    }

    private Boolean validateApproved() {
        Boolean approveValidated = true;
        Integer vacancyCounter = 0;
        List<Id> candidatesIds = new List<Id>();
        for (wrapVacancy v : vacancies) {
            Integer connectionCounter = 0;
            for (wrapConnection c : v.connections) {
                if (c.checked) {
                    vacancyCounter++;
                    connectionCounter++;
                    if (candidatesIds.contains(c.connection.Candidate__c)) {
                        approveValidated = false;
                        ApexPages.addMessage(
                                new ApexPages.Message(
                                        ApexPages.Severity.ERROR,
                                        'One Candidate can be approved only for one Vacancy'
                                )
                        );
                    } else {
                        candidatesIds.add(c.connection.Candidate__c);
                    }
                }
                if (connectionCounter > 1) {
                    approveValidated = false;
                    ApexPages.addMessage(
                            new ApexPages.Message(
                                    ApexPages.Severity.ERROR,
                                    'Only one candidate per vacancy can be approved'
                            )
                    );
                }
            }
        }
        if (vacancyCounter < 1) {
            approveValidated = false;
            ApexPages.addMessage(
                    new ApexPages.Message(
                            ApexPages.Severity.WARNING,
                            'Nothing to approve'
                    )
            );
        }

        return approveValidated;
    }

    private Boolean validateRemoved() {
        Boolean removeValidated = true;
        Integer counter = 0;
        for (wrapVacancy v : vacancies) {
            for (wrapConnection c : v.connections) {
                if (c.checked) {
                    counter++;
                }
            }
        }
        if (counter < 1) {
            removeValidated = false;
            ApexPages.addMessage(
                    new ApexPages.Message(
                            ApexPages.Severity.WARNING,
                            'Nothing to remove'
                    )
            );
        }
        return removeValidated;
    }
}