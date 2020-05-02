package it.unica.co2.diogenes.ui.handlers;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.jdt.core.ICompilationUnit;
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
import org.eclipse.ui.handlers.HandlerUtil;


public class HonestyHandler extends AbstractHandler {

    @Override
    public Object execute(ExecutionEvent event) throws ExecutionException {

        ISelection selection = HandlerUtil.getCurrentSelection(event);

        if (selection instanceof TreeSelection) {

            TreeSelection tree = (TreeSelection) selection;

            for (Object obj : tree.toList()) {

                if (obj instanceof IResource) {
                    IResource resource = (IResource) obj;

                    System.out.println("T-ID: "+Thread.currentThread().getId());

                    IProject currentProject = resource.getProject();

                    // get a new console to write in
                    MessageConsole console = getConsole();
                    showConsoleView(console);

                    // start an asynchronous job to verify the honesty
                    MaudeJob maudeJob = new MaudeJob(resource, console.newMessageStream());
                    maudeJob.setRule(currentProject);
                    maudeJob.schedule();

                }
                else if (obj instanceof ICompilationUnit) {
                    ICompilationUnit compilationUnit = (ICompilationUnit) obj;

                    System.out.println(compilationUnit.getElementName());
                    System.out.println(compilationUnit.findPrimaryType());
                }
                else {
                    System.out.println("[WARN] HonestyHandler: unexpected class "+obj.getClass());
                }
            }
        }
        else {
            System.out.println("[WARN] HonestyHandler: unexpected class "+selection.getClass());
        }

        return null;
    }


    private MessageConsole getConsole() {
        MessageConsole console = findConsole("CO2 plug-in: maude honesty checker");
        console.clearConsole();

        showConsoleView(console);        //if the console view is close, open and focus on it

        return console;
    }


    private void showConsoleView(MessageConsole console) {

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



}
