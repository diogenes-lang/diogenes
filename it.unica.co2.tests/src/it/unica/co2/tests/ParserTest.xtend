package it.unica.co2.tests

import com.google.inject.Inject
import it.unica.co2.CO2InjectorProvider
import it.unica.co2.co2.CO2System
import it.unica.co2.co2.EmptyProcess
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@InjectWith(CO2InjectorProvider)
@RunWith(XtextRunner)
class ParserTest {
	
	@Inject extension ParseHelper<CO2System>
	@Inject extension ValidationTestHelper
	
	@Test
	def void emptyProcessesTest() {
		val co2System = "
			/*
			 * empty processes
			 */
			process {}
			process {0}
		".parse
		
		co2System.assertNoErrors
		
		assertEquals(0, co2System.contracts.size)
		assertEquals(2, co2System.processes.size)
		
		var procDef1 = co2System.processes.get(0)	// get process definition
		var procDef2 = co2System.processes.get(1)	// get process definition
		
		assertNull(procDef1.name)
		assertNull(procDef2.name)
		
		assertEquals(0, procDef1.freeNames.size)	// process definition have not freenames
		assertEquals(0, procDef2.freeNames.size)	// process definition have not freenames
		
		var p1 = procDef1.process		// get the process (ParallelProcess)
		assertNull(p1)					// no process is defined
		
		var p2 = procDef2.process											// get the process (ParallelProcess = List of Delimip1dProcess)
		assertEquals(1, p2.processes.size)									// is only one
		assertTrue(p2.processes.get(0).process instanceof EmptyProcess)		// is an empty process
		assertEquals(0, p2.processes.get(0).freeNames.size)					// and not have any freename
		
	}
	
	@Test
	def void simpleTauTest() {
		val co2System = "
			/*
			 * simple tau prefix
			 */
			process {
				t. 0
			}
		".parse
		
		co2System.assertNoErrors
	}
	
	@Test
	def void delimitedProcessTest() {
		val co2System = "
			/*
			 * delimited process
			 */
			process {
				(x) tell x {} . do x a!
			}
		".parse
		
		co2System.assertNoErrors
	}
	
	@Test
	def void parallelProcessTest() {
		val co2System = "
			/*
			 * parallel process
			 */
			process {
				(x) tell x {} . do x a!
			}
		".parse
		
		co2System.assertNoErrors
	}
	
	@Test
	def void tellTest() {
		val co2System = "
			/*
			 * tell process
			 */
			process (x) {
				tell x {} . do x a!
			}
		".parse
		
		co2System.assertNoErrors
	}
	
	@Test
	def void namedProcessTest() {
		val co2System = "
			/*
			 * named process
			 */
			process PROCESS (x) {
				tell x {} . do x a!. PROCESS(x)
			}
		".parse
		
		co2System.assertNoErrors
	}
	
	
	
	
}