/*
 * generated by Xtext
 */
package it.unica.co2.ui.labeling

import com.google.inject.Inject
import it.unica.co2.co2.Ask
import it.unica.co2.co2.ContractDefinition
import it.unica.co2.co2.ContractReference
import it.unica.co2.co2.DelimitedProcess
import it.unica.co2.co2.DoInput
import it.unica.co2.co2.DoOutput
import it.unica.co2.co2.Expression
import it.unica.co2.co2.ExtAction
import it.unica.co2.co2.ExtSum
import it.unica.co2.co2.IfThenElse
import it.unica.co2.co2.Input
import it.unica.co2.co2.IntAction
import it.unica.co2.co2.IntSum
import it.unica.co2.co2.ParallelProcesses
import it.unica.co2.co2.ProcessCall
import it.unica.co2.co2.ProcessDefinition
import it.unica.co2.co2.Receive
import it.unica.co2.co2.Referrable
import it.unica.co2.co2.Send
import it.unica.co2.co2.Session
import it.unica.co2.co2.Sum
import it.unica.co2.co2.SystemDeclaration
import it.unica.co2.co2.Tau
import it.unica.co2.co2.Tell
import it.unica.co2.co2.TellAndWait
import it.unica.co2.co2.TellRetract
import it.unica.co2.co2.Variable
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import it.unica.co2.co2.Retract

/**
 * Provides labels for EObjects.
 * 
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#label-provider
 */
class CO2LabelProvider extends DefaultEObjectLabelProvider {

	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}
	
	/*
	 * IMAGE
	 */
	def image(ProcessDefinition ele) {
		'process.png'
	}
	
	def image(ContractDefinition ele) {
		'contract.png'
	}

	def image(IntAction ele) {
		'output.png'
	}

	def image(ExtAction ele) {
		'input.png'
	}
	
	def image(DelimitedProcess ele) {
		'wave.png'
	}
		
	def image(ParallelProcesses ele) {
		'waves.png'
	}
		
	def image(Referrable ele) {
		'variable.png'
	}
	
	def image(IntSum ele) {
		'xor.png'
	}
	
	def image(ExtSum ele) {
		'plus.png'
	}
	
	
	/*
	 * TEXT
	 */
	def Object text(SystemDeclaration elm) {
		'''system «elm.name»'''
	}
	
	def text(IntSum ele) {
		""
	}

	def text(ExtSum ele) {
		""
	}
	
	def text(ContractReference elm) {
		elm.ref.name
	}
	 
	def String text(ProcessDefinition ele) {
		var name = ele.name?: '<anonymous>'
		if (ele.params.length!=0)
			'''«name» «ele.params.join("(", ", ", ")", [x| text(x)])»'''
		else
			name
	}

	def text(DelimitedProcess ele) {
		""
	}
	
	def text(Sum ele) {
		"+"
	}
	
	def text(ParallelProcesses ele) {
		""
	}
	
	def text(Tell ele) {
		if (ele.contractReference!=null)
			"tell " + ele.session.name + " [" + ele.contractReference.name + "]"
		else
			"tell " + ele.session.name
	}
	
	def text(TellRetract ele) {
		if (ele.contractReference!=null)
			"tellRetract " + ele.session.name + " [" + ele.contractReference.name + "]"
		else
			"tellRetract " + ele.session.name
	}
	
	def text(TellAndWait ele) {
		if (ele.contractReference!=null)
			"tellAndWait " + ele.session.name + " [" + ele.contractReference.name + "]"
		else
			"tellAndWait " + ele.session.name
	}
	
	def text(DoInput ele) {
		"do "+ ele.session.name + " " + ele.actionName + "?"
	}
	
	def text(Receive ele) {
		"receive "+ ele.session.name
	}
	
	def text(Input ele) {
		ele.actionName + "?"
	}
	
	def text(DoOutput ele) {
		"do "+ ele.session.name + " " + ele.actionName + "!"
	}
	
	def text(Send ele) {
		"send "+ ele.session.name + " " + ele.actionName + "!"
	}
	
	def text(Tau ele) {
		"\u03c4"
	}
	
	def text(Ask ele) {
		"ask "+ ele.session.name
	}
	
	def text(Retract ele) {
		"retract "+ ele.session.name
	}
	
	def text(IfThenElse ele) {
		"ifThenElse"
	}
		
	def String text(ProcessCall ele) {
		var name = ele.reference.name?: '<anonymous>'
		if (ele.params.length!=0)
			'''«name» «ele.params.join("(", ", ", ")", [x| text(x)])»'''
		else
			name
	}
	
	def String text(Expression e) {
		"exp"
	}

	
	def text(Variable elm) {
		elm.name+" : "+elm.type.value
	}
	
	def text(Session elm) {
		elm.name+" : session"
	}

	def text(IntAction ele) {
		if (ele.type != null)
			ele.actionName + "! : " + ele.type.value
		else
			ele.actionName + "! : unit"
	}

	def text(ExtAction ele) {
		if (ele.type != null)
			ele.actionName + "! : " + ele.type.value
		else
			ele.actionName + "! : unit"
	}

}