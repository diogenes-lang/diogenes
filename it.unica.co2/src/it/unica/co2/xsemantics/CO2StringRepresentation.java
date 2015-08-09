package it.unica.co2.xsemantics;

import it.unica.co2.co2.Type;
import it.xsemantics.runtime.StringRepresentation;

public class CO2StringRepresentation extends StringRepresentation {

	protected String stringRep(Type e) {
		return e.getValue();
	}
	
	protected String stringRep(String s) {
        return "'" + s + "'";
    }
}
