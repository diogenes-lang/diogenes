package it.unica.co2.generator

import it.unica.co2.co2.Co2Factory
import it.unica.co2.co2.ContractDefinition
import it.unica.co2.co2.Tell
import it.unica.co2.co2.TellRetract
import org.eclipse.xtext.generator.IGenerator

abstract class AbstractIGenerator implements IGenerator {
		
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