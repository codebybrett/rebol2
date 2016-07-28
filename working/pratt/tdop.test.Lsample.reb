REBOL []

;
; Abandoned once I finally realised (I blame being sick while looking at this) that the Pratt's L example
; looks to require that semantic code is run on a LISP interpreter.
; If I learnt enough LISP, which I'm not prepeared to do right now, I could simulate it with Rebol but then
; I wonder whether my test will prove anything. I do however, believe that my TDOP implementation is sufficient
; to carry the example if I had decided to continue with it. Accordingly, I'd be better off now spending my time
; on some interesting Rebol example.
;
; In any case in attempting this example some interesting issues were raised:
; * How can an input matching function be written for semantic code to call.
; * How can arguments be consumed from input and how can error messages be incorporated in that neatly,
;   noting that tail tests need to be a part?
; * Whitespace: solution here was to tokenise the source and strip whitespace tokens, passing the
;   result as a stream to the parser.


do %tdop.reb
do %../tokenising/tokenise.reb

tdop-parser: tdop [

    lbps: copy [
    ]

    nuds: copy [

        "nilfix" [
            make error! {NILFIX Not implemented.}
        ]
        "prefix" [
            if none? get-rest :current [do make error! {PREFIX requires a symbol.}]
            symb: current/value
            ?? symb
            advance
            if none? get-rest :current [do make error! {PREFIX requires a LBP.}]
            bp: current/value
            advance
            ?? bp
            if none? get-rest :current [do make error! {PREFIX requires a definition.}]
            def: current/value
            advance
            ?? def
            set-lbp symb bp
            set-nud symb def
        ]
        "infix" [
            make error! {INFIX Not implemented.}
        ]
        "infixr" [
            make error! {INFIXR Not implemented.}
        ]
        "check" [
            if none? get-rest :current [do make error! {CHECK requires an argument.}]
            arg: current/value
            advance
            either all [
                not none? get-rest :current
                arg = current/value
            ] [
                advance
            ] [
                do make error! rejoin [{Expected } mold arg]
            ]
        ]
        "advance" [advance]
    ]

    leds: copy [
    ]

    get-def: func [
        {Get token definition.}
        defs
        token
        /local pos
    ][
        either pos: find/only/case defs :token [
            :pos/2
        ][
            ()
        ]
    ]

    set-def: func [
        {Set definition of a token.}
        defs
        token
        definition [block! string! function! paren!] {Empty paren unsets the token.}
        /local pos
    ][
        either pos: find/only/case defs :token [
            either value? 'definition [
                change/only next pos :definition 
            ][
                remove/part pos 2
            ]
        ][
            if value? 'definition [
                insert pos: tail defs reduce [:token :definition]
                new-line pos true ; TODO: Remove for production.
            ]
        ]
        return ()
    ]

    set-lbp: func [
        {Set LED of a token.}
        token
        definition [block! string! function! paren!] {Empty paren unsets the token.}
    ][
        (set-def lbps :token :definition)
    ]

    set-nud: func [
        {Set NUD of a token.}
        token
        definition [block! string! function! paren!] {Empty paren unsets the token.}
    ][
        (set-def nuds :token :definition)
    ]

    set-led: func [
        {Set LED of a token.}
        token
        definition [block! string! function! paren!] {Empty paren unsets the token.}
    ][
        (set-def leds :token :definition)
    ]


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
        get-def nuds token/value
    ]

    get-first: func [
        {Get first token.}
        source
    ][

        source: tokenise :next-token source ; Convert to a blocks.
        remove-each token source ['whitespace = token/1]

        token/get-next context [
            type: none
            value: none
            rest: :source
            (unset [type value])
        ]
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
            rest: (
                unset 'value
                either tail? position [
                    none ; End token.
                ][
                    set/any [type value] first position
                    next position
                ]
            )
            ; type, value field in object is set.
        ]
    ]

    interpret: func [
        {Evaluate the semantic code of the token relative to the parser environment.}
        code
        parser
    ] [

        either string? code [
            parser [evaluate code]
        ][
            do parser code
        ]
    ]

    charsets: context [
        wsp.ch: charset { ^-^/}
        dqt.ch: charset {"}
        oth.ch: complement charset { ,^-^/"}
        nqt.ch: complement dqt.ch
    ]

    next-token: func [
        {Set word to next token value, returing end position (rest of input) or none.}
        word [word!] {Set to the value of the expression.}
        position [series!] {Position in source.}
    ] [

        if tail? position [
            return none
        ]

        parse/all position bind [
            [
                [
                    some wsp.ch (tokentype: 'whitespace)
                    | dqt.ch any nqt.ch dqt.ch (tokentype: 'string)
                    | #"," (tokentype: 'comma)
                    | some oth.ch (tokentype: 'value)
                ]
                pos:
            ]
        ] charsets

        either pos [
            set word reduce [tokentype copy/part position pos]
            pos
        ][
            do make error! rejoin [
                {Unexpected token encountered near: }
                copy/part position any [find position newline tail position]
            ]
        ]
    ]
]

L-def: {
    nilfix  right          ["PARSE", bp]
}

requirements %tdop.test.Lsample.reb [

    [{L Sample.}

        all [
            [] = tdop-parser/evaluate 'value {check x x}
        ]
    ]
]
