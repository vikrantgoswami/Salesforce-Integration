trigger CaseZendeskTicketInfo_Trigger on CaseZendeskTicketInfo__e (after insert) {

    if(Trigger.isAfter && Trigger.isInsert) {
        Map<Id, CaseZendeskTicketInfo__e> caseIdToTicketIdMap = new Map<Id, CaseZendeskTicketInfo__e>();
        List<Id> idOfCases = new List<Id>();
        for(CaseZendeskTicketInfo__e event : Trigger.new){
            if(event.Ticket_Id__c != null) {
                idOfCases.add(event.Case_Id__c);
                caseIdToTicketIdMap.put(event.Case_Id__c, event);
            }
        }
        CaseTriggerHandler.updateTicketIdOnCases(idOfCases, caseIdToTicketIdMap);
    }
}