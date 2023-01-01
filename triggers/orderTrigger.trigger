/**
* @name orderTrigger
* @description
**/
trigger orderTrigger on Order (after update) {
    if(trigger.isUpdate){ 
            OrderHelper.AfterUpdate(trigger.newMap, trigger.oldMap);
    }
}