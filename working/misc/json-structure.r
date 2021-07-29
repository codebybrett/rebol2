REBOL []

tokens: funct [
    {Dictionary of words that reduce to themselves exactly.}
    words
][
    dictionary: context compose append map-each w words [to set-word! w] 'none
    words: bind/copy words dictionary
    set dictionary words
    dictionary
]

json-structure: [

    output: none
    wrd: tokens [opn map ary key itm cls]

    grammar: [

        json: [wsp value wsp]
        
        value: [
            "true"
            | "false"
            | "null"
            | object
            | array
            | string
            | number
        ]

        object: [
            #"{" (output reduce [wrd/opn wrd/map])
            wsp opt member wsp any [#"," wsp member wsp]
            #"}" (output wrd/cls)
        ]

        member: [string wsp #":" wsp value]

        array: [
            #"[" (output reduce [wrd/opn wrd/ary])
            wsp opt [
                value (output reduce [wrd/itm ]) wsp
                any [#"," wsp value wsp]
            ]
            #"]" (output wrd/cls)
        ]

        string: [#"^"" json-string #"^""]
        json-string: [
            any [some chars | #"\" [#"u" 4 hex-ch | escaped]]
        ]

        number: [
            opt #"-"
            [onenine some digit | digit] ; Integer
            opt [#"." some digit] ; Fraction
            opt [[#"E" | #"e"] opt [#"+" | #"-"] some digit]  ; Exponent
        ]

        wsp: [any wsch]
    ]

    charsets: context [

        wsch: charset { ^-^/}
        digit: charset {0123456789}
        onenine: charset {123456789}
        hex-ch: charset "0123456789ABCDEFabcdef"

        chars: complement charset {\"^-^/}
        escaped: charset {"\/>bfnrt}
    ]

    grammar: context bind grammar charsets
    ; Grammar defined first in file.
]
