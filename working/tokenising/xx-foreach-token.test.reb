REBOL []

do %../requirements.r
do %foreach-token.reb
do %set-next.reb

requirements 'tokenise [

	[
		user-error {Expected at least one token definition.} [
            foreach-token [] [] []
        ]
	]

	[
		[] = collect [foreach-token [a: :set-next] [] [keep a]]
	]

	[
		[foreach-token [a: :set-next b: :set-next] [1 2 3] [keep/only reduce [a b]]]
	]

	[
		[1 2] = tokenise :set-next [1 2]
	]
]
