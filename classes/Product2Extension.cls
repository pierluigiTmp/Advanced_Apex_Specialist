//Done: Override dei bottoni New e Add sull'oggetto Product2 con Product2New
public class Product2Extension {
    
    //Done: Creare classe wrapper che associa Product2 e relativo PriceBookEntry
    public class ProductWrapper{
        public Product2 productRecord {get;set;}
        public PriceBookEntry pricebookEntryRecord {get;set;}
        public ProductWrapper(Product2 p2, PriceBookEntry pbe){
            this.productRecord = p2;
            this.pricebookEntryRecord = pbe;
        }
    }
    
    //Done: Sostituire List<Product2> con List<ProductWrapper> 
    public List<ProductWrapper> productsToInsert {get;set;}
    
    //Done: Finire costruttore per l'estensione dello standard controller Product2 per poter fare l'override
    public Product2Extension(ApexPages.StandardController stdController){
        this.productsToInsert = new List<ProductWrapper>();
        addRows();
    }
    
    //Done: Possibilità di aggiungere più rows con un click; utilizzare DEFAULT_ROWS
    public void AddRows(){
        for ( Integer i=0; i<Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper(new Product2(), new PriceBookEntry()));
        }
    }
    
    //Done: Creare metodo GetFamilyOptions utilizzando PRODUCT_FAMILY e SELECT_ONE (label default)
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
    
    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }
    //Done: Per ogni Product2 creare PriceBookEntry e relazionare il PriceBookEntry 
    //		al record StandardPriceBook sull'oggetto PriceBook, utilizzare STANDARD_PRICEBOOK_ID
    //		Inserire Product2 per trovare gli oggetti ProductWrapper (ProductWrapper.Product2.Id != NULL) con i PriceBookEntry da inserire
    //		PER ESSERE INSERITI I ROWS IN INPUT DEVONO AVERE TUTTI E 4 I CAMPI POPOLATI 
    public PageReference Save(){
        Set<Product2> productsToInsertSet = new Set<Product2>();
        for(ProductWrapper pw : productsToInsert){
            
            if(pw.productRecord.Name != NULL && pw.productRecord.Family != Constants.SELECT_ONE
               && pw.pricebookEntryRecord.UnitPrice != NULL && pw.pricebookEntryRecord.UnitPrice > 0 && 
               pw.productRecord.Initial_Inventory__c > 0 && pw.productRecord.Initial_Inventory__c != NULL){
                   productsToInsertSet.add(pw.productRecord);
               }
        }
        Savepoint sp1 = Database.setSavepoint();
        if(!productsToInsertSet.isEmpty()){
            try {
                List<Product2> productsToInsertList = new List<Product2>(productsToInsertSet);
                insert(productsToInsertList);
                //Pulizia lista
                productsToInsertList.clear();
                
            } catch(DMLexception e) {
                apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
                Database.rollback(sp1);
            }
            //Prendo PriceBookEntry nello stesso oggetto ProductWrapper dei Product2 inseriti, assegno Product2Id e Pricebook2Id 
            //e aggiungo a lista PriceBookEntry da inserire
            List<PriceBookEntry> priceBookEntriesToInsert = new List<PriceBookEntry>();
            for(ProductWrapper pw : productsToInsert){
                if(pw.productRecord.Id != NULL){
                    pw.pricebookEntryRecord.Product2Id = pw.productRecord.Id;
                    pw.pricebookEntryRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                    priceBookEntriesToInsert.add(pw.pricebookEntryRecord);
                }
            }
            Savepoint sp2 = Database.setSavepoint();
            try {
                insert priceBookEntriesToInsert;
                //If successful clear the list and display an informational message
                apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsertSet.size()+' prodotti inseriti.'));
                //Pulizia liste e set
                productsToInsertSet.clear();
                productsToInsert.clear();
                priceBookEntriesToInsert.clear();
                addRows();  
            } catch (Exception e){
                apexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE));
                Database.rollback(sp2);
            }
        }
        return null;
        
    }
}
