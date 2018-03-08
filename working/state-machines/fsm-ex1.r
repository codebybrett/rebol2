REBOL []

; Finite state machine example.
; https://barrgroup.com/Embedded-Systems/How-To/State-Machines-Event-Driven-Systems

; Something to play with when considering implementation.
; Basic port of example.

fsm: context [
    state: none
]

fsm-init: funct [me evt][
    print "Initialise."
    me/state me evt
]

fsm-dispatch: funct [me evt][
    print "Dispatch."
    me/state me evt
]

fsm-trans: funct [me target][
    print "Transition."
    me/state: :target
]

keyboard-initial: funct [keyboard event][
    print "Keyboard initialised."
    fsm-trans keyboard :keyboard-default
]

keyboard-default: funct [keyboard event][
    if char? :event [
        probe lowercase event
        return
    ]
    switch event [
        #shift-depressed [
            print "Shift depressed."
            fsm-trans keyboard :keyboard-shifted
        ]
    ]
]

keyboard-shifted: funct [keyboard event][
    if char? :event [
        probe uppercase event
        return
    ]
    switch event [
        #shift-released [
            print "Shift released."
            fsm-trans keyboard :keyboard-default
        ]
    ]
]

keyboard: make fsm [state: :keyboard-initial]
fsm-init keyboard none

; Exercise the keyboard...
foreach event [
    #shift-depressed
    #"a"
    #"b"
    #shift-released
    #"c"
][
    fsm-dispatch keyboard :event
]

halt