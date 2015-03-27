/*
 * generated by Xtext
 */
package it.unica.co2.scoping

import com.google.common.base.Predicate
import it.unica.co2.contracts.ContractDefinition
import it.unica.co2.contracts.ExtAction
import it.unica.co2.contracts.IntAction
import it.unica.co2.contracts.Recursion
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.eclipse.xtext.scoping.impl.FilteringScope

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 * 
 */
class ContractsScopeProvider extends AbstractDeclarativeScopeProvider {

	/*
	 * Recursion reference: 
	 * refers only to recursions defined before ctx but into the same contract definition
	 */
	def IScope scope_IntAction_recursionReference(IntAction ctx, EReference ref) {
		return symbolsDefinedRecursions(ctx.eContainer);
	}

	def IScope scope_ExtAction_recursionReference(ExtAction ctx, EReference ref) {
		return symbolsDefinedRecursions(ctx.eContainer);
	}

	def dispatch IScope symbolsDefinedRecursions(EObject cont) {
		return symbolsDefinedRecursions(cont.eContainer);
	}

	def dispatch IScope symbolsDefinedRecursions(Recursion rec) {
		return Scopes.scopeFor(
			newArrayList(rec),
			symbolsDefinedRecursions(rec.eContainer) // outer
		);
	}

	def dispatch IScope symbolsDefinedRecursions(ContractDefinition obj) {
		return IScope.NULLSCOPE; // stop recursion
	}



	/*
	 * Contract reference:
	 * refers to any contract definition except for this
	 */
	def IScope scope_IntAction_contractReference(IntAction ctx, EReference ref) {
		var scope = getIScopeForAllContractDefinition(ctx);
		var contractDef = getContractDefinition(ctx)

		if (contractDef.name != null)
			getFilteredScope(scope, contractDef)
		else
			scope
	}

	def IScope scope_ExtAction_contractReference(ExtAction ctx, EReference ref) {
		var scope = getIScopeForAllContractDefinition(ctx);
		var contractDef = getContractDefinition(ctx)

		if (contractDef.name != null)
			getFilteredScope(scope, contractDef)
		else
			scope
	}

	def IScope getFilteredScope(IScope scope, ContractDefinition contractDef) {
		new FilteringScope(scope, new Predicate<IEObjectDescription>() {

			override apply(IEObjectDescription input) {
				return input.getEObjectOrProxy() != contractDef;
			}

		});
	}
	
	def IScope getIScopeForAllContractDefinition(EObject ctx){
		var root = EcoreUtil2.getRootContainer(ctx);
		var candidates = EcoreUtil2.getAllContentsOfType(root, ContractDefinition);
		return Scopes.scopeFor(candidates);
	}

	def dispatch ContractDefinition getContractDefinition(EObject obj) {
		return getContractDefinition(obj.eContainer);
	}

	def dispatch ContractDefinition getContractDefinition(ContractDefinition obj) {
		return obj;
	}
}
