package it.unica.co2.utils

import it.unica.co2.co2.CO2System
import java.io.File
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes

class CustomExtensions {
	
	/*
	 * utils: get a scope for the given clazz type
	 */
	def static IScope getIScopeForAllContentsOfClass(EObject ctx, Class<? extends EObject> clazz){
		var root = EcoreUtil2.getRootContainer(ctx);						// get the root
		var candidates = EcoreUtil2.getAllContentsOfType(root, clazz);		// get all contents of type clazz
		return Scopes.scopeFor(candidates);									// return the scope
	}
	
	/*
	 * utils: recursively find the first Eobject of the given class (from <obj> up to <clazz>)
	 */
	def static <T extends EObject> T getFirstUpOccurrenceOf(EObject obj, Class<T> clazz) {
		
		if (obj instanceof CO2System)
			return null
		
		if (clazz.isInstance(obj))
			return clazz.cast(obj)

		return getFirstUpOccurrenceOf(obj.eContainer, clazz);
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