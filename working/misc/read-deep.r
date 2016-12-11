REBOL []

; Playing around with a simpler implementation of read-below.r
; The idea was simply to reuse a single series, growing it to the final output.
; Found out the idea is called unfold.


children-of: funct [
    {Return child nodes of node f for processing.}
    item
][

    if not equal? #"/" last f [
        return make block! []
    ]

    contents: read item
    if %./ <> item [
        contents: map-each x contents [join item x]
    ]

    contents
]

; Concept of unfold: https://en.wikipedia.org/wiki/Anamorphism#Example

unfold: func [
    queue
][

    forall queue [
        insert next queue children-of first queue
    ]

    queue
]

HALT
remove unfold [%./]
