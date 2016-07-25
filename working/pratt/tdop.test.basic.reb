REBOL []

do %tdop.reb

requirements %tdop.test.basic.reb [

    [{Evaluate one expression and set next position.}

        tdop-parser: tdop [
        
            get-lbp: func [token] [0]
            get-nud: func [token][
                compose [(token/value)]
            ]   
        ]

        all [
            [2] = tdop-parser/evaluate 'value [1 2]
            1 = value
        ]
    ]

    [{Follows tokenising behaviour for rest.}

        [] = tdop-parser/evaluate 'value [1]
    ]

    [{Raises error by default at tail.}

        user-error {Expected an expression.} [tdop-parser/evaluate 'value []]
    ]
]
