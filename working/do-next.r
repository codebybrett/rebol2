REBOL []

do-next: funct [
    {Set word to result of next expression in source, returing rest of source or none.}
    word [word!] {Set to the value of the expression.}
    position [block! string!] {Position in source.}
][

    if tail? position [
        return none ; Nothing follows.
    ]

    token: do/next position
    set/any word first token

    second token
]
