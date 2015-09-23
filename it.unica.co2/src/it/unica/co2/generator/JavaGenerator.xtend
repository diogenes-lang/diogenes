package it.unica.co2.generator

import com.google.inject.Inject
import it.unica.co2.co2.ActionType
import it.unica.co2.co2.AndExpression
import it.unica.co2.co2.ArithmeticSigned
import it.unica.co2.co2.Ask
import it.unica.co2.co2.BooleanLiteral
import it.unica.co2.co2.BooleanNegation
import it.unica.co2.co2.BooleanType
import it.unica.co2.co2.CO2System
import it.unica.co2.co2.Co2Factory
import it.unica.co2.co2.Comparison
import it.unica.co2.co2.ContractDefinition
import it.unica.co2.co2.ContractReference
import it.unica.co2.co2.DelimitedProcess
import it.unica.co2.co2.DoInput
import it.unica.co2.co2.DoOutput
import it.unica.co2.co2.EmptyContract
import it.unica.co2.co2.EmptyProcess
import it.unica.co2.co2.Equals
import it.unica.co2.co2.Expression
import it.unica.co2.co2.ExtAction
import it.unica.co2.co2.ExtSum
import it.unica.co2.co2.FreeName
import it.unica.co2.co2.IfThenElse
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
import it.unica.co2.co2.Prefix
import it.unica.co2.co2.Process
import it.unica.co2.co2.ProcessCall
import it.unica.co2.co2.ProcessDefinition
import it.unica.co2.co2.SessionType
import it.unica.co2.co2.StringActionType
import it.unica.co2.co2.StringLiteral
import it.unica.co2.co2.StringType
import it.unica.co2.co2.Sum
import it.unica.co2.co2.Tau
import it.unica.co2.co2.Tell
import it.unica.co2.co2.UnitActionType
import it.unica.co2.co2.VariableReference
import java.text.SimpleDateFormat
import java.util.Date
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

import static extension it.unica.co2.generator.JavaGeneratorUtils.*

class JavaGenerator extends AbstractIGenerator {
	
	@Inject extension IQualifiedNameProvider qNameProvider
	
	int WAIT_TIMEOUT = 10000
	int MESSAGE_COUNT = 0
	int ASK_COUNT = 0
	
	override doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		MESSAGE_COUNT=0;
		CONTRACT_NAME_COUNT = 0
		ASK_COUNT = 0
		
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

		val isTranslatable = co2System.isJavaTranslatable;
		
		
		'''
		«IF !packageName.empty»
		package «packageName»;
		«ENDIF»
		
		«IF !isTranslatable.value»
		/*
		 * Sorry, your co2 system is not translatable to Java.
		 * «var node = NodeModelUtils.getNode(isTranslatable.eobject)»
		 * code    : «node.text.trim.replaceAll("\t", "").replaceAll("\n", " ")»
		 * reason  : «isTranslatable.reason»
		 * line(s) : «node.startLine»«IF node.startLine!=node.endLine»-«node.endLine»«ENDIF»
		 *
		 */
		«ELSE»
		
		
		import static it.unica.co2.model.ContractFactory.*;
		import it.unica.co2.api.Session2;
		import it.unica.co2.model.contract.Contract;
		import it.unica.co2.model.contract.ContractWrapper;
		import it.unica.co2.model.contract.Recursion;
		import it.unica.co2.model.contract.Sort;
		import it.unica.co2.model.process.CO2Process;
		import it.unica.co2.model.process.Participant;
		import co2api.ContractException;
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
«««			«c.javaRecursionContractDeclaration»
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
«««			«c.javaRecursionContractDefinition»
			«ENDFOR»
		«ENDIF»
		}
		'''
	}
	
	def String getJavaContractDeclaration(ContractDefinition c) {
		'''private static ContractWrapper «c.name» = wrapper();'''
	}

//	def String getJavaRecursionContractDeclaration(ContractDefinition c) {
//		var recursions = c.eAllContents.filter(Recursion).toSet
//		'''
//		«FOR r : recursions»
//		private static Recursion «r.name» = recursion();
//		«ENDFOR»
//		'''
//	}
	
	def String getJavaContractDefinition(ContractDefinition c) {
		c.contract = c.contract?: Co2Factory.eINSTANCE.createEmptyContract
		'''«c.name».setContract(«c.contract.javaContract»);'''
	}
	
//	def String getJavaRecursionContractDefinition(ContractDefinition c) {
//		var recursions = c.eAllContents.filter(Recursion).toSet
//		'''
//		«FOR r : recursions»
//		«r.name».setContract(«r.body.javaContract»);
//		«ENDFOR»
//		'''
//	}

	
	def dispatch String getJavaContract(IntSum c) {
		'''internalSum()«FOR a : c.actions»«a.getJavaIntAction»«ENDFOR»'''
	}
	
	def dispatch String getJavaContract(ExtSum c) {
		'''externalSum()«FOR a : c.actions»«a.getJavaExtAction»«ENDFOR»'''
	}
	
	def dispatch String getJavaContract(ContractReference c) {
		c.ref.name
	}
	
//	def dispatch String getJavaContract(Recursion c) {
//		c.name//c.body.javaContract
//	}
	
	def dispatch String getJavaContract(EmptyContract c) {
		'''null'''
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
	
	def String getJavaType(FreeName fn) {
		if (fn.type instanceof IntType) "Integer"
		else if (fn.type instanceof StringType) "String"
		else if (fn.type instanceof BooleanType) "boolean"
		else if (fn.type instanceof SessionType) "Session2<TST>"
	}
	
	
	def String getRunBody(ProcessDefinition p) {
		MESSAGE_COUNT=0		//message count can be reset
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
	
	def dispatch String toJava(DelimitedProcess p) {
		'''
		«p.process.toJava»
		'''
	}
	
	def dispatch String toJava(Process p) {
		"/* ERROR */"
	}
	
	def dispatch String toJava(EmptyProcess p) {
		""
	}
	
	def dispatch String toJava(Tell tell) {
		//tell must be followed by a sum containing an ask-prefix and a possible tau
		var Sum tellNext
		if (tell.next instanceof Sum) {
			tellNext = tell.next as Sum
		}
		else if (tell.next instanceof ParallelProcesses) {
			tellNext = (tell.next as ParallelProcesses).processes.get(0).process as Sum
		}
		
		var taus = tellNext.prefixes.filter(Tau)
		var asks = tellNext.prefixes.filter(Ask)		
		var useTimeout = taus.size==1 && asks.size==1
		
		val publicName = '''pbl$«tell.session.name»$«tell.contractReference.name»'''
		
		'''
		Public<TST> «publicName» = tell(«tell.contractReference.name»);
		«IF useTimeout»
		
		try {
			Session2<TST> «tell.session.name» = waitForSession(«publicName», «WAIT_TIMEOUT»);
			«asks.get(0).toJava»
		}
		catch(TimeExpiredException e) {
			«taus.get(0).eAllContents.filter(Ask).forEach[x|x.public=publicName]»
			«taus.get(0).toJava»
		}
		«ELSE»
		Session2<TST> «tell.session.name» = waitForSession(«publicName»);
		
		«tell.next.toJava»
		«ENDIF»
		'''
	}
	
	def dispatch String toJava(Sum p) {
		
		if (p.prefixes.size==1 && !(p.prefixes.get(0) instanceof DoInput)) {
			return p.prefixes.get(0).toJava
		}
		
		//sum can contain only DoInput (on same session) and at most one tau
		var taus = p.prefixes.filter(Tau)
		val containsTau =taus.size>0

		'''
		«IF containsTau»
		try {
			«p.getSwitchOfReceives(true)»
		}
		catch (TimeExpiredException e) {
			«taus.get(0).toJava»
		}
		
		«ELSE»
		«p.getSwitchOfReceives(false)»
		«ENDIF»
		'''
	}
	
	def String getSwitchOfReceives(Sum p, boolean timeout) {
		
		var inputActions = p.prefixes.filter(DoInput)
		val session = inputActions.get(0).session.name
		val actionNames = inputActions.map[x|x.actionName]
		
		var messageName = '''msg$«MESSAGE_COUNT++»'''
		
		'''		
		«getLogString('''waiting on '«session»' for actions [«actionNames.join(",")»]''')»
		Message «messageName» = «session».waitForReceive(«IF timeout»«WAIT_TIMEOUT», «ENDIF»«actionNames.join(",", [x|'''"«x»"'''])»);
		
		«IF inputActions.size==1»
			logger.log("received [«inputActions.get(0).actionName»]");
			«inputActions.get(0).getJavaDoInput(messageName)»
		«ELSE»				
		switch («messageName».getLabel()) {			
			«FOR a : inputActions»
			
			case "«a.actionName»":
				logger.log("received [«a.actionName»]");
				«a.getJavaDoInput(messageName)»
				break;
			«ENDFOR»
			
			default:
				throw new IllegalStateException("You should not be here");
		}
		«ENDIF»
		'''
	}
	
	/**
	 * Change variable name in order to be uniqueon sums, i.e. <code>do a? n:int + do b? n:int</code>.
	 * All references will be updated.
	 */
	def void fixVariableName(DoInput input) {
		if (input.variable!=null) 
			input.variable.name=input.variable.name+"$"+input.actionName+"$msg"+MESSAGE_COUNT
	}
	
	def String getJavaDoInput(DoInput input, String messageName) {
		
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
			«p.^else.toJava»
		}
		'''
	}
	
	def dispatch String toJava(ProcessCall p) {
		'''
		new «p.reference.name»(«p.params.join(",", [x | x.javaExpression])»).run();
		'''
	}
	
	def dispatch String toJava(Prefix p) {
		"/* ERROR */"
	}
	
	def dispatch String toJava(DoOutput p) {
		'''
		«p.session.name».send("«p.actionName»"«IF p.value!=null», «p.value.javaExpression»«ENDIF»);
		«IF p.next!=null»«p.next.toJava»«ENDIF»
		'''
	}
	
	def dispatch String toJava(Tau p) {
		'''«IF p.next!=null»«p.next.toJava»«ENDIF»'''
	}
	
	def dispatch String toJava(Ask ask) {
		'''
		«IF ask.public!=null»
		«ask.session.name = ask.session.name+"$"+ASK_COUNT++»
		Session2<TST> «ask.session.name» = waitForSession(«ask.public»);
		«ENDIF»
		«IF ask.next!=null»«ask.next.toJava»«ENDIF»
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
		'''(«exp.left.javaExpression»«exp.op»«exp.right.javaExpression»)'''
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
	
	
}