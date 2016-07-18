REBOL []

all-tokens: func [
    {Create a chained tokeniser (sequence of tokens).}
    word [word!] {Word set to each token.}
    tokenisers [block!] {Block of tokenisers, each identified by a get-word.}
][

    if empty? tokenisers [
        do make error! {Expected at least one tokeniser specified.}
    ]

    if not parse tokenisers [some get-word!][
        do make error! {Tokenisers must be specified with a get-word.}
    ]

    func compose [
        (rejoin [{ALL-TOKENS for } mold tokenisers])
        word [word!] {Word set to each token.}
        position [block! string!] {Position in source.}
        /local token result
    ] compose/only [

        result: make block! []

        foreach tokeniser (tokenisers) [
            position: do get tokeniser 'token position
            if not position [
                result: none
                break
            ]
            target: insert tail result get/any 'token
        ]

        if result [
            set word head result
            position
        ]
    ]
]
