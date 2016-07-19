REBOL []

do %../requirements.r
do %each-token.reb

requirements 'each-token [

	[
		tokeniser: each-token 'x :set-next [2 * x]
		unset 'x
		all [
			[] = tokeniser 'token [1] ; Positioned at tail.
			2 = token ; Result of evaluation of block.
			not value? 'x ; Must be a local.
		]
	]

	[ {Handles unset return from block.}
		tokeniser: each-token 'x :set-next []
		all [
			none? tokeniser 'token []
			[] = tokeniser 'token [1]
		]
	]
]
