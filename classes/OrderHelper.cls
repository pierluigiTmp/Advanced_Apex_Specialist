public without sharing class OrderHelper {
    
    /**
* @name AfterUpdate
* @description 
* @param Map<ID, Order> newList
* @param Map<ID, Order> oldList
* @return void
**/
    public static void AfterUpdate(Map<ID, Order> newMap, Map<ID, Order> oldMap){
        Set<Id> orderIds = new Set<Id>();
        for (ID key : newMap.keySet()){
            if (newMap.get(key).Status == Constants.ACTIVATED_ORDER_STATUS && oldMap.get(key).Status != Constants.ACTIVATED_ORDER_STATUS){
                orderIds.add(key);
            }
        }
        OrderHelper.RollUpOrderItems(orderIds);
    }
    
    
    
    
    /**
* @name RollUpOrderItems
* @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
* @param Set<Id> activatedOrderIds
* @return void
**/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        Map<ID, Product2> productMap = new Map<ID, Product2>([SELECT Id, Quantity_Ordered__c FROM Product2]);
        for(AggregateResult ar : [SELECT PricebookEntry.Product2.Id, SUM(Quantity)Quantity FROM OrderItem WHERE Order.Id IN :activatedOrderIds 
                                  GROUP BY PricebookEntry.Product2.Id]){
            Product2 p = productMap.get(ar.Id);
            p.Quantity_Ordered__c += Integer.valueOf(ar.get('Quantity'));
            productMap.put(p.Id, p);	
        }
        update productMap.values();
        
    }

}
