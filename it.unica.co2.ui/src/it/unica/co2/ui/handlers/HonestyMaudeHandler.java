package it.unica.co2.ui.handlers;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IResource;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.TreeSelection;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.console.ConsolePlugin;
import org.eclipse.ui.console.IConsole;
import org.eclipse.ui.console.IConsoleConstants;
import org.eclipse.ui.console.IConsoleManager;
import org.eclipse.ui.console.IConsoleView;
import org.eclipse.ui.console.MessageConsole;
import org.eclipse.ui.console.MessageConsoleStream;
import org.eclipse.ui.handlers.HandlerUtil;

import it.unica.co2.honesty.HonestyResult;
import it.unica.co2.honesty.MaudeConfiguration;
import it.unica.co2.honesty.MaudeExecutor;
import it.unica.co2.ui.internal.CO2Activator;
import it.unica.co2.ui.preferences.MaudeHonestyPreferences;


public class HonestyMaudeHandler extends AbstractHandler {

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {

		ISelection selection = HandlerUtil.getCurrentSelection(event);
		
		if (selection instanceof TreeSelection) {
			
			TreeSelection tree = (TreeSelection) selection;
			
			for (Object obj : tree.toList()) {
				
				if (obj instanceof IResource) {
					IResource resource = (IResource) obj;
					checkHonesty(resource);
				}
				else {
					System.out.println("[WARN] HonestyMaudeHandler: unexpected class "+obj.getClass());
				}
			}
		}
		else {
			System.out.println("[WARN] HonestyMaudeHandler: unexpected class "+selection.getClass());
		}
		
		return null;
	}

	
	private void checkHonesty(IResource resource) {
		
		String content = readResource(resource);
		
		MessageConsole console = findConsole("CO2 plug-in: maude honesty check");
		console.clearConsole();
		
		showConsoleView(console);		//if the console view is close, open and focus on it
		
		try (
				MessageConsoleStream output = console.newMessageStream()
		){
			
			MaudeConfiguration conf = getMaudeConfiguration();
			
			MaudeExecutor maudeExecutor = new MaudeExecutor(conf);
			maudeExecutor.redirectOutput(output);
			
			HonestyResult result = maudeExecutor.checkHonesty(content);
			printHonestyResult(result, output);
			
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	
	private void printHonestyResult(HonestyResult result, MessageConsoleStream out) {
		out.println("-------------------------------------------------- result");
		
		switch(result){
		
		case HONEST:
			out.println("honesty: true");
			break;
		
		case DISHONEST:
			out.println("honesty: false");
			break;
			
		case UNKNOWN:
			out.println("sorry, we can't check the honesty of your process due to some errors.");
			break;
		}

		out.println("--------------------------------------------------");
	}
	
	/**
	 * Read the given IResource and return its content as String.
	 * @param resource
	 * @return the content of the IResource
	 */
	private String readResource(IResource resource) {
		
		File file = new File(resource.getLocationURI());
		
		StringBuilder output = new StringBuilder();
		
		try (
				BufferedReader input = new BufferedReader(new FileReader(file))
		){
			String line;
			
			while ((line=input.readLine())!=null) {
				output.append(line).append('\n');
			}
		}
		catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		
		return output.toString();
	}
	
	
	
	
	
	private void showConsoleView(MessageConsole console) {
		
		/*
		 * get the active page
		 */
		IWorkbench wb = PlatformUI.getWorkbench();
		IWorkbenchWindow win = wb.getActiveWorkbenchWindow();
		IWorkbenchPage page = win.getActivePage();


		String id = IConsoleConstants.ID_CONSOLE_VIEW;
		IConsoleView view;
		
		try {
			view = (IConsoleView) page.showView(id);
			view.display(console);
		}
		catch (PartInitException e) {
			e.printStackTrace();
		}
	}
	
	
	
	private MessageConsole findConsole(String name) {
		ConsolePlugin plugin = ConsolePlugin.getDefault();
		IConsoleManager conMan = plugin.getConsoleManager();
		IConsole[] existing = conMan.getConsoles();
		
		for (int i = 0; i < existing.length; i++)
			if (name.equals(existing[i].getName()))
				return (MessageConsole) existing[i];
		
		// no console found, so create a new one
		MessageConsole myConsole = new MessageConsole(name, null);
		conMan.addConsoles(new IConsole[] { myConsole });
		return myConsole;
	}
	
	
	
	private MaudeConfiguration getMaudeConfiguration() {
		
		// get the properties
		final IPreferenceStore preferences = CO2Activator.getInstance().getPreferenceStore();

		System.out.println("----------------- MaudeConfiguration ------------------");
		System.out.println("in: "+preferences.getString(MaudeHonestyPreferences.HONESTY_MAUDE_PRINT_IN));
		System.out.println("out: "+preferences.getString(MaudeHonestyPreferences.HONESTY_MAUDE_PRINT_OUT));
		System.out.println("delete: "+preferences.getString(MaudeHonestyPreferences.HONESTY_MAUDE_DELETE_TEMP_FILE));
		System.out.println("exec: "+preferences.getString(MaudeHonestyPreferences.HONESTY_MAUDE_EXEC));
		System.out.println("co2-dir: "+preferences.getString(MaudeHonestyPreferences.HONESTY_MAUDE_CO2_DIR));
		System.out.println("timeout: "+preferences.getString(MaudeHonestyPreferences.HONESTY_MAUDE_TIMEOUT));
		
		return  new MaudeConfiguration() {
			
			@Override
			public boolean showInput() {
				return preferences.getBoolean(MaudeHonestyPreferences.HONESTY_MAUDE_PRINT_IN);
			}
			
			@Override
			public boolean showOutput() {
				return preferences.getBoolean(MaudeHonestyPreferences.HONESTY_MAUDE_PRINT_OUT);
			}
			
			@Override
			public boolean isDeleteTempFile() {
				return preferences.getBoolean(MaudeHonestyPreferences.HONESTY_MAUDE_DELETE_TEMP_FILE);
			}
			
			@Override
			public File getMaudeExec() {
				return new File(preferences.getString(MaudeHonestyPreferences.HONESTY_MAUDE_EXEC));
			}
			
			@Override
			public File getCo2MaudeDir() {
				return new File(preferences.getString(MaudeHonestyPreferences.HONESTY_MAUDE_CO2_DIR));
			}

			@Override
			public int timeout() {
				return preferences.getInt(MaudeHonestyPreferences.HONESTY_MAUDE_TIMEOUT);
			}

		};
	}
	
}
