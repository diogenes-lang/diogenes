package it.unica.co2.ui.handlers;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.runtime.CoreException;


public class JavaHonestyHandler extends HonestyHandler {

	@Override
	public void checkHonesty(IResource resource) {
			
		
		IProject project = resource.getProject();
		
		
//		MessageConsole console = findConsole("CO2 plug-in: maude honesty check");
//		console.clearConsole();
//		
//		showConsoleView(console);		//if the console view is close, open and focus on it
//		
//		try (
//				MessageConsoleStream output = console.newMessageStream()
//		){
//			
//			MaudeConfiguration conf = getMaudeConfiguration();
//			
//			MaudeExecutor maudeExecutor = new MaudeExecutor(conf);
//			maudeExecutor.redirectOutput(output);
//			
//			HonestyResult result = maudeExecutor.checkHonesty(content);
//			printHonestyResult(result, output);
//			
//		}
//		catch (IOException e) {
//			e.printStackTrace();
//		}
//
	}

}
