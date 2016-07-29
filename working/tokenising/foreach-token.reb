REBOL []

foreach-token: func [
    {Evaluates a block for each token in a series.}
    word [word!] {Word set to token (local to body).}
    tokeniser [function!] {Set word, returns end of token or none. Signature [word [word!] position] -> position}
    position
    body [block!] {Block to evaluate.}
][

    word: use compose [(word)] compose [(to lit-word! word)] ; Make word local.
    body: bind/copy body word ; Use the local.

    forever compose/only [
        position: tokeniser (to lit-word! word) position
        if not position [break]
        do body
    ]

    position
]
