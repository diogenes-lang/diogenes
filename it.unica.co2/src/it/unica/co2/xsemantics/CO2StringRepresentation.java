package it.unica.co2.xsemantics;

import it.unica.co2.co2.BooleanType;
import it.unica.co2.co2.IntType;
import it.unica.co2.co2.SessionType;
import it.unica.co2.co2.StringType;
import it.unica.co2.co2.Type;
import it.xsemantics.runtime.StringRepresentation;

public class CO2StringRepresentation extends StringRepresentation {

	protected String stringRep(Type e) {
		return e.getValue();
	}
	
	protected String stringRep(IntType e) {
		return "int";
	}
	
	protected String stringRep(BooleanType e) {
		return "boolean";
	}
	
	protected String stringRep(StringType e) {
		return "string";
	}
	
	protected String stringRep(SessionType e) {
		return "session";
	}
	
	
	protected String stringRep(String s) {
        return "'" + s + "'";
    }
}
