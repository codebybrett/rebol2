Tokenising
==========

Playing around with tokenising functions just to see where it leads, what the issues are, any insights.

Motivated by the following:

* There was a change of signature for DO/NEXT from Rebol 2 to Rebol 3, whereby a position word
is supplied to be set.
* In Ren-C a change was made to prevent void! from being inserted into blocks, yet an expression may evaluate
to void, and SET/OPT is allowable.

So to capture void/unset I need to set a word. I decided to try the idea whereby tokenising functions would
return a postion on match or none for mismatch and which would set/unset a word as a side-effect for the value.

Returning position on match and none for mismatch is the same condition used for my PARSING-AT function in
parse-kit.reb which allows simple integration of DO dialect code into parse for arbitrary matching.  


Could have:

* cycle-token - to cycle through a list on each call
* longest-token
* etc.


For anyone new to Rebol - this isn't the way to do it, use PARSE.
