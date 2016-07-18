REBOL []

repeat-token: func [
    {Create tokeniser that repeats another. Implements repetitive matching.}
    min [integer! none!] {Minimum occurrences. None: No minimum.}
    max [integer! none!] {Maximum occurrences. None: No Maximum.}
    tokeniser [function!] {Set word, returns end of token or none. Signature [word [word!] position] -> position}
][

do make error! {Not implemented.}

]
