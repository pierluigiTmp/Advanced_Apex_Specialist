/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}
	
    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;
    

    public OrderExtension(ApexPages.StandardController standardController){
        this.orderRecord = (Order)standardController.getRecord();
        this.orderItemList = new List<OrderItem>();
        this.orderItemMap = new Map<Id,OrderItem>();
		this.pieData = new List<chartHelper.chartData>();
   		this.total = 0;
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
            for(OrderItem oi : orderRecord.OrderItems){
                orderItemMap.put(oi.Product2Id, oi);
            }
        }
        controllerPriceBookEntries(False); //Prima paginazione
        popolaPieChart();
    }
    

    
    /**
     * @name populateTable
     * @description Creazione dei rows della Table in base al set dello standardSetController e popolazione fields (New o Edit)
     * 		    Mappatura degli OrderItem con il corrispettivo Product2 per poter salvare i valori ad ogni chiamata onFieldChange e paginazione
    **/
    public void popolaTable(){
        //Se la mappa è popolata (record Order esiste) - Edit o Ripaginazione
        if(orderItemMap.size() > 0){
            //Per ogni sObject nel set controllato dallo standardSetController
            for (sObject obj : standardSetController.getRecords()){
                PriceBookEntry pbe = (PriceBookEntry) obj;
                //Se la mappa contiene un Product2 relativo al PriceBookEntry allora popola i fields con i valori dell'OrderItem relativo al Product2
                if(orderItemMap.containsKey(pbe.Product2Id)){
                    orderItemList.add(orderItemMap.get(pbe.Product2Id));
                //Else crea nuovi OrderItem relativi ai restanti PriceBookEntry dello standardSetController  
                } else {
                    OrderItem oi = new OrderItem(Product2Id = pbe.Product2Id, PricebookEntryId = pbe.Id, UnitPrice = pbe.UnitPrice, Product2 = pbe.Product2, Quantity = 0);
                    orderItemList.add(oi);
                    orderItemMap.put(pbe.Product2Id, oi);
                    
                }                    
            }
        }
        //Else se la mappa è null allora crea tutti nuovi OrderItem per ogni PriceBookEntry nel set dello standardSetController (Quantity default 0) - New
        else{
            for (sObject obj : standardSetController.getRecords()){
                PriceBookEntry pbe = (PriceBookEntry) obj;
                OrderItem oi = new OrderItem(Product2Id = pbe.Product2Id, PricebookEntryId = pbe.Id, UnitPrice = pbe.UnitPrice, Product2 = pbe.Product2, Quantity = 0);
                orderItemList.add(oi);
                orderItemMap.put(pbe.Product2Id, oi);
                
            }
        }    
    }
    
    /**
     * @name controllerPriceBookEntries
     * @description Inizializza lo standard set controller per tutti i record PriceBookEntry che rispettano il filtro scelto dall'utente
     * 
     * Done: Aggiungere filtro query in base a valore {!selectedFamily} 
    **/
    public void controllerPriceBookEntries(Boolean filter) {
        if(filter){
            List<PriceBookEntry> pbes = [SELECT Product2.Family, Product2.Quantity_Remaining__c, Product2Id, UnitPrice, Product2.Name FROM PriceBookEntry 
					 WHERE IsActive = True AND Product2.Family = :selectedFamily];
            standardSetController = new ApexPages.StandardSetController(pbes);
        } else{
            List<PriceBookEntry> pbes = [SELECT Product2.Family, Product2.Quantity_Remaining__c, Product2Id, UnitPrice, Product2.Name FROM PriceBookEntry 
					 WHERE IsActive = True];
            standardSetController = new ApexPages.StandardSetController(pbes);     
        }
        //Imposta numero massimo di record che è possibile recuperare dal set per ogni paginazione
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
        popolaTable(); //Per refreshare una volta chiamato SelectFamily
    } 
   
    /**
     * @name popolaPieChart
     * @description ChartHelper.cls
    **/
    public void popolaPieChart(){
        if(orderItemMap.size() > 0){
            for(Id key : orderItemMap.keySet()){
                OrderItem oi = orderItemMap.get(key);
                if(oi.Quantity > 0){
                    pieData.add(new ChartHelper.ChartData(oi.Product2.Name, oi.Quantity*oi.UnitPrice));
                    total += oi.Quantity*oi.UnitPrice;
                }
            }
        } 
    }
    
	/**
     * @name OnFieldChange
     * @description Per ogni oggetto (riga della table) in orderItemList se Quantity o UnitPrice è diverso dal vecchio valore contenuto in orderItemMap
     * 		    allora sostituisco il vecchio OderItem della mappa con un nuovo oggeto con campi aggiornati
    **/
    public void OnFieldChange(){
        //Done: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total
        for(OrderItem oi_new : orderItemList){
            OrderItem oi = new OrderItem(Product2Id = orderItemMap.get(oi_new.Product2Id).Product2Id, PricebookEntryId = orderItemMap.get(oi_new.Product2Id).Id, 
                                         UnitPrice = orderItemMap.get(oi_new.Product2Id).UnitPrice, Quantity = orderItemMap.get(oi_new.Product2Id).Quantity, 
					 Product2 = orderItemMap.get(oi_new.Product2Id).Product2);
            if(oi.Quantity != oi_new.Quantity){
            	oi.Quantity = oi_new.Quantity;
                orderItemMap.put(oi_new.Product2Id, oi);
            }
            if(oi.UnitPrice != oi_new.UnitPrice){
                oi.UnitPrice = oi_new.UnitPrice;
                orderItemMap.put(oi_new.Product2Id, oi);
            }
        }
        pieData.clear();
        total = 0;
        popolaPieChart();
        

    }

    /**
     * @name SelectFamily
     * @description Se selectedFamily != da Select one pulisce la Table e chiama una nuova paginazione filtrata
     * 		    se selectedFamily = a Select one pulisce la Table e chiama una nuova paginazione non filtrata
    **/
    public void SelectFamily(){
        //Done: Implement logic to filter based on the selected product family
        if(selectedFamily != Constants.SELECT_ONE){
            orderItemList.clear();
            controllerPriceBookEntries(True);    
        }
        else {
            orderItemList.clear();
            controllerPriceBookEntries(False);
        }        
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        //Done: Implement logic to save the Order and populated OrderItems
        //
        Savepoint sp = Database.setSavepoint();
        //Mappa Id Product2, Product2 per il campo Quantity_Remaining__c 
        Map<Id, Product2> productsMap = new Map<Id, Product2>([SELECT Id, Quantity_Remaining__c FROM Product2]);
        //Creare lista di OrderItem da filtrare in base a Quantity_Remaining__c e Quantity dell'OrderItem
        List<OrderItem> filteredOrderItemsList = new List<OrderItem>();
        List<OrderItem> deleteOrderItemsList = new List<OrderItem>();
        for(Id key : orderItemMap.keySet()){
            OrderItem oi = orderItemMap.get(key);
            if(oi.Quantity < productsMap.get(oi.Product2Id).Quantity_Remaining__c && oi.Quantity > 0){
                filteredOrderItemsList.add(oi);
            }
            //Se Quantity è 0  e il record OrderItem esiste allora aggiungo alla lista di OrderItem da eliminare
            if(oi.Quantity == 0 && oi.Id != NULL){
                deleteOrderItemsList.add(oi);
            }
        }
        //FIELD_INTEGRITY_EXCEPTION, Price Book Not Set on Order: []
        orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
        //If .size() della lista filtrata = 0 && orderRecord esiste DELETE 
        if(deleteOrderItemsList.size() > 0){
            try {
                delete deleteOrderItemsList;
            } catch(DmlException e) {
                System.debug(e.getMessage());
                apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
                Database.rollback(sp);
            }
        }
        //If .size() della lista filtrata > 0 allora per ogni oggetto crea relazione con orderRecord
        if(filteredOrderItemsList.size() > 0 && orderRecord.Id != NULL){
            //If orderRecord esiste allora crea relazioni con gli OrderItem, UPDATE orderRecord INSERT lista di OrderItem
            
            for(OrderItem oi : filteredOrderItemsList){
                if(oi.OrderId == NULL){
                    oi.OrderId = orderRecord.Id;
                }
            }
            
            try{
                update orderRecord;
                upsert filteredOrderItemsList;
            } catch(DmlException e) {
                System.debug(e.getMessage());
                apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
                Database.rollback(sp);
            } 
        }
        
        if(filteredOrderItemsList.size() > 0 && orderRecord.Id == NULL) {
            //Else INSERT orderRecord crea relazioni con gli OrderItem, INSERT lista di OrderItem
            try {
                insert orderRecord;
            } catch(DmlException e) {
                System.debug(e.getMessage());
                apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
                Database.rollback(sp);
            }
            for(OrderItem oi : filteredOrderItemsList){
                if(oi.OrderId == NULL){
                    oi.OrderId = orderRecord.Id;
                }
            }
            try{
                insert filteredOrderItemsList;
            } catch(DmlException e) {
                System.debug(e.getMessage());
                apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
                Database.rollback(sp);
            }
        }     	
    }

    

    /**
     * @name First
     * @description Chiama .first() sullo standardSetController alla prossima paginazione prende i primi n records del set 
     *		    (n dipende dal paramentro passato in setPageSize)
     *	  	    Pulisce la Table e ripopola con il metodo popolaTable() chiamando una nuova paginazione	
    **/
    public void First(){
		standardSetController.first();
        orderItemList.clear();
        popolaTable();
    }


    /**
     * @name Next
     * @description Chiama .next() sullo standardSetController alla prossima paginazione prende i successivi n records del set 
     *		    (n dipende dal paramentro passato in setPageSize)
     *		    Pulisce la Table e ripopola con il metodo popolaTable() chiamando una nuova paginazione								
    **/
    public void Next(){
		standardSetController.next();
        orderItemList.clear();
        popolaTable();
    }


    /**
     * @name Previous
     * @description Chiama .previous() sullo standardSetController alla prossima paginazione prende i precedenti n records del set 
     *              (n dipende dal paramentro passato in setPageSize)
     *		    Pulisce la Table e ripopola con il metodo popolaTable() chiamando una nuova paginazione
    **/
    public void Previous(){
		standardSetController.previous();
        orderItemList.clear();
        popolaTable();
    }

    /**
     * @name Last
     * @description Chiama .first() sullo standardSetController alla prossima paginazione prende gli ultimi n o <n records del set 
     *	            (n dipende dal paramentro passato in setPageSize)
     *		    Pulisce la Table e ripopola con il metodo popolaTable() chiamando una nuova paginazione
    **/
    public void Last(){
		standardSetController.last();
        orderItemList.clear();
        popolaTable();
    }

    /**
     * @name GetHasPrevious
     * @description Ritorna True se lo standardSetController ha record che sono già stati paginati
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description Ritorna True se lo standardSetController ha ancora altri record da poter paginare
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
	}

    /**
     * @name GetTotalPages
     * @description 
    **/
    public Integer GetTotalPages(){
        Decimal totalPages = standardSetController.getResultSize() / Constants.DEFAULT_ROWS;
        if(Math.mod(standardSetController.getResultSize(),Constants.DEFAULT_ROWS) == 0){ 
            return (Integer) totalPages;
        } else{
            return (Integer) totalPages + 1;
        }
        
    }

    /**
     * @name GetPageNumber
     * @description https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/apex_ApexPages_StandardSetController_methods.htm
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description Product2Extension.cls
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> familyOptions = new List<SelectOption>();
        SelectOption so1 = new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE);
        familyOptions.add(so1);
        for(Schema.PicklistEntry spe : Constants.PRODUCT_FAMILY){
            SelectOption so2 = new SelectOption(spe.getValue(), spe.getLabel());
            familyOptions.add(so2);
        }
        return familyOptions;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}
