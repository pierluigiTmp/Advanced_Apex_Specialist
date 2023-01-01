/**
* @name TestDataFactory
* @description Contains methods to construct and/or validate commonly used records
**/
public without sharing class TestDataFactory {
    
    /**
* @name ConstructCollaborationGroup
* @description
**/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //Done: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.ù
        CollaborationGroup cg = new CollaborationGroup(Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS, CollaborationType = 'Public');
        return cg;
    }
    
    /**
* @name CreateProducts
* @description Constructs a list of Product2 records for unit tests
**/
    public static List<Product2> ConstructProducts(Integer cnt){
        //Done: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        Integer j = 0;
        List<Product2> ps = new List<Product2>();
        for(Integer i = 0; i < cnt; i++){
            String family = Constants.PRODUCT_FAMILY[j].getValue();
            Product2 p = new Product2(Name = 'Product ' + i, isActive = True, Initial_Inventory__c = 10, Family = family);
            ps.add(p);
            j = j == Constants.PRODUCT_FAMILY.size() - 1 ? j = 0 : j + 1;
        }
        return ps;
    }
    
    /**
* @name CreatePricebookEntries
* @description Constructs a list of PricebookEntry records for unit tests
**/
    public static List<PriceBookEntry> ConstructPricebookEntries(List<Product2> prods){
        //Done: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        List<PriceBookEntry> pbes = new List<PriceBookEntry>();
        for(Product2 p : prods){
            PriceBookEntry pbe = new PriceBookEntry(IsActive = True, Product2Id = p.Id, Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID, UnitPrice = 10);
            pbes.add(pbe);
        }
        return pbes;
    }
    
    /**
* @name CreateAccounts
* @description Constructs a list of Account records for unit tests
**/
    public static List<Account> ConstructAccounts(Integer cnt){
        //Done: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        List<Account> accs = new List<Account>();
        for(Integer i = 0; i < cnt; i++){
            Account acc = new Account(Name = 'Account ' + i);
            accs.add(acc);
        }
        return accs;
    }
    
    /**
* @name CreateContacts
* @description Constructs a list of Contacxt records for unit tests
**/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //Done: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Contact> contcs =  new List<Contact>();
        
        for(Integer i = 0; i < cnt; i++){
            Contact c = new Contact(LastName = 'Contact ' + i, AccountId = accts[i].Id);
            contcs.add(c);
            
        }
        return contcs;
        
    }
    
    /**
* @name CreateOrders
* @description Constructs a list of Order records for unit tests
**/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //Done: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> orders =  new List<Order>();
        
        for(Integer i = 0; i < cnt; i++){
            Order o = new Order(AccountId = accts[i].Id, Status = 'Draft', EffectiveDate = System.today(), Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID);
            orders.add(o);
            
        }
        return orders;
    }
    
    /**
* @name CreateOrderItems
* @description Constructs a list of OrderItem records for unit tests
**/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //Done: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        
        List<OrderItem> ois = new List<OrderItem>();
        for(Integer i = 0; i<cnt; i++){
            OrderItem oi = new OrderItem(OrderId = ords[i].Id, Quantity = Constants.DEFAULT_ROWS, PricebookEntryId = pbes[i].Id, UnitPrice = 1);
            ois.add(oi);
            
        }
        return ois;
    }
    
    /**
* @name SetupTestData
* @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
**/
    public static void InsertTestData(Integer cnt){
        //Done: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        CollaborationGroup cg = TestDataFactory.ConstructCollaborationGroup();
        insert cg;
        List<Product2> p2s = TestDataFactory.ConstructProducts(cnt);
        insert p2s;
        List<PriceBookEntry> pbes = TestDataFactory.ConstructPricebookEntries(p2s);
        insert pbes;
        List<Account> accs = TestDataFactory.ConstructAccounts(cnt);
        insert accs;
        List<Contact> conts = TestDataFactory.ConstructContacts(cnt, accs);
        insert conts;
        List<Order> os = TestDataFactory.ConstructOrders(cnt, accs);
        insert os;
        List<OrderItem> ois = TestDataFactory.ConstructOrderItems(cnt, pbes, os);
        insert ois;
    }

    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){
        System.assertEquals(originalProduct.Quantity_Ordered__c + qtyOrdered, updatedProduct.Quantity_Ordered__c );
    }

}