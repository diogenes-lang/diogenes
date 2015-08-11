package it.unica.co2.generator

import com.google.inject.Inject
import it.unica.co2.co2.ActionType
import it.unica.co2.co2.BooleanType
import it.unica.co2.co2.CO2System
import it.unica.co2.co2.Co2Factory
import it.unica.co2.co2.Contract
import it.unica.co2.co2.ContractDefinition
import it.unica.co2.co2.ContractReference
import it.unica.co2.co2.EmptyContract
import it.unica.co2.co2.ExtAction
import it.unica.co2.co2.ExtSum
import it.unica.co2.co2.FreeName
import it.unica.co2.co2.IntAction
import it.unica.co2.co2.IntActionType
import it.unica.co2.co2.IntSum
import it.unica.co2.co2.IntType
import it.unica.co2.co2.ProcessDefinition
import it.unica.co2.co2.SessionType
import it.unica.co2.co2.StringActionType
import it.unica.co2.co2.StringType
import it.unica.co2.co2.UnitActionType
import java.io.File
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.naming.IQualifiedNameProvider

class JavaGenerator extends AbstractIGenerator {
	
	@Inject extension IQualifiedNameProvider qNameProvider
	
	override doGenerate(Resource resource, IFileSystemAccess fsa) {
		//get the IProject from the given Resource
		val platformString = resource.URI.toPlatformString(true);
	    val myFile = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(platformString));
	    val project = myFile.getProject();
		
		//get location of workspace (java.io.File)  
		var workspaceDirectory = ResourcesPlugin.getWorkspace().getRoot().getLocation().toFile()
		
		//get location of the project
		var projectDirectory = new File(workspaceDirectory, project.name)
		
		for (e : resource.allContents.toIterable.filter(CO2System)) {
			var outputFilename = e.systemDeclaration.fullyQualifiedName.toString("/") + ".java"
			println('''generating «outputFilename»''')
			fsa.generateFile(outputFilename, e.generateJava)
		}
	}
	
	
	
	def String generateJava(CO2System co2System) {
		var className = co2System.systemDeclaration.fullyQualifiedName.lastSegment
		var packageName = co2System.systemDeclaration.fullyQualifiedName.skipLast(1)
		var processDefinitions = co2System.eAllContents.filter(ProcessDefinition).toIterable
		var contractDefinitions = co2System.eAllContents.filter(ContractDefinition).toIterable
		
		'''
		«IF !packageName.empty»
		package «packageName»;
		«ENDIF»
		
		import static it.unica.co2.model.ContractFactory.*;
		import it.unica.co2.api.Session2;
		import it.unica.co2.model.contract.Contract;
		import it.unica.co2.model.contract.Sort;
		import it.unica.co2.model.process.CO2Process;
		import it.unica.co2.model.process.Participant;
		import co2api.ContractException;
		import co2api.Message;
		import co2api.Public;
		import co2api.TST;
		import co2api.TimeExpiredException;
		
		@SuppressWarnings("unused")
		public class «className» {
		
			«FOR c : contractDefinitions»
			«c.javaContractDefinition»
			«ENDFOR»
			
			«FOR p : processDefinitions»
			«p.getJavaClass»
			«ENDFOR»
			
			public static void main(String[] args) {
				
			}
		}
		'''
	}
	
	def String getJavaContractDefinition(ContractDefinition c) {
		c.contract = c.contract?: Co2Factory.eINSTANCE.createEmptyContract
		'''private Contract «c.name» = «c.contract.javaContract»;'''
	}
	
	def dispatch String getJavaContract(Contract c) {
		c.next = c.next?: Co2Factory.eINSTANCE.createEmptyContract
		c.next.javaContract
	}
	
	def dispatch String getJavaContract(IntSum c) {
		'''internalSum()«FOR a : c.actions»«a.getJavaIntAction»«ENDFOR»'''
	}
	
	def dispatch String getJavaContract(ExtSum c) {
		'''externalSum()«FOR a : c.actions»«a.getJavaExtAction»«ENDFOR»'''
	}
	
	def dispatch String getJavaContract(ContractReference c) {
		c.ref.name
	}
	
	def dispatch String getJavaContract(EmptyContract c) {
		'''null'''
	}
	
	def String getJavaIntAction(IntAction a) {
		a.next = a.next?: Co2Factory.eINSTANCE.createEmptyContract
		'''.add("«a.actionName»", «a.type.javaActionSort», «a.next.javaContract»)'''
	}
	
	def String getJavaExtAction(ExtAction a) {
		a.next = a.next?: Co2Factory.eINSTANCE.createEmptyContract
		'''.add("«a.actionName»", «a.type.javaActionSort», «a.next.javaContract»)'''
	}
	
	def String getJavaActionSort(ActionType type) {
		if (type==null || type instanceof UnitActionType) "Sort.UNIT"
		else if (type instanceof IntActionType) "Sort.INT"
		else if (type instanceof StringActionType) "Sort.STRING"
	}
	
	def String getJavaClass(ProcessDefinition p) {
		var className = p.name
		var hasFreeName = !p.params.empty
		'''
		private static class «className» extends «IF hasFreeName»CO2Process«ELSE»Participant«ENDIF» {
			private static final long serialVersionUID = 1L;
			«IF !hasFreeName»
			private static String username = "test@co2-plugin.com";
			private static String password = "test";
			«ENDIF»
			«p.getFieldsAndConstructor»
			
			@Override
			public void run() {
				
			}
		}
		'''
	}
	
	
	def String getFieldsAndConstructor(ProcessDefinition p) {
		
		'''
		«FOR fn : p.params»
		private «fn.javaType» «fn.name»;
		«ENDFOR»
		
		public «p.name»(«p.params.join(",", [fn | fn.javaType+" "+fn.name])») {
			«IF p.params.empty»
			super(username, password);
			«ELSE»
			super("«p.name»");
			«ENDIF»
			«FOR fn : p.params»
			this.«fn.name»=«fn.name»;
			«ENDFOR»
		}
		'''
	}
	
	def String getJavaType(FreeName fn) {
		if (fn.type instanceof IntType) "int"
		else if (fn.type instanceof StringType) "String"
		else if (fn.type instanceof BooleanType) "boolean"
		else if (fn.type instanceof SessionType) "Session2<TST>"
	}
	
}