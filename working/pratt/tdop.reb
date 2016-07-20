REBOL [
	Title: {Pratt/TDOP Parsing}
	Purpose: "Top Down Operator Precedence Parsing."
	File: %tdop.r
	Date: 17-Jul-2016
	Version: 1.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	License: {

		Copyright 2016 Brett Handley

		Licensed under the Apache License, Version 2.0 (the "License");
		you may not use this file except in compliance with the License.
		You may obtain a copy of the License at

			http://www.apache.org/licenses/LICENSE-2.0

		Unless required by applicable law or agreed to in writing, software
		distributed under the License is distributed on an "AS IS" BASIS,
		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		See the License for the specific language governing permissions and
		limitations under the License.
	}
]

; ----------------------------------------------------------------------------------------------------------------------
;
; TDOP - Top Down Operator Precedence parsing.
;
; See tdop.tests.r for implemented functionality and some examples.
;
; References:
;
;	Top Down Operator Precedence (Vaughan R. Pratt)
;	- http://web.archive.org/web/20151223215421/http://hall.org.ua/halls/wizzard/pdf/Vaughan.Pratt.TDOP.pdf
;	- https://tdop.github.io/ (remastered version of the above)
;
;	Top-Down operator precedence parsing (Eli Bendersky)
;	- http://eli.thegreenplace.net/2010/01/02/top-down-operator-precedence-parsing/
;
;	Pratt Parsers: Expression Parsing Made Easy (Bob Nystrom)
;	- http://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/
;
;	Top Down Operator Precedence (Douglas Crockford)
;	- http://javascript.crockford.com/tdop/tdop.html
;   -- Note the commentary on statements in the above and at https://pythonhosted.org/PrattParse/tutorial.html#adding-statements
;
;	A Monadic Pratt Parser (Matthew Manela) - see discussion of someFunction.
;	- matthewmanela.com/blog/a-monadic-pratt-parser/
;	-- (for background on function call syntax in haskell see https://www.fpcomplete.com/school/starting-with-haskell/basics-of-haskell/function-application)
;
; ----------------------------------------------------------------------------------------------------------------------


do %../tokenising/set-next.reb

;
; The algorithm here aims to be a forward only parser and not mandate any particular method of token
; representation except the requirement to have a separate end token whose end position (REST) is none.

tdop: func [
    token-spec [block!] {Token definition.}
][

    context [

        current: none ; Represents token.
        lookahead: none; Next token.

        lbp: none ; Left Binding Power

        advance: func [
            {Advance to next token. Set current from lookahed, load lookahead.}
        ][
            set/any 'current get/any 'lookahead
            set/any 'lookahead token/get-next :lookahead
            current
        ]

        evaluate: func [
            {Evaluate expression and return end position.}
            word [word!] {Word set to the value of the evaluated expression.}
            input {Input to parse.}
            /local result
        ] [

            unset [current lookahead]
            lookahead: token/initialise input

            advance ; Prime lookahead.

            set/any word recurse 0

            token/get-rest :current
        ]

        recurse: func [
            {Parses expression at binding power and above.}
            rbp [integer!] {Right Binding Power.}
            /local left
        ][

            advance
            unset reduce [
                'left
                in token 'code
            ]

            set/any in token 'code token/get-nud :current
            if not value? in token 'code [
                do make error! rejoin [{Cannot begin an expression with } mold current]
            ]

            set/any 'left token/run 'rbp

            ; Process any remaining expression tokens.
            while [
                lbp: either any [
                    not value? 'lookahead
                    none? token/get-rest :lookahead
                ] [
                    0 ; End token shall not be processed within the loop.
                ][
                    token/get-lbp :lookahead
                ]
                lbp > rbp ; Assumes that no binding power will be less than zero.
            ] [

                advance

                set/any in token 'code token/get-led :current
                if not value? in token 'code [
                    do make error! rejoin [
                        {Operator } mold current { does not define how to process it's left argument.}
                    ]
                ]

                set/any 'left token/run 'rbp
            ]

            ; Return the value of the expression.
            RETURN get/any 'left
        ]

        ;
        ; Token definition.
        ;

        token: make context [

            code: none ; Code used to evaluate a token.

            ;
            ; Default tokeniser - just take next value from a block as the token.

            get-next: func [
                {Fetch token following this.}
                token {Represents a token.}
                /local value position
            ][
                if none? position: get-rest token [exit]
                make token [
                    rest: set-next 'value position
                ]
            ]

            ;
            ; Default token rest.

            get-rest: func [
                {Get rest of input.}
                token {Represents a token.}
            ][
                token/rest
            ]

            ;
            ; Default beginning (head) token - initialise with input.

            initialise: func [
                {Initialise to before first token.}
                position
            ][
                context [
                    value: none
                    rest: :position
                ]
            ]

            ;
            ; Default token code evaluator - just DO the code.

            run: func [
                {Evaluate code of the token. Position likely to be advanced.}
                ctx {Parser context.}
            ] [
                do bind/copy code ctx
            ]

        ] bind token-spec self
    ]
]
