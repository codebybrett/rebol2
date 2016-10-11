REBOL []

do %tdop.reb

requirements %tdop.test.evaluation.reb [

    [{Infix style evaluation.}

        tdop-parser: tdop [
        
            get-lbp: func [token] [
                either '+ = :token/value [10][0]
            ]
    

            get-led: func [token] [
                if not ('+ = :token/value) [exit]
                [+ (:left) (recurse lbp)]
            ]

            get-nud: func [token][
                [(:token/value)]
            ]

            interpret: func [
                {Evaluate the semantic code of the token relative to the parser environment.}
                code
                parser
            ] [
                compose/only parser code
            ]
        ]

        all [
            [] = tdop-parser/evaluate 'value [left + right]
            [+ [left] [right]] = value
        ]
    ]

    [{Mode where evaluating the first value ends the expression.}

        all [
            [+ right] = tdop-parser/evaluate/first 'value [left + right]
            [left] = value
        ]
    ]
]
