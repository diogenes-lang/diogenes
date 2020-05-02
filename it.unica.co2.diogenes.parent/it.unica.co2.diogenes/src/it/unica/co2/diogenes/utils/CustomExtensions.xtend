package it.unica.co2.diogenes.utils

import it.unica.co2.diogenes.diogenes.CO2System
import java.io.File
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.xbase.lib.Functions.Function1

class CustomExtensions {

    /**
     * utils: get a scope for the given clazz type within the whole document
     */
    def static IScope getIScopeForAllContentsOfClass(EObject ctx, Class<? extends EObject> clazz){
        var root = EcoreUtil2.getRootContainer(ctx);                        // get the root
        var candidates = EcoreUtil2.getAllContentsOfType(root, clazz);        // get all contents of type clazz
        return Scopes.scopeFor(candidates);                                    // return the scope
    }

    /**
     * recursively find the first Eobject of the given <code>clazz</code> (from <code>obj</code> up to CO2System)
     */
    def static <T extends EObject> T getFirstUpOccurrenceOf(EObject obj, Class<T> clazz) {
        getFirstUpOccurrenceOf(obj, clazz, [x| x instanceof CO2System])
    }

    /**
     * recursively find the first Eobject of the given <code>clazz</code> (from <code>obj</code> up to <code>upToClazz</code>)
     *
     * @param obj the starting point
     * @param clazz the class of the object you are searching
     * @param uToClazz the ending point
     */
    def static <T extends EObject, T1 extends EObject> T getFirstUpOccurrenceOf(EObject obj, Class<T> clazz, Function1<EObject, Boolean> predicate) {

        if (clazz.isInstance(obj))
            return clazz.cast(obj)

        if (predicate.apply(obj))    // stop search
            return null
        else
            return getFirstUpOccurrenceOf(obj.eContainer, clazz, predicate);
    }

    def static EObject searchTop(EObject obj, Function1<EObject, Boolean> predicate) {

        if (obj instanceof CO2System)
            return null                // emergency stop

        if (predicate.apply(obj))    // stop search
            return obj
        else
            return searchTop(obj.eContainer, predicate);
    }

    /*
     * get the project directory
     */
    def static File getProjectDir(Resource resource) {

        //get the IProject from the given Resource
        val platformString = resource.URI.toPlatformString(true);
        val myFile = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(platformString));
        val project = myFile.getProject();

        //get location of workspace (java.io.File)
        var workspaceDirectory = ResourcesPlugin.getWorkspace().getRoot().getLocation().toFile()

        //get location of the project
        new File(workspaceDirectory, project.name)
    }
}