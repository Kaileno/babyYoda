trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            CaseTriggerHandler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            CaseTriggerHandler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when AFTER_INSERT {
            CaseTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
        }
    }
}