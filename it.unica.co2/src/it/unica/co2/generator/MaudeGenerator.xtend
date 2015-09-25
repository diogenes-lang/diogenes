package it.unica.co2.generator

import com.google.inject.Inject
import it.unica.co2.co2.ActionType
import it.unica.co2.co2.Ask
import it.unica.co2.co2.CO2System
import it.unica.co2.co2.Co2Factory
import it.unica.co2.co2.ContractDefinition
import it.unica.co2.co2.ContractReference
import it.unica.co2.co2.DelimitedProcess
import it.unica.co2.co2.DoInput
import it.unica.co2.co2.DoOutput
import it.unica.co2.co2.EmptyContract
import it.unica.co2.co2.EmptyProcess
import it.unica.co2.co2.Expression
import it.unica.co2.co2.ExtAction
import it.unica.co2.co2.ExtSum
import it.unica.co2.co2.FreeName
import it.unica.co2.co2.IfThenElse
import it.unica.co2.co2.IntAction
import it.unica.co2.co2.IntActionType
import it.unica.co2.co2.IntSum
import it.unica.co2.co2.IntType
import it.unica.co2.co2.ParallelProcesses
import it.unica.co2.co2.ProcessCall
import it.unica.co2.co2.ProcessDefinition
import it.unica.co2.co2.SessionType
import it.unica.co2.co2.StringActionType
import it.unica.co2.co2.StringType
import it.unica.co2.co2.Sum
import it.unica.co2.co2.Tau
import it.unica.co2.co2.Tell
import it.unica.co2.co2.UnitActionType
import it.unica.co2.co2.VariableReference
import it.unica.co2.xsemantics.CO2TypeSystem
import it.xsemantics.runtime.RuleApplicationTrace
import java.text.SimpleDateFormat
import java.util.Date
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.naming.IQualifiedNameProvider
import it.unica.co2.co2.Retract
import it.unica.co2.co2.TellRetract

class MaudeGenerator extends AbstractIGenerator{
	
	@Inject CO2TypeSystem co2TypeSystem
	@Inject extension IQualifiedNameProvider qNameProvider
	
	static final String TAB = "    "

	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		for (e : resource.allContents.toIterable.filter(CO2System)) {
			var outputFilename = e.systemDeclaration.fullyQualifiedName.toString("/") + ".maude"
			println('''generating «outputFilename»''')
			fsa.generateFile(outputFilename, e.maudeCode)
		}
	}
	


	def dispatch String maudeCode(CO2System _co2System){
		
		var co2System = EcoreUtil.copy(_co2System)	//clone the AST (multiple generators use this)
		
		var moduleName = co2System.systemDeclaration.fullyQualifiedName.lastSegment.toUpperCase
		
		var processToCheck = if (co2System.honesty!=null) co2System.honesty.process else null
				
		var processes = co2System.contractsAndProcessesDeclaration.processes.filter[p| p.params.length==0].toSet
		var envProcesses = co2System.contractsAndProcessesDeclaration.processes.filter[p| p.params.length!=0].toSet
		var contracts = co2System.contractsAndProcessesDeclaration.contracts.toSet
		
		//fix anonymous tells
		contracts.addAll( co2System.eAllContents.filter(Tell).map[t| t.fixTell("TELL-CONTR")].toSet )
		contracts.addAll( co2System.eAllContents.filter(TellRetract).map[t| t.fixTell("TELLR-CONTR")].toSet )
			
		var processNames = processes.map[p | p.name].toSet
		var envProcessNames = envProcesses.map[p | p.name].toSet
		var contractNames = contracts.map[c | c.name].toSet
//		var recContractNames = co2System.eAllContents.filter(Recursion).map[c | c.name].toSet
		
		return '''
		***
		*** auto-generated by co2-plugin
		*** creation date: «new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())»
		***
		
		in co2-abs .
		
		mod «moduleName» is
		
		«TAB»including CO2-ABS-SEM .
		«TAB»including CONTR-EQ .
		«TAB»including STRING .
		
		«TAB»subsort String < ActName .
		
		«TAB»ops unit int string : -> BType [ctor] .
		«TAB»ops exp : -> Expression [ctor] .
		
		«TAB»**********************************
		«TAB»***          CONTRACTS         ***
		«TAB»**********************************
		«TAB»op env : -> CEnv .
		«IF contractNames.size>0»
		«TAB»ops «contractNames.join(" ", [x|x+"env"])» : -> Var [ctor] .
		«ENDIF»
		«IF contractNames.size>0»
		«TAB»ops «contractNames.join(" ")» : -> UniContract .
		«ENDIF»
		
		«IF contracts.size>0»
		«TAB»*** env contracts
		«TAB»eq env = (
		«TAB»«TAB»«contracts.join("\n"+TAB+TAB+"&\n"+TAB+TAB, [c| c.maudeCode])»
		«TAB») .
		
		«TAB»*** list of contracts
		«FOR contract : contracts»
		«TAB»eq «contract.name» = defToRec(«contract.name»env, env) .
		«ENDFOR»
		«ENDIF»
		
		«TAB»**********************************
		«TAB»***          PROCESSES         ***
		«TAB»**********************************
		«IF processNames.size>0»
		«TAB»ops «processNames.join(" ")» : -> Process .
		«ENDIF»
		«IF envProcesses.size>0»
		«TAB»ops «envProcessNames.join(" ")» : -> ProcIde .
		«ENDIF»
		
		«TAB»*** list of processes
		«FOR process : processes»    
		«TAB»«process.toMaude(TAB)»
		«ENDFOR»
		
		«IF envProcesses.size>0»
		«TAB»*** env processes
		«TAB»eq env = (
		«TAB»«TAB»«envProcesses.join("\n"+TAB+TAB+"&\n"+TAB+TAB, [p| p.toMaude(TAB+TAB)])»
		«TAB») .
		«ENDIF»
		
		endm
		
		*** honesty
		«IF processToCheck!=null»
		red honest(«processToCheck.name» , ['«moduleName»] , 50) .
		«ENDIF»
		
		*** exit the program
		quit
		'''
	}
	
	/*
	 * maude code generation
	 */
	def dispatch String maudeCode(ContractDefinition contractDef) {
		'''«contractDef.name»env =def «IF contractDef.contract!=null»«contractDef.contract.maudeCode»«ELSE»0«ENDIF»'''
	}
	
	def dispatch String maudeCode(IntSum obj) {
		if (obj.actions.length==1)
			obj.actions.get(0).maudeCode
		else
			obj.actions.join("( ", " (+) ", " )", [a | a.maudeCode])
	}
	
	def dispatch String maudeCode(ExtSum obj) {
		if (obj.actions.length==1)
			obj.actions.get(0).maudeCode
		else
			obj.actions.join("( ", " + ", " )", [a | a.maudeCode])
	}
	
	def dispatch String maudeCode(EmptyContract obj) {
		"0"
	}
	
	def dispatch String maudeCode(IntAction obj) {
		'''"«obj.actionName»" ! «getActionType(obj.type)»«IF obj.next!=null» . «obj.next.maudeCode»«ELSE» . 0«ENDIF»'''
	}
	
	def dispatch String maudeCode(ExtAction obj) {
		'''"«obj.actionName»" ? «getActionType(obj.type)»«IF obj.next!=null» . «obj.next.maudeCode»«ELSE» . 0«ENDIF»'''
	}
	
	def dispatch String maudeCode(ContractReference obj) {
		obj.ref.name+"env"
	}

	
	
	/*
	 * 
	 * processes
	 * 
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	def dispatch String toMaude(ProcessDefinition obj, String padLeft) {
		if (obj.process==null) obj.process = Co2Factory.eINSTANCE.createParallelProcesses
		
		if (obj.params.size==0)
			'''eq «obj.name» = «IF obj.process!=null»«obj.process.toMaude(padLeft)»«ELSE»0«ENDIF» .'''
		else
			'''«obj.name»«obj.params.join("("," ; ", ")",[
				n | '''«IF n.type instanceof SessionType»"«n.name»"«ELSE»exp«ENDIF»'''
			])» =def «obj.process.toMaude(padLeft)»'''
	}
	
	def dispatch String toMaude(ParallelProcesses obj, String padLeft) {
		if (obj.processes.size==0)
			return "0"
		
		var pad = padLeft;
		var sb = new StringBuilder()
		
		if (obj.processes.size>1) {
			sb.append("\n").append(pad).append("(")
			pad=pad.addPad
		}
		
		var i=0;
		for (p : obj.processes) {
			
			if (i++>0) {
				sb.append(" | ");
			}
			
			if (obj.processes.size()>1) {
				sb.append("\n").append(pad)
			}
			
			sb.append(p.toMaude(pad));
		}
	
		if (obj.processes.size>1) {
			pad=pad.removePad
			sb.append("\n").append(pad).append(")")
		}
		
		return sb.toString
	}
	
	def dispatch String toMaude(DelimitedProcess obj, String padLeft) {
		if (obj.freeNames.length>0)
			'''(«obj.freeNames.join(" ", [x| '''("«x.name»")'''])» «obj.process.toMaude(padLeft)»)'''
		else
			obj.process.toMaude(padLeft)
	}
	
	def dispatch String toMaude(Sum obj, String padLeft) {
		var pad = padLeft;
		var sb = new StringBuilder()
		
		if (obj.prefixes.size>1) {
			sb.append("\n").append(pad).append("(")
			pad=pad.addPad
		}
		
		var i=0;
		for (p : obj.prefixes) {
			
			if (i++>0) {
				sb.append(" + ");
			}
			
			if (obj.prefixes.size()>1) {
				sb.append("\n").append(pad)
			}
			
			sb.append(p.toMaude(pad));
		}
	
		if (obj.prefixes.size>1) {
			pad=pad.removePad
			sb.append("\n").append(pad).append(")")
		}
		
		return sb.toString
	}
	
	def dispatch String toMaude(EmptyProcess obj, String padLeft) {
		"0"
	}
	
	def dispatch String toMaude(IfThenElse obj, String padLeft) {
		if (obj.^else==null) obj.^else = Co2Factory.eINSTANCE.createEmptyProcess

		var pad = padLeft;
		var sb = new StringBuilder()
		
		sb.append("\n").append(pad).append("(")
		pad=pad.addPad
			
		sb.append("\n").append(pad).append('''if «obj.^if.toMaude(pad)» ''')
		sb.append("\n").append(pad).append('''then «obj.then.toMaude(pad)» ''')
		sb.append("\n").append(pad).append('''else «obj.^else.toMaude(pad)» ''')

		pad=pad.removePad
		sb.append("\n").append(padLeft).append(")")	
		
		return sb.toString		
	}
	
	/*
	 * prefixes
	 */
	def dispatch String toMaude(Tau obj, String padLeft) {
		if (obj.next==null) obj.next = Co2Factory.eINSTANCE.createEmptyProcess
		'''t . «obj.next.toMaude(padLeft)»'''
	}
	
	def dispatch String toMaude(Tell obj, String padLeft) {
		if (obj.next==null) obj.next = Co2Factory.eINSTANCE.createEmptyProcess
		'''tell "«obj.session.name»" «obj.contractReference.name» . «obj.next.toMaude(padLeft)»'''
	}
	
	def dispatch String toMaude(TellRetract obj, String padLeft) {
		if (obj.RProcess==null) obj.RProcess = Co2Factory.eINSTANCE.createEmptyProcess
		'''tell "«obj.session.name»" «obj.contractReference.name» . ( ask "«obj.session.name»" True . «obj.process.toMaude(padLeft)» + retract "«obj.session.name»" . «obj.RProcess.toMaude(padLeft)» )'''
	}
	
	def dispatch String toMaude(DoInput obj, String padLeft) {
		if (obj.next==null) obj.next = Co2Factory.eINSTANCE.createEmptyProcess
		'''do "«obj.session.name»" "«obj.actionName»" ? «getFreeNameType(obj.variable)» . «obj.next.toMaude(padLeft)»'''
	}
	
	def dispatch String toMaude(DoOutput obj, String padLeft) {
		if (obj.next==null) obj.next = Co2Factory.eINSTANCE.createEmptyProcess
		'''do "«obj.session.name»" "«obj.actionName»" ! «getExpressionType(obj.value)» . «obj.next.toMaude(padLeft)»'''
	}
	
	def dispatch String toMaude(Ask obj, String padLeft) {
		if (obj.next==null) obj.next = Co2Factory.eINSTANCE.createEmptyProcess
		'''ask "«obj.session.name»" True . «obj.next.toMaude(padLeft)»'''
	}
	
	def dispatch String toMaude(Retract obj, String padLeft) {
		if (obj.next==null) obj.next = Co2Factory.eINSTANCE.createEmptyProcess
		'''retract "«obj.session.name»" . «obj.next.toMaude(padLeft)»'''
	}
	
	def dispatch String toMaude(ProcessCall obj, String padLeft) {
		if (obj.params.length==0)
			'''«obj.reference.name»'''
		else {
			'''«obj.reference.name»«obj.params.join("("," ; ", ")",[
				n|'''«n.toMaude(padLeft)»'''
			])»'''
		}
	}
	
	def dispatch String toMaude(Expression exp, String padLeft) {
		if (
			exp instanceof VariableReference 
			&& (exp as VariableReference).ref.type instanceof SessionType
		)
			return '''"«(exp as VariableReference).ref.name»"'''
		else
			return "exp"
	}
	
	
	
	
	
	
	def String getActionType(ActionType type) {
		if (type==null || type instanceof UnitActionType) return "unit"
		else if (type instanceof IntActionType) return "int"
		else if (type instanceof StringActionType) return "string"
	}
	
	def String getExpressionType(Expression exp) {
		
		if (exp==null)
			return "unit"
		
		val typeTrace = new RuleApplicationTrace()
		val result = co2TypeSystem.type(null, typeTrace, exp)
        
        val type = result.value
        
		if (type instanceof IntType) return "int"
		else if (type instanceof StringType) return "string"
		//other types are not permitted by the semantic checker
	}
	
	def String getFreeNameType(FreeName variable) {
		if (variable==null) return "unit"
		else if (variable.type instanceof IntType) return "int"
		else if (variable.type instanceof StringType) return "string"
	}
	
	
	def String addPad(String pad) {
		pad+TAB
	}
	
	def String removePad(String pad) {
		pad.replaceFirst(TAB,"")
	}
	
}