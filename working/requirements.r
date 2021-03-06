REBOL []

either system/version > 2.100.0 [;Rebol3
	user-error: funct [match [string! block!] test [block!]] [
		if string? match [match: compose [(match) to end]]
		all [
			error? err: try test
			parse err/arg1 match
		]
	]
] [
	user-error: funct [match [string! block!] test [block!]] [
		if string? match [match: compose [(match) to end]]
		all compose [
			error? err: try test
			err: disarm err
			parse/all err/arg1 match
		]
	]
]

	throws-error?: funct [
		condition [block!] {Bound to error object. Evaluated by ALL.}
		test [block!]
	] [
		to-value if error? err: try test [
			all bind/copy condition in disarm err 'type
		]
	]

	user-error?: funct [match [string! block!] test [block!]] [
		if string? match [match: compose [(match) to end]]
		all compose [
			error? set/any 'err try test
			err: disarm err
			string? err/arg1
			parse/all err/arg1 match
		]
	]


requirements: funct [
	{Test requirements.}
	about
	block [block!] {Series of test blocks. A textual requirement begins the block (optional).}
] [
	results: new-line/all/skip collect [
		foreach test block [
			value: none
			error? set/any 'value try bind test 'user-error
			keep all [
				value? 'value
				logic? value
				value
			]
			keep/only either string? test/1 [test/1] [test]
		]
	] true 2

	remove-each [passed id] results [passed]
	either empty? results [
		compose/only [
			(:about) Passed
		]
	] [
		new-line compose/only [
			(:about) TODO
			(new-line/all extract next results 2 true)
		] true
	]
]
