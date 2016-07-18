REBOL []

chain-tokens: func [
    {Create a chained tokeniser. Implements sequence matching.}
    begin [integer!] {First tokeniser to begin the chain.}
    end [integer! logic!] {Final tokeniser to end the chain. False: Any; True: Last.}
    tokenisers [block!] {Block of tokenisers, each identified by a get-word.}
    /local last-idx
][

    if empty? tokenisers [
        do make error! {Expected at least one tokeniser specified.}
    ]

    if not parse tokenisers [some get-word!][
        do make error! {Tokenisers must be specified with a get-word.}
    ]

    if any [
        1 > begin
        all [
            number? end
            0 > (end - begin)
        ] 
    ] [
        do make error! {Expected to chain at least one tokeniser.}
    ]

    last-idx: length? tokenisers
    either number? end [
        last-idx: min last-idx end
    ][
        if end [end: last-idx]
    ]

    func compose [
        {CHAIN-TOKENS (see source).}
        word [word!] {Word set to each token.}
        position [block! string!] {Position in source.}
        /local tokenisers tokeniser token result
    ] compose/deep/only [

        tokenisers: (copy tokenisers)

        result: make block! []

        for i (begin) (last-idx) 1 [
            tokeniser: tokenisers/:i
            position: do get tokeniser 'token position
            if not position [
                if all [(end) i <= (end)] [
                    result: none
                ]
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
