REBOL [
    Title: "Parse 2"
    Rights: {
        Copyright 2016 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Experiment with a PARSE like function which supports value attribute.}
]

; Could gather stats on conditions met.

parse2: funct [
    {Match rules against input.}
    rules [block!]
    input [series!]
][

; Start with position as return value to get logic working, then add other attributes.

    fail: func [][
        input: none
        break
    ]

    eval: func [rule][

        case [

            if lit-word? :rule [
                rules: next rules
                if tail? input [fail]
                if not equal? first input :rule [fail]
                input: next input
            ]
        
            if string? :rule [
                rules: next rules
                if tail? input [fail]
                if not find/match input :rule [fail]
                input: next input
            ]
        
            'skip = :rule [
                rules: next rules
                if tail? input [fail]
                input: next input
            ]

            true [
                make error! join {Unexpected rule: } mold rules
            ]
        ]
    ]

    while [not tail? rules] [
        eval first rules
    ]

    input
]