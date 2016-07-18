REBOL []

each-token: func [
    {Create a tokeniser which evaluates a block for each token.}
    word [word!] {Word set to each token (local).}
    tokeniser [function!] {Set word, returns end of token or none. Signature [word [word!] position] -> position}
    body [block!] {Block to evaluate.}
][

    word: use compose [(word)] compose [(to lit-word! word)] ; Make word local.
    body: bind/copy body word ; Use the local.

    func compose [
        (rejoin [{Evaluates EACH-TOKEN block for token } uppercase form word {.}])
        word [word!] {Word set to each token.}
        position [block! string!] {Position in source.}
    ] compose/only [
        position: tokeniser (to lit-word! word) position
        set word (to paren! body)
        position
    ]
]
