Pratt / Top Down Operator Precedence
====================================

Playing around using this parsing approach.

Want:

* Reusable function that implements the algorithm.
* Not to arbitrarily constrain the user.
* Minimal requirements to implement, low overhead.
* Allow processing of forward only token streams.
* Flexible token representation. Not require object oriented tokens, but allow them.
* Leave it to client to determine how semantic code will be defined/retrieved.
* Have the power demonstrated by Pratt in his paper.
* Allow definitions to be straight Rebol or defined within the language being parsed. Perhaps this is just a recursive call.
* Be able to use the resulting parser as a tokeniser to be able to be called from Rebol's parse.


How does this implementation relate to the paper?

> For the examples we shall assume that lbp, nud and led are really the functions lbp(token), nud(token) and led(token).

* get-lbp, get-nud, get-led.

> To call the parser and simultaneously establish a value for rbp in the environment of the parser,
we write parse(rbp), passing rbp as a parameter.

* RBP is a parameter of recurse. 

> Then a led runs, its left hand argument's interpretation is the value of the variable LEFT,
which is local to the parser calling that led.

* LEFT is local to recurse.

> Tokens without an explicit nud are assumed to have for their nud the value of the variable nonud,
and for their led, noled.

* Can be covered as a condition in get-nud, get-led. I see this functionality as part of client code.

> Also the variable self will have as value the token whose code is missing when the error occurs.

* Implemented as CURRENT.

> the language used for the semantic code

* token/run interprets the code and can be overridden by client code.

* TODO: I want to have the choice to allow semantic code to be written within the language being
defined and therefore interpreted by the parser, or by Rebol's DO dialect.

> We write check x for if token = x then advance else (print "missing"; print x; halt).

* TODO: Could implement using a Rebol parse rule as a parameter to an internal function MATCH.

> To run the theorem prover, evaluate k←1; parse 0.

* TODO: Consider how variables can be created, bound by semantic code. What is their environment?

> a subset of the definitions of tokens of the language L; all of them are defined in L,
although in practice one would begin with a host language H (say the target language, here LISP)
and write as many definitions in H

* So practically one needs to write these functions if wanting to define a language. Perhaps they will
simplify the definition of Rebol dialects. As this is optional, I'll leave this to client code to do for now,
though it might be convenient to have some reusable definitions for these.

> definitions of nilfix, prefix, infix or infixr 

* TODO: Create client code example where these are defined.

> (prefix a b c) sets bp←b

* BP should live in a context created by the client code.

> The variable bp is available for use for calling the parser when reading code.

* The client code will need to make BP available to semantic code.

> (delim x) does lbp(x)←0.

* TODO: If get-lbp returns zero by default is this required?

>  The function (a getlist b) parses a list of expressions delimited by as,
parsing each one by calling parse b, and it returns a LISP list of the results.

* TODO: There should be available a function that equivalent to Rebol's reduce but using the parser.

* TODO: Should be able to implement getlist functionality if required.

* TODO: Check that the haskell style function calls can be made. Refer to the Manella article relating to "someFunction".

> The object is to translate...

* TODO: Create an example by which the semantic code is defined in terms of itself. Perhaps just an excerpt of L
from Pratt's article.

Other thoughts:

* Experiment with tree rewriting functions. Do they have any relevance to this algorithm?
