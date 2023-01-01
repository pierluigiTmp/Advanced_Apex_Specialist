public without sharing class ChartHelper {
	
    @AuraEnabled 
    public static List<chartData> GetInventory(){
        List<chartData> cht = new List<chartData>();
        //Done: Perform a calculation that aggregates active Products that have a positive Quantity_Remaining__c | WHERE isActive = True AND Quantity_Remaining__c > 0
        //  	And return a list of chartData
        //  	Where the name is the Product Family and the Qty is the sum of the Quantity_Remaining__c | SELECT Family, SUM(Quantity_Remaining__c) GROUP BY Family
        List<AggregateResult> aggResults = [SELECT Family, SUM(Quantity_Remaining__c)Quantity_Remaining__c FROM Product2 
					    WHERE isActive = True AND Quantity_Remaining__c > 0 GROUP BY Family];
        for(AggregateResult ar : aggResults){      
            cht.add(new ChartData(String.valueOf(ar.get('Family')), Integer.valueOf(ar.get('Quantity_Remaining__c'))));
        }
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}
