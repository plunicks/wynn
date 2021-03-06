=begin overview

This is the grammar for Wynn in Perl 6 rules.

=end overview

grammar Wynn::Grammar is HLL::Grammar;

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
    Wynn::Grammar.O(':prec<z>, :assoc<left>',  '%namespace-lookup');
    Wynn::Grammar.O(':prec<q>, :assoc<unary>', '%member');
    Wynn::Grammar.O(':prec<p>, :assoc<unary>', '%unary-applicative');
    Wynn::Grammar.O(':prec<o>, :assoc<unary>', '%unary-count');
    Wynn::Grammar.O(':prec<o>, :assoc<unary>', '%unary-flatten');
    Wynn::Grammar.O(':prec<n>, :assoc<unary>', '%unary-negative');
    Wynn::Grammar.O(':prec<n>, :assoc<unary>', '%unary-not');
    Wynn::Grammar.O(':prec<m>, :assoc<left>',  '%applicative');
    Wynn::Grammar.O(':prec<l>, :assoc<left>',  '%function-composition');
    Wynn::Grammar.O(':prec<k>, :assoc<left>',  '%combining-or');
    Wynn::Grammar.O(':prec<e>, :assoc<left>',  '%multiplicative');
    Wynn::Grammar.O(':prec<d>, :assoc<left>',  '%additive');
    Wynn::Grammar.O(':prec<a>, :assoc<left>',  '%comparative');
    Wynn::Grammar.O(':prec<S>, :assoc<list>',  '%list');
    Wynn::Grammar.O(':prec<R>, :assoc<right>', '%cons');
    Wynn::Grammar.O(':prec<R>, :assoc<left>',  '%cons-left');
    Wynn::Grammar.O(':prec<P>, :assoc<left>',  '%conjunctive');
    Wynn::Grammar.O(':prec<O>, :assoc<left>',  '%disjunctive');
    Wynn::Grammar.O(':prec<M>, :assoc<right>', '%applicative-low');
    Wynn::Grammar.O(':prec<I>, :assoc<unary>', '%unary-function');
    Wynn::Grammar.O(':prec<I>, :assoc<right>', '%function');
    Wynn::Grammar.O(':prec<I>, :assoc<right>', '%pair');
    Wynn::Grammar.O(':prec<F>, :assoc<right>', '%assign');
    Wynn::Grammar.O(':prec<F>, :assoc<left>',  '%assign-map');
    Wynn::Grammar.O(':prec<1>, :assoc<right>', '%sequencing');
}

token postfix:sym<!> {
    <sym> <!before '='> # don't match in '!='
    <O('%unary-applicative')>
}

token infix:sym<:>  { <sym> <O('%namespace-lookup')> }
token infix:sym<::> { <sym> <!before <identifier>> <O('%namespace-lookup')> }

token prefix:sym('#') { <sym> <O('%unary-count')> }

token prefix:sym<|> { <sym> <O('%unary-flatten')> }

token prefix:sym<+> { <sym> <O('%unary-negative')> }
token prefix:sym<-> { <sym> <O('%unary-negative')> }

token prefix:sym<¬> { <sym> <O('%unary-not')> }

token infix:sym<@>  { <sym> <O('%applicative')> }

token infix:sym<∘>  { <sym> <O('%function-composition')> }

token infix:sym<|>  { <sym> <O('%combining-or')> }

token infix:sym<*>  { <sym> <O('%multiplicative')> }
token infix:sym</>  { <sym> <O('%multiplicative')> }
token infix:sym<%>  { <sym> <O('%multiplicative')> }

token infix:sym<+>  { <sym> <O('%additive')> }
token infix:sym<->  { <sym> <O('%additive')> }
token infix:sym<~>  { <sym> <O('%additive')> }

token infix:sym«<»  { <sym> <O('%comparative, :pasttype<chain>')> }
token infix:sym«>»  { <sym> <O('%comparative, :pasttype<chain>')> }
token infix:sym«<>» { <sym> <O('%comparative, :pasttype<chain>')> }
token infix:sym«<=» { <sym> <O('%comparative, :pasttype<chain>')> }
token infix:sym«>=» { <sym> <O('%comparative, :pasttype<chain>')> }
token infix:sym«==» { <sym> <O('%comparative, :pasttype<chain>')> }
token infix:sym«!=» { <sym> <O('%comparative, :pasttype<chain>')> }

token infix:sym«=~» { <sym> <O('%comparative')> }

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

token begin_function {
    <?>
}

token infix:sym«=>» {
    <sym> <O('%pair')>
}

token infix:sym<:=> { <sym> <O('%assign, :pasttype<bind>')> }
token infix:sym<=>  { <sym> <O('%assign, :pasttype<copy>')> }

token infix:sym<=|> { <sym> <O('%assign-map')> }

token infix:sym<;>  { <sym> <O('%sequencing')> }

## Terms

# don't match foo:bar (namespace-lookup), but match foo :bar
token function_call {
    <invocant=factor> [
    [ <?before <[\s]>+ ':'> || <!before ':'> ]
      <.ws> <argument=factor> ]*
}

rule term:sym<function_call> {
    <function_call>
}

## Factors

proto token factor { <...> }

token factor:sym<( )> {
    '(' <.ws> <expression> [ ')' || <.panic: "Expected ')'"> ]
}

token factor:sym<{ }> {
    '{'
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
    '«' $<identifier>=<-[»]>* [ '»' || <.panic: "Expected '»'"> ]
}

token variable {
    <identifier>
}

token parameter {
    <variable> [ $<optional>='?' ]?
}

rule factor:sym<parameters> {
    <parameter> ** ',' <?before '->'>
}

token factor:sym<variable> {
    <variable> <!before <.ws> '->'>
               <!before <.ws> '.'>
}

token factor:sym<symbol> {
    ':' <identifier>
}

# class definition
rule factor:sym<[ ]> {
    '['
        <class_body>
    [ ']' || <.panic: "Expected ']'"> ]
}

rule class_body {
    <member_def> ** ';'
}

rule member_def {
    <identifier> [ '=' $<expression>=<factor> ]?
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
token quote:sym<' '> { <?[\']> <quote_EXPR: ':q'> }
token quote:sym<" "> { <?[\"]> <quote_EXPR: ':qq'> }

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
