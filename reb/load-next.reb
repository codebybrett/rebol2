REBOL [
	Title: "Load-Next"
	Version: 1.0.0
	Rights: {
		Copyright 2015 Brett Handley

		Rebol3 load-next by Chris Ross-Gill, new signature by Brett Handley.
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Transition load/next from Rebol 2 to Rebol 3.}
]

either system/version > 2.100.0 [; Rebol3

	load-next: function [
		{Load the next value. Return block with value and new position.}
		word {Word set to represent each value. Will be unset at tail.}
		string [string!]
	] [
		out: transcode/next to binary! string
		out/2: skip string subtract length string length to string! out/2
		set/any word out/1
		out/2
	] ; by @rgchris.

] [; Rebol2

	load-next: func [
		{Set word to the next value, return the new position.}
		word {Word set to represent each value. Will be unset at tail.}
		position [string!] {Position in the REBOL source.}
		/local token
	][
		unset word
		if not tail? position [
			token: load/next position
			set/any word token/1
			position: token/2
		]
		position
	]
]

