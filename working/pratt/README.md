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

> The lbp (left binding power) is a property of the current token in the input stream,
and in general will change each time state q1 is entered.
The left binding power is the only property of the token not in its semantic code.

* LBP is a local variable of recurse and forms part of the parser environment.

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

* Implemented as THIS. Needed because ADVANCE is called before the code is evaluated and the code
may need to refer to the current token. Also remember the code itself may call ADVANCE as well.
* TODO: Because THIS and CODE are set at pretty much the same time, are they the same operation?

> the language used for the semantic code

* The semantic code for the token is written in whatever language is most convenient.
* token/interpret interprets this semantic code as required having access to the parser environment.

> We write check x for if token = x then advance else (print "missing"; print x; halt).

* TODO: Create an example where CHECK is defined by token definition code.

> To run the theorem prover, evaluate k←1; parse 0.

* Client code will need to manage it's own variables used by semantic code.

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

* TODO: There should be available a function that is equivalent to Rebol's reduce but using the parser.

* TODO: Should be able to implement getlist functionality if required.

* When RECURSE is called it is assumed that an expression evaluation can be started, so an error is raised
if this is not true. The /OPT refinement makes recurse optional in the sense that no error is raised
if there is no expression.

* Haskell style function calls can be parsed. Refer to the Manella article relating to "someFunction". Here
implemented in my varargs test. 

> The object is to translate...

* Math example demonstrates translation.
* TODO: Create an example by which the semantic code is defined in terms of itself.

Other thoughts:

* Rebol block input requires recursing on a nested block.
* TODO: How are error messages to be handled?
* TODO: Demonstrate integration with a Rebol parse rule.
* TODO: Experiment with tree rewriting functions. Do they have any relevance to this algorithm?
