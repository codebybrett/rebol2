REBOL []


foreach-token: func [
    {Set set words to tokens by using specified tokenisers.}
    spec [block! object!] {Block of set-word tokeniser pairs. Object spec format.}
    series
    body [block!]
    /default value {Default value for words.}
    /local ctx words word emit name tokeniser while-body
][

    if block? spec [spec: context spec]
    words: words-of spec
    if empty? words [do make error! {Expected at least one token definition.}]
    use words compose/only [words: (words)] ; Give words their own context.
    while-body: copy []

    emit: func [value /only /line /local pos][
        either only [
            insert/only pos: tail while-body :value
        ][
            insert pos: tail while-body :value
        ]
        if line [new-line pos true] ; Make debugging loop code easier.
    ]

    emit/line compose/only  either default [
        [set (words) (:value)]
    ][
        [unset (words)]
    ]

    foreach word words [
        name: in spec word
        tokeniser: to lit-word! word
        emit/line [if series ]
        emit/only compose [ series: (name) (:tokeniser) series]
    ]

    emit/only/line to paren! bind/copy body first words

    while [not none? series] while-body
]
