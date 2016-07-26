REBOL []

do %tdop.reb

tdop-parser: tdop [


    get-lbp: func [
        token
    ] [
        0
    ]


    get-led: func [
        token
    ] [
        exit
    ]


    get-nud: func [
        token [any-type!]
    ][
        exit
    ]

    get-next: func [
        {Fetch token following this.}
        token {Represents a token.}
        /local position
    ][

        if any [
            none? position: get-rest token
        ] [
            return context [rest: none]
        ]

        make token [
            rest: next-token 'value position
            ; value field in object is set.
        ]
    ]

    interpret: func [
        {Evaluate the semantic code of the token relative to the parser environment.}
        code
        parser
    ] [

        compose parser code
    ]

    lexer: context [

        p1: p2: value: none

        mark: [p2: (value: copy/part p1 p2)]

        charsets: context [
            digit: charset {0123456789}  
            letter: charset [#"a" - #"z" #"A" - #"Z"]
        ]

        rules: context bind [
            name: [letter any [letter | digit] mark]
            token: [
                p1:
                name
            ]
        ] charsets
    ]

    next-token: funct [
        {Set word to next value, returing end position (rest of input) or none.}
        word [word!] {Set to the value of the expression.}
        position [series!] {Position in source.}
    ][
        value: none
        if parse/all/case position [
            lexer/rules/token 
        ] [
            set word lexer/value
            lexer/p2
        ]
    ]
]

requirements %tdop.test.Lsample.reb [

    [{L Sample.}

        all [
            {} = tdop-parser/evaluate 'value {}
        ]
    ]
]
