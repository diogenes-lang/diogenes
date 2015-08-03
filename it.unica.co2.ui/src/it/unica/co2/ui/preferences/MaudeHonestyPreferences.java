package it.unica.co2.ui.preferences;

import java.io.File;

import org.eclipse.jface.preference.BooleanFieldEditor;
import org.eclipse.jface.preference.DirectoryFieldEditor;
import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.FileFieldEditor;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;

import it.unica.co2.ui.internal.ContractsActivator;

/**
 * Define the properties' page related to maude honesty checking
 * 
 * @author Nicola Atzei
 */
public class MaudeHonestyPreferences extends FieldEditorPreferencePage implements IWorkbenchPreferencePage {

	public static final String HONESTY_MAUDE_DELETE_TEMP_FILE = "honesty.maude.delete-temp-file";
	public static final String HONESTY_MAUDE_CO2_DIR = "honesty.maude.co2-dir";
	public static final String HONESTY_MAUDE_EXEC = "honesty.maude.exec";
	public static final String HONESTY_MAUDE_PRINT_IN = "honesty.maude.print-in";
	public static final String HONESTY_MAUDE_PRINT_OUT = "honesty.maude.print-out";

	public MaudeHonestyPreferences() {
		super(GRID);
	}
	
	@Override
	public void createFieldEditors() {
		
		DirectoryFieldEditor co2MaudeDirField = new DirectoryFieldEditor(HONESTY_MAUDE_CO2_DIR, "&CO2 maude directory:", getFieldEditorParent());
		co2MaudeDirField.setFilterPath(new File(System.getProperty("user.home")));
		addField(co2MaudeDirField);
		
		FileFieldEditor maudeExecField = new FileFieldEditor(HONESTY_MAUDE_EXEC, "&Maude executable:", getFieldEditorParent());
		maudeExecField.setFilterPath(new File(System.getProperty("user.home")));
		addField(maudeExecField);
		
		addField(new BooleanFieldEditor(HONESTY_MAUDE_DELETE_TEMP_FILE, "&Delete temporary file", getFieldEditorParent()));
		addField(new BooleanFieldEditor(HONESTY_MAUDE_PRINT_IN, "&Print input maude process", getFieldEditorParent()));
		addField(new BooleanFieldEditor(HONESTY_MAUDE_PRINT_OUT, "&Print output stream", getFieldEditorParent()));
	}

	@Override
	public void init(IWorkbench workbench) {
		setPreferenceStore(ContractsActivator.getInstance().getPreferenceStore());
	}

}
