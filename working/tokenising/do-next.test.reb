REBOL []

do %../requirements.r
do %do-next.reb

requirements 'do-next [

	[
        all [
            [] = do-next 'token ['x]
            'x = token
        ]
    ]
]
