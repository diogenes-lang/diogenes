/*
 * generated by Xtext
 */
package it.unica.co2.ui.outline

import it.unica.co2.contracts.AbstractNextContract
import it.unica.co2.contracts.ContractDefinition
import it.unica.co2.contracts.ContractGrammar
import it.unica.co2.contracts.ExtSum
import it.unica.co2.contracts.IntSum
import org.eclipse.xtext.ui.editor.outline.IOutlineNode
import org.eclipse.xtext.ui.editor.outline.impl.DefaultOutlineTreeProvider
import org.eclipse.xtext.ui.editor.outline.impl.DocumentRootNode

/**
 * Customization of the default outline structure.
 *
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#outline
 */
class ContractsOutlineTreeProvider extends DefaultOutlineTreeProvider {
	
	def void _createChildren(DocumentRootNode parentNode, ContractGrammar grammar) {
        for(ContractDefinition element: grammar.contracts) {
            createNode(parentNode, element);
        }
    }
    
    //cut off <unamed> due to "." token
    def void _createNode(IOutlineNode parentNode, AbstractNextContract next) {
    	if (next.nextContract!=null)
			createNode(parentNode, next.nextContract)		//cut
		else
			createChildren(createEObjectNode(parentNode,next), next)	//normal behavior
    }
    
    //don't create type node
//    def void _createChildren(IOutlineNode parentNode, Type type) {
//    }
    
    //cut off (+) if the sum is single element
    def void _createNode(IOutlineNode parentNode, IntSum sum) {
    	if (sum.actions.length==1)
			createNode(parentNode, sum.actions.get(0))		//cut
		else
			createChildren(createEObjectNode(parentNode,sum), sum)	//normal behavior
    }
    
    //cut off + if the sum is single element
    def void _createNode(IOutlineNode parentNode, ExtSum sum) {
    	if (sum.actions.length==1)
			createNode(parentNode, sum.actions.get(0))		//cut
		else
			createChildren(createEObjectNode(parentNode,sum), sum)	//normal behavior
    }
}
