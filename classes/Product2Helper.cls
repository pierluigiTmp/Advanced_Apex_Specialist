public class Product2Helper {
    
    /**
* @name COLLABORATION_GROUP
* @description List of CollaborationGroup used in both business and test logic
**/
    static List<CollaborationGroup> COLLABORATION_GROUP = [
        SELECT Id
        FROM CollaborationGroup
        WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('TEST'+ Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];
    
    /**
* @name afterUpdate
* @description called by product2 Trigger on After Update
* @param List<Product2> newList
* @param Map<ID, Product2> oldMap
**/
    public static void AfterUpdate(List<Product2> newList, Map<ID, Product2> oldMap){
        //Done: Declare a List of Product2 records named needsAnnouncement
        List<Product2> needsAnnouncement = new List<Product2>();
        //Done: Declare a Map of Strings to Inventory_Setting__mdt records
        Map<String, Inventory_Setting__mdt> settMap = new Map<String, Inventory_Setting__mdt>(); 
        //Done: Loop through a query of Inventory_Setting__mdt records and populate the Map with Name as the key
        for(Inventory_Setting__mdt is : [SELECT Id, MasterLabel, Low_Quantity_Alert__c FROM Inventory_Setting__mdt]){
            settMap.put(is.MasterLabel, is);
        }
        //Done: Loop through the Products in newList
        // Se la quantità del Product2 è stata cambiata (controllo con oldMap) && quantità < settMap.get(Product2.Family).Low_Quantity_Alert__c
        // aggiungi alla lista needsAnnouncement
        for(Product2 p : newList){
            if(p.Quantity_Remaining__c != oldMap.get(p.Id).Quantity_Remaining__c && p.Quantity_Remaining__c < settMap.get(p.Family).Low_Quantity_Alert__c ){
                needsAnnouncement.add(p);
            }
        }
		//Done: Pass records to the postAlerts method
		PostAlerts(needsAnnouncement);		
    }
    
    /**
* @name postAlerts
* @description called by product2 Trigger on After Update
* @param List<Product2> productList
**/
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            // Done: Construct a new AnnouncementInput for the Chatter Group so that it:
            // expires in a day
            // does not notify users via email.
            // and has a text body that includes the name of the product followed by the INVENTORY_LEVEL_LOW constant
            ConnectApi.AnnouncementInput ai = new ConnectApi.AnnouncementInput();
            ai.ParentId = COLLABORATION_GROUP[0].Id;
            ai.expirationDate = System.now().addDays(1);
            ai.sendEmails = False;
            //Creazione body dell'AnnouncementInput
            ai.body = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = p.Name + ' ' + Constants.INVENTORY_LEVEL_LOW + ' of ' + p.Quantity_Remaining__c;
            ai.body.messageSegments = new List<ConnectApi.MessageSegmentInput> {textSegmentInput};
            toPost.add(ai);    
        }
        System.debug(toPost);
        // Done: Create and enqueue an instance of the announcementQueuable class with the list of Products
        // Totale async
        AnnouncementQueueable job = new AnnouncementQueueable();
        job.toPost = toPost;
        System.enqueueJob(job);
        //Ibrido sync e async
        //Chiamando direttamente PostAnnouncements si utilizzano tutte le DML possibili in sync prima di passare la lista con i rimanenti record alla queue
        //AnnouncementQueueable.PostAnnouncements(toPost);
    }
}
