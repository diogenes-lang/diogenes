/*
 * generated by Xtext 2.21.0.M3
 */
package it.unica.co2.diogenes;


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
public class DiogenesStandaloneSetup extends DiogenesStandaloneSetupGenerated {

	public static void doSetup() {
		new DiogenesStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}
