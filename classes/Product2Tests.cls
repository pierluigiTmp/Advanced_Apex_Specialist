@isTest 
private class Product2Tests {
    
    /**
* @name product2Extension_UnitTest
* @description UnitTest for product2Extension
**/
    static TestMethod void Product2Extension_UnitTest(){
        //Istanziamento della pagina Product2New per simulare utente
        PageReference pageRef = page.Product2New;
        //Creo uno standard controller e passo un oggetto Product2 fantoccio
        ApexPages.StandardController standardController = new ApexPages.StandardController(new Product2());
        Test.startTest();
        //Passo la reference dello standard controller all'estensione 
        Product2Extension ext = new Product2Extension(standardController);
        //Test addRows()
        System.assertEquals(ext.productsToInsert.size(), Constants.DEFAULT_ROWS);
        ext.addRows();
        System.assertEquals(ext.productsToInsert.size(), Constants.DEFAULT_ROWS*2);
        //Test save()
        for(Integer i = 0; i < Constants.DEFAULT_ROWS; i++){
            ext.productsToInsert[i].productRecord.Name = 'Prodotto ' + i;
            ext.productsToInsert[i].productRecord.Family = ext.GetFamilyOptions()[1].getValue();
            ext.productsToInsert[i].productRecord.isActive = True;
            ext.productsToInsert[i].productRecord.Initial_Inventory__c = 10;
            ext.productsToInsert[i].pricebookEntryRecord.UnitPrice = 1;
        }
        ext.save();
        List<Product2> products = [SELECT Id FROM Product2];
        System.assertEquals(products.size(), Constants.DEFAULT_ROWS);
        Test.stopTest();
    }
    
    
    static TestMethod void Product2Trigger_UnitTest(){
        insert TestDataFactory.ConstructCollaborationGroup();
        List<Product2> ps = new List<Product2>();
        for(Integer i = 0; i < 150; i++){
            Product2 p = new Product2(Name = 'Product ' + i, isActive = True, Initial_Inventory__c = 21, Family = 'Entree');
            ps.add(p);
        }
        insert ps;
        List<Product2> ps1 = [SELECT Id FROM Product2 WHERE Id IN :ps];
        for(Product2 p : ps1){
            p.Quantity_Ordered__c = 2;
        }
        Test.startTest();
        update ps1;
        Test.stopTest();
        
    }
    
    static TestMethod void ChartHelper_UnitTest(){
        TestDataFactory.InsertTestData(20);
        List<ChartHelper.ChartData> cdc = ChartHelper.GetInventory();
        List<AggregateResult> aggResults = [SELECT Family, SUM(Quantity_Remaining__c)Quantity_Remaining__c FROM Product2 
                                            WHERE isActive = True AND Quantity_Remaining__c > 0 GROUP BY Family];
        for(Integer i = 0; i < cdc.size(); i++){      
            System.assertEquals(cdc[i].name, String.valueOf(aggResults[i].get('Family')));
            System.assertEquals(cdc[i].val, Integer.valueOf(aggResults[i].get('Quantity_Remaining__c')));                 
            
        }
    }
    
    
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    
}
