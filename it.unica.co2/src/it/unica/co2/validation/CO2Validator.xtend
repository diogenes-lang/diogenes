/*
 * generated by Xtext
 */
package it.unica.co2.validation

import it.unica.co2.co2.Co2Package
import it.unica.co2.co2.ContractDefinition
import it.unica.co2.co2.DelimitedProcess
import it.unica.co2.co2.DoInput
import it.unica.co2.co2.EmptyContract
import it.unica.co2.co2.EmptyProcess
import it.unica.co2.co2.ExtAction
import it.unica.co2.co2.ExtSum
import it.unica.co2.co2.FreeName
import it.unica.co2.co2.HonestyDeclaration
import it.unica.co2.co2.IntAction
import it.unica.co2.co2.IntSum
import it.unica.co2.co2.ProcessDefinition
import it.unica.co2.co2.UnitActionType
import it.unica.co2.xsemantics.validation.CO2TypeSystemValidator
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.validation.Check

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class CO2Validator extends CO2TypeSystemValidator {
	
	
//	@Check
//	def void checkLanguageVersion(CO2System sys){
//		var versionWithMacros = if (sys.version!=null) sys.version.macro else true
//		
//		println('''versionWithMacros: «versionWithMacros»''');
//		
//		if (versionWithMacros) {
//			/*
//			 * the program cannot contain
//			 * - prefixes
//			 * - delimited processes with freeNames
//			 */
//			var children = sys.eAllContents.filter[x| x instanceof Prefix || x instanceof DelimitedProcess].toIterable
//			for (node : children) {
//				error("This code is not allowed with the given language version", 
//					node.
//				);
//			}
//		}
//	}

	@Check
	def void checkContractNameIsUnique(ProcessDefinition procDef) {
		var root = EcoreUtil2.getRootContainer(procDef);
		for (other: EcoreUtil2.getAllContentsOfType(root, ProcessDefinition)){
			
			if (procDef!=other && procDef.getName.equals(other.name)) {
				error("Process names must be unique", 
					Co2Package.Literals.PROCESS_DEFINITION__NAME
				);
				return;
			}
		}
	}

	@Check
	def void checkHonestyDeclaration(HonestyDeclaration honestyDecl) {
		var p = honestyDecl.process
		if (p.params.size > 0) {
				error("You can check only processes without args", 
					Co2Package.Literals.HONESTY_DECLARATION__PROCESS
				);
			}
		
//		/*
//		 * each process must appear once and declared without params
//		 */
//		for (var i=0; i<honestyDecl.processes.size; i++) {
//			var p = honestyDecl.processes.get(i)
//			if (p.params.size > 0) {
//				error("You can check only processes without args", 
//					Co2Package.Literals.HONESTY_DECLARATION__PROCESSES,
//					i
//				);
//			}
//		}
//		
//		for (var i=0; i<honestyDecl.processes.size-1; i++) {
//			
//			for (var j=i+1; j<honestyDecl.processes.size; j++) {
//				var p1 = honestyDecl.processes.get(i)
//				var p2 = honestyDecl.processes.get(j)
//				if (p1.name == p2.name) {
//					error("Process already present", 
//						Co2Package.Literals.HONESTY_DECLARATION__PROCESSES,
//						j
//					);
//				}
//			}
//		}
			
	}

	@Check
	def void checkEmptyProcess(EmptyProcess empty) {
		info("Empty process can be omitted", 
			Co2Package.Literals.EMPTY_PROCESS__VALUE
		);
	}
	
	
	@Check
	def void checkContractNameIsUnique(ContractDefinition contractDef) {
		var root = EcoreUtil2.getRootContainer(contractDef);
		for (other: EcoreUtil2.getAllContentsOfType(root, ContractDefinition)){
			
			if (contractDef!=other && contractDef.getName.equals(other.name)) {
				error("Contract names must be unique",
					contractDef,
					Co2Package.Literals.CONTRACT_DEFINITION__NAME
				);
				return;
			}
		}
	}
	
	@Check
	def void checkInternalActionsName(IntAction internalAction) {
		
		if (internalAction.eContainer instanceof IntSum)
			for (other: (internalAction.eContainer() as IntSum).actions){
				
				if (internalAction!=other && internalAction.actionName.equals(other.actionName)) {
					error("Action names must be unique", 
						Co2Package.Literals.INT_ACTION__ACTION_NAME
					);
					return;
				}
			}
	}
	
	@Check
	def void checkExternalActionsName(ExtAction externalAction) {
		
		if (externalAction.eContainer instanceof ExtSum)
			for (other: (externalAction.eContainer() as ExtSum).actions){
				
				if (externalAction!=other && externalAction.actionName.equals(other.actionName)) {
					error("Action names must be unique", 
						Co2Package.Literals.EXT_ACTION__ACTION_NAME
					);
					return;
				}
			}
	}
	
	@Check
	def void checkExtActionType(ExtAction action) {
		if (action.type!=null && action.type instanceof UnitActionType)
			info('Unit type can be omitted', Co2Package.Literals.EXT_ACTION__TYPE)
	}
	
	@Check
	def void checkIntActionType(IntAction action) {
		if (action.type!=null && action.type instanceof UnitActionType)
			info('Unit type can be omitted', Co2Package.Literals.INT_ACTION__TYPE)
	}
	
	@Check
	def void checkEmptyContract(EmptyContract empty) {
		info("Empty contract can be omitted", 
			Co2Package.Literals.EMPTY_CONTRACT__VALUE
		);
	}
	
//	@Check
//	def void checkRecursionDefinition(Recursion recursion) {
//		this.checkRecursionID(recursion.eContainer, recursion.name)
//	}
//	
//	def dispatch void checkRecursionID(EObject obj, String name) {
//    	checkRecursionID(obj.eContainer, name)
//    }
//    
//    def dispatch void checkRecursionID(Recursion obj, String name) {
//    	if (obj.name.equals(name)) {
//    		warning("You are hiding an existing name",
//    			Co2Package.Literals.REFERRABLE__NAME
//    		)
//    	}
//    	checkRecursionID(obj.eContainer, name)
//    }
//    
//    def dispatch void checkRecursionID(ContractDefinition obj, String name) {
//    	// stop recursion
//    }
	
	
	/*
	 * check shadowed variables
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	
	@Check
	def void checkShadowDelimitedProcess(DelimitedProcess proc) {
		
		// we already check that fn into DelimitedProcess are unique
		var i=0
		for (fn : proc.freeNames) {
			this.checkFreeName(proc.eContainer, fn, i)
			i++
		}
	}
	
	@Check
	def void checkShadowDoInput(DoInput proc) {
		this.checkFreeName(proc.eContainer, proc.variable, 0)
	}
	
	def dispatch void checkFreeName(EObject obj, FreeName fn, int i) {
    	checkFreeName(obj.eContainer, fn, i)
    }
    
    def dispatch void checkFreeName(DoInput obj, FreeName fn, int i) {
    	if (obj.variable.name == fn.name) {
    		warning("Shadowed free-name", obj.variable.eContainer, obj.variable.eContainingFeature)
	    	warning("You are hiding an existing name", fn.eContainer, fn.eContainingFeature)
    	}
    	checkFreeName(obj.eContainer, fn, i)
    }
    
    def dispatch void checkFreeName(DelimitedProcess proc, FreeName fn, int i) {
    	var j=0
    	for (fn1 : proc.freeNames) {
			if (fn1.name == fn.name) {
	    		warning("Shadowed free-name", fn1.eContainer, fn1.eContainingFeature, j)
	    		warning("You are hiding an existing name", fn.eContainer, fn.eContainingFeature, i)
    		}
    		j++
		}
    	checkFreeName(proc.eContainer, fn, i)
    }
    
    def dispatch void checkFreeName(ProcessDefinition proc, FreeName fn, int i) {
    	var j=0
    	for (fn1 : proc.params) {
			if (fn1.name == fn.name) {
				warning("Shadowed free-name", fn1.eContainer, fn1.eContainingFeature, j)
	    		warning("You are hiding an existing name", fn.eContainer, fn.eContainingFeature, i)
    		}
    		j++
		}
    	// stop recursion
    }
	
	
	/*
	 * check contract cycle-reference
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	 
	 
}
