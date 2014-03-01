=begin overview

This is the grammar for Epsilon in Perl 6 rules.

=end overview

grammar Epsilon::Grammar is HLL::Grammar;

token TOP {
    <.begin_TOP>
    <expression>
    [ $ || <.panic: "Syntax error"> ]
}

token begin_TOP {
    <?>
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
    Epsilon::Grammar.O(':prec<z>, :assoc<unary>', '%unary-negative');
    Epsilon::Grammar.O(':prec<u>, :assoc<left>',  '%multiplicative');
    Epsilon::Grammar.O(':prec<t>, :assoc<left>',  '%additive');
    Epsilon::Grammar.O(':prec<f>, :assoc<list>',  '%list');
    Epsilon::Grammar.O(':prec<e>, :assoc<right>', '%cons');
    Epsilon::Grammar.O(':prec<b>, :assoc<right>', '%assign');
    Epsilon::Grammar.O(':prec<1>, :assoc<right>', '%sequencing');
}

token prefix:sym<+> { <sym> <O('%unary-negative')> }
token prefix:sym<-> { <sym> <O('%unary-negative')> }

token infix:sym<*>  { <sym> <O('%multiplicative')> }
token infix:sym</>  { <sym> <O('%multiplicative')> }

token infix:sym<+>  { <sym> <O('%additive')> }
token infix:sym<->  { <sym> <O('%additive')> }

token infix:sym<,>  { <sym> <O('%list')> }

token infix:sym<:>  { <sym> <O('%cons')> }

token infix:sym<=>  { <sym> <O('%assign, :pasttype<bind>')> }

token infix:sym<;>  { <sym> <O('%sequencing')> }

proto rule postfix_expression { <...> }

rule postfix_expression:sym<[ ]> { $<start>='[' <expression> $<end>=']' }

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

token term:sym<identifier> {
    $<identifier>=[ <ident> ** <[\'\-]> ]
}

token term:sym<integer> { <integer> }
token term:sym<quote> { <quote> }

proto token quote { <...> }
token quote:sym<'> { <?[']> <quote_EXPR: ':q'> }
token quote:sym<"> { <?["]> <quote_EXPR: ':qq'> }
