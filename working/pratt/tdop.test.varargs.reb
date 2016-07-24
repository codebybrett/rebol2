REBOL []

do %tdop.reb

requirements 'TDOP [

	[{Support variadic functions.}

		tdop-parser: tdop [


			get-lbp: func [token] [

                either '+ = :token/value [10][0]
            ]
    

			get-led: func [token] [

                if not ('+ = :token/value) [exit]

                [
					compose [add (left) (recurse lbp)]
                ]
            ]
    

			get-nud: func [
				token [any-type!]
			][

				if none? get-rest token [
                    return [[]]
                ]

                if number? :token/value [
                    return compose [(:token/value)]
                ]

                if not find/match form :token/value charset [#"a" - #"z"] [
                    exit
                ]

                [
                    either rbp < 90 [

                        use [varargs arg][

                            varargs: collect [
                                while [
                                    not none? get-rest current
                                    not unset? set/any 'arg recurse/opt 90
                                ][
                                    keep :arg
                                ]
                            ]

                            compose/only [INVOKE (:this/value) (varargs)]
                        ]
                    ][

                        (:token/value)
                    ]
                ]
			]
		]

		all [
            [] = tdop-parser/evaluate 'value [1 + a b c + 2]
			[add add 1 INVOKE a [b c] 2] = value
		]
	]
]
