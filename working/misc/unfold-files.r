REBOL []

; Playing around with a simple implementations of recursive reads.
; The idea here was to reuse a single series, growing it to the final output.
; Found out the idea is called unfold.

files-of: funct [
    {Return child file nodes of item for processing.}
    item
][

    if not equal? #"/" last item [
        return make block! []
    ]

    contents: read item
    if %./ <> item [
        contents: map-each x contents [join item x]
    ]

    contents
]

; Concept of unfold: https://en.wikipedia.org/wiki/Anamorphism#Example

unfold-files: func [
    queue
][

    forall queue [
        insert next queue files-of first queue
    ]

    queue
]

HALT

unfold-files [%./]
