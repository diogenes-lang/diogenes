/*
 * generated by Xtext
 */
package it.unica.co2.ui.outline

import it.unica.co2.co2.CO2System
import it.unica.co2.co2.DelimitedProcess
import it.unica.co2.co2.ParallelProcesses
import it.unica.co2.co2.ProcessCall
import it.unica.co2.co2.ProcessDefinition
import it.unica.co2.co2.Sum
import it.unica.co2.contracts.ContractDefinition
import org.eclipse.xtext.ui.editor.outline.IOutlineNode
import org.eclipse.xtext.ui.editor.outline.impl.DocumentRootNode

/**
 * Customization of the default outline structure.
 *
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#outline
 */
class CO2OutlineTreeProvider extends ContractsOutlineTreeProvider {
	
	
	def void _createChildren(DocumentRootNode parentNode, CO2System grammar) {
        for(ContractDefinition element: grammar.contracts) {
            createNode(parentNode, element);
        }
        
        for(ProcessDefinition element: grammar.processes) {
            createNode(parentNode, element);
        }
    }
    
    //cut off <unamed> due to "." token
//    def void _createNode(IOutlineNode parentNode, AbstractNextProcess next) {
//    	if (next.nextProcess!=null)
//			createNode(parentNode, next.nextProcess)		//cut
//		else
//			createNode(parentNode, next.processReference)
//			//createChildren(createEObjectNode(parentNode,next), next)	//normal behavior
//    }
    
	//cut off + if the sum is single element
    def void _createNode(IOutlineNode parentNode, Sum sum) {
    	if (sum.prefixes.length==1)
			createNode(parentNode, sum.prefixes.get(0))		//cut
		else
			createChildren(createEObjectNode(parentNode,sum), sum)	//normal behavior
    }
    
    //cut off | if the sum is single element
    def void _createNode(IOutlineNode parentNode, ParallelProcesses paral) {
    	if (paral.processes.length==1)
			createNode(parentNode, paral.processes.get(0))		//cut
		else
			createChildren(createEObjectNode(parentNode,paral), paral)	//normal behavior
    }
    
    //cut off free names if no one is defined
    def void _createNode(IOutlineNode parentNode, DelimitedProcess process) {
    	if (process.freeNames.length==0)
			createNode(parentNode, process.process)		//cut
		else
			createChildren(createEObjectNode(parentNode,process), process)	//normal behavior
    }
    
    //
    def void _createNode(IOutlineNode parentNode, ProcessCall process) {
		createNode(parentNode, process.reference)		//cut
    }
//    def void _createNode(IOutlineNode parentNode, ProcessReference process) {
//		createChildren(createEObjectNode(parentNode,process), process)
//    }
}
