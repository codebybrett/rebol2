REBOL []

do %../requirements.r
do %set-next.reb

requirements 'set-next [

	[
        all [
            [] = set-next 'token [x]
            'x = token
        ]
    ]
]
