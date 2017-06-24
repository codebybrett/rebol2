REBOL [
	Title: "Separators"
	File: %separators.r
	Purpose: "Insert separators into blocks."
	Version: 3.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
	history: [
		1.0.0 [22-Feb-2014 "Initial version." "Brett Handley"]
		3.0.0 [24-Jun-2017 "Move to GitHub and remove old script manager." "Brett Handley"]
		; GitHub now tracks history.
	]
]

bookend: func [
	{Insert seperator at head and tail of a series.}
	separator [any-type!]
	series [series!]
	/local result
][
	result: make type? series 2 + (length? series)
	append/only result :separator
	append result :series
	append/only result :separator
	result
]

interpose: funct [
	{Insert seperator between elements of a series.}
	separator [any-type!]
	series [series!]
	/only {Inserts a block separator as a block.}
	/skip {Treat the series as records of fixed size.} size [integer!] {Size of each record.}
][
	skip: get bind 'skip 'do ; Default meaning of skip.
	size: any [size 1]
	if (size + 1) > length? series [return copy series]
	length: add length? series to integer! (divide length? series size)
	result: make type? series length
	append result copy/part series size
	series: skip series size
	add-next: copy [insert insert tail result :separator copy/part series size]
	if only [add-next/2: 'insert/only]
	forskip series size add-next
	result
]

separate: funct [
	{Seperates a series on seperator pattern.}
	pattern {A valid parse pattern.}
	series [series!]
	/case {Uses case-sensitive comparison.}
][
	*parse: 'parse/all
	if case [append *parse 'case]
	result: collect [
		do *parse series [
			start:
			any [
				match: pattern finish: (keep/only copy/part start match start: :finish)
				| skip
			]
			(keep/only copy start)
		]
	]
	result
]



