REBOL []

do %../requirements.r
do %tdop.reb

requirements %tdop.test.reb [

    ['passed = last do %tdop.test.basic.reb]
    ['passed = last do %tdop.test.evaluation.reb]
    ['passed = last do %tdop.test.matching.reb]
    ['passed = last do %tdop.test.varargs.reb]
    ['passed = last do %tdop.test.Lsample.reb]
]
