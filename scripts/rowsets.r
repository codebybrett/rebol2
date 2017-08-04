REBOL [
	Title: "Rowsets"
	File: %rowsets.r
	Purpose: "An object to manipulate a simple rowset data structure."
	Version: 3.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	History: [
		1.0.0 [20-Oct-2014 "Initial version." "Brett Handley"]
		1.1.0 [07-Jan-2015 "Now supports Rebol 3 ie: [bind remove-each]." "Brett Handley"]
		1.2.0 [17-Jan-2015 "Can't use SELF as reference to new row in R3, replace with optional issues." "Brett Handley"]
		2.0.0 [30-Jan-2015 "Change parameter order on column functions. Added convenience function rowset/from/objects." "Brett Handley"]
		3.0.0 [24-Jun-2017 "Move to GitHub and remove old script manager." "Brett Handley"]
		; GitHub now tracks history.
	]
]

comment {

	Rowsets have words (columns) and the row data:

		players: [
			words [name score]
			rows [
				[{Tom}   4]
				[{Dick}  9]
				[{Harry} 7]
			]
		]

	Example rowset queries:

		rowset/query [

			select *
			where [score > 5]
			from x players

		]

		rowset/query [

			select [
				w: x/name
				l: y/name
				s: x/score * 10
			]
			join [
				x/score < y/score
				x/name <> y/name
			]
			from x players
			from y players

		]


	Querying supports rowsets based upon simple series:

		rowset/query [

			select [x: x + 10]
			from-series s [x y] [1 2 3 4 5 6]

		]

	Querying also supports rowsets based upon a block of objects:

		objs: reduce [
			make object! [x: 1 a: {Tom}]
			make object! [x: 2 b: {Dick}]
			make object! [x: 3 c: {Harry}]
		]

		rowset/query [

			select * from-objects o objs

		]

	The set words in the body of each command define a new row for that command.
	You can create a word to reference that new row using an issue at the beginning of the block.
	Get the old row value using the unqualified word or the original rowsource name.

	For example:

		rowset/query [

			update [
				#new
				x: x + 10
				print [{Old: } x {New: } new/x]
			]
			from a [words [x] rows [[1][2][3]]]

		]

	Any set-word! that doesn't exist in the rowset can be considered equivalent to being a local.
	For example, T in the following update block is a local to the update command:

		rowset/query [

			update [
				t: now
				x: t/date + x
			]
			from a [words [x] rows [[1][2][3]]]

		]

	A shortcut notation is available to make simple projections using Select - just list the fields. Eg.:

		select [a b] ; which is equivalent to [a: a b: b]
		from ....

	Some Built-In functions that take the row source name as an argument:
	*** WARNING Do not modifying the underlying data as returned by these functions - the results will be unpredictable. ***

		* position? - Returns the current row position for the specified rowsource (specify the rowsource by name).
		* row? - The current row reference of the named row source.
		* sourcetype? - The type of the named row source.
		* value? - The row object itself.
		* words? - The words allocated to the row source.

	Notes:

		Joins can be made between the different source types.

		Update and Delete will modify only the first (as written left to right) rowset of a join.

		Commands (Select, Where, From, ...) are bound deep within the query block but not within command body blocks,
		so the normal Rebol SELECT function etc., is available within expressions. Commands can be used inside
		If statements, etc.  For example:

			text: [1 {First} 2 {Second} 3 {Third}]
			rowset/query [

				if true [
					select [info: select text x] from a [words [x] rows [[1][2][3]]]
				]

			]

		Select has two refinements:

			* /Series causes rows to be returned as a simple series.
			*/ Value only the row values are returned - useful when combined with /Series for setting words.

		Commands chaining works as follows:

			* From takes a rowset and returns a "query source".
			* Where and Update each take and return a query source.
			* Join combines two query sources to return a query source.
			* Select takes a query source and returns a rowset.
			* So you can have a chained query like:

				select * where [y < 3] update [x: 1] where [something] from r ...

		Update will only change the fields of an object that have been specified in the Update block,
		so that a QUERY on the object will be accurate.

	To Do:
		* Consider a grouping command.  Define a comparison function to determine if two rows are in same group (returns zero.)
		* Consider adding a merge join for sorted rowsets.
}

script-needs [
	%binding.r
	%requirement.r
	%row-formatting.r
]


rowset: binding/custom/object [errors internal pretty] [

	as: binding/custom/object [] [

		excel-text: funct [
			{Emits Excel text.}
			delim [char!] "The cell delimiter used in the data, usually either a tab or comma."
			source [block!] {E.g.: [words [i w] rows [[1 a][2 b]]].}
		][
			internal/require-rowset {excel-text} source
			rejoin [
				excel-text delim reduce [source/words]
				excel-text delim source/rows
			]
		]

	]

	column: binding/custom/object [] [

		insert: func [
			{Inserts a column.}
			column [word! block!] {Column(s) to insert (word!).}
			number [integer!] {Column position for insertion.}
			source [block!] {E.g.: [words [i w] rows [[1 a][2 b]]].}
			/local values
		] [
			internal/require-rowset {insert} source
			column: compose [(:column)]
			insert at source/words number :column
			if select source 'types [insert at source/types number 'any-type!]
			values: head insert/dup copy [] none length? column
			foreach row source/rows [insert at row number values]
			return source
		]

		delete: func [
			{Deletes the specified columns from the rowset.}
			column [word! integer! block!] {Must be words or integer.}
			source [block!] {E.g.: [words [i w] rows [[1 a][2 b]]].}
			/local edit block
		] [
			internal/require-rowset {delete} source
			column: compose [(:column)]
			repeat i length? column [if not integer? column/:i [poke column i index? find source/words column/:i]]
			edit: copy []
			foreach i head reverse sort column [append edit compose [remove at block (i)]]
			edit: func [block] edit
			edit source/words
			if select source 'types [edit source/types]
			foreach row source/rows [edit row]
			return source
		]

	]

	errors: funct [
		{Returns errors in source.}
		source [block!] {E.g.: [words [i w] rows [[1 a][2 b]]].}
	][

		if not empty? errors: collect [
			foreach word [words rows] [
				either found? find source word [
					if not block? select source word [
						keep rejoin [{Expected block value for } uppercase form word {.}]
					]
				][
					keep rejoin [{Missing } uppercase form word {.}]
				]
			]
		][return errors]

		collect [
			if not parse source/words [any word!][keep {WORDS must be a block of words.}]
			if not parse source/rows [any block!][keep {ROWS must be block of blocks.}]
		]
	]

	from: context [

		iterator: func [
			{Builds rowset from iterator.}
			iterator [object!] {Object supporting iterator interface (words, /next, /tail?).}
			/local rows
		] [

			rows: either in iterator 'length? [make block! iterator/length?] [copy []]
			iterate iterator [append/only rows iterator/value]
			pretty compose/only [
				words (binding/local iterator/words) ; Prevent leak of binding of iterator words.
				rows (rows)
			]
		]

		pairs: func [
			{Convert a series of blocks, where each block contains name/value pairs, to a rowset (names should be words).}
			block [block!]
			/default value {Default value to be used instead of NONE.}
			/column columns [Block!] "Specific names to be selected."
		] [

			if not parse block [any block!] [make error! {pairs2rowset requires a block of blocks as input.}]

			use [data row] [

				; build header row
				if not column [
					columns: make block! 100
					repeat record block [insert tail columns exclude extract record 2 columns]
				]

				; build data data
				data: make block! (length? block) * length? columns
				repeat record block [
					row: make block! length? columns
					repeat column columns [insert/only tail row any [select/only/case record column :value]]
					insert/only tail data row
				]

				; rowset result
				reduce [
					'words columns
					'rows new-line/all data true
				]

			]
		]

		objects: funct [
			{Builds rowset from a series of objects.}
			series [series!]
		][
			rowset/query [select * from-objects object series]
		]

		rows: func [
			{Builds rowset from a set of rows.}
			rows [block!] {A block of blocks. Use /words to provide column names or first row must be a block of names to be loaded as word! (
spaces will be converted to hypens).}
			/words {Specify columns. Default assumes first row is a header row.} columns [block!] "A block of words to represent the columns."
			/local result
		] [
			either words [
				columns: copy columns
			] [
				columns: map-each heading rows/1 [
					to word! either any-word? :heading [:heading] [
						replace/all form heading " " "-"
					]
				]
				rows: next rows
			]
			pretty compose/only [
				words (copy columns)
				rows (copy rows)
			]
		]

		series: funct [
			{Builds rowset from a series.}
			words [block!] {Specify columns.}
			series [series!]
		][
			pretty compose/only [
				words (copy words)
				rows (do compose/deep/only [collect [foreach (words) series [keep/only reduce (words)]]])
			]

		]

	]

	internal: make object! [

		indicies: funct [
			length [integer!]
			/skip size [integer!]
		] [
			size: any [size 1]
			result: make block! 1 + divide length size
			for i 1 length size [append/only result reduce [i]]
			result
		]

		is-rebol2: (system/version < 2.100.0)

		require-rowset: funct [
			[catch! throw!]
			name source
		][
			requirement rejoin [form name { expects a valid rowset.}] [empty? errors source]
		]

		require-query-source: funct [[catch! throw!] name source] [
			requirement rejoin [form name { requires a valid query source.}] [
				all map-each word [rowsources positions] [found? find source word]
			]
		]

		bind-query: funct [
			{For use by select, where, update, etc.}
			body [block!]
			rowsources [block!] {Rowset source names.}
		] [

			body: copy/deep body

			; Get current columns of sources.
			columns: collect [foreach rowsource rowsources [src: get rowsource keep src/words]]

			; Capture new rowset user variable if any.
			if parse body [issue! to end][
				new.name: first body
				if is-rebol2 [new.name: form new.name]
				new.name: to word! new.name
				remove body
			]			

			; Define new rowset.
			remove-each x specs: copy body [
				any [find columns :x]
			] ; Workaround (R3 bug: Exclude does not support paths yet).
			either object-notation: not empty? specs [
				; Set-words declare the new rowset's words.
				remove-each x new: copy body [not set-word? :x]
			] [
				; A simple projection of existing rowset words.
				new: map-each word body [to set-word! word]
				body: collect [foreach word body [keep to set-word! word keep :word]]
			]
			new: make object! append new 'none

			; Bind columns of new context.
			; Allows reference to new rowset columns if no name clash with existing columns.
			bind body new

			; Bind columns of the sources (Earlier encountered sources have precedence).
			foreach rowsource reverse copy rowsources [src: get rowsource bind body src/value]

			; Bind rowset names and paths (only for object notation).
			if object-notation [
				row: make object! collect [
					if new.name [keep to set-word! new.name keep new]
					foreach rowsource rowsources [
						src: get rowsource
						keep to set-word! src/name keep get src/name
					]
				]
				bind body row
			]

			; Bind set-words to new's fields.
			binding/replace/deep/where words-of new body [set-word? word]

			; Bind special functions.
			functions: collect [
				foreach word [position row sourcetype value words] [
					keep to set-word! join form word "?"
					keep compose/deep [
						funct [[catch] 'name [word!]] [
							if not pos: find rowsources name [make error! rejoin [(form word) { cannot use } uppercase form name {. It is not a rowset source.} ]]
							rowsource: get pos/1
							get in rowsource (to lit-word! word)
						]
					]
				]
			]
			functions: make object! functions
			foreach word words-of functions [binding/replace/deep word body]

			; Build row processing functions.
			set-row: copy []
			unset-row: copy []
			repeat i length? rowsources [
				src: get rowsources/:i
				append set-row compose [(in src 'set) pick positions (i)]
				append unset-row compose [(in src 'unset)]
			]
			set-row: funct [positions] set-row
			unset-row: does unset-row

			binding/custom/object [] [
				body: (body)
				new: (new)
				set: (:set-row)
				unset: (:unset-row)
			]

		]

		query-keyword: make object! [

			from: funct/extern [
				{Returns a rowset query source.}
				'name [word! issue!] {A name for the rowset.}
				source [block!] {E.g.: [words [i w] rows [[1 a][2 b]]].}
			] [
				require-rowset {from} source
				name: to word! name ; Convert issue.
				data: source
				rowsource: binding/custom/object [value source row position] [
					name: first binding/local :name ; Name is put into it's own context.
					sourcetype: 'rowset
					source: data
					value: make object! append map-each word source/words [to set-word! :word] 'none
					words: words-of value
					row: position: none
					set: funct/extern [index] compose/only [set (words-of value) row: pick source/rows position: index][row position]
					update: funct [new][change row reduce bind/copy (words-of value) new]
					delete: funct [index] [remove at source/rows index]
					unset: does compose/only [row: position: none unset (words-of value)]
					set self/name value
				]
				rowsources: binding/local :name
				set rowsources/1 rowsource
				compose/only/deep [
					rowsources (rowsources)
					positions (indicies length? source/rows)
				]
			][set unset]

			from-records: funct [
				{Returns a rowset query source.}
				'name [word! issue!] {A name for the rowset.}
				source [block!] {E.g.: [[i w] 1 a 2 b].}
			] [
				from-series :name source/1 next source
			]

			from-series: funct/extern [
				{Returns a rowset query source.}
				'name [word! issue!] {A name for the rowset.}
				words [block!] {Words to set each time (will be local).}
				source [block!] {E.g.: [1 a 2 b].}
			] [
				requirement {From-Series requires that WORDS is a block of words} [parse words [any any-word!]]
				name: to word! name ; Convert issue.
				data: source
				rowsource: binding/custom/object [value source row position] [
					name: first binding/local :name ; Name is put into it's own context.
					sourcetype: 'series
					source: data
					value: make object! append map-each word words [to set-word! :word] 'none
					words: words-of value
					row: position: none
					set: funct/extern [index] compose/only [set (words-of value) row: at source position: index][row position]
					update: funct [new][change row reduce bind/copy (words-of value) new]
					delete: funct [index] compose [remove/part at source index (length? words)]
					unset: does compose/only [row: position: none unset (words-of value)]
					set self/name value
				]
				rowsources: binding/local :name
				set rowsources/1 rowsource
				compose/only/deep [
					rowsources (rowsources)
					positions (indicies/skip length? source length? words)
				]
			][set unset]

			from-iterator: funct/extern [
				{Returns a rowset query source.}
				'name [word! issue!] {A name for the rowset.}
				iterator [object!] {An iterator.}
			] [
				requirement {From-Iterator requires an iterator that supports [HEAD INDEX? AT].} [
					all map-each word [next tail? index? at] [found? in iterator word]
				]
				name: to word! name ; Convert issue.
				rowsource: binding/custom/object [value source row position] [
					name: first binding/local :name ; Name is put into it's own context.
					sourcetype: 'iterator
					source: row: iterator
					position: none
					value: make object! append map-each word source/words [to set-word! :word] 'none
					words: words-of value
					set: funct/extern [index] compose/only [source/at position: index set (words-of value) source/value][row position]
					update: funct [new][do bind body-of new (to lit-word! first source/words) source/change]
					delete: funct [index] compose [source/remove]
					unset: does compose/only [row: position: none unset (words-of value)]
					set self/name value
				]
				rowsources: binding/local :name
				set rowsources/1 rowsource
				compose/only/deep [
					rowsources (rowsources)
					positions (collect [iterate/head iterator [keep/only reduce [iterator/index?]]])
				]
			][set unset]

			from-objects: funct/extern [
				{Returns a rowset query source.}
				'name [word! issue!] {A name for the rowset.}
				source [block!] {A block of objects.}
				/use {Use specific words. By default, a union of words found in the objects is used.} words [block!]
			] [
				requirement {From-Objects requires a block of objects.} [parse source [any object!]]
				name: to word! name ; Convert issue.
				if not use [
					words: copy []
					foreach object source [append words exclude words-of object words]
				]
				data: source
				rowsource: binding/custom/object [value source row position] [
					name: first binding/local :name ; Name is put into it's own context.
					sourcetype: 'rowset
					source: data
					value: make object! append map-each word words [to set-word! :word] 'none
					words: words-of value
					row: position: none
					set: funct/extern [index] compose/only [
						set (self/words) none
						set (self/words) reduce bind/copy (self/words) row: pick source position: index
					][row position]
					update: funct [new][do bind body-of new row]
					delete: funct [index] [remove at source index]
					unset: does compose/only [row: position: none unset (self/words)]
					set self/name value
				]
				rowsources: binding/local :name
				set rowsources/1 rowsource
				compose/only/deep [
					rowsources (rowsources)
					positions (indicies length? source)
				]
			][set unset]

			join: funct [
				{Returns a rowset query source.}
				body [block!] {Conditions to be satifisfied, bound to words. Evaluated by ALL.}
				source [block!] {Rowset query source.}
				join-source [block!] {Rowset query source.}
			] [

				require-query-source {join} source
				require-query-source {join} join-source
				if not empty? duplicate-aliases: intersect source/rowsources join-source/rowsources [
					make error! rejoin [{Duplicate aliases used: } mold duplicate-aliases]
				]

				rowsources: append copy source/rowsources join-source/rowsources

				qry: bind-query body rowsources

				either empty? body [
					positions: copy []
				] [
					positions: make block! multiply length? source/positions length? join-source/positions
					foreach source-row source/positions compose/only/deep [
						foreach joining-row join-source/positions [
							row: append copy source-row joining-row
							qry/set row
							if all (qry/body) [append/only positions row]
						]
					]
					qry/unset
				]

				compose/only [
					rowsources (rowsources)
					positions (positions)
				]

			]

			where: funct [
				{Returns a subset of the original rows that satisfy the conditions.}
				body [block!] {Conditions to be satifisfied, bound to words. Evaluated by ALL.}
				source [block!] {Rowset query source.}
			] [
				require-query-source {where} source

				qry: bind-query body source/rowsources

				either empty? body [
					rows: copy []
				] [
					rows: copy source/positions
					remove-each row rows compose/only [
						qry/set row
						not all (qry/body)
					]
				]
				qry/unset

				compose/only [
					rowsources (copy source/rowsources)
					positions (rows)
				]
			]

			select: funct [
				{Returns a new rowset from query source.}
				'body [word! block!] {Block to evaluate for each row. * supported. Eg. [date amount] or [new-column: 3 * old-column col: 1 + A/col].}
				source [block!] {A rowset query source.}
				/series {Returns results as a simple series.}
				/value {Just returns the row values.}
			] [
				require-query-source {select} source

				if all [word? :body '* = body] [
					body: collect [foreach rowsource source/rowsources [src: get rowsource keep src/words]]
				]
				if any-word? body [body: reduce [to word! body]]

				qry: bind-query body source/rowsources

				if empty? words-of qry/new [make error! {No select columns defined. Use simple field names or use object creation notation for complex expressions.}]

				rows: make block! length? source/positions
				foreach row source/positions compose/only [
					qry/set row
					do (qry/body)
					(either series ['append]['append/only]) rows reduce (words-of qry/new)
				]
				qry/unset

				words: unbind words-of qry/new
				length: 1 if series [length: length? words]
				if any [not series greater? length? rows length] [
					new-line/all/skip rows true length]
				if value [return rows]

				compose/only [
					words (words)
					rows (rows)
				]
			]

			update: funct [
				{Updates rowset (visually the earliest rowset in joins). Use object notation.}
				body [block!] {Block to evaluate for each row. Eg. [x: x + 1].}
				source [block!] {A rowset query source.}
			] [
				require-query-source {update} source

				qry: bind-query body source/rowsources
				src: get source/rowsources/1

				foreach row source/positions compose/only [
					qry/set row
					do (qry/body)
					src/update qry/new
				]

				qry/unset

				return source
			]

			delete: funct [
				{Delete rows from rowset (visually the earliest rowset in joins).}
				source [block!] {A rowset query source.}
			] [
				require-query-source {update} source
				src: get source/rowsources/1

				delete-list: sort/reverse unique collect [foreach row source/positions [keep row/1]]
				foreach row delete-list [src/delete row]

				exit ; All query source rows are deleted.
			]


		]
	]

	pretty: func [
		{Formats the rowset.}
		source [block!] {E.g.: [words [i w] rows [[1 a][2 b]]].}
	] [
		internal/require-rowset {pretty} source
		new-line/all/skip source true 2
		new-line/all source/rows true
		return source
	]

	query: funct [
		{Query rowsets.}
		block {Query expression.}
	] [
		commands: words-of self/internal/query-keyword
		command!: remove collect [foreach word commands [keep '| keep to lit-word! :word]]
		parse block: copy/deep block rule: [
			any [
				x: command! (binding/first commands/1 x) opt [any-block!] ; Bind commands but not within command body blocks.
				| path! :x into [x: opt [command! (binding/first commands/1 x)] to end] ; Handle command refinements, ignore other paths.
				| any-block! :x into rule ; Supports commands within If statements etc.
				| skip
			]
		]
		do block
	]

	sort: funct [
		{Sorts the rowset using a list of expressions. (words are bound).}
		order-by [block!] {A block of expressions to evaluate foreach row, reduced result is compared with other rows.}
		source [block!] {E.g.: [words [i w] rows [[1 a][2 b]]].}
		/reverse {Reverse sort order.}
	] [
		*sort: copy 'sort/compare if reverse [append *sort 'reverse]
		columns: use source/words compose/only [(source/words)] ; Isolated context for column words.
		order-by: bind/copy order-by columns/1
		row: func [ref] [set columns ref reduce order-by]
		do compose [(*sort) source/rows func [a b] [lesser? row a row b]]
		return source
	]

]
