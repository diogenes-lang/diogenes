package it.unica.co2.diogenes.xsemantics;

import org.eclipse.xsemantics.runtime.StringRepresentation;

import it.unica.co2.diogenes.diogenes.BooleanType;
import it.unica.co2.diogenes.diogenes.IntType;
import it.unica.co2.diogenes.diogenes.SessionType;
import it.unica.co2.diogenes.diogenes.StringType;
import it.unica.co2.diogenes.diogenes.Type;

public class DiogenesStringRepresentation extends StringRepresentation {

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
