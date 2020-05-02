/*
 * generated by Xtext 2.20.0
 */
package it.unica.co2.diogenes.ide

import com.google.inject.Guice
import it.unica.co2.diogenes.DiogenesRuntimeModule
import it.unica.co2.diogenes.DiogenesStandaloneSetup
import org.eclipse.xtext.util.Modules2

/**
 * Initialization support for running Xtext languages as language servers.
 */
class DiogenesIdeSetup extends DiogenesStandaloneSetup {

    override createInjector() {
        Guice.createInjector(Modules2.mixin(new DiogenesRuntimeModule, new DiogenesIdeModule))
    }

}
