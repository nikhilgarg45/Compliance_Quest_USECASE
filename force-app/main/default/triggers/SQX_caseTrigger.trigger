trigger SQX_caseTrigger on Case (after Insert,after Update) {
    
    if(trigger.isinsert && trigger.isafter){
        SQX_CaseTriggerHandler.checkandCreateNonconformance(trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isafter){  
        SQX_CaseTriggerHandler.updateCaseIfUserHasPermissionSet(trigger.new);
    }
}