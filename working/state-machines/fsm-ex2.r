REBOL []

; Finite state machine example.
; https://barrgroup.com/Embedded-Systems/How-To/State-Machines-Event-Driven-Systems

; Something to play with when considering implementation
; This is a rebol version - inspriration: "events as instructions".

; Trello card has more links.

cmt: funct [value][print compose [{  ;} (value)]]

keyboard: context [

    states: context [

        keyboard-initial: context [
            initialise: funct [][
                cmt "Keyboard initialised."
                set-state 'keyboard-default
            ]
        ]

        keyboard-default: context [
            key: funct [char] [probe lowercase char]
            shift-depressed: funct [][
                cmt "Shift depressed."
                set-state 'keyboard-shifted
            ]
        ]

        keyboard-shifted: context [
            key: funct [char] [probe uppercase char]
            shift-released: funct [][
                cmt "Shift released."
                set-state 'keyboard-default
            ]
        ]
    ]

    set-state: funct ['target][
        cmt {Transition.}
        cmt [{State: } target]
        set 'keyboard-state :target
    ]

    dispatch: funct [evt][
        probe evt
        if not action: all [
            state: get in states keyboard-state
            in state evt/1
        ][
            make error! join {Invalid transition from state } form keyboard-state
        ]
        do/next bind evt state
    ]

    keyboard-state: 'keyboard-initial
]

; Exercise the keyboard...
foreach event [
    [initialise]
    [shift-depressed]
    [key #"a"]
    [key #"b"]
    [shift-released]
    [key #"c"]
][
    keyboard/dispatch :event
]

halt