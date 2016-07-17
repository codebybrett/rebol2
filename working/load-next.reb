REBOL []

load-next: func [
    {Set word to the next value, return the new position.}
    word {Word set to represent each value. Will be unset at tail.}
    position [string!] {Position in the REBOL source.}
    /local token
][

    if tail? position [
        return none ; Nothing follows.
    ]

    token: load/next position
    set/any word token/1

    token/2
]
