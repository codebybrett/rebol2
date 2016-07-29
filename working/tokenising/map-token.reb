REBOL []

map-token: func [
    {Create a tokeniser which evaluates a block for each token.}
    spec [block! object!] {Block of set-word tokeniser pairs. Object spec format.}
    body [block!] {Block to evaluate.}
    /local func-body 
][

    if block? spec [spec: context spec]
    words: words-of spec
    if empty? words [do make error! {Expected at least one token definition.}]
    use words compose/only [words: (words)] ; Give words their own context.

    body: bind/copy body first words ; Use the local.

    func-body: compose/deep/only [
        unset (words)
    ]

    for i 1 length? words 1 [
        append func-body compose/deep/only [
            position: do (to get-word! in spec words/:i) (to lit-word! words/:i) position
        ]
    ]

    append func-body compose/deep/only [
        set/any word (to paren! body)
        position
    ]

    func compose [
        (rejoin [{Evaluates block for token } uppercase mold words {.}])
        word [word!] {Word set to each token.}
        position [block! string!] {Position in source.}
    ] func-body
]
