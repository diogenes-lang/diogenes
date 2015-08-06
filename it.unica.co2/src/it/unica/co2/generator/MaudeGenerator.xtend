package it.unica.co2.generator

import it.unica.co2.co2.AbstractNextProcess
import it.unica.co2.co2.Ask
import it.unica.co2.co2.DelimitedProcess
import it.unica.co2.co2.DoInput
import it.unica.co2.co2.DoOutput
import it.unica.co2.co2.ElseStatement
import it.unica.co2.co2.EmptyProcess
import it.unica.co2.co2.IfThenElse
import it.unica.co2.co2.ParallelProcesses
import it.unica.co2.co2.ProcessDefinition
import it.unica.co2.co2.ProcessReference
import it.unica.co2.co2.Sum
import it.unica.co2.co2.Tau
import it.unica.co2.co2.Tell
import it.unica.co2.co2.ThenStatement
import it.unica.co2.co2.Value
import it.unica.co2.contracts.AbstractNextContract
import it.unica.co2.contracts.ContractDefinition
import it.unica.co2.contracts.EmptyContract
import it.unica.co2.contracts.ExtAction
import it.unica.co2.contracts.ExtSum
import it.unica.co2.contracts.IntAction
import it.unica.co2.contracts.IntSum
import it.unica.co2.contracts.IntegerType
import it.unica.co2.contracts.Recursion
import it.unica.co2.contracts.StringType
import it.unica.co2.contracts.Type
import it.unica.co2.contracts.UnitType
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import it.unica.co2.co2.UnitValue
import it.unica.co2.co2.StringValue
import it.unica.co2.co2.IntegerValue

class MaudeGenerator extends AbstractIGenerator{
	
	String basepathOfGeneratedFiles = "maude"
	File co2MaudeDirectory

	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		//get the IProject from the given Resource
		val platformString = resource.URI.toPlatformString(true);
	    val myFile = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(platformString));
	    val project = myFile.getProject();
		
		//get location of workspace (java.io.File)  
		var workspaceDirectory = ResourcesPlugin.getWorkspace().getRoot().getLocation().toFile()
		
		//get location of the project
		var projectDirectory = new File(workspaceDirectory, project.name)
		
		//get location of the co2-maude directory
		co2MaudeDirectory = new File(projectDirectory, "co2-maude")
		
		var outputFilename = basepathOfGeneratedFiles+"/"+resource.URI.lastSegment.replace(".co2", ".maude")
		
		println('''generating «outputFilename»''')
		fsa.generateFile(outputFilename, resource.maudeCode )
	}
	


	def dispatch String maudeCode(Resource resource){
		var moduleName = resource.URI.lastSegment.replace(".co2", "").toUpperCase
		
		var processes = resource.allContents.filter(ProcessDefinition).filter[p| p.freeNames.length==0].toSet
		var envProcesses = resource.allContents.filter(ProcessDefinition).filter[p| p.freeNames.length!=0].toSet
		var contracts = resource.allContents.filter(ContractDefinition).toSet
		
		fixNames(processes)		//fill anonymous processes names
		fixNames(envProcesses)	//fill anonymous envProcesses names
		fixNames(contracts)		//fill anonymous contracts names
		
		//fix tells
		contracts.addAll( resource.allContents.filter(Tell).map[t| t.fixTell].toSet )
		
		
		var processNames = processes.map[p | p.name].toSet
		var envProcessNames = envProcesses.map[p | p.name].toSet
		var contractNames = contracts.map[c | c.name].toSet
//		var actionNames = 
//			resource.allContents
//				.filter[ obj | (obj instanceof IntAction || obj instanceof ExtAction || obj instanceof DoOutput || obj instanceof DoInput)]
//				.map[obj | obj.actionName]
//				.toSet
		
//		var sessionNames = 
//			resource.allContents
//				.filter[ obj | (obj instanceof Tell || obj instanceof DoOutput || obj instanceof DoInput)]
//				.map[obj | obj.sessionName]
//				.toSet
		
		println('''processes: «processNames»''')
		println('''contracts: «contractNames»''')
		
		return '''
		***
		*** auto-generated by co2-plugin
		*** creation date: «new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())»
		***
		
		in co2-abs .
		
		mod «moduleName» is
		
		    including CO2-ABS-SEM .
		    including STRING .
		    
		    subsort String < ActName .
		    
		    ops unit int string : -> BType [ctor] .
		    ops exp : -> Expression [ctor] .
		    
		«IF contractNames.size>0»    ops «contractNames.join(" ")» : -> UniContract .«ENDIF»
		«IF processNames.size>0»    ops «processNames.join(" ")» : -> Process .«ENDIF»
		«IF envProcesses.size>0»    ops «envProcessNames.join(" ")» : -> ProcIde .«ENDIF»
		
		    *** list of contracts
		«FOR contract : contracts»    «maudeCode(contract)»«ENDFOR»
		    
		    *** list of processes
		«FOR process : processes»    «maudeCode(process)»«ENDFOR»
		    
		«IF envProcesses.size>0»    *** env
		    eq env = (
		        «envProcesses.join("\n&\n", [p| maudeCode(p)])»
		    ) .
		«ENDIF»
		
		endm
		
		*** honesty
		«FOR process : processes»
		red honest(«process.name» , ['«moduleName»] , 50) .
		«ENDFOR»
		
		*** exit the program
		quit
		'''
	}
	
	/*
	 * maude code generation
	 */
	def dispatch String maudeCode(ContractDefinition contractDef) {
		
		'''eq «contractDef.name» = «IF contractDef.contract!=null»«contractDef.contract.maudeCode»«ELSE»0«ENDIF» .'''
	}
	
	def dispatch String maudeCode(Recursion obj) {
		'''rec «obj.name» . ( «obj.body.maudeCode» )'''
	}
	
	def dispatch String maudeCode(IntSum obj) {
		if (obj.actions.length==1)
			obj.actions.get(0).maudeCode
		else
			obj.actions.join(" (+) ", [a | a.maudeCode])
	}
	
	def dispatch String maudeCode(ExtSum obj) {
		if (obj.actions.length==1)
			obj.actions.get(0).maudeCode
		else
			obj.actions.join(" + ", [a | a.maudeCode])
	}
	
	def dispatch String maudeCode(EmptyContract obj) {
		"0"
	}
	
	def dispatch String maudeCode(IntAction obj) {
		'''"«obj.actionName»" ! «obj.type.typeAsString»«IF obj.next!=null» «obj.next.maudeCode»«ELSE» . 0«ENDIF»'''
	}
	
	def dispatch String maudeCode(ExtAction obj) {
		'''"«obj.actionName»" ? «obj.type.typeAsString»«IF obj.next!=null» «obj.next.maudeCode»«ELSE» . 0«ENDIF»'''
	}
	
	def dispatch String maudeCode(AbstractNextContract obj) {
		
		if (obj.nextContract!=null) {
			if (obj.nextContract instanceof IntAction || obj.nextContract instanceof ExtAction || obj.nextContract instanceof EmptyContract)
				''' . «obj.nextContract.maudeCode»'''
			else
				''' . ( «obj.nextContract.maudeCode» )'''
		}
		else if (obj.recursionReference!=null) {
			''' . «obj.recursionReference.name»'''
		}
		else if (obj.contractReference!=null) {
			''' . «obj.contractReference.name»'''
		}
	}
	
	
	//processes
	def dispatch String maudeCode(ProcessDefinition obj) {
		if (obj.freeNames.length==0)
			'''eq «obj.name» = «IF obj.process!=null»«obj.process.maudeCode»«ELSE»0«ENDIF» .'''
		else
			'''«obj.name»«obj.freeNames.join("("," ; ", ")",[n|'''"«n»"'''])» =def «obj.process.maudeCode»'''
	}
	
	def dispatch String maudeCode(ParallelProcesses obj) {
		if (obj.processes.length==1)
			obj.processes.get(0).maudeCode
		else
			obj.processes.join(" | ", [a | a.maudeCode])
	}
	
	def dispatch String maudeCode(DelimitedProcess obj) {
		if (obj.freeNames.length>0)
			'''«obj.freeNames.join(" ", [x| '''("«x»")'''])» «obj.process.maudeCode»'''
		else
			obj.process.maudeCode
	}
	
	def dispatch String maudeCode(Sum obj) {
		if (obj.prefixes.length==1)
			obj.prefixes.get(0).maudeCode
		else
			obj.prefixes.join(" + ", [a | a.maudeCode])
	}
	
	def dispatch String maudeCode(EmptyProcess obj) {
		"0 "
	}
	
	def dispatch String maudeCode(IfThenElse obj) {
		'''if exp then («obj.then.maudeCode») else («obj.^else.maudeCode»)'''
	}
	
	def dispatch String maudeCode(ThenStatement obj) {
		if (obj.processReference!=null)
			obj.processReference.maudeCode
		else
			obj.process.maudeCode
	}
	
	def dispatch String maudeCode(ElseStatement obj) {
		if (obj.processReference!=null)
			obj.processReference.maudeCode
		else
			obj.process.maudeCode
	}
	
	def dispatch String maudeCode(Tau obj) {
		'''t«obj.next.maudeCode»'''
	}
	
	def dispatch String maudeCode(Tell obj) {
		'''tell "«obj.session»" «obj.contractReference.name»«IF obj.next!=null» «obj.next.maudeCode»«ELSE» . 0«ENDIF»'''
	}
	
	def dispatch String maudeCode(DoInput obj) {
		'''do "«obj.session»" "«obj.actionName»" ? «obj.type.typeAsString»«IF obj.next!=null» «obj.next.maudeCode»«ELSE» . 0«ENDIF»'''
	}
	
	def dispatch String maudeCode(DoOutput obj) {
		'''do "«obj.session»" "«obj.actionName»" ! «obj.value.valueAsString»«IF obj.next!=null» «obj.next.maudeCode»«ELSE» . 0«ENDIF»'''
	}
	
	def dispatch String maudeCode(Ask obj) {
		'''ask "«obj.session»" True «IF obj.next!=null» «obj.next.maudeCode»«ELSE» . 0«ENDIF»'''
	}
	
	def dispatch String maudeCode(AbstractNextProcess obj) {
		
		if (obj.nextProcess!=null) {
			if (obj.nextProcess instanceof DoInput || obj.nextProcess instanceof DoOutput || obj.nextProcess instanceof Tell || obj.nextProcess instanceof EmptyProcess)
				''' . «obj.nextProcess.maudeCode»'''
			else
				''' . ( «obj.nextProcess.maudeCode» )'''
		}
		else if (obj.processReference!=null) {
			''' . «obj.processReference.maudeCode»'''
		}
	}
	
	def dispatch String maudeCode(ProcessReference obj) {
		if (obj.variables.length==0)
			'''«obj.reference.name»'''
		else {
			'''«obj.reference.name»«obj.variables.join("("," ; ", ")",[n|'''"«n»"'''])»'''
		}
	}
	
	def String getTypeAsString(Type type) {
		if (type instanceof UnitType) return "unit"
		else if (type instanceof StringType) return "string"
		else if (type instanceof IntegerType) return "int"
	}
	
	def String getValueAsString(Value value) {
		if (value instanceof UnitValue) return "unit"
		else if (value instanceof StringValue) return "string"
		else if (value instanceof IntegerValue) return "int"
	}
}