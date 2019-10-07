trigger setResponsible on Vacancy__c (before update) {
    for(Vacancy__c v: Trigger.new) {
        if(Trigger.oldMap.get(v.Id).Responsible__c == null && v.Responsible__c != null) {
            v.OwnerId = v.Responsible__c;
            v.Status__c = 'In-Process';
        }
    }
}