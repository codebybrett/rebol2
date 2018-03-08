REBOL []

; Conversion from HSM example in "State Oriented Programming" pdf.
; Removed some redundancy.

; This machine is a subset of UML statecharts.

; Start, Enter and Exit actions are implemented as events.
; Note that event (and args) could be saved in hsm rather than passed around.

cmt: funct [value][print compose [{  ;} (value)]]

state: context [
    name: none
    super: none
    handler: none
]

hsm: context [
    name: none
    current-state: none
    target-state: none ;; Was next-state
    top-state: none
]

msg: funct [
    {Message function.}
    hsm value
][]

StateCtor: funct [
    {HSM Constructor.}
    me name super handler
][
    me/name: name
    me/super: super
    me/handler: :handler
 ]

; ----------------------------------------------------------------
; HSM engine.
; ----------------------------------------------------------------

HsmCtor: funct [
    {HSM Constructor.}
    me name topHandler
][
    me/top-state: make-state
    StateCtor me/top-state "top" none :topHandler
    me/name: name
]

HsmOnStart: funct [
    {Enter and start the top state.}
    me
][
    entryPath: copy []

    ;; Enter top state.
    HsmFinaliseTransition me me/top-state
    doStateEvent me/current-state me #enter-action

    ;; When the state starts it may make an initial transition to a nested sub state,
    ;; which in turn needs to be started.
    while [
        doStateEvent me/current-state me #initial-transition
        me/target-state
    ][
        ;; Process initial transition.

        ;; Enter each psuedostate inwards, including target.
        HsmEnterSubstates me me/target-state entryPath

        ;; Set target sub state as current.
        HsmFinaliseTransition me me/target-state
    ]
    cmt [me/name {has completed startup.}]
]

HsmOnEvent: funct [
    {Dispatch event to relevant state.}
    me msg
][
    entryPath: copy []

    ;; Move through state hierarchy until event is handled.

    st: me/current-state
    while [st][

        ;; Handle the event with the state handler.
        ;; UML statecharts require the event to be the original event.
        ;; Possibly one could return a different event to communicate exceptions.
        msg: doStateEvent st me msg

        if none? msg [

            ;; Event has been processed.
            ;; The state may have requested a transition in response to the event.
            if me/target-state [

                ; State transition required.

                ;; Enter each state inwards to target.
                HsmEnterSubstates me me/target-state entryPath

                ;; Set target sub state as current.
                HsmFinaliseTransition me me/target-state

                ;; When the state starts it may make an initial transition to a
                ;; nested sub state, which in turn needs to be started.
                while [
                    doStateEvent me/current-state me #initial-transition
                    me/target-state
                ][
                    ;; Enter each state inwards to super of target.
                    HsmEnterSubstates me me/target-state/super entryPath

                    ;; Set target state as current.
                    HsmFinaliseTransition me me/target-state
                ]
            ]

            break ; Event processed
        ]

        ;; Move outwards to super state to process the event.
        st: st/super
    ]
]

HsmToLca: funct [
    {Find # of levels to Least Common Ancestor.}
    me target
][
    toLca: 1

    ;; Find LCA.

    ;; For each ancestor of this state, see if
    ;; we can find an ancestor of target that matches.

    st: me/current-state/super
    while [st][

        tgt: target
        while [tgt][

            if same? :st :tgt [
                RETURN toLca
            ]

            tgt: tgt/super
        ]

        toLca: toLca + 1
        st: st/super
    ]

    0 ; Not found.
]

HsmExit: funct [
    {Exit # of levels of state.}
    me toLCA
][
    st: me/current-state
    while [toLCA > 0][
        doStateEvent st me #exit-action
        toLCA: toLCA - 1
        st: st/super
    ]
    me/current-state: st
]

;; Helper routines ------------------

HsmFinaliseTransition: funct [
    {This ends the transition to the target state.}
    me target-state
][
    me/current-state: target-state
    me/target-state: none

    cmt [{State} me/current-state/name {ready.}]
]

HsmEnterSubstates: funct [
    {Enter states on path from current.}
    me target-state entryPath
][
    clear entryPath

    ;; Trace the states on the path outwards from target to current.
    st: target-state
    while [st <> me/current-state][
        append entryPath st
        st: st/super
    ]

    reverse entryPath

    ;; Enter each state on path inwards from current to target.
    ;; The enter event allows a state to allocate resources.
    foreach st entryPath [
        doStateEvent st me #enter-action
    ]
]

doStateEvent: funct [
    me ctx msg
][
    cmt [{Event:} ctx/name me/name :msg]
    me/handler :ctx :msg
]

; ----------------------------------------------------------------
; State transition functions
; - call from state handler to make a transition
; ----------------------------------------------------------------

;; Used by state handler to make initial transition to sub state.
transition-into: funct [
    {Transition into target sub state.}
    me target
][
    assert [none? me/target-state]
    me/target-state: :target
]

;; Used by state handler to transition to new state.
transition-to: funct [
    {Transition to target state.}
    me target static-lca
][
    cmt [{Transition to} target/name]

    ;; Must not be mid transition.
    assert [none? me/target-state]

    ;; For any given transition the LCA needs to be calculated only once for the source
    ;; and target combination. It is characteristic of the Hsm (sub)class rather than
    ;; individual state machine objects.
    ;; The original C code uses a macro to stores this static variable in the state's
    ;; handler code section that encodes/handles the transition.
    ;; To achieve a similar effect here I use a third argument to transition-to to hold
    ;; the static structure.

    if zero? static-lca/1 [
        static-lca/1: HsmToLca me target
    ]

    ;; Exit state levels outwards to least common ancestor
    HsmExit me static-lca/1

    ;; Set transition target.
    me/target-state: :target
]

; -----------------------------------------------
; Watch definition
; -----------------------------------------------

WatchCtor: funct [me][

    HsmCtor me "Watch" :watch_top

    StateCtor me/timekeeping "timekeeping" me/top-state :Watch_timekeeping

    StateCtor me/time "time" me/timekeeping :Watch_time
    StateCtor me/date "date" me/timekeeping :Watch_date

    StateCtor me/setting "setting" me/top-state :Watch_setting

    StateCtor me/hour "hour" me/setting :Watch_hour
    StateCtor me/minute "minute" me/setting :Watch_minute
    StateCtor me/day "day" me/setting :Watch_day
    StateCtor me/month "month" me/setting :Watch_month

    do bind [
        tsec: tmin: thour: 0
        dday: dmonth: 1
        tkeepingHist: none
    ] me
]

Watch_top: funct [me event][
    switch event [
        #initial-transition [
            transition-into me me/setting
            return none
        ]
        #enter-action [
            return none
        ]
        #exit-action [
            return none
        ]
    ]

    cmt [{Unhandled event:} me/current-state/name event]

    return none ; Top always handles everything.
]

Watch_timekeeping: funct [me event][
    switch event [
        #initial-transition [
            ; Display most recently selected information: time or date,
            ; default to time.
            transition-into me either me/tkeepingHist [me/tkeepingHist][me/time]
            return none
        ]
        #set_evt [
            transition-to me me/setting [0] ; block simulates static variable.
            return none
        ]
        #tick_evt [
            cmt "tick."
            return none
        ]
        #exit-action [
            me/tkeepingHist: me/current-state
            return none
        ]
    ]

    event ; Unhandled event.
]

Watch_time: funct [me event][
    switch event [
        #tick_evt [
            probe now/time
            return none
        ]
        #set_evt [
            transition-to me me/date [0] ; block simulates static variable.
            return none
        ]
    ]
    event ; Unhandled event.
]

Watch_date: funct [me event][
    switch event [
        #tick_evt [
            probe now/date
            return none
        ]
        #set_evt [
            transition-to me me/time [0] ; block simulates static variable.
            return none
        ]
    ]
    event ; Unhandled event.
]

Watch_setting: funct [me event][
    switch event [
        #initial-transition [
            transition-into me me/hour
            return none
        ]
    ]
    event ; Unhandled event.
]

Watch_hour: funct [me event][
    switch event [
        #mode_evt [
            do bind [
                thour: thour + 1
                ?? thour
            ] me
            return none
        ]
        #set_evt [
            transition-to me me/minute [0] ; block simulates static variable.
            return none
        ]
    ]
    event ; Unhandled event.
]

Watch_minute: funct [me event][
    switch event [
        #mode_evt [
            do bind [
                tmin: tmin + 1
                ?? tmin
            ] me
            return none
        ]
        #set_evt [
            transition-to me me/day [0] ; block simulates static variable.
            return none
        ]
    ]
    event ; Unhandled event.
]

Watch_day: funct [me event][
    switch event [
        #set_evt [
            transition-to me me/month [0] ; block simulates static variable.
            return none
        ]
    ]
    event ; Unhandled event.
]

Watch_month: funct [me event][
    switch event [
        #set_evt [
            transition-to me me/timekeeping [0] ; block simulates static variable.
            return none
        ]
    ]
    event ; Unhandled event.
]

make-state: does [make state []]

watch: make hsm [

    ; HSM Superclass
    super: none

    ; properties.
    tsec: tmin: thour: dday: dmonth: none

    ; States.
    timekeeping: make-state
    time: make-state
    date: make-state

    setting: make-state

    hour: make-state
    minute: make-state
    day: make-state
    month: make-state

    tkeepingHist: none
]

WatchCtor watch
HsmOnStart watch

;; Run watch...
HsmOnEvent watch #mode_evt
HsmOnEvent watch #set_evt
HsmOnEvent watch #mode_evt
HsmOnEvent watch #mode_evt
HsmOnEvent watch #set_evt
HsmOnEvent watch #set_evt
HsmOnEvent watch #set_evt
HsmOnEvent watch #set_evt


HALT