=begin overview

This is the grammar for Epsilon in Perl 6 rules.

=end overview

grammar Epsilon::Grammar is HLL::Grammar;

token TOP {
    ^ <hashbang>?
    <.begin_TOP>
    <expression>
    [ $ || <.panic: "Syntax error"> ]
}

token begin_TOP {
    <?>
}

token hashbang {
    '#!' \N*
}

## Lexer items

# This <ws> rule treats ## and # followed by whitespace as "comment to eol" and
# #* .. *# as a (potentially) multi-line comment.
token ws {
    <!ww>
    [ '#*' .*? '*#'
    | '#' [ '#' | \s ] \N* \n?
    | <.pod>
    | \s+ ]*
}

# Ignore embedded Plain Old Documentation (loose syntax, both old- and new-style
# endings).
token pod {
    ^^ '=' <ident> $$
    .*?
    ^^ [ '=cut' | '=end' ] [ \s | $$ ]
}

## Expressions

rule expression {
    <EXPR> | <void>
}

token void { }

## Operators

INIT {
    Epsilon::Grammar.O(':prec<q>, :assoc<unary>', '%member');
    Epsilon::Grammar.O(':prec<p>, :assoc<unary>', '%postcircumfix');
    Epsilon::Grammar.O(':prec<p>, :assoc<unary>', '%unary-applicative');
    Epsilon::Grammar.O(':prec<o>, :assoc<unary>', '%unary-count');
    Epsilon::Grammar.O(':prec<n>, :assoc<unary>', '%unary-negative');
    Epsilon::Grammar.O(':prec<n>, :assoc<unary>', '%unary-not');
    Epsilon::Grammar.O(':prec<m>, :assoc<left>',  '%applicative');
    Epsilon::Grammar.O(':prec<e>, :assoc<left>',  '%multiplicative');
    Epsilon::Grammar.O(':prec<d>, :assoc<left>',  '%additive');
    Epsilon::Grammar.O(':prec<a>, :assoc<left>',  '%comparative');
    Epsilon::Grammar.O(':prec<S>, :assoc<list>',  '%list');
    Epsilon::Grammar.O(':prec<R>, :assoc<right>', '%cons');
    Epsilon::Grammar.O(':prec<R>, :assoc<left>',  '%cons-left');
    Epsilon::Grammar.O(':prec<P>, :assoc<left>',  '%conjunctive');
    Epsilon::Grammar.O(':prec<O>, :assoc<left>',  '%disjunctive');
    Epsilon::Grammar.O(':prec<M>, :assoc<right>', '%applicative-low');
    Epsilon::Grammar.O(':prec<I>, :assoc<unary>', '%unary-function');
    Epsilon::Grammar.O(':prec<I>, :assoc<right>', '%function');
    Epsilon::Grammar.O(':prec<F>, :assoc<right>', '%assign');
    Epsilon::Grammar.O(':prec<1>, :assoc<right>', '%sequencing');
}

token postcircumfix:sym<[ ]> {
    '[' <expression> [ ']' || <.panic: "Expected ']'"> ]
    <O('%postcircumfix')>
}

token postfix:sym<!> {
    <sym> <!before '='> # don't match in '!='
    <O('%unary-applicative')>
}

token prefix:sym('#') { <sym> <O('%unary-count')> }

token prefix:sym<+> { <sym> <O('%unary-negative')> }
token prefix:sym<-> { <sym> <O('%unary-negative')> }

token prefix:sym<¬> { <sym> <O('%unary-not')> }

token infix:sym<@>  { <sym> <O('%applicative')> }

token infix:sym<*>  { <sym> <O('%multiplicative')> }
token infix:sym</>  { <sym> <O('%multiplicative')> }

token infix:sym<+>  { <sym> <O('%additive')> }
token infix:sym<->  { <sym> <O('%additive')> }
token infix:sym<~>  { <sym> <O('%additive')> }

token infix:sym«<»  { <sym> <O('%comparative, :pasttype<chain>')> }
token infix:sym«>»  { <sym> <O('%comparative, :pasttype<chain>')> }
token infix:sym«<=» { <sym> <O('%comparative, :pasttype<chain>')> }
token infix:sym«>=» { <sym> <O('%comparative, :pasttype<chain>')> }
token infix:sym«==» { <sym> <O('%comparative, :pasttype<chain>')> }
token infix:sym«!=» { <sym> <O('%comparative, :pasttype<chain>')> }

token infix:sym<,>  { <sym> <O('%list')> }

token infix:sym«>>» { <sym> <O('%cons')> }

token infix:sym«<<» { <sym> <O('%cons-left')> }

token infix:sym<&&> { <sym> <O('%conjunctive, :pasttype<if>')> }

token infix:sym<||> { <sym> <O('%disjunctive, :pasttype<unless>')> }

token infix:sym<$>  { <sym> <O('%applicative-low')> }

token prefix:sym«->» {
    <sym> <.begin_function>
    <O('%unary-function')>
}

token infix:sym«->» {
    <sym> <.begin_function>
    <O('%function')>
}

token infix:sym<=>  { <sym> <O('%assign, :pasttype<bind>')> }

token begin_function {
    <?>
}

token infix:sym<;>  { <sym> <O('%sequencing')> }

## Terms

rule function_call {
    <invocant> [ <factor> <.ws> ]+
}

rule term:sym<function_call> {
    <function_call>
}

rule term:sym<factor> {
    <factor>
}

## Factors

proto token factor { <...> }

token factor:sym<( )> {
    '(' <.ws> <expression> [ ')' || <.panic: "Expected ')'"> ]
}

token factor:sym<{ }> {
    '{' <!before '{'>
        <.begin_block>
        <.ws> <expression>
    [ '}' || <.panic: "Expected '}'"> ]
}

token begin_block {
    <?>
}

token identifier {
    $<identifier>=[ <quoted_identifier> | <ident> ** <[\'\-]>* <[\']>* ]
}

token quoted_identifier {
    '«' $<identifier>=<-[\n»]>* [ '»' || <.panic: "Expected '»'"> ]
}

token variable {
    <identifier>
}

token factor:sym<parameter> {
    <variable> <?before <.ws> '->'>
}

token factor:sym<variable> {
    <variable> <!before <.ws> '->'>
               <!before <.ws> '.'>
}

# class definition
rule factor:sym<{{ }}> {
    '{{'
        <.begin_function>
        <class_body>
    [ '}}' || <.panic: "Expected '}}'"> ]
}

rule class_body {
    <variable> ** ';'
}

token factor:sym<.> {
    <object_variable>
}

# match before «==» but not before «=»
token object_variable {
    <variable> [ '.' <identifier> <!before <.ws> '=' <-[=]>> ]*
}

token factor:sym<. => {
    <object_variable> [ '.' <identifier> ] <.ws> '=' <.ws> $<value>=<term>
}

token sign { '+' | '-' }
token factor:sym<integer> { <sign>? <integer> <!before '.'> }
token factor:sym<float> {
    <sign>? [ \d+ '.' \d* | \d* '.' \d+ ]
}
token factor:sym<quote> { <quote> }

proto token quote { <...> }
token quote:sym("'") { <?[\']> <quote_EXPR: ':q'> }
token quote:sym('"') { <?[\"]> <quote_EXPR: ':qq'> }

token quote_atom {
    <!stopper>
    [
    | <quote_escape>
    | [ <-[\\]-stopper> ]+
    ]
}

token quote_escape:sym<interpolation> {
    \\ '{' <?quotemod_check('b')>
        [ <void> <?before '}'>
        | <expression>
        ]
    [ '}' || <.panic: "Expected '}' in string interpolation"> ]
}

## Invocants

proto token invocant { <...> }

token invocant:sym<variable> {
    <variable>
}

token invocant:sym<( )> {
    '(' <.ws> <expression> [ ')' || <.panic: "Expected ')'"> ]
}

token invocant:sym<{ }> {
    '{' <!before '{'>
        <.begin_block>
        <.ws> <expression>
    [ '}' || <.panic: "Expected '}'"> ]
}

rule invocant:sym<{{ }}> {
    '{{'
        <.begin_function>
        <class_body>
    [ '}}' || <.panic: "Expected '}}'"> ]
}

token invocant:sym<.> {
    <object_variable>
}

token invocant:sym<integer> { <sign>? <integer> <!before '.'> }
token invocant:sym<float> {
    <sign>? [ \d+ '.' \d* | \d* '.' \d+ ]
}
