#Version#

2015-08-22: version **1.1.0** released!

2015-08-13: version **1.0.0** released!

2015-08-03: version **0.1.0** released!

2015-05-21: version **0.0.3** released!

2015-04-18: version **0.0.2** released!

2015-04-03: version **0.0.1** released!

#Changelog
**1.1.0**

* added support to parallel processes

**1.0.0**

* **syntax is changed** (see example below)
* added expressions
* added static type-check for expressions and freenames

**0.1.0**

* you can check the honesty of co2 maude process (right-click on the maude file)
* add preferences page for maude model-checking


#Installation#

##Plugin Users##
* go to `Help -> Install New Software...` from the menu bar and `Add...`
* add the update site for Xsemantics 1.8.x : [http://master.dl.sourceforge.net/project/xsemantics/updates/releases/1.8](http://master.dl.sourceforge.net/project/xsemantics/updates/releases/1.8) *(1)*
* add the update site for Xtext 2.8.x (only for Eclipse IDE older than the *mars* version 4.5.x ): [http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/](http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/) *(1)*
* add Co2 update site [http://co2.unica.it/eclipse-plugin/](http://co2.unica.it/eclipse-plugin/)
* install CO2 SDK Feature

##Plugin Developers##
I recommend you to install the last Eclipse IDE (*mars* 4.5.\* at the moment) for Java and DSL Developers (see [http://www.eclipse.org/downloads/packages/eclipse-ide-java-and-dsl-developers/marsr](http://www.eclipse.org/downloads/packages/eclipse-ide-java-and-dsl-developers/marsr)), that embed the Xtext module 2.8.\*, required by the plugin. 

You can install it on older Eclipse versions (see [https://eclipse.org/Xtext/download.html](https://eclipse.org/Xtext/download.html)). This approach is discouraged.

* import all projects `it.unica.co2*` and go to `Project -> Build All` *(2)*
* run as *Eclipse Application* *(3)*

###Notes###
*(1)* **You don't need to install it**, the update site is required to solve Co2 plugin dependencies.

*(2)* you might need to create some folders manually due to the *mercurial feature* that not push empty directories. It's currently necessary for the project `it.unica.co2.tests` for `src` and `xtend-gen` folders.

*(3)* if it fails due to memory problems, such as `OutOfMemoryException` or similar, go to `Run -> Run configurations..`, select *Eclipse Application*, *Arguments*, and set `-Xms40m -Xmx512m -XX:MaxPermSize=256m` into *VM arguments*

#Co2 Project#
* create a Java project
* create files with extension `co2` into the `src` folder (see example below)
* maude files will be generated automatically into `src-gen`

# Co2 syntax #
The syntax is defined into `it.unica.co2.CO2.xtext`

# Example #
See other examples into [`Co2Sample`](Co2Sample).
```

/*
 *  Insured-sale
 */
system insuredSale

// list of processes will be checked for honesty
honesty PA

contract CA  {
	order ? int . (amount! int . pay ? (+) abort!)
}

contract CI {
	reqI ! unit . (okI ? + abortI ?)
}


process PA {
	(x:session) (
		tell x CA . (
			do x order ? n:int . (if n>50 then PAY(x) else INS(x))
		) 
	)
}

process PAY (x:session) {
    do x amount ! . do x pay ? + do x abort !
}
   
process INS (x:session) {
	(y:session) tell y CI . (
        do y reqI ! . ( 
              do y okI ? . PAY(x)
            + do y abortI ? . do x abort !
            + t . ( do x abort ! | do y okI ? + do y abortI ? ) 
        )
        + t . (
        	do x abort ! | 
			do y reqI ! . (
				do y okI ? + do y abortI ?
			)
        ) 
    )
}
```