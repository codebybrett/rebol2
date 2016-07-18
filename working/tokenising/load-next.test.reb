REBOL []

do %../requirements.r
do %load-next.reb

requirements 'load-next [

	[
        all [
            {} = load-next 'token {x}
            'x = token
        ]
    ]
]
