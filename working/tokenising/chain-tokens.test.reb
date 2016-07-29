REBOL []

do %../requirements.r
do %chain-tokens.reb
do %set-next.reb

requirements 'chain-tokens [

	[
		user-error {Expected at least one tokeniser specified.} [
			chain-tokens 1 1 []
		]
	]

	[
		user-error {Tokenisers must be specified with a get-word.} [
			chain-tokens 1 1 [1]
		]
	]

	[ {Use first tokeniser only.}
		tokeniser: chain-tokens 1 1 [:set-next]
		all [
			[2] = tokeniser 'token [1 2] ; Success.
			[1] = token
		]
	]

	[ {Match one or two tokenisers.}
		tokeniser: chain-tokens 1 2 [:set-next :set-next]
		all [
			none? tokeniser 'token [1] ; Success.
			[] = tokeniser 'token [1 2] ; Success.
		]
	]

	[ {Match second to end.}
		tokeniser: chain-tokens 2 true [:set-next :set-next :set-next]
		all [
			none? tokeniser 'token [1] ; Failed - wants two in the chain.
			[] = tokeniser 'token [1 2] ; Success.
			[1 2] = token ; First tokeniser skipped.
		]
	]
]
