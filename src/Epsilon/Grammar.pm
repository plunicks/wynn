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

# This <ws> rule treats // as "comment to eol" and /* .. */ as a (potentially)
# multi-line comment.
token ws {
    <!ww>
    [ '/*' .*? '*/'
    | '//' \N* \n?
    | \s+ ]*
}

## Expressions

rule expression {
    <EXPR>
}

## Operators

INIT {
    Epsilon::Grammar.O(':prec<o>, :assoc<unary>', '%postcircumfix');
    Epsilon::Grammar.O(':prec<o>, :assoc<unary>', '%unary-applicative');
    Epsilon::Grammar.O(':prec<n>, :assoc<unary>', '%unary-negative');
    Epsilon::Grammar.O(':prec<m>, :assoc<left>',  '%applicative');
    Epsilon::Grammar.O(':prec<k>, :assoc<left>',  '%multiplicative');
    Epsilon::Grammar.O(':prec<j>, :assoc<left>',  '%additive');
    Epsilon::Grammar.O(':prec<h>, :assoc<left>',  '%comparative');
    Epsilon::Grammar.O(':prec<f>, :assoc<list>',  '%list');
    Epsilon::Grammar.O(':prec<e>, :assoc<right>', '%cons');
    Epsilon::Grammar.O(':prec<e>, :assoc<left>',  '%cons-left');
    Epsilon::Grammar.O(':prec<c>, :assoc<right>', '%applicative-low');
    Epsilon::Grammar.O(':prec<b>, :assoc<unary>', '%unary-function');
    Epsilon::Grammar.O(':prec<b>, :assoc<right>', '%function');
    Epsilon::Grammar.O(':prec<a>, :assoc<right>', '%assign');
    Epsilon::Grammar.O(':prec<1>, :assoc<right>', '%sequencing');
}

token postcircumfix:sym<[ ]> {
    '[' <expression> ']'
    <O('%postcircumfix')>
}

token postfix:sym<!> { <sym> <O('%unary-applicative')> }

# these are only optimizations - void makes them redundant
token prefix:sym<+> { <sym> <O('%unary-negative')> }
token prefix:sym<-> { <sym> <O('%unary-negative')> }

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

token circumfix:sym<( )> { '(' <.ws> <expression> ')' }

token circumfix:sym<{ }> {
    '{'
        <.begin_block>
        <.ws> <expression>
    '}'
}

token begin_block {
    <?>
}

## Terms

token identifier {
    | <quoted_identifier>
    | $<identifier>=[ <ident> ** <[\'\-]>* <[\']>* ]
}

token quoted_identifier {
    '«' $<identifier>=[\N*?] '»'
}

token term:sym<parameter> {
    <identifier> <?before <.ws> '->'>
}

token term:sym<variable> {
    <identifier> <!before <.ws> '->'>
}

token term:sym<void> { }

token term:sym<integer> { <integer> }
token term:sym<quote> { <quote> }

proto token quote { <...> }
token quote:sym<'> { <?[']> <quote_EXPR: ':q'> }
token quote:sym<"> { <?["]> <quote_EXPR: ':qq'> }
