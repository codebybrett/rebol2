REBOL []

do %requirements.r
do %tokenise.reb
do %set-next.reb

requirements 'tokenise [

	[
		[] = tokenise :set-next []
	]

	[
		[1 2] = tokenise :set-next [1 2]
	]

	[
		[1] = tokenise/part :set-next s: [1 2] next s
	]
]
