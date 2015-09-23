package it.unica.co2.generator

import it.unica.co2.co2.Ask
import it.unica.co2.co2.CO2System
import it.unica.co2.co2.DoInput
import it.unica.co2.co2.DoOutput
import it.unica.co2.co2.ParallelProcesses
import it.unica.co2.co2.Prefix
import it.unica.co2.co2.Sum
import it.unica.co2.co2.Tau
import it.unica.co2.co2.Tell
import org.eclipse.emf.ecore.EObject

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
	

	def static dispatch IsTranslatable check(Tell tell) {
		//tell must be followed by a sum containing an ask-prefix and a possible tau
		if (tell.next instanceof ParallelProcesses) {
			
			var pp = (tell.next as ParallelProcesses)
			
			if (pp.processes.size!=1) 
				return new IsTranslatable(false, tell, "unexpected parallel process after the tell")
			if (!(pp.processes.get(0).process instanceof Sum)) 
				return new IsTranslatable(false, tell, "unexpected object after the tell, sum expected")
			
			var sum = (pp.processes.get(0).process as Sum)
			var taus = sum.prefixes.filter(Tau)
			var asks = sum.prefixes.filter(Ask)
			
			if (sum.prefixes.size>2) return new IsTranslatable(false, tell, "the tell can't be followed by a sum with more than 2 elements")
			if (taus.size>1) return new IsTranslatable(false, tell, "the tell can be followed by at most one tau prefix")
			if (asks.size!=1) return new IsTranslatable(false, tell, "the tell must be followed by an ask prefix")
			
			return new IsTranslatable(true)
		}
		else if (tell.next instanceof Sum) {
			var sum = (tell.next as Sum)
			var taus = sum.prefixes.filter(Tau)
			var asks = sum.prefixes.filter(Ask)
			
			if (sum.prefixes.size>2) return new IsTranslatable(false, tell, "the tell can't be followed by a sum with more than 2 elements")
			if (taus.size>1) return new IsTranslatable(false, tell, "the tell can be followed by at most one tau prefix")
			if (asks.size!=1) return new IsTranslatable(false, tell, "the tell must be followed by an ask prefix")
			
			return new IsTranslatable(true)
		}
		else {
			return new IsTranslatable(false, tell, "the tell must be followed by an ask prefix")
		}
	}
	
	def static dispatch IsTranslatable check(Sum sum) {
		
		var taus = sum.prefixes.filter(Tau)
		var input = sum.prefixes.filter(DoInput)
		var output = sum.prefixes.filter(DoOutput)
		var tells = sum.prefixes.filter(Tell)
		var asks = sum.prefixes.filter(Ask)

		if (sum.prefixes.size<=1) {
			return new IsTranslatable(true)
		}
		else {
			if (output.size>0) return new IsTranslatable(false, sum, "the sum can't contain do!")	//output is not allowed	
			if (tells.size>0) return new IsTranslatable(false, sum, "the sum can't contain the tell prefix")	//tells not permitted
			if (taus.size>1) return new IsTranslatable(false, sum, "the sum can contain at most one tau prefix")	//at most one tau
			if (asks.size>1) return new IsTranslatable(false, sum, "the sum can contain at most one ask prefix")	//at most one ask
			
			if (input.size==0 && asks.size==0)	//or input or asks
				return new IsTranslatable(false, sum, "ask and do? are not allowed on the same sum")

			var inputActionNames = input.map[x|x.actionName].toSet

			if (inputActionNames.size!=input.size)
				return new IsTranslatable(false, sum, "action name repeated between two or more prefix")

			//prefixes are ok, check for session
			var String session;
						
			for (var i=0; i<sum.prefixes.size; i++){
				var prefix = sum.prefixes.get(i)
				var pSession = prefix.session;
				
				if (pSession!=null) {
					
					if (session==null) 
						session = pSession
						
					if (session!=pSession)
						return new IsTranslatable(false, sum, "all prefixes must use the same session")
				}
			}
			
			return new IsTranslatable(true);
		}
	}
	
	
	def static dispatch String getSession(DoInput p) {
		p.session.name
	}
	
	def static dispatch String getSession(Ask p) {
		p.session.name
	}
	
	def static dispatch String getSession(Prefix p) {
		null
	}
	
	
	def static String getLogString(String str){
		'''logger.log("«str»");'''
	}
	
}