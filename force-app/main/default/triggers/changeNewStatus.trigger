trigger changeNewStatus on Vacancy__c (before insert) {
    for(Vacancy__c v: Trigger.new) {
        if(v.Status__c == null) {
            v.Status__c = 'New';
        }
    }
}