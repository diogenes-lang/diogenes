package it.unica.co2.generator

import it.unica.co2.co2.DoInput
import it.unica.co2.co2.DoOutput
import it.unica.co2.co2.ProcessDefinition
import it.unica.co2.co2.Tell
import it.unica.co2.contracts.ContractDefinition
import it.unica.co2.contracts.ExtAction
import it.unica.co2.contracts.IntAction
import it.unica.co2.contracts.impl.ContractsFactoryImpl
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.generator.IGenerator

abstract class AbstractIGenerator implements IGenerator {
		
	private int CONTRACT_NAME_COUNT = 0;
	private int PROCESS_NAME_COUNT = 0;
	
	/*
	 * fix anonymous processes/contracts
	 */
	def void fixNames(Set<? extends EObject> elements) {
		for (e : elements)
			e.fixName
	}
	
	def dispatch void fixName(ProcessDefinition process) {
		process.name = process.name ?: "PROC#"+PROCESS_NAME_COUNT++
	}
	
	def dispatch void fixName(ContractDefinition contract) {
		contract.name = contract.name ?: "CONTR#"+CONTRACT_NAME_COUNT++
	}
	
	def dispatch void fixName(EObject process) {}
	
	/*
	 * fix tell with anonymous contract
	 */
	def ContractDefinition fixTell(Tell tell) {
		if (tell.contractReference==null) {
			var contractDef = ContractsFactoryImpl.init().createContractDefinition
			contractDef.name = "TELL-CONTR#"+CONTRACT_NAME_COUNT++
			contractDef.contract = tell.contract
			tell.contract=null
			tell.contractReference = contractDef
			return contractDef;
		}
		else {
			tell.contractReference
		}
	}
	
	/*
	 * get actionNames of the given object
	 */
	def dispatch getActionName(EObject obj){}
	
	def dispatch getActionName(IntAction obj){
		obj.actionName
	}
	
	def dispatch getActionName(ExtAction obj){
		obj.actionName
	}
	
	def dispatch getActionName(DoInput obj){
		obj.actionName
	}
	
	def dispatch getActionName(DoOutput obj){
		obj.actionName
	}
	
	/*
	 * get sessionNames of the given object
	 */
//	def dispatch getSessionName(EObject obj){}
//	
//	def dispatch getSessionName(Tell obj){
//		obj.session
//	}
//	
//	def dispatch getSessionName(DoInput obj){
//		obj.session
//	}
//	
//	def dispatch getSessionName(DoOutput obj){
//		obj.session
//	}
}