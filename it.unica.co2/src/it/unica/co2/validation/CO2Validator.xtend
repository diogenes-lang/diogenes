/*
 * generated by Xtext
 */
package it.unica.co2.validation

import it.unica.co2.co2.CO2System
import it.unica.co2.co2.Co2Package
import it.unica.co2.co2.ContractDefinition
import it.unica.co2.co2.DelimitedProcess
import it.unica.co2.co2.DoInput
import it.unica.co2.co2.EmptyContract
import it.unica.co2.co2.EmptyProcess
import it.unica.co2.co2.ExtAction
import it.unica.co2.co2.ExtSum
import it.unica.co2.co2.HonestyDeclaration
import it.unica.co2.co2.Input
import it.unica.co2.co2.IntAction
import it.unica.co2.co2.IntSum
import it.unica.co2.co2.ProcessDefinition
import it.unica.co2.co2.Referrable
import it.unica.co2.co2.TellAndWait
import it.unica.co2.co2.TellRetract
import it.unica.co2.co2.UnitActionType
import it.unica.co2.xsemantics.validation.CO2TypeSystemValidator
import java.io.File
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.validation.Check
import org.eclipse.core.resources.IProjectDescription

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class CO2Validator extends CO2TypeSystemValidator {
	
	@Check
	def void checkPackage(CO2System system) {
		
//		var IWorkspaceRoot myWorkspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
		
		val String platformString = system.eResource.URI.toPlatformString(false);
	    val IFile myFile = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(platformString));
	    val IProject currentProject = myFile.getProject();
		val IProjectDescription currentProjectDesc = currentProject.description;
		
//		println("** conf");
//		println(currentProject.activeBuildConfig);
//		println("**")
		
		var packageName = system.name
		var realPath = system.eResource.URI.toPlatformString(false)
		var expectedPath = packageName.replaceAll("\\.", File.separator)+File.separator+system.eResource.URI.lastSegment
	
		if (!realPath.endsWith( expectedPath )) {
			error('''The declared package "«packageName»" does not match the path "«expectedPath»"''', 
					Co2Package.Literals.CO2_SYSTEM__NAME
				);
				return;
		}		
	}
	
	
	
	@Check
	def void checkProcessNameStartWithCapital(ProcessDefinition procDef) {
		
		if (!Character.isUpperCase(procDef.getName().charAt(0))) {
            warning("Process name should start with a capital", 
            		Co2Package.Literals.PROCESS_DEFINITION__NAME,
            		procDef.getName());
        }
    }
    
    @Check
	def void checkContractNameStartWithCapital(ContractDefinition contractDef) {
		
		if (!Character.isUpperCase(contractDef.getName().charAt(0))) {
            warning("Contract name should start with a capital", 
            		Co2Package.Literals.CONTRACT_DEFINITION__NAME,
            		contractDef.getName());
        }
    }
	
	
	
	@Check
	def void checkProcessNameDoesNotContainUnderscores(ProcessDefinition procDef) {
		
        if (procDef.name.contains("_")) {
            error("Process name must not contain underscores", 
            		Co2Package.Literals.PROCESS_DEFINITION__NAME,
            		procDef.getName());
        }
	}
	
	@Check
	def void checkContractNameDoesNotContainUnderscores(ContractDefinition contractDef) {
		if (contractDef.name.contains("_")) {
            error("Process name must not contain underscores", 
            		Co2Package.Literals.CONTRACT_DEFINITION__NAME,
            		contractDef.getName());
        }
	}	
	
	
	
	@Check
	def void checkProcessNameIsUnique(ProcessDefinition procDef) {
		
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
	def void checkHonestyDeclaration(HonestyDeclaration honestyDecl) {
		
		for (var i=0; i<honestyDecl.processes.length; i++) {
			var p = honestyDecl.processes.get(i)
			if (p.params.size > 0) {
					error("You can check only processes without args",
						Co2Package.Literals.HONESTY_DECLARATION__PROCESSES,
						i
					);
				}
		}
		
	}



	@Check
	def void checkEmptyProcess(EmptyProcess empty) {
		info("Empty process can be omitted", 
			Co2Package.Literals.EMPTY_PROCESS__VALUE
		);
	}
	
	@Check
	def void checkEmptyContract(EmptyContract empty) {
		info("Empty contract can be omitted", 
			Co2Package.Literals.EMPTY_CONTRACT__VALUE
		);
	}
	
	
	
	@Check
	def void checkInternalActionsName(IntAction internalAction) {
		
		if (internalAction.eContainer instanceof IntSum)
			for (other: (internalAction.eContainer() as IntSum).actions){
				
				if (internalAction!=other && internalAction.name.equals(other.name)) {
					error("Action names must be unique", 
						Co2Package.Literals.INT_ACTION__NAME
					);
					return;
				}
			}
	}
	
	@Check
	def void checkExternalActionsName(ExtAction externalAction) {
		
		if (externalAction.eContainer instanceof ExtSum)
			for (other: (externalAction.eContainer() as ExtSum).actions){
				
				if (externalAction!=other && externalAction.name.equals(other.name)) {
					error("Action names must be unique", 
						Co2Package.Literals.EXT_ACTION__NAME
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
	def void checkExtActionName(ExtAction action) {
		if (Character.isUpperCase(action.getName().charAt(0))) {
            warning("Action name should start with a lowercase", 
            		Co2Package.Literals.EXT_ACTION__NAME,
            		action.getName());
        }
	}
	
	@Check
	def void checkIntActionName(IntAction action) {
		if (Character.isUpperCase(action.getName().charAt(0))) {
            warning("Action name should start with a lowercase", 
            		Co2Package.Literals.INT_ACTION__NAME,
            		action.getName());
        }
	}
	
	
	
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
	
	@Check
	def void checkShadowTellRetract(TellRetract proc) {
		this.checkFreeName(proc.eContainer, proc.session, 0)
	}
	
	@Check
	def void checkShadowTellAndWait(TellAndWait proc) {
		this.checkFreeName(proc.eContainer, proc.session, 0)
	}
	
	@Check
	def void checkShadowInput(Input proc) {
		this.checkFreeName(proc.eContainer, proc.variable, 0)
	}
	
	def dispatch void checkFreeName(EObject obj, Referrable fn, int i) {
    	checkFreeName(obj.eContainer, fn, i)
    }
    
    def dispatch void checkFreeName(DoInput obj, Referrable fn, int i) {
    	if (obj.variable.name == fn.name) {
    		warning("Shadowed free-name", obj.variable.eContainer, obj.variable.eContainingFeature)
	    	warning("You are hiding an existing name", fn.eContainer, fn.eContainingFeature)
    	}
    	checkFreeName(obj.eContainer, fn, i)
    }
    
    def dispatch void checkFreeName(Input obj, Referrable fn, int i) {
    	if (obj.variable.name == fn.name) {
    		warning("Shadowed free-name", obj.variable.eContainer, obj.variable.eContainingFeature)
	    	warning("You are hiding an existing name", fn.eContainer, fn.eContainingFeature)
    	}
    	checkFreeName(obj.eContainer, fn, i)
    }
    
    def dispatch void checkFreeName(TellRetract obj, Referrable fn, int i) {
    	if (obj.session.name == fn.name) {
    		warning("Shadowed free-name", obj.session.eContainer, obj.session.eContainingFeature)
	    	warning("You are hiding an existing name", fn.eContainer, fn.eContainingFeature)
    	}
    	checkFreeName(obj.eContainer, fn, i)
    }
    
    def dispatch void checkFreeName(TellAndWait obj, Referrable fn, int i) {
    	if (obj.session.name == fn.name) {
    		warning("Shadowed free-name", obj.session.eContainer, obj.session.eContainingFeature)
	    	warning("You are hiding an existing name", fn.eContainer, fn.eContainingFeature)
    	}
    	checkFreeName(obj.eContainer, fn, i)
    }
    
    def dispatch void checkFreeName(DelimitedProcess proc, Referrable fn, int i) {
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
    
    def dispatch void checkFreeName(ProcessDefinition proc, Referrable fn, int i) {
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
	 * check contract cycle-reference: TODO
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	 
	 
}
