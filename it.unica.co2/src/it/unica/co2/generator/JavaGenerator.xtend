package it.unica.co2.generator

import it.unica.co2.generator.AbstractIGenerator
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess

class JavaGenerator extends AbstractIGenerator {
	
	String basepathOfGeneratedFiles = "java"
	
	override doGenerate(Resource input, IFileSystemAccess fsa) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
}