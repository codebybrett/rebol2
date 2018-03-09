REBOL [
    Title: "Read-Deep Tests"
    Rights: {
        Copyright 2018 Brett Handley
    }
    License: {
        Licensed under the Apache License, Version 2.0
        See: http://www.apache.org/licenses/LICENSE-2.0
    }
    Author: "Brett Handley"
    Purpose: {Test READ-DEEP.}
]

script-needs [
	%requirements.r
    %../read-deep.r
]


read-deep-test: requirements 'read-deep [

    [found? files: read-deep %../]
    [found? find files %read-deep.r]
    [found? find files %test/read-deep.test.r]
]


read-tree-test: requirements 'read-tree [

    [
        quote (%"" %./) = first read-tree %./
    ]

    [
        found? find/only read-tree %./ quote (%./ %read-deep.test.r)
    ]
]


file-tree-test: requirements 'file-tree [

    [
        %./ = first file-tree %./
    ]

    [
        found? find file-tree %./ %read-deep.test.r
    ]
]


requirements %read-deep.r [

    ['passed = last read-deep-test]
    ['passed = last read-tree-test]
    ['passed = last file-tree-test]
]