@isTest 
private class OrderTests {
    
    @testSetup static void SetupTestData() {
    	TestDataFactory.InsertTestData(5);
    }
    
    @isTest private static void OrderUpdate_UnitTest(){
        Order o = [SELECT Id FROM Order LIMIT 1];
		OrderItem oi = [SELECT PricebookEntry.Product2.Id, Quantity FROM OrderItem WHERE OrderId = :o.Id];
		Product2 productBeforeUpdate = [SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id = :oi.PricebookEntry.Product2.Id LIMIT 1];
        o.Status = Constants.ACTIVATED_ORDER_STATUS;
        update o;
        Product2 productAfterUpdate = [SELECT Id, Quantity_Ordered__c FROM Product2 WHERE Id = :oi.PricebookEntry.Product2.Id LIMIT 1];
        //Test.startTest();
        TestDataFactory.VerifyQuantityOrdered(productBeforeUpdate, productAfterUpdate, Constants.DEFAULT_ROWS);
		//Test.stopTest();               
    }
    
    @isTest private static void OrderExtension_UnitTest(){
	OrderExtension_UnitTest_RecordNotNull();
        OrderExtension_UnitTest_RecordNull();
    }
    
    private static void OrderExtension_UnitTest_RecordNull(){
        PageReference pageRef = page.OrderEdit;
        ApexPages.StandardController standardController = new ApexPages.StandardController(new Order());
        OrderExtension ext = new OrderExtension(standardController);
        ext.Save();
    }
    
    
    private static void OrderExtension_UnitTest_RecordNotNull(){
        Order o = [SELECT Id FROM Order LIMIT 1];
        PageReference pageRef = page.OrderEdit;
        ApexPages.StandardController standardController = new ApexPages.StandardController(o);
        OrderExtension ext = new OrderExtension(standardController);
        ext.selectedFamily = ext.GetFamilyOptions()[1].getValue();
        ext.SelectFamily();
        ext.selectedFamily = ext.GetFamilyOptions()[0].getValue();
        ext.SelectFamily();
        ext.OnFieldChange();
        ext.GetPageNumber();
        ext.GetTotalPages();
        ext.GetHasNext();
        ext.GetHasPrevious();
        ext.Last();
        ext.Previous();
        ext.Next();
        ext.First();
        ext.Save();
        
    }
}
