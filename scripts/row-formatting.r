REBOL [
	Title: "Row Formatting"
	File: %row-formatting.r
	Purpose: "Formats."
	Version: 3.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	History: [
		1.0.0 [7-Dec-2014 "Initial version." "Brett Handley"]
		1.1.0 [15-Feb-2015 "Modify excel-text to output date and datetime properly." "Brett Handley"]
		3.0.0 [24-Jun-2017 "Move to GitHub." "Brett Handley"]
		; GitHub now tracks history.
	]
]

script-needs [
	%binding.r
	%separators.r
	%date.r
]


value-types?: funct [
	block [block!] {Get's types of values.}
][
	map-each value block [type?/word :value]
]


pad: (funct [length value] [head insert/dup value: form value #"0" length - length? value])

excel-text: funct [
	{Emit excel text.}
	delim [char!] "The cell delimiter used in the data, usually either a tab or comma."
	data [block! object!] {A block of blocks or object supporting iterator interface (/next, /tail?).}
][
	qc: charset join delim {"'}
	cell-format: func [value] [
		if none? :value [value: {}]
		if date? :value [value: date/as/excel value]
		if not string? :value [value: form :value]
		if find value qc [value: head insert append replace/all copy value {"} {""} {"} {"}]
		value
	]
	row-format: func [value [block!]] [join rejoin interpose delim map-each x value [cell-format :x] lf]
	result: copy {}
	either block? data [
		foreach row data [append result row-format row]
	][
		iterate data [append result row-format data/value]
	]
	result
]


sqlencoder: binding/custom/object [
	value type value-list
	type-list
	name-list name-encoding
	column.prefix column.suffix
] [

	column.prefix: none
	column.suffix: none

	value: none
	type: none

	value-list: funct [
		values [block!]
	][
		result: copy []
		foreach x values [append result reduce [{, } value :x]]
		remove result ; First seperator.
		rejoin result
	]

	type-list: funct [
		types [block!]
	][
		map-each x types [type :x]
	]

	name-list: funct [
		names [block!]
	][
		result: copy []
		foreach x names [append result reduce [{, } name-encoding :x]]
		remove result ; First separator.
		rejoin result
	]

	name-encoding: funct [name][
		rejoin [
			any [column.prefix {}]
			form :name
			any [column.suffix {}]
		]
	]

	create: funct [
		table-name [string!]
		names [block!]
		types [block!]
	] [
		types: type-list types
		field-list: copy []
		repeat i length? names [
			name: names/:i
			type: types/:i
			append field-list reduce [{, } name-encoding :name]
			if found? type [append field-list reduce [#" " form :type]]
		]
		remove field-list; First separator.
		rejoin ["create table " table-name " (" field-list ");"]
	]

	insert: funct [
		table-name [string!]
		values [block!]
		/column names [block!]
	] [
		names: either column [compose [{ (} (name-list names) {)}]][[]]
		rejoin compose [{insert into } (table-name) (names) { values (} (value-list values) {);}]
	]

]

odbc-sql: make sqlencoder [

	column.prefix: #"["
	column.suffix: #"]"

	type: funct [
		type [word!] {REBOL type as word!.}
	] [
		switch/default :type [
			integer! [{NUMBER}]
			decimal! [{NUMBER}]
			number! [{NUMBER}]
			money! [{CURRENCY}]
			logic! [{LOGICAL}]
			date! [{DATETIME}]
			string! [{TEXT}]
		] [{TEXT}]
	]

	value: funct [
		value
	] [

		switch/default type? :value [
			#[datatype! integer!] [form value]
			#[datatype! decimal!] [form value]
			#[datatype! logic!] [form value]
			#[datatype! date!] [rejoin [{#} form value/year "-" either value/month < 10 ["0"] [""] form value/month "-" either value/day < 10 ["0"] [""] form value/day either value/time [join " " form value/time] [""] {#}]]
			#[datatype! none!] ["null"]
			#[datatype! string!] [rejoin [{'} (replace/all copy value {'} {''}) {'}]]
		] [rejoin [{'} (replace/all mold value {'} {''}) {'}]] ; For everything else - just insert it as REBOL syntax for now.

	]

]

sqlite-sql: make sqlencoder [

	type: funct [
		type [word!] {REBOL type as word!.}
	] [
		switch/default :type [
			integer! [{INTEGER}]
			decimal! [{REAL}]
			number! [{NUMERIC}]
			money! [{REAL}]
			logic! [{INTEGER}]
			date! [{TEXT}]
			string! [{TEXT}]
		] [{TEXT}]
	]

	value: funct [
		value
	] [

		switch/default type? :value [
			#[datatype! integer!] [form value]
			#[datatype! decimal!] [form value]
			#[datatype! logic!] [form either value [1] [0]]
			#[datatype! date!] [rejoin [{'} form value/year "-" either value/month < 10 ["0"] [""] form value/month "-" either value/day < 10 ["0"] [""] form value/day either value/time [join " " form value/time] [""] {'}]]
			#[datatype! none!] ["null"]
			#[datatype! string!] [rejoin [{'} (replace/all copy value {'} {''}) {'}]]
		] [rejoin [{'} (replace/all mold value {'} {''}) {'}]] ; For everything else - just insert it as REBOL syntax for now.

	]

]
