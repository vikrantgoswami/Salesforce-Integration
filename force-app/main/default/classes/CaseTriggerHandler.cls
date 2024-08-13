public with sharing class CaseTriggerHandler {
    
    public static void handleAfterInsert(List<Case> listOfCases) {
        if(System.isFuture() || System.isBatch()){
            return;
        }

        Map<Id, Case> casesMap = new Map<Id, Case>([SELECT Id, Contact.Name, ContactEmail FROM Case WHERE Id IN :listOfCases]);
        for(Id caseId : casesMap.keySet()){
            Case c = casesMap.get(caseId);
        }
        for (Case newCase : listOfCases) {
            ZendeskTicketUtils.TicketWrapper wrapper = new ZendeskTicketUtils.TicketWrapper();
            wrapper.body = newCase.Description;
            wrapper.priority = newCase.Priority;
            wrapper.name = casesMap.get(newCase.Id).Contact.Name;
            wrapper.email = casesMap.get(newCase.Id).ContactEmail;
            wrapper.subject = newCase.Subject + '_' + newCase.Id;
            makeCallout(JSON.serialize(wrapper));
        }
    }

    @future(callout = true)
    private static void makeCallout(String wrapperString) {
        ZendeskTicketUtils.TicketWrapper wrapper = (ZendeskTicketUtils.TicketWrapper)JSON.deserialize(wrapperString, ZendeskTicketUtils.TicketWrapper.class);
        ZendeskTicketUtils.ResponseClass response = ZendeskTicketUtils.createTicket(wrapper);
        if(response.responseCode == 201) {
            String caseId = wrapper.subject.substringAfter('_');
            CaseZendeskTicketInfo__e eventToPublish = new CaseZendeskTicketInfo__e(API_Response__c=response.message, Case_Id__c=caseId, Ticket_Id__c=response.ticketId, Ticket_URL__c=response.ticketUrl);
            Database.SaveResult sr = EventBus.publish(eventToPublish);
            if(sr.isSuccess()) {
                System.debug('Successfully published event.');
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }
        }
    }

    public static void updateTicketIdOnCases(List<Id> caseIds, Map<Id, CaseZendeskTicketInfo__e> caseIdToTicketMap) {
        List<Case> casesToUpdate = [SELECT Id, ZendeskTicketId__c FROM Case WHERE Id IN :caseIds];
        for (Case c : casesToUpdate) {
            c.ZendeskTicketId__c = caseIdToTicketMap.get(c.Id).Ticket_Id__c;
            c.ZendeskTicketURL__c = caseIdToTicketMap.get(c.Id).Ticket_URL__c;
        }
        update casesToUpdate;
    }
}