package it.unica.co2.ui.preferences;

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.jface.preference.IPreferenceStore;

import it.unica.co2.ui.internal.CO2Activator;

/**
 * Set default values to the properties related to maude honesty checking
 * 
 * @author Nicola Atzei
 * 
 * @see MaudeHonestyPreferences
 */
public class MaudeDefaultInitializer extends AbstractPreferenceInitializer {


	@Override
	public void initializeDefaultPreferences() {
		IPreferenceStore store = CO2Activator.getInstance().getPreferenceStore();
		
		store.setDefault(MaudeHonestyPreferences.HONESTY_MAUDE_DELETE_TEMP_FILE, true);
		store.setDefault(MaudeHonestyPreferences.HONESTY_MAUDE_PRINT_IN, false);
		store.setDefault(MaudeHonestyPreferences.HONESTY_MAUDE_PRINT_OUT, false);
		store.setDefault(MaudeHonestyPreferences.HONESTY_MAUDE_EXEC, "/bin/maude");
		store.setDefault(MaudeHonestyPreferences.HONESTY_MAUDE_CO2_DIR, System.getProperty("user.home")+"/co2-maude");
	}

}
