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
