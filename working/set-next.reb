REBOL []

;
; Identity tokeniser.

set-next: funct [
    {Set word to next value, returing end position (rest of input) or none.}
    word [word!] {Set to the value of the expression.}
    position [series!] {Position in source.}
][

    if tail? position [
        return none ; Nothing follows.
    ]

    set/any word first position
    next position
]
