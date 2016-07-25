REBOL []

do %tdop.reb

requirements %tdop.test.matching.reb [

    [{Can match next token.}

        tdop-parser: tdop [
            get-lbp: func [token] [0]
            get-nud: func [
                token [any-type!]
            ][

                if 'if = :token/value [
                    return [
                        use [cond value][
                            cond: recurse 0
                            if any [
                                none? get-rest :current
                                not 'then = :current/value
                            ] [
                                do make error! {Expected THEN.}
                            ]
                            advance
                            value: recurse 0
                            if cond [value]
                        ]
                    ]
                ]

                compose [(token/value)]
            ]   
        ]

        all [
            [] = tdop-parser/evaluate 'value [if 1 then 2]
            2 = value
        ]
    ]

    [
        user-error {Expected THEN.} [tdop-parser/evaluate 'value [if 1]]
    ]

    [
        user-error {Expected an expression.} [tdop-parser/evaluate 'value [if 1 then]]
    ]
]
