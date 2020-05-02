package it.unica.co2.diogenes.ui.handlers;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;

import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.WorkspaceJob;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.preference.IPreferenceStore;

import it.unica.co2.diogenes.ui.internal.DiogenesActivator;
import it.unica.co2.diogenes.ui.preferences.MaudePreferences;
import it.unica.co2.honesty.HonestyResult;
import it.unica.co2.honesty.MaudeConfiguration;
import it.unica.co2.honesty.MaudeExecutor;

public class MaudeJob extends WorkspaceJob {

    private IResource maudeFile;
    private PrintStream out;
    private MaudeExecutor maudeExecutor;

    public MaudeJob(IResource maudeFile, OutputStream out) {
        super("Maude Honesty Checker");
        this.maudeFile = maudeFile;
        this.out = new PrintStream(out);

        MaudeConfiguration conf = getMaudeConfiguration();

        maudeExecutor = new MaudeExecutor(conf);
        maudeExecutor.redirectOutput(out);
    }

    @Override
    public IStatus runInWorkspace(IProgressMonitor monitor) throws CoreException {

        monitor.beginTask("Checking the honesty of " + maudeFile.getName() + "", IProgressMonitor.UNKNOWN);

        Thread maudeJobThread = Thread.currentThread(); // the thread started by the UI

        /*
         * The purpose of the poller is check if the user perform the 'cancel' operation
         * (polling). If it is the case, the maude thread is interrupted and will kill
         * its subprocess.
         */
        Thread poller = new Thread(new Runnable() {

            @Override
            public void run() {

                System.out.println("T-ID (pooler): " + Thread.currentThread().getId());

                boolean loop = true;

                while (loop) {

                    try {

                        if (monitor.isCanceled()) { // stop condition

                            out.println("-------------------------------------------------- aborted by the user");
                            maudeJobThread.interrupt();

                            loop = false;
                        }

                        Thread.sleep(1000);

                    } catch (InterruptedException e) {
                        // this part should never be executed
                        loop = false;
                        e.printStackTrace();
                    }
                }

            }
        });

        poller.start(); // start the poller

        checkHonesty(); // check the honesty of the maude file

        monitor.done(); // notify the end og the task

        return Status.OK_STATUS;
    }

    public void checkHonesty() {

        String content = readResource(maudeFile); // read the file

        HonestyResult result = maudeExecutor.checkHonesty(content); // invoke the model-checker

        printHonestyResult(result, out); // print the result to the console
    }

    @SuppressWarnings("incomplete-switch")
    protected void printHonestyResult(HonestyResult result, PrintStream out) {

        out.println("-------------------------------------------------- result");

        switch (result) {

        case HONEST:
            out.println("honesty: true");
            break;

        case DISHONEST:
            out.println("honesty: false");
            break;

        case UNKNOWN:
            out.println("honesty: unknown");
            break;
        }

        out.println("--------------------------------------------------");
    }

    /**
     * Read the given IResource and return its content as String.
     *
     * @param resource
     * @return the content of the IResource
     */
    protected String readResource(IResource resource) {

        File file = new File(resource.getLocationURI());

        StringBuilder output = new StringBuilder();

        try (BufferedReader input = new BufferedReader(new FileReader(file))) {
            String line;

            while ((line = input.readLine()) != null) {
                output.append(line).append('\n');
            }
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }

        return output.toString();
    }

    private MaudeConfiguration getMaudeConfiguration() {

        // get the properties
        final IPreferenceStore preferences = DiogenesActivator.getInstance().getPreferenceStore();

        System.out.println("----------------- MaudeConfiguration ------------------");
        System.out.println("in: " + preferences.getString(MaudePreferences.HONESTY_MAUDE_PRINT_IN));
        System.out.println("out: " + preferences.getString(MaudePreferences.HONESTY_MAUDE_PRINT_OUT));
        System.out.println("delete: " + preferences.getString(MaudePreferences.HONESTY_MAUDE_DELETE_TEMP_FILE));
        System.out.println("exec: " + preferences.getString(MaudePreferences.HONESTY_MAUDE_EXEC));
        System.out.println("co2-dir: " + preferences.getString(MaudePreferences.HONESTY_MAUDE_CO2_DIR));
        System.out.println("timeout: " + preferences.getString(MaudePreferences.HONESTY_MAUDE_TIMEOUT));

        return new MaudeConfiguration() {

            @Override
            public boolean showInput() {
                return preferences.getBoolean(MaudePreferences.HONESTY_MAUDE_PRINT_IN);
            }

            @Override
            public boolean showOutput() {
                return preferences.getBoolean(MaudePreferences.HONESTY_MAUDE_PRINT_OUT);
            }

            @Override
            public boolean isDeleteTempFile() {
                return preferences.getBoolean(MaudePreferences.HONESTY_MAUDE_DELETE_TEMP_FILE);
            }

            @Override
            public File getMaudeExec() {
                return new File(preferences.getString(MaudePreferences.HONESTY_MAUDE_EXEC));
            }

            @Override
            public File getCo2MaudeDir() {
                return new File(preferences.getString(MaudePreferences.HONESTY_MAUDE_CO2_DIR));
            }

            @Override
            public int timeout() {
                return preferences.getInt(MaudePreferences.HONESTY_MAUDE_TIMEOUT);
            }

        };
    }
}
