#Version#
2015-04-18: version **0.0.2** released!

2015-04-03: version **0.0.1** released!

#Installation#

##Plugin Users##
* go to `Help -> Install New Software...` from the menu bar and `Add...`
* add the update site for Xtext 2.8.0 or greater ([http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/](http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/)) *(1)*
* add Co2 update site [http://seclab.unica.it/eclipse-plugin/update_site/](http://seclab.unica.it/eclipse-plugin/update_site/)
* install CO2 SDK Feature

##Plugin Developers##
* install Xtext module, version 2.8.0 or greater (see [https://eclipse.org/Xtext/download.html](https://eclipse.org/Xtext/download.html))
* import all projects `it.unica.co2*` and go to `Project -> Build All` *(2)*
* run as *Eclipse Application* *(3)*

###Notes###
*(1)* you don't need to install the full xtext sdk. The update site is required to solve Co2 plugin dependencies.

*(2)* you might need to create some folders manually due to the *mercurial feature* that not push empty directories. It's currently necessary for the project `it.unica.co2.tests` for `src` and `xtend-gen` folders.

*(3)* if it fails due to memory problems, such as `OutOfMemoryException` or similar, go to `Run -> Run configurations..`, select *Eclipse Application*, *Arguments*, and set `-Xms40m -Xmx512m -XX:MaxPermSize=256m` into *VM arguments*

#Co2 Project#
* create a Java project
* create files with extension `co2` into the `src` folder (see example below)
* maude files will be generated automatically into `src-gen`

# Co2 syntax #
The syntax is defined into `it.unica.co2.CO2.xtext` and `it.unica.co2.Contracts.xtext`

# Example #
```
/*
 *  Insured-sale.co2
 */
contract CA {
	order ? int . (amount! . pay ? (+) abort!)
}

contract CI {
	reqI ! unit . (okI ? + abortI ?)
}


process PA {
	(x) (
		tell x CA . (
			do x order ? n:int . (if e then PAY(x) else INS(x))
		) 
	)
}

process PAY (x) {
    do x amount ! . do x pay ? + do x abort !
}
   
process INS (x) {
	(y) tell y CI . (
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