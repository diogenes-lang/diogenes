package it.unica.co2.generator

import it.unica.co2.co2.ContractDefinition
import it.unica.co2.co2.Tell
import org.eclipse.xtext.generator.IGenerator
import it.unica.co2.co2.Co2Factory

abstract class AbstractIGenerator implements IGenerator {
		
	private int CONTRACT_NAME_COUNT = 0;
	
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
	
}