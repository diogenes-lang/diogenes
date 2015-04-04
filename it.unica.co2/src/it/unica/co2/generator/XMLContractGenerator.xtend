package it.unica.co2.generator

import it.unica.co2.co2.Tell
import it.unica.co2.contracts.ContractDefinition
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess

class XMLContractGenerator extends AbstractIGenerator {
	
	override doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		var xmlContractDir = resource.URI.lastSegment.replace(".co2", "")
		
		var contracts = resource.allContents.filter(ContractDefinition).toSet
		
		fixNames(contracts)		//fill anonymous contracts names
		
		//fix tells
		contracts.addAll( resource.allContents.filter(Tell).map[t| t.fixTell].toSet )
		
		for (c : contracts)
			fsa.generateFile(xmlContractDir+"/"+c.name+".xml", c.toXml)
	}
	
	
	def String toXml(ContractDefinition definition) {
		'''<?xml version="1.0" encoding="UTF-8"?>'''
	}
	
}