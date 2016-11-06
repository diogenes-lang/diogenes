/*
 * generated by Xtext
 */
package it.unica.co2;

import it.unica.co2.xsemantics.CO2StringRepresentation;
import it.xsemantics.runtime.StringRepresentation;

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
public class CO2RuntimeModule extends it.unica.co2.AbstractCO2RuntimeModule {

	/*
	 * custom implementation for xsemantics.
	 */
	public Class<? extends StringRepresentation> bindStringRepresentation() {
		return CO2StringRepresentation.class;
	}
	
}
