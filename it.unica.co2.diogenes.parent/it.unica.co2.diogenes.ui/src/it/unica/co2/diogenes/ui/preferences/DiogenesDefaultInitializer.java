package it.unica.co2.diogenes.ui.preferences;

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.jface.preference.IPreferenceStore;

import it.unica.co2.diogenes.ui.internal.DiogenesActivator;

/**
 * Set default values to the properties related to maude honesty checking
 * 
 * @author Nicola Atzei
 * 
 * @see MaudePreferences
 */
public class DiogenesDefaultInitializer extends AbstractPreferenceInitializer {

    @Override
    public void initializeDefaultPreferences() {
        IPreferenceStore store = DiogenesActivator.getInstance().getPreferenceStore();

        store.setDefault(MaudePreferences.HONESTY_MAUDE_DELETE_TEMP_FILE, true);
        store.setDefault(MaudePreferences.HONESTY_MAUDE_PRINT_IN, false);
        store.setDefault(MaudePreferences.HONESTY_MAUDE_PRINT_OUT, false);
        store.setDefault(MaudePreferences.HONESTY_MAUDE_EXEC, "/bin/maude");
        store.setDefault(MaudePreferences.HONESTY_MAUDE_CO2_DIR, System.getProperty("user.home") + "/co2-maude");
        store.setDefault(MaudePreferences.HONESTY_MAUDE_TIMEOUT, 10);
    }

}
