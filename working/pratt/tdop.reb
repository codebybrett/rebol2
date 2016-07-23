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


;
; The algorithm here aims to be a forward only parser and not mandate any particular method of token
; representation except the requirement to have a separate end token whose end position (REST) is none.

tdop: func [
    token-spec [block!] {Token definition.}
][

    context [

        evaluate: func [
            {Evaluate expression and return end position.}
            word [word!] {Word set to the value of the evaluated expression.}
            input {Input to parse.}
            /local
            current ; Represents token.
            advance
            recurse
            parser
            token-at ; Position of current token.
        ] [

            advance: func [
                {Advance to the next token.}
            ][
                token-at: if value? 'current [token/get-rest :current]
                set/any 'current token/get-next get/any 'current
            ]

            recurse: func [
                {Parses expression at binding power and above.}
                rbp [integer!] {Right Binding Power.}
                /local left code lbp parser
            ][

                parser: func [
                    {Bind code to parser environment.}
                    code
                ][
                    bind bind code 'recurse 'rbp
                ]

                unset [left]

                set/any 'code token/get-nud :current
                if not value? 'code [
                    do make error! rejoin [{Cannot begin an expression with } mold current]
                ]

                advance

                set/any 'left token/interpret code :parser
                ; Position could be advanced by code.

                ; Process any remaining expression tokens.
                while [
                    lbp: either any [
                        not value? 'current
                        none? token/get-rest :current
                    ] [
                        0 ; End token shall not be processed within the loop.
                    ][
                        token/get-lbp :current
                    ]
                    lbp > rbp ; Assumes that no binding power will be less than zero.
                ] [

                    set/any 'code token/get-led :current
                    if not value? 'code [
                        do make error! rejoin [
                            {Operator } mold current { does not define how to process it's left argument.}
                        ]
                    ]

                    advance ; Next token in expression becomes current.

                    set/any 'left token/interpret code :parser
                    ; Position could be advanced by code.
                ]

                ; Return the value of this expression.
                RETURN get/any 'left
            ]

            ;
            ; Process a single expression.

            unset [token-at current]
            set/any 'current token/initialise input ; Prime the stream.
            advance ; Load Current.

            set/any word recurse 0

            token-at
        ]

        ;
        ; Token definition.
        ;

        token: make context [

            ;
            ; Default tokeniser - just take next value from a block as the token.

            get-next: func [
                {Fetch token following this.}
                token {Represents a token.}
                /local position
            ][

                if any [
                    none? position: get-rest token
                ] [
                    return context [rest: none]
                ]

                make token [
                    rest: (
                        either tail? position [
                            none ; End token.
                        ][
                            set/any 'value first position
                            next position
                        ]
                    )
                    ; value field in object is set.
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
                    (unset 'value)
                ]
            ]

            ;
            ; Default token code evaluator - just DO the code in the context of the parser.

            interpret: func [
                {Evaluate the semantic code of the token relative to the parser environment.}
                code {Semantic code of the token.}
                parser
            ] [
                do parser code
            ]

        ] bind token-spec self
    ]
]
