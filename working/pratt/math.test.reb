REBOL [
	Title: "Math Tests"
	Rights: {
		Copyright 2016 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Test MATH.}
]

do %../requirements.r
do %math.reb

requirements 'math [

	[
		user-error {Expected an expression.} [math []]
	]

	[
		user-error {Expected number.} [math [{x}]]
	]

	[
		user-error {Expected a single expression.} [math [1 2]]
	]

	[
		{Single value.}
		1 = math [1]
	]

	[
		{Complex expression.}
		19 = math [1 + 2 * 3 ** 2]
	]
]