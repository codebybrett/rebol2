REBOL []

foreach-token: func [
    {Create a tokeniser which evaluates a block for each token.}
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
