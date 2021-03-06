package it.unica.co2.diogenes.generator

import com.google.inject.Inject
import it.unica.co2.diogenes.diogenes.ActionType
import it.unica.co2.diogenes.diogenes.AndExpression
import it.unica.co2.diogenes.diogenes.ArithmeticSigned
import it.unica.co2.diogenes.diogenes.BoolPlaceholder
import it.unica.co2.diogenes.diogenes.BooleanLiteral
import it.unica.co2.diogenes.diogenes.BooleanNegation
import it.unica.co2.diogenes.diogenes.BooleanType
import it.unica.co2.diogenes.diogenes.CO2System
import it.unica.co2.diogenes.diogenes.Comparison
import it.unica.co2.diogenes.diogenes.ContractDefinition
import it.unica.co2.diogenes.diogenes.ContractReference
import it.unica.co2.diogenes.diogenes.DelimitedProcess
import it.unica.co2.diogenes.diogenes.DiogenesFactory
import it.unica.co2.diogenes.diogenes.EmptyContract
import it.unica.co2.diogenes.diogenes.EmptyProcess
import it.unica.co2.diogenes.diogenes.Equals
import it.unica.co2.diogenes.diogenes.Expression
import it.unica.co2.diogenes.diogenes.ExtAction
import it.unica.co2.diogenes.diogenes.ExtSum
import it.unica.co2.diogenes.diogenes.IfThenElse
import it.unica.co2.diogenes.diogenes.Input
import it.unica.co2.diogenes.diogenes.IntAction
import it.unica.co2.diogenes.diogenes.IntActionType
import it.unica.co2.diogenes.diogenes.IntPlaceholder
import it.unica.co2.diogenes.diogenes.IntSum
import it.unica.co2.diogenes.diogenes.IntType
import it.unica.co2.diogenes.diogenes.Minus
import it.unica.co2.diogenes.diogenes.MultiOrDiv
import it.unica.co2.diogenes.diogenes.NumberLiteral
import it.unica.co2.diogenes.diogenes.OrExpression
import it.unica.co2.diogenes.diogenes.ParallelProcesses
import it.unica.co2.diogenes.diogenes.Placeholder
import it.unica.co2.diogenes.diogenes.Plus
import it.unica.co2.diogenes.diogenes.ProcessCall
import it.unica.co2.diogenes.diogenes.ProcessDefinition
import it.unica.co2.diogenes.diogenes.Receive
import it.unica.co2.diogenes.diogenes.RetractedProcess
import it.unica.co2.diogenes.diogenes.Send
import it.unica.co2.diogenes.diogenes.SessionType
import it.unica.co2.diogenes.diogenes.StringActionType
import it.unica.co2.diogenes.diogenes.StringLiteral
import it.unica.co2.diogenes.diogenes.StringPlaceholder
import it.unica.co2.diogenes.diogenes.StringType
import it.unica.co2.diogenes.diogenes.SwitchCase
import it.unica.co2.diogenes.diogenes.Tell
import it.unica.co2.diogenes.diogenes.TellAndReturn
import it.unica.co2.diogenes.diogenes.TellAndWait
import it.unica.co2.diogenes.diogenes.TimeoutProcess
import it.unica.co2.diogenes.diogenes.UnitActionType
import it.unica.co2.diogenes.diogenes.Variable
import it.unica.co2.diogenes.diogenes.VariableReference
import it.unica.co2.diogenes.xsemantics.DiogenesTypeSystem
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

import static extension it.unica.co2.diogenes.generator.JavaGeneratorUtils.*

class JavaGenerator extends AbstractIGenerator {

    @Inject extension IQualifiedNameProvider qNameProvider
    @Inject DiogenesTypeSystem typeSystem

    String packageName
    String mainClass = "Main"
    String resourceName
    boolean allInOneClass;

    override doGenerate(Resource resource, IFileSystemAccess fsa) {

        clearFreeNames()

        CONTRACT_NAME_COUNT = 0

        resourceName = resource.URI.lastSegment.replace(".co2","")
        resourceName = resourceName.replaceAll("[^A-Za-z]","")

        val l = resource.allContents.toIterable.filter(CO2System).get(0)

        allInOneClass = l.^package !== null && l.^package.single

        if (allInOneClass) {
            for (e : resource.allContents.toIterable.filter(CO2System)) {

                var basepath = if (e.^package === null) resourceName else e.^package.fullyQualifiedName.append(resourceName).toString(File.separator) ;
                var outputFilename = basepath+ File.separator+ mainClass+".java"

                println('''generating «outputFilename»''')
                fsa.generateFile(outputFilename, e.generateJava)
            }
        }
        else {

            for (s : resource.allContents.toIterable.filter(CO2System)) {
                var basepath = if (s.package === null) resourceName else s.package.fullyQualifiedName.append(resourceName).toString(File.separator) ;
                var outputFilename = basepath+ File.separator+ mainClass+".java"

                println('''generating main class: «outputFilename»''')
                fsa.generateFile(outputFilename, s.generateJava)

                val isTranslatable = s.isJavaTranslatable;

                if (isTranslatable.value) {

                    for (e : s.eAllContents.toIterable.filter(ProcessDefinition)) {

                        basepath = if (s.package === null) resourceName else s.package.fullyQualifiedName.append(resourceName).toString(File.separator) ;
                        outputFilename = basepath+ File.separator+ e.name+".java"

                        println('''generating process class: «outputFilename»''')
                        fsa.generateFile(outputFilename, e.javaClass)
                    }
                }
            }
        }
    }



    def String generateJava(CO2System co2System) {
        packageName = if (co2System.package === null) resourceName else co2System.package.fullyQualifiedName.append(resourceName).toString;
        var processDefinitions = co2System.contractsAndProcessesDeclaration.processes
        var contractDefinitions = co2System.contractsAndProcessesDeclaration.contracts
        var honestyProcesses = if (co2System.honesty !== null) co2System.honesty.processes else null

        //fix recursion name
//        contractDefinitions.fixRecursions()

        //fix anonymous tells
        contractDefinitions.addAll( co2System.eAllContents.filter(Tell).map[t| t.fixTell("TellContr")].toSet )
        contractDefinitions.addAll( co2System.eAllContents.filter(TellAndWait).map[t| t.fixTell("TellContr")].toSet )
        contractDefinitions.addAll( co2System.eAllContents.filter(TellAndReturn).map[t| t.fixTell("TellContr")].toSet )

        var placeholders = co2System.eAllContents.filter(Placeholder).toSet;
//        for (p:placeholders.toSet) {
//            println("-> "+p.type)
//        }
        var hasIntPlaceholders =         placeholders.filter[p| (p.type instanceof IntType) || (p instanceof IntPlaceholder)].toSet.size>0;
        var hasBooleanPlaceholders =     placeholders.filter[p| (p.type instanceof BooleanType) || (p instanceof BoolPlaceholder)].toSet.size>0;
        var hasStringPlaceholders =     placeholders.filter[p| (p.type instanceof StringType) || (p instanceof StringPlaceholder)].toSet.size>0;
        var hasSessionPlaceholders =     placeholders.filter[p| (p.type instanceof SessionType)].toSet.size>0;

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

                «getImports()»

                /*
                 * auto-generated by co2-plugin
                 * creation date: «new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date())»
                 */
                @SuppressWarnings("unused")
                public class «mainClass» {

                    private static final String username = "eclipse@co2.unica.it";
                    private static final String password = "eclipse";

                    «IF hasIntPlaceholders»static final Integer intPlaceholder = 42;«ENDIF»
                    «IF hasStringPlaceholders»static final String stringPlaceholder = "42";«ENDIF»
                    «IF hasBooleanPlaceholders»static final Boolean booleanPlaceholder = false;«ENDIF»
                    «IF hasSessionPlaceholders»static final SessionI<SessionType> sessionPlaceholder = null;«ENDIF»
                    «IF hasIntPlaceholders||hasStringPlaceholders||hasBooleanPlaceholders||hasSessionPlaceholders»

                    «ENDIF»
                    «contractDefinitions.getJavaContractDeclarations»
                    «contractDefinitions.getJavaContractDefinitions»

                    «IF allInOneClass»
                        «FOR p : processDefinitions»
                            «p.getJavaClass»
                        «ENDFOR»
                    «ENDIF»

                    public static void main(String[] args) {
                        «IF honestyProcesses !== null»
                            «FOR honestyProcess : honestyProcesses»
                                HonestyChecker.isHonest(«honestyProcess.name».class, «mainClass».username, «mainClass».password);
                            «ENDFOR»
                            «FOR honestyProcess : honestyProcesses»
                                //new Thread(new «honestyProcess.name»(«mainClass».username, «mainClass».password)).start();
                            «ENDFOR»
                        «ENDIF»
                    }
                }
            «ENDIF»
        '''
    }

    def String getImports() {
        '''
            import static it.unica.co2.api.contract.utils.ContractFactory.*;
            import it.unica.co2.api.contract.ContractDefinition;
            import it.unica.co2.api.contract.Recursion;
            import it.unica.co2.api.contract.SessionType;
            import it.unica.co2.api.contract.Sort;
            import it.unica.co2.api.process.CO2Process;
            import it.unica.co2.api.process.Participant;
            import it.unica.co2.honesty.HonestyChecker;
            import co2api.ContractException;
            import co2api.ContractExpiredException;
            import co2api.Message;
            import co2api.Public;
            import co2api.Session;
            import co2api.SessionI;
            import co2api.TimeExpiredException;
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
        '''static final ContractDefinition «c.name» = def("«c.name»");'''
    }

    def String getJavaContractDefinition(ContractDefinition c) {
        c.contract = c.contract?: DiogenesFactory.eINSTANCE.createEmptyContract
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
        '''.add("«a.name»", «a.type.javaActionSort»«IF a.next !== null», «a.next.javaContract»«ENDIF»)'''
    }

    def String getJavaExtAction(ExtAction a) {
        '''.add("«a.name»", «a.type.javaActionSort»«IF a.next !== null», «a.next.javaContract»«ENDIF»)'''
    }

    def String getJavaActionSort(ActionType type) {
        if (type === null || type instanceof UnitActionType) "Sort.unit()"
        else if (type instanceof IntActionType) "Sort.integer()"
        else if (type instanceof StringActionType) "Sort.string()"
    }

    def String getJavaClass(ProcessDefinition p) {
        var className = p.name
        '''
            «IF !allInOneClass && !packageName.isEmpty»
                package «packageName»;

                «getImports()»
            «ENDIF»

            «IF !allInOneClass»@SuppressWarnings("unused")«ENDIF»
            public «IF allInOneClass»static«ENDIF» class «className» extends Participant {

                private static final long serialVersionUID = 1L;
                «p.getFieldsAndConstructor»

                «p.runBody»
            }
        '''
    }

    def String getJavaType(Variable fn) {
        if (fn.type instanceof IntType)            "Integer"
        else if (fn.type instanceof StringType)    "String"
        else if(fn.type instanceof BooleanType) "Boolean"
        else if(fn.type instanceof SessionType) "SessionI<SessionType>"
    }

    def String getFieldsAndConstructor(ProcessDefinition p) {
        '''
            «FOR fn : p.params»
                private «fn.javaType» «fn.name»;
            «ENDFOR»

            public «p.name»(String username, String password«p.params.join(", ", ", ", "", [fn | fn.javaType+" "+fn.name])») {
                super(username, password);
                «FOR fn : p.params»
                    this.«fn.name»=«fn.name»;
                «ENDFOR»
            }
        '''
    }


    def String getRunBody(ProcessDefinition p) {
        clearFreeNames        // freenames can be reset

        '''
        @Override
        public void run() {
            «IF p.process !== null»«p.process.toJava»«ENDIF»
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


    def dispatch String toJava(TellAndReturn tell) {
        var freshName = getFreshName(tell.session.name)        // get a fresh name
        tell.session.name = freshName                        // update the name all its references

        '''
        Public<SessionType> «tell.session.name» = tell(«mainClass».«tell.session.contractReference.name»);

        «tell.process.toJava»'''
    }

    def dispatch String toJava(TellAndWait tell) {
        var freshName = getFreshName(tell.session.name)        // get a fresh name
        tell.session.name = freshName                        // update the name all its references
        val publicName = '''pbl_«tell.session.name»'''

        '''
            «IF tell.isTimeout»
                Public<SessionType> «publicName» = tell(«mainClass».«tell.session.contractReference.name», «tell.timeoutValue.value.javaExpression»*1000); «IF tell.timeoutValue instanceof Placeholder»//TODO: remove the placeholder/s«ENDIF»

                try {
                    Session<SessionType> «tell.session.name» = «publicName».waitForSession();

                    «tell.process.toJava»
                }
                catch(ContractExpiredException «getFreshName("e")») {
                    //retract «tell.session.name»
                    «IF tell.timeoutValue.TProcess !== null»
                        «tell.timeoutValue.TProcess.toJava»
                    «ENDIF»
                }
            «ELSE»
                Session<SessionType> «tell.session.name» = tellAndWait(«mainClass».«tell.session.contractReference.name»);

                «IF tell.process !== null»
                    «tell.process.toJava»
                «ENDIF»
            «ENDIF»
        '''
    }

    def dispatch String toJava(TimeoutProcess p) {
        p.TProcess.toJava
    }

    def dispatch String toJava(RetractedProcess p) {
        p.process.toJava
    }

    def dispatch String toJava(Receive receive) {

        var sessions = receive.inputs.map[i|i.session.name].toSet

        if (sessions.size<=1) {
            '''
                «IF receive.isTimeout»
                    try {
                        «receive.inputs.singleSessionReceive(true, receive.timeoutValue.value)»
                    }
                    catch (TimeExpiredException «getFreshName("e")») {
                        «receive.timeoutValue.TProcess.toJava»
                    }

                «ELSE»
                    «receive.inputs.singleSessionReceive(false, null)»
                «ENDIF»
            '''
        }
        else {

            '''
                «IF receive.isTimeout»
                    try {
                        «receive.multipleSessionReceive(true)»
                    }
                    catch (TimeExpiredException «getFreshName("e")») {
                        «receive.timeoutValue.TProcess.toJava»
                    }

                «ELSE»
                    «receive.multipleSessionReceive(false)»
                «ENDIF»
            '''
        }
    }

    def String multipleSessionReceive(Receive receive, boolean timeout) {
        var messageName = getFreshName("msg")

        '''
            multipleSessionReceiver()
                «FOR input : receive.inputs»
                    .add(
                        «input.session.name»,
                        («messageName») -> {
                            «input.getJavaInput(messageName)»
                        },
                        «input.actions.join(", ", [a|'''"«a.name»"'''])»
                    )
                «ENDFOR»
                .waitForReceive(«IF timeout»«receive.timeoutValue.value.javaExpression»*1000«ENDIF») «IF receive.timeoutValue instanceof Placeholder»//TODO: remove the placeholder/s«ENDIF»
            ;
        '''
    }

    def String singleSessionReceive(EList<Input> inputs, boolean timeout, Expression timeoutValue) {

        val session = inputs.get(0).session.name;    // inputs are at least 1 and on the same session
        val allActions = inputs.map[x|x.actions].flatten.map[x|x.name].toSet

        var messageName = getFreshName("msg")

        '''
            logger.info("waiting on '«session»' for actions [«allActions.join(", ")»]");
            Message «messageName» = «session».waitForReceive(«IF timeout»«timeoutValue.javaExpression»*1000, «ENDIF»«allActions.join(", ", [x|'''"«x»"'''])»); «IF timeoutValue instanceof Placeholder»//TODO: remove the placeholder/s«ENDIF»

            «IF allActions.size==1»
                logger.info("received [«allActions.get(0)»]");
                «getJavaInput(inputs.get(0), messageName)»
            «ELSE»
                switch («messageName».getLabel()) {
                    «FOR input : inputs»
                        «FOR a : input.actions»
                            case "«a.name»":
                        «ENDFOR»
                        logger.info("received ["+«messageName».getLabel()+"]");
                        «input.getJavaInput(messageName)»
                        break;
                    «ENDFOR»
                }
            «ENDIF»
        '''
    }

    /**
     * Change variable name in order to be unique on sums, i.e. <code>do a? n:int + do b? n:int</code>.
     * All references will be updated.
     */
    def void fixVariableName(Input input) {
        if (input.variable !== null)
            input.variable.name = getFreshName(input.variable.name)
    }

    def String getJavaInput(Input input, String messageName) {

        // change variable name in order to be unique, i.e. like  do a? n:int + do b? n:int
        input.fixVariableName

        '''
            «IF input.variable !== null»
                «input.variable.javaType» «input.variable.name»;
                «IF input.variable.type instanceof IntType»
                    «var exFreeName = getFreshName("e")»
                    try {
                        «input.variable.name» = Integer.parseInt(«messageName».getStringValue());
                    }
                    catch (NumberFormatException «exFreeName») {
                        throw new RuntimeException(«exFreeName»);
                    }
                «ELSE»
                    «input.variable.name» = «messageName».getStringValue();
                «ENDIF»
            «ENDIF»
            «IF input.next !== null»«input.next.toJava»«ENDIF»
        '''
    }


    def dispatch String toJava(IfThenElse p) {
        '''
            if («p.^if.javaExpression») { «IF p.^if instanceof Placeholder»//TODO: remove the placeholder/s«ENDIF»
                «p.^then.toJava»
            }
            else {
                «IF p.^else !== null»«p.^else.toJava»«ENDIF»
            }
        '''
    }

    def dispatch String toJava(ProcessCall p) {
        '''
            processCall(«p.reference.name».class, username, password«p.params.join(" ,", ", ", "", [x | x.javaExpression])»); «IF p.params.exists[x|x instanceof Placeholder]»//TODO: remove the placeholder/s«ENDIF»
        '''
    }

    def dispatch String toJava(Send p) {
        '''
            logger.info("sending action '«p.action.name»'");
            «p.session.name».sendIfAllowed("«p.action.name»"«IF p.value !== null», «p.value.javaExpression»«ENDIF»); «IF p.value instanceof Placeholder»//TODO: remove the placeholder/s«ENDIF»
            «IF p.next !== null»

                «p.next.toJava»
            «ENDIF»
        '''
    }

    def dispatch String toJava(SwitchCase p) {
        '''
            switch («p.exp.getJavaExpression») { «IF p.exp instanceof Placeholder»//TODO: remove the placeholder/s«ENDIF»
                «FOR c : p.cases»
                    case «c.match.getJavaExpression»:
                        «c.caseProc.toJava»
                        break;

                «ENDFOR»
                «IF p.^default»
                    default:
                        «p.defaultProc.toJava»
                «ENDIF»
            }
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

    def dispatch String getJavaExpression(Placeholder p) {
        var type = typeSystem.type(p).value
        if (type instanceof IntType)         '''«mainClass».intPlaceholder'''
        else if (type instanceof StringType) '''«mainClass».stringPlaceholder'''
        else if(type instanceof BooleanType) '''«mainClass».booleanPlaceholder'''
        else if(type instanceof SessionType) '''«mainClass».sessionPlaceholder'''
    }

}
