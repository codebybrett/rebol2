REBOL [
    Title: "binding - Tests"
    Version: 1.0.0
    Rights: {
        Copyright 2017 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Testing.}
]

script-needs [
    %requirements.r
    %../binding.r
]


obj: context [
    a1: {obj/a1}
    b1: [x {x}]
]
a1: {a1}

requirements 'binding [

    [ {Bind first word of any-block!}
        all [
            ["obj/a1" "a1"] = reduce binding/first obj [a1 a1]
            {x} = do binding/first obj 'b1/x
        ]
    ]

    [ {Custom bound object.}

        cus.obj: binding/custom/object [c1] [
            a1: {custom/a1} ; Will not bind.
            c1: {custom/c1} ; Will bind.
            f: funct [] [reduce [a1 c1]]
        ]

        ["a1" "custom/c1"] = cus.obj/f
    ]

    [ {Self contained locals.}
        local: binding/local [a1]
        not value? first local ; Notice a1 is set in user context, but local is unset.
    ]

    [ {Replace bindings for specific words.}
        equal? ["a1" [x "x"]] reduce binding/replace (in obj 'b1) [a1 b1]
    ]

    [ {Replace bindings in block and paths recursively.}
        ["obj/a1" "x"] = reduce binding/replace/deep words-of obj [a1 b1/x]
    ]

    [ {Replace bindings for specific words meeting condition.}
        equal? ["a1" "obj/a1"] reduce binding/replace/where (in obj 'a1) [a1 a1] [
            2 = index? position
        ]
    ]

    [ {Bind set-words of block (not deep).}
        block: use [a1] [[a1]]
        body: binding/set-words (first block) [a1: {set-words} a1]
        all [
            "a1" = do body
            ["set-words"] = reduce block
        ]
    ]
]
