package it.unica.co2.generator

import it.unica.co2.co2.Ask
import it.unica.co2.co2.CO2System
import it.unica.co2.co2.DoInput
import it.unica.co2.co2.DoOutput
import it.unica.co2.co2.ParallelProcesses
import it.unica.co2.co2.Sum
import it.unica.co2.co2.Tau
import it.unica.co2.co2.Tell
import org.eclipse.emf.ecore.EObject

class JavaGeneratorUtils {
	
	def static boolean isJavaTranslatable(CO2System co2System) {
		println("START")
		for (x : co2System.eAllContents.toIterable) {
			println(x)
			if (!x.check) {
				println("false: "+x)
				return false
			} 
		}
		
		return true
	}
	
	def static dispatch boolean check(EObject obj) {
		return true
	}
	
	def static dispatch boolean check(ParallelProcesses p) {
		return p.processes.size<=1
	}
	
	def static dispatch boolean check(Tell tell) {
		//tell must be followed by a sum containing an ask-prefix and a possible tau
		println("-->"+tell.next)
		if (tell.next instanceof ParallelProcesses) {
			
			var pp = (tell.next as ParallelProcesses)
			
			if (pp.processes.size!=1) return false
			if (!(pp.processes.get(0).process instanceof Sum)) return false
			
			var sum = (pp.processes.get(0).process as Sum)
			var taus = sum.prefixes.filter(Tau)
			var asks = sum.prefixes.filter(Ask)
			
			if (sum.prefixes.size>2) return false
			if (taus.size>1) return false
			if (asks.size!=1) return false
			
			return true
		}
		else if (tell.next instanceof Sum) {
			var sum = (tell.next as Sum)
			var taus = sum.prefixes.filter(Tau)
			var asks = sum.prefixes.filter(Ask)
			
			if (sum.prefixes.size>2) return false
			if (taus.size>1) return false
			if (asks.size!=1) return false
			
			return true
		}
		else {
			return false
		}
	}
	
	def static dispatch boolean check(Sum p) {
		
		var taus = p.prefixes.filter(Tau)
		var input = p.prefixes.filter(DoInput)
		var output = p.prefixes.filter(DoOutput)
		var tells = p.prefixes.filter(Tell)
		var asks = p.prefixes.filter(Ask)

		println('''size) «p.prefixes.size»''')
		println('''prefixes) «p.prefixes.join(" + ", [x|x.class.simpleName])»''')
		
		if (p.prefixes.size<=1) {
			return p.prefixes.size==1 && taus.size==0
		}
		else {
			if (output.size>0) return false	//output is not allowed	
			if (tells.size>0) return false	//tells not permitted
			if (taus.size>1) return false	//at most one tau
			if (asks.size>1) return false	//at most one ask
			
			if (input.size==0 && asks.size==0)	//or input or asks
				return false
			
			return true;
		}
	}
	
}