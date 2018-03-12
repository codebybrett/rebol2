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
    doEvent: none
]

hsm: context [
    name: none
    current-state: none
    target-state: none ;; Transition target.
    top-state: none
    state-path: none ;; Static buffer var.
    event: none ;; To allow assertion into transition-into.
]

msg: funct [
    {Message function.}
    hsm value
][]

make-state: does [
    make state []
]

StateCtor: funct [
    {HSM Constructor.}
    me name super handler
][
    me/name: name
    me/super: super
    me/doEvent: :handler
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
    me/current-state: me/top-state
    doStateEvent me/current-state me #enter-action
    startState me
]

HsmOnEvent: funct [
    {Dispatch event to relevant state.}
    me msg
][
    ;; Move through state hierarchy until event is handled.

    st: me/current-state
    while [st][

        ;; Handle the event with the state handler.
        ;; UML statecharts require the event to be the original event.
        ;; Possibly one could return a different event to communicate exceptions.

        msg: doStateEvent st me msg

        if none? msg [

            ;; We found a state to handle the event.
 
            if me/target-state [

                ;; The state is part way through a transition in response to the event.
                ;; Old states below the least common ancestor have already been exited.

                doEntryActions me
                finaliseTransition me

                ;; State is started only after the transition has completed.
                startState me
            ]

            break ; Event processed
        ]

        ;; Event not processed.
        ;; Search outwards for a state to process the event.
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

;; Helper routines ------------------

finaliseTransition: funct [
    {This ends the transition to the target state.}
    me
][
    me/current-state: me/target-state
    me/target-state: none
]

HsmFindState: funct [
    {Return the number of levels the target is above current or none.}
    me target-state
][
    levels: 0

    ;; Find target in hierarchy.

    st: me/current-state
    while [st][

        if same? st target-state [
            RETURN levels
        ]

        levels: levels + 1
        st: st/super
    ]

    none ; Not found.
]

startState: funct [
    me
][
    ;; When started, the state may make an initial transition to a nested sub state.
    ;; The sub state may be more than 1 level below current.
    ;; Initial transitions are valid only for states targetted by a transition,
    ;; not every state entered.  An initial transition, may cause further
    ;; initial transitions.

    while [
        doStateEvent me/current-state me #start_evt
        me/target-state ; Is there a consequent initial transition?
    ][
        doEntryActions me
        finaliseTransition me
    ]
]

doEntryActions: funct [
    {Enter states on path from current.}
    me
][
    ;; Target may more than 1 level below current.
    ;; Calculate path from Current to target.

    clear me/state-path
    st: me/target-state
    while [st <> me/current-state][
        append me/state-path st
        st: st/super
    ]
    reverse me/state-path    

    ;; Enter each state on path inwards from current to target.
    ;; The enter action allows a state to allocate resources.

    foreach st me/state-path [
        doStateEvent st me #enter-action
    ]
]

exitToLca: funct [
    {Exit # of levels of state.}
    me toLCA
][
    ;; The exit action allows a state to deallocate resources.

    st: me/current-state
    while [toLCA > 0][
        doStateEvent st me #exit-action
        toLCA: toLCA - 1
        st: st/super
    ]
    me/current-state: st
]

doStateEvent: funct [
    me ctx msg
][
    cmt [{Event:} ctx/name me/name :msg]
    ctx/event: :msg
    me/doEvent :ctx :msg
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
    cmt [{Initial transition into} target/name]

    assert [none? me/target-state]
    assert [#start_evt = me/event] ; Needs special initial transition handling.

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
    ;; The original C code used a macro to store this static variable in the state's
    ;; handler code section that encodes/handles the transition.
    ;; To achieve a similar intent here I use a third argument to transition-to to hold
    ;; the static structure.

    if zero? static-lca/1 [
        static-lca/1: HsmToLca me target
    ]

    ;; Exit state levels outwards to least common ancestor
    exitToLca me static-lca/1

    ;; Set transition target.
    me/target-state: :target
]

; -----------------------------------------------
; Watch definition
; -----------------------------------------------

make-watch: does [
    make hsm [

        ; HSM Superclass
        super: none
        state-path: copy []

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
]

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
        #enter-action [
            return none
        ]
        #start_evt [
            transition-into me me/setting
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
        #display_evt [
            transition-to me me/setting [0] ; block simulates static variable.
            return none
        ]
        #tick_evt [
            cmt "tick."
            return none
        ]
        #start_evt [
            ; Display most recently selected information: time or date,
            ; default to time.
            transition-into me either me/tkeepingHist [me/tkeepingHist][me/time]
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
        #display_evt [
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
        #display_evt [
            transition-to me me/time [0] ; block simulates static variable.
            return none
        ]
    ]
    event ; Unhandled event.
]

Watch_setting: funct [me event][
    switch event [
        #start_evt [
            transition-into me me/hour
            return none
        ]
    ]
    event ; Unhandled event.
]

Watch_hour: funct [me event][
    switch event [
        #modify_evt [
            do bind [
                thour: thour + 1
                ?? thour
            ] me
            return none
        ]
        #display_evt [
            transition-to me me/minute [0] ; block simulates static variable.
            return none
        ]
    ]
    event ; Unhandled event.
]

Watch_minute: funct [me event][
    switch event [
        #modify_evt [
            do bind [
                tmin: tmin + 1
                ?? tmin
            ] me
            return none
        ]
        #display_evt [
            transition-to me me/day [0] ; block simulates static variable.
            return none
        ]
    ]
    event ; Unhandled event.
]

Watch_day: funct [me event][
    switch event [
        #display_evt [
            transition-to me me/month [0] ; block simulates static variable.
            return none
        ]
    ]
    event ; Unhandled event.
]

Watch_month: funct [me event][
    switch event [
        #display_evt [
            transition-to me me/timekeeping [0] ; block simulates static variable.
            return none
        ]
    ]
    event ; Unhandled event.
]

;; Create and start watch.

watch: make-watch
WatchCtor watch
HsmOnStart watch
assert [HsmFindState watch watch/setting] ; Check superstate.
assert ["hour" = watch/current-state/name]

;; Run watch with events.

HsmOnEvent watch #modify_evt
HsmOnEvent watch #modify_evt
assert ["hour" = watch/current-state/name]
assert [2 = watch/thour]

HsmOnEvent watch #display_evt
assert ["minute" = watch/current-state/name]

HsmOnEvent watch #display_evt
assert ["day" = watch/current-state/name]

HsmOnEvent watch #display_evt
assert ["month" = watch/current-state/name]

HsmOnEvent watch #display_evt
HsmOnEvent watch #tick_evt
assert [HsmFindState watch watch/timekeeping] ; Check superstate.
assert [not HsmFindState watch watch/setting]
assert ["time" = watch/current-state/name]

HsmOnEvent watch #display_evt
HsmOnEvent watch #tick_evt
assert ["date" = watch/current-state/name]

HsmOnEvent watch #display_evt
assert ["time" = watch/current-state/name]

HALT