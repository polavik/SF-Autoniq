public with sharing class ATNQRulesEngine {
	public static final string DATE_RANGE_TYPE = 'Date_Range';
    public static List<Rule> parse(sObject record, String[] fieldsParts, String[] valuesParts, String [] operand, String [] recordTypes) {
        system.debug('valuesParts ' + valuesParts);
        system.debug('operand ' + operand);
        List<Rule> rules = new List<Rule>();

        if (fieldsParts.size() != valuesParts.size()) {
            throw new RulesEngineException('Length of fields did not match length of values');
        }

        for (integer i = 0; i < fieldsParts.size(); i++) {
            if (recordTypes[i] == DATE_RANGE_TYPE) {
                Date field = (Date) ATNQDynamicPathUtility.getValue(record, fieldsParts[i].trim());
                Date value = (Date) ATNQDynamicPathUtility.getValue(record, valuesParts[i].trim());
                rules.add(new IsWithinDates(field, value));
            }
            else {
            	if (operand[i] == '=') {
            		Object field = ATNQDynamicPathUtility.getValue(record, fieldsParts[i].trim());
    	        	Object value = valuesParts[i].trim();
                    string strValue = (string) value;
    	            if (value == 'notnull') {
    	                rules.add(new NotNullRule(field));
    	            }
    	            else if (value == 'null') {
    	                rules.add(new NullRule(field));
    	            }
    	            else {
                        if ( strValue.contains(',')) {
                            system.debug('- IsEqualMultipleValueRule ' + strValue);
                           rules.add(new IsEqualMultipleValueRule(field, strValue.split(',')));
                        }
                        else {
                            system.debug('- IsEqualRule ' + value);
    	                   rules.add(new IsEqualRule(field, value));
                       }
    	            }
                }
                else if (operand[i] == '>' ) {
                	try {
                	
    	            	Decimal field = (Decimal) ATNQDynamicPathUtility.getValue(record, fieldsParts[i].trim());
    		        	Decimal value = Decimal.valueOf(valuesParts[i].trim());
    	            	rules.add(new IsGreaterThan(field, value));            		
                	}
                	catch (Exception e) {
                		throw new RulesEngineException(e.getMessage() + ' - ' + e.getStackTraceString());
                	}
                }
                else if (operand[i] == '<' ) {
                	try {
                		Decimal field = (Decimal) ATNQDynamicPathUtility.getValue(record, fieldsParts[i].trim());
    	        		Decimal value = Decimal.valueOf(valuesParts[i].trim());
                		rules.add(new IsLessThan(field, value));
                	}
                	catch (Exception e) {
                		throw new RulesEngineException(e.getMessage());
                	}
                }
                else if (operand[i] == '>=' ) {
                	try {
                		Decimal field = (Decimal) ATNQDynamicPathUtility.getValue(record, fieldsParts[i].trim());
    	        		Decimal value = Decimal.valueOf(valuesParts[i].trim());
                		rules.add(new IsGreaterThanOrEqual(field, value));
                	}
                	catch (Exception e) {
                		throw new RulesEngineException(e.getMessage());
                	}
                }
                else if (operand[i] == '<=' ) {
                	try {
                		Decimal field = (Decimal) ATNQDynamicPathUtility.getValue(record, fieldsParts[i].trim());
    	        		Decimal value = Decimal.valueOf(valuesParts[i].trim());
                		rules.add(new IsLessThanOrEqual(field, value));
                	}
                	catch (Exception e) {
                		throw new RulesEngineException(e.getMessage());
                	}
                }
            }
        }

        return rules;
    }
   

    public static boolean test(Rule[] rules) {
        for (Rule r : rules) {
            if (!r.test())
                return false;
        }
        return true;
    }

    public class RulesEngineException extends Exception {}

    public abstract class Rule {
        public Rule(Object val1) {
            this.Value1 = val1;
        }

        public Object Value1 { get; private set; }

        public abstract boolean test();
    }

    public abstract class TwoValueRule extends Rule {
        public TwoValueRule(Object val1, Object val2) {
            super(val1);

            this.Value2 = val2;
        }

        public Object Value2 { get; private set; }
    }

    public class NullRule extends Rule {
        public NullRule(Object val1) {
            super(val1);
        }

        public override boolean test() {
            Boolean result = false;
            if(Value1 == null){
                result = true;
            }
            else{
                try{
                    Decimal value = (Decimal) Value1;
                    if (value == 0) result = true;
                }
                catch (TypeException e){
                    result = false;
                }
            }
            return result;
        }
    }

    public class NotNullRule extends Rule {
        public NotNullRule(Object val1) {
            super(val1);
        }

        public override boolean test() {
            return !(new NullRule(Value1).test());
        }
    }

    public class IsEqualRule extends TwoValueRule {
        public IsEqualRule(Object val1, Object val2) {
            super(val1, val2);
        }

        public override boolean test() {
            return Value1 == Value2;
        }
    }

    public class IsEqualMultipleValueRule extends Rule {
        public string [] multiValues;
        public IsEqualMultipleValueRule(Object val1, string [] val2) {
            super(val1);
            this.multiValues = val2;
        }

        public override boolean test() {
            //boolean isEvaluatedTrue = false;
            for (string v2 : multiValues) {
                system.debug('### ' + v2);
                if (new IsEqualRule(Value1, v2.trim()).test()) {
                    return true;
                }
            }
            return false;
        }
    }

    public class IsGreaterThan extends TwoValueRule {
        public IsGreaterThan(Decimal val1, Decimal val2) {
            super(val1, val2);
        }

        public override boolean test() {
            return (Decimal) Value1 > (Decimal) Value2;            
        }
    }

    public class IsGreaterThanOrEqual extends TwoValueRule {
        public IsGreaterThanOrEqual(Decimal val1, Decimal val2) {
            super(val1, val2);
        }

        public override boolean test() {            
            return (Decimal) Value1 >= (Decimal) Value2;    
        }
    }

    public class IsLessThanOrEqual extends TwoValueRule {
        public IsLessThanOrEqual(Decimal val1, Decimal val2) {
            super(val1, val2);
        }

        public override boolean test() {            
            return (Decimal) Value1 <= (Decimal) Value2;
        }
    }

    public class IsLessThan extends TwoValueRule {
        public IsLessThan(Decimal val1, Decimal val2) {
            super(val1, val2);
        }

        public override boolean test() {            
            return (Decimal) Value1 < (Decimal) Value2;
        }
    }

    public class IsWithinDates extends TwoValueRule {
        public IsWithinDates(Date val1,  Date val2) {
            super(val1, val2);
        }

        public override boolean test() {
            return (Date) system.today() >= (Date) Value1 && (Date) system.today() <= (Date) Value2;            
        }
    }

}