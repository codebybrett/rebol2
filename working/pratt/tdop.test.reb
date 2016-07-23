REBOL []

do %../requirements.r
do %tdop.reb

requirements 'TDOP [

	[{Evaluate one expression and set next position.}

		tdop-parser: tdop [
			get-lbp: func [token] [0]
			get-nud: func [token [any-type!]][
				none? get-rest token [exit]
				compose [(token/value)]
			]	
		]

		all [
			[2] = tdop-parser/evaluate 'value [1 2]
			1 = value
		]
	]

	[{Follows tokenising behaviour for rest.}

		[] = tdop-parser/evaluate 'value [1]
	]

	[{Follows tokenising behaviour for tail.}

		none? tdop-parser/evaluate 'value []
	]

	[{Can match next token.}

		tdop-parser: tdop [
			get-lbp: func [token] [0]
			get-nud: func [
				token [any-type!]
			][

				none? get-rest token [exit]

				if 'if = :token/value [
					return [
						use [code value][
							cond: recurse 0
							if not 'then = :current/value [
								do make error! {Expected THEN.}
							]
							advance
							value: recurse 0
							if cond [?? value]
						]
					]
				]

				compose [(token/value)]
			]	
		]

		all [
			[] = tdop-parser/evaluate 'value [if 1 then 2]
			2 = value
		]
	]
]
