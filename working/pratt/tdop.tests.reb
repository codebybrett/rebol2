REBOL []

do %../requirements.r
do %tdop.reb

requirements %tdop.tests.reb [

	['passed = last do %tdop.test.basic.reb]
	['passed = last do %tdop.test.matching.reb]
	['passed = last do %tdop.test.varargs.reb]
]
