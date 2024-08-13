trigger CaseTrigger on Case (before insert, after insert, before update, after update) {
    if(trigger.isInsert && trigger.isAfter) {
        CaseTriggerHandler.handleAfterInsert(trigger.new);
    }
}