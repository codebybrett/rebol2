REBOL [
    Title: "Math Tests"
    Rights: {
        Copyright 2016 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Test Parse2.}
]

do %../requirements.r
do %parse2.reb

requirements 'parse2 [

    [{Failure returns none.}
        none? parse2 [skip] []
    ]

    [{Success returns end position by default.}
        all [
            [] = parse2 [] []
            [2] = parse2 [skip] [1 2]
        ]
    ]
]