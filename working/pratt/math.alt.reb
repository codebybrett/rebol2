REBOL [
    Title: "Math"
    rights: {
        Copyright 2016 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Implement a simple Math function that supports precedence using a Pratt parser.}
]


;
; The aim here was to clarify concepts in Pratt's algorithm using a simple example such as MATH.
;

do-math: funct [
    {Evaluate math expression with standard precedence, returning next position or none.}
    word [word!] {Set to the value of the expression.}
    position [block! paren!]
] [

    load-nud: func [
        {Loads token definitions that do not require a left argument.}
        bp token
        /local rbp
    ][

        case [

            none? :token [
                func [/local result][
                    result: compose/only [
                        error {Expected an expression.}
                        position (position)
                    ]
                    position: none
                    result
                ]
            ]

            '- = :token [
                rbp: 100
                func [] [
                    compose [negate (parse-math rbp)]
                ]
            ]

            '+ = token [
                rbp: 100
                func [] [
                    compose [(parse-math rbp)]
                ]
            ]

            any [
                number? :token
                word? :token
                path? :token
            ] [
                func [] [
                    compose [(:token)]
                ]
            ]

            paren? :token [
                func [] [
                    compose [(to paren! math/only :token)]
                ]
            ]

            block? :token [
                func [] [
                    compose [(to paren! :token)]
                ]
            ]

            true [
                func [] [
                    make error! {Expected argument or unary operators + or -.}
                ]
            ]
        ]
    ]

    load-led: func [
        {Loads token definitions that process left argument.}
        bp token
        /local fn rbp lbp
    ][
    
        if none? :token [
            return none
        ]

        fn: case [

            '+ = :token [
                lbp: rbp: 10
                func [left] [
                    compose [add (left) (parse-math rbp)]
                ]
            ]

            '- = :token [
                lbp: rbp: 10
                func [left] [
                    compose [subtract (left) (parse-math rbp)]
                ]
            ]

            '* = :token [
                lbp: rbp: 20
                func [left] [
                    compose [multiply (left) (parse-math rbp)]
                ]
            ]

            :token = first [/] [
                lbp: rbp: 20
                func [left] [
                    compose [divide (left) (parse-math rbp)]
                ]
            ]

            '** = :token [
                lbp: 30
                rbp: lbp - 1
                func [left] [
                    compose [power (left) (parse-math rbp)]
                ]
            ]

            true [
                lbp: 0
                none
            ]

        ]

        if lbp > bp [
            :fn
        ]
    ]

    parse-math: func [
        bp
        /local left fn token
    ][
        unset 'left
        token: position/1 ; none! indicates end token.
        fn: load-nud bp token
        until [
            position: next position ; Really part of token code.
            set/any 'left fn get/any 'left
            if none? position [break] ; Invalid position indicates parsing error.
            token: position/1 ; none! indicates end token.
            none? fn: load-led bp token
        ]
        get/any 'left
    ]

    set/any word parse-math 0
    
    position
]

math: funct [
    {Evaluate math expression with standard precedence.}
    expression [block! paren!]
    /only {Translate the expression only.}
    /local result
] [
    position: do-math 'result expression
    if none? position [
        make error! result/error
    ]
    if not tail? position [
        make error! {Expected a single expression.}
    ]
    either only [result][do result]
]