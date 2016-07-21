REBOL [
	Title: "Math"
	Rights: {
		Copyright 2016 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Implement a simple Math function that supports precedence.}
]

do %tdop.reb

math-parser: tdop [

    get-lbp: func [
        {Set Left Binding Power of token. Defines precedence.}
        token {Represents a token.}
    ][
        any [
            select [
                + 10 - 10
                * 20 / 20
                ** 30
            ] token/value
            0
        ]
    ]

    get-nud: func [
        {Obtains the NUD code of the current token. E.g. Define Values and Prefix tokens.}
        token {Represents a token.}
        /local operation
    ][

        if none? :token/rest [
            do make error! {Expected an expression.}
        ]

        if number? :token/value [
           return [(token/value)]
        ]

        if paren? :token/value [
            use [value][ 
               return [(to paren! math/only :token/value)]
            ]
        ]

        operation: select [
            + [(recurse 100)]
            - [negate (recurse 100)]
        ] :token/value

        if not operation [
            do make error! {Expected number.}
        ]
        
        operation
    ]

    get-led: func [
        {Obtains the LED code of the current token (has LEFT argument) E.g Define Infix and Postfix tokens.}
        token {Represents a token.}
        /local operation
    ][
        any [
            select [
                + [add (left) (recurse lbp)]
                - [subtract (left) (recurse lbp)]
                * [multiply (left) (recurse lbp)]
                / [divide (left) (recurse lbp)]
                ** [power (left) (recurse lbp - 1)]
            ] :token/value
            ()
        ]
    ]

    interpret: func [
        {Evaluate the semantic code of the token relative to the parser environment.}
        code
        parser
    ] [

        ; The dialect of COMPOSE has been chosen to encode the semantic code of the tokens.
        ; Ideally only parens should be bound since it is only parens that refer to the parser environment.

        compose parser code
    ]
]


math: funct [
    {Evaluate math expression with standard precedence.}
    expression [block! paren!]
    /only {Translate the expression only.}
] [
    result: none
    position: math-parser/evaluate 'result expression
    if not tail? position [
        do make error! {Expected a single expression.}
    ]
    either only [result][do result]
]