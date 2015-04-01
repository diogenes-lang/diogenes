# Instructions #
* install xtext module, version 2.8.0 or greater (see [https://eclipse.org/Xtext/download.html](https://eclipse.org/Xtext/download.html))
* import all projects `it.unica.co2*` (1) and go to `Project -> Build All`
* run as *Eclipse Application* (2)
* create a Java project
* create files with extension `co2` into the `src` folder (see example below)
* maude files will be generated automatically into `src-gen`

###Notes###
(1) you might need to create some folders manually due to the *mercurial feature* that not push empty directories. It's currently necessary for the project `it.unica.co2.tests` for `src` and `xtend-gen` folders.

(2) if it fails due to memory problems, such as `OutOfMemoryException` or similar, go to `Run -> Run configurations..`, select *Eclipse Application*, *Arguments*, and set `-Xms40m -Xmx512m -XX:MaxPermSize=256m` into *VM arguments*


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