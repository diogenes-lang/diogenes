package it.unica.co2.generator

import it.unica.co2.co2.Co2Factory
import it.unica.co2.co2.ContractDefinition
import it.unica.co2.co2.Tell
import it.unica.co2.co2.TellAndWait
import it.unica.co2.co2.TellProcess
import it.unica.co2.co2.TellRetract
import java.util.HashMap
import java.util.Map
import org.eclipse.xtext.generator.IGenerator

abstract class AbstractIGenerator implements IGenerator {
	
	Map<String,Integer> freeNames = new HashMap 
	
	def String getFreshName(String name) {
		var count = freeNames.get(name)
		
		if (count==null) {
			freeNames.put(name, 1);
			return name;
		}
		else {
			freeNames.put(name, count+1);
			return name+""+count
		}
	}
	
	def void clearFreeNames() {
		freeNames.clear
	}
	
	
	protected int CONTRACT_NAME_COUNT = 0;
	
	/*
	 * fix tell with anonymous contract
	 */
	def ContractDefinition fixTell(Tell tell, String prefix) {
		
		if (tell.contractReference==null) {
			var contractDef = Co2Factory.eINSTANCE.createContractDefinition
			contractDef.name = prefix+CONTRACT_NAME_COUNT++
			contractDef.contract = tell.contract
			tell.contract=null
			tell.contractReference = contractDef
			return contractDef;
		}
		else {
			tell.contractReference
		}
	}
	
	def ContractDefinition fixTell(TellRetract tell, String prefix) {
		
		if (tell.session.contractReference==null) {
			var contractDef = Co2Factory.eINSTANCE.createContractDefinition
			contractDef.name = prefix+CONTRACT_NAME_COUNT++
			contractDef.contract = tell.session.contract
			tell.session.contract=null
			tell.session.contractReference = contractDef
			return contractDef;
		}
		else {
			tell.session.contractReference
		}
	}
	
	def ContractDefinition fixTell(TellAndWait tell, String prefix) {
		
		if (tell.session.contractReference==null) {
			var contractDef = Co2Factory.eINSTANCE.createContractDefinition
			contractDef.name = prefix+CONTRACT_NAME_COUNT++
			contractDef.contract = tell.session.contract
			tell.session.contract=null
			tell.session.contractReference = contractDef
			return contractDef;
		}
		else {
			tell.session.contractReference
		}
	}
	
	def ContractDefinition fixTell(TellProcess tell, String prefix) {
		
		if (tell.session.contractReference==null) {
			var contractDef = Co2Factory.eINSTANCE.createContractDefinition
			contractDef.name = prefix+CONTRACT_NAME_COUNT++
			contractDef.contract = tell.session.contract
			tell.session.contract=null
			tell.session.contractReference = contractDef
			return contractDef;
		}
		else {
			tell.session.contractReference
		}
	}
	
//	def void fixRecursions(Iterable<ContractDefinition> contracts) {
//		
//		for (c : contracts) {
//			var recursions = c.eAllContents.filter(Recursion).toSet
//			
//			val Map<String,Integer> counts = new HashMap()
//			
//			/*
//			 * fix recursion names in order to be unique
//			 */
//			recursions.forEach[x| 
//				if (!counts.containsKey(x.name)) 
//					counts.put(x.name, 0)
//				
//				var n = counts.put(x.name, counts.get(x.name)+1)
//				
//				x.name = '''rec_«c.name»_«x.name»_«n»'''
//			]
//		}
//	}
	
	
	
}