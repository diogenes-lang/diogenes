package it.unica.co2.generator

import com.google.inject.Inject
import it.unica.co2.co2.ActionType
import it.unica.co2.co2.AndExpression
import it.unica.co2.co2.ArithmeticSigned
import it.unica.co2.co2.BooleanLiteral
import it.unica.co2.co2.BooleanNegation
import it.unica.co2.co2.BooleanType
import it.unica.co2.co2.CO2System
import it.unica.co2.co2.Co2Factory
import it.unica.co2.co2.Comparison
import it.unica.co2.co2.ContractDefinition
import it.unica.co2.co2.ContractReference
import it.unica.co2.co2.DelimitedProcess
import it.unica.co2.co2.EmptyContract
import it.unica.co2.co2.EmptyProcess
import it.unica.co2.co2.Equals
import it.unica.co2.co2.Expression
import it.unica.co2.co2.ExtAction
import it.unica.co2.co2.ExtSum
import it.unica.co2.co2.IfThenElse
import it.unica.co2.co2.Input
import it.unica.co2.co2.IntAction
import it.unica.co2.co2.IntActionType
import it.unica.co2.co2.IntSum
import it.unica.co2.co2.IntType
import it.unica.co2.co2.Minus
import it.unica.co2.co2.MultiOrDiv
import it.unica.co2.co2.NumberLiteral
import it.unica.co2.co2.OrExpression
import it.unica.co2.co2.ParallelProcesses
import it.unica.co2.co2.Plus
import it.unica.co2.co2.ProcessCall
import it.unica.co2.co2.ProcessDefinition
import it.unica.co2.co2.Receive
import it.unica.co2.co2.Send
import it.unica.co2.co2.SessionType
import it.unica.co2.co2.StringActionType
import it.unica.co2.co2.StringLiteral
import it.unica.co2.co2.StringType
import it.unica.co2.co2.Tell
import it.unica.co2.co2.TellAndWait
import it.unica.co2.co2.TellRetract
import it.unica.co2.co2.UnitActionType
import it.unica.co2.co2.Variable
import it.unica.co2.co2.VariableReference
import it.unica.co2.xsemantics.CO2TypeSystem
import java.text.SimpleDateFormat
import java.util.Date
import java.util.HashMap
import java.util.Map
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

import static extension it.unica.co2.generator.JavaGeneratorUtils.*

class JavaGenerator extends AbstractIGenerator {
	
	@Inject extension IQualifiedNameProvider qNameProvider
	@Inject CO2TypeSystem typeSystem
	
	int WAIT_TIMEOUT = 10_000
	int TELL_RETRACT_TIMEOUT = 10_000
	
	override doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		CONTRACT_NAME_COUNT = 0
		
		for (e : resource.allContents.toIterable.filter(CO2System)) {
			var outputFilename = e.systemDeclaration.fullyQualifiedName.toString("/") + ".java"
			println('''generating «outputFilename»''')
			fsa.generateFile(outputFilename, e.generateJava)
		}
	}
	
	
	
	def String generateJava(CO2System co2System) {
		var className = co2System.systemDeclaration.fullyQualifiedName.lastSegment
		var packageName = co2System.systemDeclaration.fullyQualifiedName.skipLast(1)
		var processDefinitions = co2System.contractsAndProcessesDeclaration.processes
		var contractDefinitions = co2System.contractsAndProcessesDeclaration.contracts
		var honestyProcess = if (co2System.honesty!=null) co2System.honesty.process else null
		
		//fix recursion name
//		contractDefinitions.fixRecursions()
		
		//fix anonymous tells
		contractDefinitions.addAll( co2System.eAllContents.filter(Tell).map[t| t.fixTell("_tell_contr_")].toSet )
		contractDefinitions.addAll( co2System.eAllContents.filter(TellRetract).map[t| t.fixTell("_tell_contr_")].toSet )

		val isTranslatable = co2System.isJavaTranslatable;
		
		
		'''
		«IF !packageName.empty»
		package «packageName»;
		«ENDIF»
		
		«IF !isTranslatable.value»
		/*
		 * Sorry, your co2 system is not translatable to Java.
		 * «var node = NodeModelUtils.getNode(isTranslatable.eobject)»
		 * code    : «node.getString»
		 * reason  : «isTranslatable.reason»
		 * line(s) : «node.startLine»«IF node.startLine!=node.endLine»-«node.endLine»«ENDIF»
		 *
		 */
		«ELSE»
		
		
		import static it.unica.co2.api.contract.utils.ContractFactory.*;
		import it.unica.co2.api.Session2;
		import it.unica.co2.api.contract.Contract;
		import it.unica.co2.api.contract.ContractDefinition;
		import it.unica.co2.api.contract.Recursion;
		import it.unica.co2.api.contract.Sort;
		import it.unica.co2.api.process.CO2Process;
		import it.unica.co2.api.process.Participant;
		import co2api.ContractException;
		import co2api.ContractExpiredException;
		import co2api.Message;
		import co2api.Public;
		import co2api.TST;
		import co2api.TimeExpiredException;
		
		/*
		 * auto-generated by co2-plugin
		 * creation date: «new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())»
		 */
		
		@SuppressWarnings("unused")
		public class «className» {
			
			private static String username = "test@co2-plugin.com";
			private static String password = "test";
			
			«contractDefinitions.getJavaContractDeclarations»
			«contractDefinitions.getJavaContractDefinitions»
			«FOR p : processDefinitions»
			«p.getJavaClass»
			«ENDFOR»
			
			public static void main(String[] args) {
				«IF honestyProcess!=null»
				new «honestyProcess.name»().run();
				«ENDIF»
			}
		}
		«ENDIF»
		'''
	}
	
	def String getJavaContractDeclarations(Iterable<ContractDefinition> contracts) {
		'''
		«IF contracts.size>0»
		
		/*
		 * contracts declaration
		 */
		«FOR c : contracts»
			«c.javaContractDeclaration»
			«ENDFOR»
		«ENDIF»
		'''
	}
	
	def String getJavaContractDefinitions(Iterable<ContractDefinition> contracts) {
		'''
		«IF contracts.size>0»
		
		/*
		 * contracts initialization
		 */
		static {
			«FOR c : contracts»
			«c.javaContractDefinition»
			«ENDFOR»
		}
		«ENDIF»
		'''
	}
	
	def String getJavaContractDeclaration(ContractDefinition c) {
		'''private static ContractDefinition «c.name» = def("«c.name»");'''
	}
	
	def String getJavaContractDefinition(ContractDefinition c) {
		c.contract = c.contract?: Co2Factory.eINSTANCE.createEmptyContract
		'''«c.name».setContract(«c.contract.javaContract»);'''
	}
	
	
	def dispatch String getJavaContract(IntSum c) {
		'''internalSum()«FOR a : c.actions»«a.getJavaIntAction»«ENDFOR»'''
	}
	
	def dispatch String getJavaContract(ExtSum c) {
		'''externalSum()«FOR a : c.actions»«a.getJavaExtAction»«ENDFOR»'''
	}
	
	def dispatch String getJavaContract(ContractReference c) {
		'''ref(«c.ref.name»)'''
	}
	
	def dispatch String getJavaContract(EmptyContract c) {
		'''empty()'''
	}
	
	def String getJavaIntAction(IntAction a) {
		'''.add("«a.actionName»", «a.type.javaActionSort»«IF a.next!=null», «a.next.javaContract»«ENDIF»)'''
	}
	
	def String getJavaExtAction(ExtAction a) {
		'''.add("«a.actionName»", «a.type.javaActionSort»«IF a.next!=null», «a.next.javaContract»«ENDIF»)'''
	}
	
	def String getJavaActionSort(ActionType type) {
		if (type==null || type instanceof UnitActionType) "Sort.UNIT"
		else if (type instanceof IntActionType) "Sort.INT"
		else if (type instanceof StringActionType) "Sort.STRING"
	}
	
	def String getJavaClass(ProcessDefinition p) {
		var className = p.name
		'''
		
		public static class «className» extends Participant {
			
			private static final long serialVersionUID = 1L;
			«p.getFieldsAndConstructor»
			
			«p.runBody»
		}
		'''
	}
	
	def String getJavaType(Variable fn) {
		if (fn.type instanceof IntType)			"Integer"
		else if (fn.type instanceof StringType)	"String"
		else if(fn.type instanceof BooleanType) "boolean" 
		else if(fn.type instanceof SessionType) "Session2<TST>"
	}
	
	
	def String getFieldsAndConstructor(ProcessDefinition p) {
		'''
		«FOR fn : p.params»
		private «fn.javaType» «fn.name»;
		«ENDFOR»
		
		public «p.name»(«p.params.join(",", [fn | fn.javaType+" "+fn.name])») {
			super(username, password);
			«FOR fn : p.params»
			this.«fn.name»=«fn.name»;
			«ENDFOR»
		}
		'''
	}
	
	
	def String getRunBody(ProcessDefinition p) {
		clearFreeNames		// freenames can be reset
		
		'''
		@Override
		public void run() {
			«IF p.process!=null»«p.process.toJava»«ENDIF»
		}'''
	}
	
	def dispatch String toJava(ParallelProcesses pp) {
		// pp.processes is always > 0
		if (pp.processes.size>1) { 
			'''
			«FOR p : pp.processes »
			
			parallel(()->{
				«p.toJava»
			});
			«ENDFOR»
			'''
		}
		else {
			pp.processes.get(0).toJava
		}
	}
	
	def dispatch String toJava(EObject obj) {
		'''
		/* 
		 * ERROR: please report to the author 
		 * node: «NodeModelUtils.getNode(obj).text.trim.replaceAll("\t", "").replaceAll("\n", " ")»
		 */
		'''
	}

	def dispatch String toJava(DelimitedProcess p) {
		p.process.toJava
	}
	
	def dispatch String toJava(EmptyProcess p) {
		""
	}
	
	def dispatch String toJava(TellRetract tell) {
		
		var freshName = getFreshName(tell.session.name)		// get a fresh name
		tell.session.name = freshName						// update the name all its references
		
		val publicName = '''pbl_«tell.session.name»'''
		
		'''
		Public<TST> «publicName» = tell(«tell.contractReference.name», «TELL_RETRACT_TIMEOUT»);
		
		try {
			Session2<TST> «tell.session.name» = waitForSession(«publicName»);
			
			«tell.process.toJava»
		}
		catch(ContractExpiredException e) {
			//retract «tell.session.name»
			«IF tell.RProcess!=null»
			«tell.RProcess.toJava»
			«ENDIF»
		}
		'''
	}
	
	def dispatch String toJava(TellAndWait tell) {
		var freshName = getFreshName(tell.session.name)		// get a fresh name
		tell.session.name = freshName						// update the name all its references
		
		'''
		Session2<TST> «tell.session.name» = tellAndWait(«tell.contractReference.name»);
		
		«tell.process.toJava»
		'''
	}
	
	def dispatch String toJava(Receive receive) {
		
		'''
		«IF receive.isTimeout»
		try {
			«receive.actions.getSwitchOfReceives(receive.session.name, true)»
		}
		catch (TimeExpiredException e) {
			«receive.TProcess.toJava»
		}
		
		«ELSE»
		«receive.actions.getSwitchOfReceives(receive.session.name, false)»
		«ENDIF»
		'''
	}
	
	def String getSwitchOfReceives(EList<Input> inputActions, String session, boolean timeout) {
		
		val actionNames = inputActions.map[x|x.actionName]
		
		var messageName = getFreshName("msg")
		
		'''		
		«getLogString('''waiting on '«session»' for actions [«actionNames.join(",")»]''')»
		Message «messageName» = «session».waitForReceive(«IF timeout»«WAIT_TIMEOUT», «ENDIF»«actionNames.join(",", [x|'''"«x»"'''])»);
		
		«IF inputActions.size==1»
			logger.log("received [«inputActions.get(0).actionName»]");
			«inputActions.get(0).getJavaInput(messageName)»
		«ELSE»				
		switch («messageName».getLabel()) {			
			«FOR a : inputActions»
			
			case "«a.actionName»":
				logger.log("received [«a.actionName»]");
				«a.getJavaInput(messageName)»
				break;
			«ENDFOR»
			
			default:
				throw new IllegalStateException("You should not be here");
		}
		«ENDIF»
		'''
	}
	
	/**
	 * Change variable name in order to be unique on sums, i.e. <code>do a? n:int + do b? n:int</code>.
	 * All references will be updated.
	 */
	def void fixVariableName(Input input) {
		if (input.variable!=null) 
			input.variable.name = getFreshName(input.variable.name)
	}
	
	def String getJavaInput(Input input, String messageName) {
		
		// change variable name in order to be unique, i.e. like  do a? n:int + do b? n:int
		input.fixVariableName
		
		'''
		«IF input.variable!=null»
			«input.variable.javaType» «input.variable.name»;
			«IF input.variable.type instanceof IntType»
				try {
					«input.variable.name» = Integer.parseInt(«messageName».getStringValue());
				}
				catch (NumberFormatException | ContractException e) {
					throw new RuntimeException(e);
				}
				«ELSE»
				try {
					«input.variable.name» = «messageName».getStringValue();
				}
				catch (ContractException e) {
					throw new RuntimeException(e);
				}
			«ENDIF»
		«ENDIF»
		«IF input.next!=null»«input.next.toJava»«ENDIF»
		'''
	}
	
	
	def dispatch String toJava(IfThenElse p) {
		'''
		if («p.^if.javaExpression») {
			«p.^then.toJava»
		}
		else {
			«IF p.^else!=null»«p.^else.toJava»«ENDIF»
		}
		'''
	}
	
	def dispatch String toJava(ProcessCall p) {
		'''
		new «p.reference.name»(«p.params.join(",", [x | x.javaExpression])»).run();
		'''
	}
	
	def dispatch String toJava(Send p) {
		'''
		«p.session.name».send("«p.actionName»"«IF p.value!=null», «p.value.javaExpression»«ENDIF»);
		«IF p.next!=null»«p.next.toJava»«ENDIF»
		'''
	}
	
	
	
	
	
	
	
	def dispatch String getJavaExpression(Expression exp) {
		"/* ERROR */"
	}
	
	def dispatch String getJavaExpression(OrExpression exp) {
		'''(«exp.left.javaExpression»||«exp.right.javaExpression»)'''
	}
	
	def dispatch String getJavaExpression(AndExpression exp) {
		'''(«exp.left.javaExpression»&&«exp.right.javaExpression»)'''
	}
	
	def dispatch String getJavaExpression(Comparison exp) {
		'''(«exp.left.javaExpression»«exp.op»«exp.right.javaExpression»)'''
	}
	
	def dispatch String getJavaExpression(Equals exp) {
		
		var lType = typeSystem.type(exp.left).value
		var rType = typeSystem.type(exp.right).value
		
		if (lType instanceof StringType || rType instanceof StringType)
			'''(«exp.left.javaExpression».equals(«exp.right.javaExpression»))'''
		else
			'''(«exp.left.javaExpression»==«exp.right.javaExpression»)'''
	}
	
	def dispatch String getJavaExpression(Plus exp) {
		'''(«exp.left.javaExpression»+«exp.right.javaExpression»)'''
	}
	
	def dispatch String getJavaExpression(Minus exp) {
		'''(«exp.left.javaExpression»-«exp.right.javaExpression»)'''
	}
	
	def dispatch String getJavaExpression(MultiOrDiv exp) {
		'''(«exp.left.javaExpression»«exp.op»«exp.right.javaExpression»)'''
	}
	
	def dispatch String getJavaExpression(BooleanNegation exp) {
		'''!«exp.expression.javaExpression»'''
	}
	
	def dispatch String getJavaExpression(ArithmeticSigned exp) {
		'''-«exp.expression.javaExpression»'''
	}
	
	def dispatch String getJavaExpression(NumberLiteral exp) {
		exp.value.toString
	}
	
	def dispatch String getJavaExpression(StringLiteral exp) {
		'''"«exp.value»"'''
	}
	
	def dispatch String getJavaExpression(BooleanLiteral exp) {
		exp.value
	}
	
	def dispatch String getJavaExpression(VariableReference exp) {
		exp.ref.name
	}
	
	
	
	
	
	
	Map<String,Integer> freeNames = new HashMap 
	
	def String getFreshName(String name) {
		var count = freeNames.get(name)
		
		if (count==null) {
			freeNames.put(name, 1);
			return name;
		}
		else {
			freeNames.put(name, count+1);
			return name+"_"+count
		}
	}
	
	def void clearFreeNames() {
		freeNames.clear
	}
	
}