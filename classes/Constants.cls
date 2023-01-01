public class Constants {
    
    PUBLIC FINAL STATIC Integer DEFAULT_ROWS = 5;
    PUBLIC FINAL STATIC String SELECT_ONE = System.Label.Select_One;
    PUBLIC FINAL STATIC String INVENTORY_LEVEL_LOW = System.Label.Inventory_Level_Low;
    //Costante lista con valori della picklist Family su Product2
    PUBLIC FINAL STATIC List<Schema.PicklistEntry> PRODUCT_FAMILY;
    //Return lista di valori del field picklist Family su Product2
    private static List<Schema.PicklistEntry> getPicklistValues() {
        Schema.DescribeFieldResult F = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        return P;
    }
    //Assegnazione valore PRODUCT_FAMILY in blocco statico
    static {
        PRODUCT_FAMILY = getPicklistValues();
    }
    PUBLIC FINAL STATIC String DRAFT_ORDER_STATUS = 'Draft';
    PUBLIC FINAL STATIC String ACTIVATED_ORDER_STATUS = 'Activated';
    PUBLIC FINAL STATIC String INVENTORY_ANNOUNCEMENTS = 'Inventory Announcements';
    PUBLIC FINAL STATIC String ERROR_MESSAGE = 'An error has occurred, please take a screenshot with the URL and send it to IT.';
    PUBLIC FINAL STATIC ID STANDARD_PRICEBOOK_ID = '01s68000000BomwAAC';
}