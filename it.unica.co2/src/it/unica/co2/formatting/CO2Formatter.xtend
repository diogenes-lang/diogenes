/*
 * generated by Xtext
 */
package it.unica.co2.formatting

import com.google.inject.Inject
import it.unica.co2.services.CO2GrammarAccess
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter
import org.eclipse.xtext.formatting.impl.FormattingConfig
import org.eclipse.xtext.util.Pair;
/**
 * This class contains custom formatting declarations.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#formatting
 * on how and when to use it.
 * 
 * Also see {@link org.eclipse.xtext.xtext.XtextFormattingTokenSerializer} as an example
 */
class CO2Formatter extends AbstractDeclarativeFormatter {

	@Inject extension CO2GrammarAccess
	
	override protected void configureFormatting(FormattingConfig c) {
		// It's usually a good idea to activate the following three statements.
		// They will add and preserve newlines around comments
//		c.setLinewrap(0, 1, 2).before(SL_COMMENTRule)
//		c.setLinewrap(0, 1, 2).before(ML_COMMENTRule)
//		c.setLinewrap(0, 1, 1).after(ML_COMMENTRule)
		
		// set a maximum size of lines
//        c.setAutoLinewrap(160);
		
//		// set no space before all commas
//        for(Keyword comma : findKeywords(",")) {
//            c.setNoSpace().before(comma);
//        }
//        
//        // set no space around all parentheses
//        for(Pair<Keyword, Keyword> p : findKeywordPairs("(", ")")) {
//            c.setNoSpace().around(p.getFirst());
//            c.setNoSpace().around(p.getSecond());
//        }
//        

		findKeywords("{").forEach[k | c.setSpace(" ").before(k);]
		findKeywords(",").forEach[k | c.setNoSpace().before(k);]	// set no space before all commas
		findKeywords("!").forEach[k | c.setNoSpace().before(k);]	// set no space before all !
		findKeywords("?").forEach[k | c.setNoSpace().before(k);]	// set no space before all ?
		findKeywordPairs("[","]").forEach[p | 						// set no space within []
			c.setNoSpace().around(p.first);
        	c.setNoSpace().before(p.second);
        ]
		
        // set no space before action types
        c.setNoSpace().before(actionTypeRule);
        
        // set no space for ! and ? into actions
        c.setNoSpace().between(intActionAccess.nameAssignment_0, intActionAccess.exclamationMarkKeyword_1);
        c.setNoSpace().between(extActionAccess.nameAssignment_0, extActionAccess.questionMarkKeyword_1);
        
        // set no space around :
        c.setNoSpace().around(variableAccess.colonKeyword_1);
        c.setNoSpace().around(placeholderAccess.colonKeyword_2);
                
        // process definitions
        c.setLinewrap(2).before(processDefinitionRule);
        c.setIndentation(processDefinitionAccess.getLeftCurlyBracketKeyword_4,processDefinitionAccess.rightCurlyBracketKeyword_6);
        c.setLinewrap().after(processDefinitionAccess.getLeftCurlyBracketKeyword_4);
        c.setLinewrap().before(processDefinitionAccess.rightCurlyBracketKeyword_6);
        
        // contract definitions
        c.setLinewrap(2).before(contractDefinitionRule);
        c.setIndentation(contractDefinitionAccess.leftCurlyBracketKeyword_3,contractDefinitionAccess.rightCurlyBracketKeyword_5);
        c.setLinewrap().after(contractDefinitionAccess.leftCurlyBracketKeyword_3);
        c.setLinewrap().before(contractDefinitionAccess.rightCurlyBracketKeyword_5);
        
        // switch-case
        c.setLinewrap().before(switchCaseRule);
        c.setIndentation(switchCaseAccess.leftCurlyBracketKeyword_2,switchCaseAccess.rightCurlyBracketKeyword_5);
        c.setLinewrap().after(switchCaseAccess.leftCurlyBracketKeyword_2);
        c.setLinewrap().before(switchCaseAccess.rightCurlyBracketKeyword_5);
        
        c.setLinewrap().after(caseRule);
        c.setIndentationIncrement().after(caseAccess.matchAssignment_1);
        c.setIndentationDecrement().after(caseRule);
        
    	c.setIndentationIncrement().after(switchCaseAccess.defaultAssignment_4_0);
    	c.setIndentationDecrement().after(switchCaseAccess.defaultProcAssignment_4_2);
        
        
        // receive
        c.setLinewrap().before(receiveRule);
        c.setIndentation(receiveAccess.leftCurlyBracketKeyword_1,receiveAccess.rightCurlyBracketKeyword_4);
        c.setLinewrap().after(receiveAccess.leftCurlyBracketKeyword_1);
        c.setLinewrap().before(receiveAccess.rightCurlyBracketKeyword_4);
        c.setLinewrap().around(receiveAccess.inputsAssignment_2);
        
        // tell retract
        c.setLinewrap().before(tellRetractRule);
        c.setLinewrap().after(tellRetractAccess.fullStopKeyword_2_0);
        c.setLinewrap().after(tellRetractAccess.processAssignment_2_1);
        c.setIndentation(tellRetractAccess.fullStopKeyword_2_0,retractedProcessAccess.colonKeyword_0);
        c.setLinewrap().before(retractedProcessAccess.colonKeyword_0);
        c.setSpace(" ").after(retractedProcessAccess.colonKeyword_0);
        
        // if then else
        c.setLinewrap().before(ifThenElseRule);
        c.setLinewrap().before(ifThenElseAccess.thenKeyword_3);		// then in a newline
        c.setLinewrap().before(ifThenElseAccess.elseKeyword_5_0);	// else in a new line
//        c.setLinewrap().after(ifThenElseAccess.thenKeyword_3);
//        c.setLinewrap().after(ifThenElseAccess.elseKeyword_5_0);
//        c.setIndentationIncrement().after(ifThenElseAccess.thenKeyword_3);
//        c.setIndentationIncrement().after(ifThenElseAccess.elseKeyword_5_0);
//        c.setIndentationDecrement().after(ifThenElseAccess.thenAssignment_4);
//		c.setIndentationDecrement().after(ifThenElseAccess.elseAssignment_5_1);

		// parallel
		c.setLinewrap().after(parallelProcessesAccess.verticalLineKeyword_1_0);
		
		// parenthesis
		c.setLinewrap().after(nextAccess.leftParenthesisKeyword_10_0);
		c.setLinewrap().before(nextAccess.rightParenthesisKeyword_10_2);
		c.setIndentation(nextAccess.leftParenthesisKeyword_10_0, nextAccess.rightParenthesisKeyword_10_2);
	
		// alternative send/receive
		c.setNoSpace().after(sendAltAccess.sendKeyword_0);
		c.setNoSpace().after(simpleReceiveAltAccess.receiveKeyword_0);
		findKeywords("@").forEach[k | c.setNoSpace().after(k);]	// set no space before all ?
	}
}
