REBOL []

do %../requirements.r
do %foreach-token.reb
do %set-next.reb

requirements 'foreach-token [

    [
        none? foreach-token 'token :set-next [] []
    ]

	[
        [1 2 3] = collect [foreach-token 'token :set-next [1 2 3] [keep token]]
	]

	[
		[2 3] = foreach-token 'token :set-next [1 2 3] [break]
	]
]
