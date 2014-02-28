=begin overview

This is the grammar for Epsilon in Perl 6 rules.

=end overview

grammar Epsilon::Grammar is HLL::Grammar;

token TOP {
    <expression>
    [ $ || <.panic: "Syntax error"> ]
}

## Lexer items

# This <ws> rule treats # as "comment to eol".
token ws {
    <!ww>
    [ '#' \N* \n? | \s+ ]*
}

## Expressions

rule expression {
    <EXPR> [ <postfix_expression> ]*
}

## Operators

INIT {
    Epsilon::Grammar.O(':prec<u>, :assoc<left>',  '%multiplicative');
    Epsilon::Grammar.O(':prec<t>, :assoc<left>',  '%additive');
    Epsilon::Grammar.O(':prec<f>, :assoc<list>',  '%list');
}

token circumfix:sym<( )> { '(' <.ws> <EXPR> ')' }

token infix:sym<*>  { <sym> <O('%multiplicative')> }
token infix:sym</>  { <sym> <O('%multiplicative')> }

token infix:sym<+>  { <sym> <O('%additive')> }
token infix:sym<->  { <sym> <O('%additive')> }

token infix:sym<,>  { <sym> <O('%list')> }

proto rule postfix_expression { <...> }

rule postfix_expression:sym<[ ]> { $<start>='[' <expression> $<end>=']' }

## Terms

token term:sym<integer> { <integer> }
token term:sym<quote> { <quote> }

proto token quote { <...> }
token quote:sym<'> { <?[']> <quote_EXPR: ':q'> }
token quote:sym<"> { <?["]> <quote_EXPR: ':qq'> }
