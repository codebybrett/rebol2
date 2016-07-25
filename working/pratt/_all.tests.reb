REBOL []

do %../requirements.r
do %tdop.reb

tests: read %./
remove-each test tests [not parse/all test [thru %.test.reb]]

requirements %_all.tests.reb map-each test tests [
    compose ['passed = last do (test)]
]
