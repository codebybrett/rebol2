REBOL [
    Title: "Tokenise"
    Version: 1.0.0
    Rights: {
        Copyright 2016 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
]

;
; Tokenise is equivalent to Rebol's REDUCE.
;

tokenise: func [
    {Get tokens from position until exhausted.}
    tokeniser [function!] {Set word, returns end of token or none. Signature [word [word!] position] -> position}
    position
    /into {Insert tokens into target.} target
    /local token
][

    if not into [target: make block! []]

    forever [
        position: tokeniser 'token position
        if not position [break]
        target: insert target get/any 'token
    ]    

    if not into [target: head target]

    target
]