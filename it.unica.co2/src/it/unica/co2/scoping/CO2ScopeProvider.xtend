/*
 * generated by Xtext
 */
package it.unica.co2.scoping

import it.unica.co2.co2.ContractDefinition
import it.unica.co2.co2.DelimitedProcess
import it.unica.co2.co2.DoInput
import it.unica.co2.co2.ExtAction
import it.unica.co2.co2.Input
import it.unica.co2.co2.IntAction
import it.unica.co2.co2.ProcessDefinition
import it.unica.co2.co2.TellAndWait
import it.unica.co2.co2.TellProcess
import it.unica.co2.co2.TellRetract
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider

import static extension it.unica.co2.utils.CustomExtensions.*

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 *
 */
class CO2ScopeProvider extends AbstractDeclarativeScopeProvider {
	
	/*
	 * FreeName reference
	 * 
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	def IScope scope_Referrable(EObject ctx, EReference ref) {
		return getDeclaredVariables(ctx.eContainer);
	}

	//utils: recursively get all free-names declarations until ProcessDefinition
	def dispatch IScope getDeclaredVariables(EObject cont) {
		return getDeclaredVariables(cont.eContainer);
	}
	
	def dispatch IScope getDeclaredVariables(DelimitedProcess proc) {
		return Scopes.scopeFor(
			proc.freeNames
			,
			getDeclaredVariables(proc.eContainer) // outer
		);
	}
	
	def dispatch IScope getDeclaredVariables(DoInput proc) {
		if (proc.variable==null)
			return getDeclaredVariables(proc.eContainer)
		else
			return Scopes.scopeFor(
				newArrayList(proc.variable)
				,
				getDeclaredVariables(proc.eContainer) // outer
			);
	}
	
	def dispatch IScope getDeclaredVariables(Input proc) {
		if (proc.variable==null)
			return getDeclaredVariables(proc.eContainer)
		else
			return Scopes.scopeFor(
				newArrayList(proc.variable)
				,
				getDeclaredVariables(proc.eContainer) // outer
			);
	}
	
	def dispatch IScope getDeclaredVariables(TellRetract proc) {
		return Scopes.scopeFor(
			newArrayList(proc.session)
			,
			getDeclaredVariables(proc.eContainer) // outer
		);
	}
	
	def dispatch IScope getDeclaredVariables(TellProcess proc) {
		return Scopes.scopeFor(
			newArrayList(proc.session)
			,
			getDeclaredVariables(proc.eContainer) // outer
		);
	}

	def dispatch IScope getDeclaredVariables(TellAndWait proc) {
		return Scopes.scopeFor(
			newArrayList(proc.session)
			,
			getDeclaredVariables(proc.eContainer) // outer
		);
	}

	def dispatch IScope getDeclaredVariables(ProcessDefinition obj) {
		return Scopes.scopeFor(obj.params); // stop recursion
	}
	
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	
	
	/*
	 * Contract reference: refers to any contract
	 * 
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	def IScope scope_ContractDefinition(EObject ctx, EReference ref) {
		ctx.getIScopeForAllContentsOfClass(ContractDefinition);
	}
	
	/*
	 * Process reference: refers to any process
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	def IScope scope_ProcessDefinition(EObject ctx, EReference ref) {
		ctx.getIScopeForAllContentsOfClass(ProcessDefinition);
	}

	/*
	 * Action references: resolve the references into advertised contracts
	 * 
	 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	def IScope scope_IntAction(EObject ctx, EReference ref) {
		ctx.getIScopeForAllContentsOfClass(IntAction);
	}
	
	def IScope scope_ExtAction(EObject ctx, EReference ref) {
		ctx.getIScopeForAllContentsOfClass(ExtAction);
	}

}
