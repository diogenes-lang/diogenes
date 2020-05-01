package it.unica.co2.diogenes.generator

import it.unica.co2.diogenes.diogenes.CO2System
import it.unica.co2.diogenes.diogenes.ProcessDefinition
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.INode

class JavaGeneratorUtils {
	
	static class IsTranslatable {
		new (boolean value) {
			this(value, null, null)
		}
		
		new (boolean value, EObject eobject, String reason) {
			this.value=value
			this.eobject=eobject
			this.reason=reason
		}
		
		public final boolean value
		public final EObject eobject
		public final String reason
	}
	
	def static IsTranslatable isJavaTranslatable(CO2System co2System) {
		
		for (x : co2System.eAllContents.toIterable) {
			var checkRes = x.check
			if (! checkRes.value) {
				return checkRes;
			} 
		}
		
		return new IsTranslatable(true)
	}
	
	def static dispatch IsTranslatable check(EObject obj) {
		return new IsTranslatable(true)
	}
	
	def static dispatch IsTranslatable check(ProcessDefinition obj) {
		if (obj.withoutRestrictions) {
			return new IsTranslatable(false, obj, "cannot translate co2 specifications described with the 'process' keyword (you must use 'specification')")			
		}
		else {
			return new IsTranslatable(true)
		}
	}
	
	
	
	def static String getString(INode node) {
		var text = node.text
		text = text.replaceAll("/\\*(?:.|[\\n\\r])*?\\*/", "");		// remove all comments
		text.trim.replaceAll("\t", "").replaceAll("\n", " ")
	}
	
}