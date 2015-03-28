# Instructions #
* install xtext module (see [https://eclipse.org/Xtext/download.html](https://eclipse.org/Xtext/download.html))
* import all projects `it.unica.co2*`
* run as *Eclipse Application* (if fails due to memory problems, as `OutOfMemoryException` or similar, go to `Run -> Run configurations..`, select *Eclipse Application*, *Arguments*, and set `-Xms40m -Xmx512m -XX:MaxPermSize=256m` into *VM arguments*)
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