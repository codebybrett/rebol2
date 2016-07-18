REBOL []

do %../requirements.r
do %all-tokens.reb

requirements 'all-tokens [

	[
		user-error {Expected at least one tokeniser specified.} [
			all-tokens 'x []
		]
	]

	[
		user-error {Tokenisers must be specified with a get-word.} [
			all-tokens 'x [1]
		]
	]

	[
		tokeniser: all-tokens 'x [:set-next :set-next]
		all [
			none? tokeniser 'token [1] ; Failed.
			[] = tokeniser 'token [1 2] ; Succeeded.
			[1 2] = token
		]
	]
]
