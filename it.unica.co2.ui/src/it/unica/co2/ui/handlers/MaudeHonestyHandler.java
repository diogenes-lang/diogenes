package it.unica.co2.ui.handlers;

import java.io.IOException;

import org.eclipse.core.resources.IResource;
import org.eclipse.ui.console.MessageConsole;
import org.eclipse.ui.console.MessageConsoleStream;

import it.unica.co2.honesty.HonestyResult;
import it.unica.co2.honesty.MaudeConfiguration;
import it.unica.co2.honesty.MaudeExecutor;


public class MaudeHonestyHandler extends HonestyHandler {

	@Override
	public void checkHonesty(IResource resource) {
			
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

}
